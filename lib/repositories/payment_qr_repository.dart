import 'package:store_app/services/api_service.dart';

/// Repository tạo và kiểm tra trạng thái QR thanh toán (VietQR/Casso)
class PaymentQrRepository {
  PaymentQrRepository._();
  static final instance = PaymentQrRepository._();

  /// Tạo QR cho đơn hàng [orderId] với số tiền [amountVnd]
  /// Có thể truyền thông tin ngân hàng tùy chỉnh
  Future<Map<String, dynamic>> create({
    required String orderId,
    required int amountVnd,
    String? bankBin,
    String? accountNumber,
    String? accountName,
    String? token,
  }) async {
    final body = {
      'orderId': orderId,
      'amountVnd': amountVnd,
      if (bankBin != null) 'bankBin': bankBin,
      if (accountNumber != null) 'accountNumber': accountNumber,
      if (accountName != null) 'accountName': accountName,
    };
    return await ApiService.instance.postJson('/api/payments/qr/create', body, token: token);
  }

  /// Kiểm tra trạng thái thanh toán của 1 order (server đối soát qua webhook)
  Future<Map<String, dynamic>> status(String orderId, {String? token}) async {
    return await ApiService.instance.getJsonMap('/api/payments/qr/status', query: {'orderId': orderId}, token: token);
  }
}
