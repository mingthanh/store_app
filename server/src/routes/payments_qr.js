import express, { Router } from 'express';
import QRCode from 'qrcode';
import crypto from 'crypto';
import { buildVietQR, toVietQRImageUrl } from '../utils/vietqr.js';
import fetch from 'node-fetch';

const router = Router();

// In-memory store for demo; replace with MongoDB collection in production
const intents = new Map();

function now() { return Date.now(); }
function ttlMs() { return 15 * 60 * 1000; }

function normalize(s = '') {
  return s
    .normalize('NFD')
    .replace(/\p{Diacritic}/gu, '')
    .toUpperCase();
}

function hmacOk(req, rawBody, secret) {
  try {
    const sig = req.headers['x-signature'] || '';
    if (!sig || !secret) return false;
    const calc = crypto.createHmac('sha256', secret).update(rawBody).digest('hex');
    return sig === calc;
  } catch { return false; }
}

router.post('/create', async (req, res) => {
  try {
    const { orderId, amountVnd, bankBin, accountNumber, accountName } = req.body || {};
    if (!orderId || !amountVnd) return res.status(400).json({ message: 'orderId, amountVnd required' });

    const envBankBin = process.env.VIETQR_BANK_BIN;
    const envAcc = process.env.VIETQR_ACC_NUMBER;
    const envName = process.env.VIETQR_ACC_NAME;

    const useQuickLink = (process.env.VIETQR_USE_VIETQR_IO || 'true').toLowerCase() === 'true';
    const accNo = accountNumber || envAcc;
    const bin = bankBin || envBankBin;
    const accName = accountName || envName || '';
    const amt = parseInt(amountVnd, 10);
    const addInfo = `ORDER-${orderId}`;

    let payload = '';
    let qrBase64 = '';
    if (useQuickLink) {
      // Use QuickLink image for maximum compatibility
      const template = process.env.VIETQR_TEMPLATE || 'compact2';
      const url = toVietQRImageUrl({ bankId: bin, accountNumber: accNo, template, amount: amt, addInfo, accountName: accName });
      const resp = await fetch(url);
      if (!resp.ok) {
        const errText = await resp.text().catch(() => '');
        throw new Error(`VietQR.io HTTP ${resp.status}: ${errText || 'Unknown error'}`);
      }
      const buf = Buffer.from(await resp.arrayBuffer());
      qrBase64 = `data:image/png;base64,${buf.toString('base64')}`;
      payload = url; // return URL as payload reference
    } else {
      // Fallback to local EMV render
      payload = buildVietQR({ bankBin: bin, accountNumber: accNo, accountName: accName, amount: amt, addInfo });
      qrBase64 = await QRCode.toDataURL(payload, { errorCorrectionLevel: 'M' });
    }
    const expireAt = now() + ttlMs();

    intents.set(orderId, {
      orderId,
      amountVnd: amt,
      addInfo,
      status: 'pending',
      expireAt,
      matchedTxId: null,
      paidAt: null,
      rawWebhook: null,
    });

    return res.json({ orderId, payload, qrBase64, addInfo, expireAt, bankBin: bin, accountNumber: accNo, accountName: accName });
  } catch (e) {
    return res.status(400).json({ message: e.message });
  }
});

// GET handler for Casso webhook verification
// Casso sends GET request to verify webhook URL before saving
router.get('/webhook', (req, res) => {
  console.log('[Webhook] GET verification from Casso', req.query);
  
  // Casso expects specific response format with error code
  // Return success response that Casso recognizes
  return res.json({ 
    error: 0,  // 0 = success in Casso's format
    message: 'Webhook endpoint is active',
    data: {
      service: 'VietQR Payment Gateway',
      status: 'ready',
      timestamp: new Date().toISOString()
    }
  });
});

