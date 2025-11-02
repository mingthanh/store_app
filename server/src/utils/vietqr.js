import crc from 'crc';

function tlv(id, value) {
  const len = String(value.length).padStart(2, '0');
  return `${id}${len}${value}`;
}

function normalizeAscii(input = '', { upper = true, maxLen } = {}) {
  let s = input
    .normalize('NFD')
    .replace(/\p{Diacritic}/gu, '')
    .replace(/[^0-9A-Za-z \-_.]/g, ' ') // chỉ giữ ASCII an toàn
    .replace(/\s+/g, ' ')               // gộp khoảng trắng
    .trim();
  if (upper) s = s.toUpperCase();
  if (maxLen && s.length > maxLen) s = s.slice(0, maxLen);
  return s;
}

// Build EMVCo/Napas 247 payload cho VietQR (thẻ 26 = Merchant Account Info VietQR)
// Thứ tự khuyến nghị: 00,01,26,52,53,54,58,59,62,63
export function buildVietQR({ bankBin, accountNumber, accountName = '', amount, addInfo = '' }) {
  if (!bankBin || !accountNumber) throw new Error('bankBin and accountNumber required');
  if (!amount || amount <= 0) throw new Error('amount invalid');

  const nameSan = normalizeAscii(accountName, { maxLen: 25 });
  const infoSan = normalizeAscii(addInfo, { maxLen: 50 });

  // Tag 26: VietQR template (AID + BIN + Account + optional name)
  const merchantAccountInfo = tlv('26',
    tlv('00', 'A000000727') +       // AID VietQR/NAPAS
    tlv('01', String(bankBin)) +    // Bank BIN
    tlv('02', String(accountNumber)) + // Account number
    (nameSan ? tlv('03', nameSan) : '')
  );

  const payloadNoCRC =
    tlv('00', '01') +              // Payload format indicator
    tlv('01', '12') +              // 12 = Dynamic QR
    merchantAccountInfo +
    tlv('52', '0000') +            // Merchant category code (default)
    tlv('53', '704') +             // Currency code VND
    tlv('54', String(amount)) +    // Amount
    tlv('58', 'VN') +              // Country code
    (nameSan ? tlv('59', nameSan) : '') +
    (infoSan ? tlv('62', tlv('08', infoSan)) : '');

  const dataForCRC = payloadNoCRC + '63' + '04';
  const crcValue = crc.crc16ccitt(Buffer.from(dataForCRC, 'utf8')).toString(16).toUpperCase().padStart(4, '0');
  return payloadNoCRC + tlv('63', crcValue);
}

// Build a VietQR.io QuickLink image URL
export function toVietQRImageUrl({ bankId, accountNumber, template = 'compact2', amount, addInfo, accountName }) {
  const base = `https://img.vietqr.io/image/${encodeURIComponent(bankId)}-${encodeURIComponent(accountNumber)}-${encodeURIComponent(template)}.png`;
  const qs = new URLSearchParams();
  if (amount) qs.set('amount', String(amount));
  if (addInfo) qs.set('addInfo', addInfo);
  if (accountName) qs.set('accountName', accountName);
  const s = qs.toString();
  return s ? `${base}?${s}` : base;
}
