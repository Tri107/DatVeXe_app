import 'dart:convert';
import 'package:http/http.dart' as http;
import '../config/api.dart';

class PaymentService {
  static Future<String?> createVNPay(int veId, double amount) async {
    try {
      final res = await http.post(
        Uri.parse('${Api.client.options.baseUrl}/payment/create'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'veId': veId, 'amount': amount}),
      );

      if (res.statusCode == 200) {
        final data = jsonDecode(res.body);
        return data['paymentUrl'];
      } else {
        print(' Lỗi tạo thanh toán VNPay: ${res.body}');
        return null;
      }
    } catch (e) {
      print(' Exception: $e');
      return null;
    }
  }
}
