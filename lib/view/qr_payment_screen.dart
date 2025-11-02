import 'dart:async';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:store_app/repositories/payment_qr_repository.dart';

class QrPaymentScreen extends StatefulWidget {
  final String orderId;
  final int amountVnd;
  const QrPaymentScreen({super.key, required this.orderId, required this.amountVnd});

  @override
  State<QrPaymentScreen> createState() => _QrPaymentScreenState();
}

class _QrPaymentScreenState extends State<QrPaymentScreen> {
  String? _qrBase64;
  DateTime? _expireAt;
  Timer? _timer;
  Duration _remain = Duration.zero;

  @override
  void initState() {
    super.initState();
    _init();
  }

  Future<void> _init() async {
    try {
      final res = await PaymentQrRepository.instance.create(
        orderId: widget.orderId,
        amountVnd: widget.amountVnd,
      );
      setState(() {
        _qrBase64 = res['qrBase64'] as String?;
        final expireMs = res['expireAt'] as int?;
        if (expireMs != null) {
          _expireAt = DateTime.fromMillisecondsSinceEpoch(expireMs);
          _updateRemain();
          _timer = Timer.periodic(const Duration(seconds: 2), (_) => _poll());
        }
      });
    } catch (e) {
      Get.snackbar('Lỗi', 'Không tạo được QR: $e');
      Get.back(result: false);
    }
  }

  void _updateRemain() {
    if (_expireAt == null) return;
    final diff = _expireAt!.difference(DateTime.now());
    _remain = diff.isNegative ? Duration.zero : diff;
  }

  Future<void> _poll() async {
    try {
      _updateRemain();
      if (_remain == Duration.zero) {
        _timer?.cancel();
        Get.snackbar('Hết hạn', 'QR đã hết hạn, vui lòng tạo lại');
        Get.back(result: false);
        return;
      }
      final st = await PaymentQrRepository.instance.status(widget.orderId);
      if (st['status'] == 'paid') {
        _timer?.cancel();
        
        // Show success dialog
        if (mounted) {
          await showDialog(
            context: context,
            barrierDismissible: false,
            builder: (ctx) => AlertDialog(
              title: Row(
                children: [
                  const Icon(Icons.check_circle, color: Colors.green, size: 32),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Thanh toán thành công',
                      style: Theme.of(ctx).textTheme.titleLarge,
                    ),
                  ),
                ],
              ),
              content: const Text('Chuyển khoản đã được xác nhận!\nĐang tạo đơn hàng...'),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(ctx).pop(),
                  child: const Text('OK'),
                ),
              ],
            ),
          );
        }
        
        // Navigate back with success result
        if (mounted) {
          Navigator.of(context).pop(true);
        }
      }
    } catch (e) {
      // Silently ignore polling errors to avoid spam
    }
  }

  Widget _buildQrImage(String qrBase64) {
    try {
      final uri = Uri.parse(qrBase64);
      if (uri.data != null) {
        return Image.memory(uri.data!.contentAsBytes());
      }
      return const Text('Lỗi: Không thể parse QR code');
    } catch (e) {
      return Text('Lỗi hiển thị QR: $e');
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Chuyển khoản qua VietQR')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: _qrBase64 == null
            ? const Center(child: CircularProgressIndicator())
            : Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Text('Số tiền: ${widget.amountVnd} VND', style: Theme.of(context).textTheme.titleMedium),
                  const SizedBox(height: 12),
                  if (_expireAt != null) Text('Hết hạn sau: ${_remain.inMinutes.remainder(60).toString().padLeft(2,'0')}:${(_remain.inSeconds.remainder(60)).toString().padLeft(2,'0')}'),
                  const SizedBox(height: 12),
                  if (_qrBase64 != null)
                    Expanded(
                      child: Center(
                        child: _buildQrImage(_qrBase64!),
                      ),
                    ),
                  const SizedBox(height: 8),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 8),
                    child: Text(
                      'Nội dung chuyển khoản: ORDER-${widget.orderId}',
                      textAlign: TextAlign.center,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                  ),
                ],
              ),
      ),
    );
  }
}
