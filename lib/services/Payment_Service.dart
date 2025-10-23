
import 'dart:convert';
import 'package:http/http.dart' as http;
import '../config/api.dart';

class PaymentService {

  static Future<String?> createVNPay(int veId, double amount) async {
    try {
      final url = '${Api.client.options.baseUrl}/payment/vnpay/create';
      print(' Body: {"veId": $veId, "amount": $amount}');

      final res = await http.post(
        Uri.parse(url),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'veId': veId, 'amount': amount}),
      );

      print('📥 Status code: ${res.statusCode}');
      print('📥 Body: ${res.body}');

      if (res.statusCode == 200) {
        final data = jsonDecode(res.body);
        final paymentUrl = data['paymentUrl'];

        if (paymentUrl == null || paymentUrl.toString().isEmpty) {
          print('⚠️ Backend trả về nhưng không có trường paymentUrl.');
          return null;
        }

        print('✅ Nhận được VNPay URL: $paymentUrl');
        return paymentUrl;
      } else {
        print('❌ Lỗi tạo thanh toán VNPay: ${res.body}');
        return null;
      }
    } catch (e) {
      print('💥 Exception khi tạo VNPay: $e');
      return null;
    }
  }
}