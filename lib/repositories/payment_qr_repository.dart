import 'package:store_app/services/api_service.dart';

class PaymentQrRepository {
  PaymentQrRepository._();
  static final instance = PaymentQrRepository._();

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

  Future<Map<String, dynamic>> status(String orderId, {String? token}) async {
    return await ApiService.instance.getJsonMap('/api/payments/qr/status', query: {'orderId': orderId}, token: token);
  }
}