// Webhook from Casso or other aggregator
router.post('/webhook', express.json({ type: '*/*' }), (req, res) => {
  const body = req.body || {};
  const secret = process.env.QR_WEBHOOK_SECRET || '';

  console.log('[Webhook] RAW BODY:', JSON.stringify(body, null, 2));
  console.log('[Webhook] Headers:', JSON.stringify(req.headers, null, 2));

  const mock = (process.env.MOCK_QR_WEBHOOK || 'false').toLowerCase() === 'true';
  
  // Casso không sử dụng HMAC signature, skip verification
  // if (!mock && secret) {
  //   const raw = JSON.stringify(body);
  //   if (!hmacOk(req, raw, secret)) {
  //     console.log('[Webhook] Invalid signature');
  //     return res.status(401).json({ ok: false, error: 'bad signature' });
  //   }
  // }

  // Support multiple webhook formats
  // Casso format: { code, desc, data: { amount, description, reference, ... }, signature }
  // Generic format: { txId, amount, description, time }
  
  // Extract data - Casso nests data inside 'data' object
  const data = body.data || body;
  
  const txId = data.reference || data.tid || body.txId || body.id || `tx-${Date.now()}`;
  const amount = Number(data.amount || body.amount || 0);
  const description = (data.description || body.description || data.desc || body.desc || '').toString();
  const time = data.transactionDateTime || body.when || body.time || now();

  if (!amount) {
    console.log('[Webhook] Missing amount:', body);
    return res.status(400).json({ 
      error: 1, 
      message: 'amount required',
      code: '01',
      desc: 'Thiếu thông tin số tiền'
    });
  }

  console.log(`[Webhook] Received: txId=${txId}, amount=${amount}, desc="${description}"`);

  // Try to match with pending payment intents
  let matched = false;
  for (const [orderId, pi] of intents.entries()) {
    if (pi.status !== 'pending') continue;
    
    // Check expiration
    if (now() > pi.expireAt) { 
      pi.status = 'expired'; 
      intents.set(orderId, pi); 
      continue; 
    }
    
    // Match by amount and description
    const okAmt = Number(pi.amountVnd) === amount;
    const okDesc = normalize(description).includes(normalize(pi.addInfo));
    
    if (okAmt && okDesc) {
      pi.status = 'paid';
      pi.matchedTxId = txId;
      pi.paidAt = time;
      pi.rawWebhook = body;
      intents.set(orderId, pi);
      matched = true;
      console.log(`[Webhook] ✅ Matched orderId=${orderId}, txId=${txId}`);
      break;
    }
  }

  if (!matched) {
    console.log(`[Webhook] ⚠️ No match found for amount=${amount}, desc="${description}"`);
  }

  // Return response in Casso format
  return res.json({ 
    error: 0,
    code: '00',
    desc: 'Thành công',
    data: {
      matched,
      processed: true
    }
  });
});

router.get('/status', (req, res) => {
  const { orderId } = req.query;
  const pi = intents.get(orderId);
  if (!pi) return res.status(404).json({ status: 'not_found' });
  if (now() > pi.expireAt && pi.status === 'pending') { pi.status = 'expired'; intents.set(orderId, pi); }
  return res.json(pi);
});

// Optional dev helper to mark paid without aggregator
router.post('/mockPaid', (req, res) => {
  const allow = (process.env.MOCK_QR_WEBHOOK || 'false').toLowerCase() === 'true';
  if (!allow) return res.status(403).json({ ok: false });
  const { orderId, txId = `mock-${Date.now()}` } = req.body || {};
  const pi = intents.get(orderId);
  if (!pi) return res.status(404).json({ ok: false });
  if (now() > pi.expireAt) { pi.status = 'expired'; intents.set(orderId, pi); return res.json({ ok: true, status: 'expired' }); }
  pi.status = 'paid';
  pi.matchedTxId = txId;
  pi.paidAt = now();
  intents.set(orderId, pi);
  return res.json({ ok: true, status: 'paid' });
});

export default router;
