import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../services/Auth_Services.dart';
import '../../config/api.dart';
import 'home_screen.dart';

class PaymentSuccessful extends StatefulWidget {
  final String? email; // ✅ Nhận email từ màn trước (PaymentScreen)

  const PaymentSuccessful({super.key, this.email});

  @override
  State<PaymentSuccessful> createState() => _PaymentSuccessfulState();
}

class _PaymentSuccessfulState extends State<PaymentSuccessful> {
  bool _isSending = false;
  String? _displayEmail; // ✅ Biến hiển thị email cuối cùng

  @override
  void initState() {
    super.initState();
    _loadEmailAndSend(); // ✅ Tự động gửi email và hiển thị
  }

  /// ✅ Lấy email (ưu tiên từ widget → SharedPreferences) và gửi vé
  Future<void> _loadEmailAndSend() async {
    final prefs = await SharedPreferences.getInstance();

    // 1️⃣ Ưu tiên email truyền từ màn trước
    String? email = widget.email;
    if (email != null && email.isNotEmpty) {
      await prefs.setString('last_email', email); // Lưu lại
    } else {
      // 2️⃣ Nếu widget không có → lấy từ SharedPreferences
      email = prefs.getString('last_email');
    }

    setState(() => _displayEmail = email ?? 'email của bạn');

    if (email == null || email.isEmpty) {
      print("⚠️ Không có email để gửi!");
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Không tìm thấy địa chỉ email để gửi vé!"),
            backgroundColor: Colors.orange,
          ),
        );
      }
      return;
    }

    // ✅ Gửi email
    await _sendEmailAfterPayment(email);
  }

  /// 🔹 Gửi email xác nhận vé sau khi thanh toán
  Future<void> _sendEmailAfterPayment(String email) async {
    try {
      print("📧 Gửi vé tới email: $email");
      setState(() => _isSending = true);

      final response = await Api.client.post(
        '/email/send-ticket-email',
        data: {'email': email},
      );

      print("📨 Server trả về: ${response.data}");

      if (response.statusCode == 200) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text("📩 Vé đã được gửi tới Gmail của bạn!"),
              backgroundColor: Colors.green,
            ),
          );
        }
      } else {
        throw Exception("Lỗi gửi email (status ${response.statusCode})");
      }
    } catch (e) {
      print("❌ Lỗi gửi email: $e");
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("Không thể gửi email: $e"),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isSending = false);
    }
  }

  /// 🔹 Quay lại Home
  Future<void> _goHome(BuildContext context) async {
    final user = await AuthService.getCurrentUser();
    if (!context.mounted) return;

    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (_) => HomeScreen(user: user!)),
          (_) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text('Thanh toán thành công'),
        backgroundColor: Colors.green,
        foregroundColor: Colors.white,
        centerTitle: true,
      ),
      body: Center(
        child: _isSending
            ? Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: const [
            CircularProgressIndicator(color: Colors.green),
            SizedBox(height: 16),
            Text(
              "Đang gửi vé đến email của bạn...",
              style: TextStyle(fontSize: 16),
            ),
          ],
        )
            : Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.check_circle,
                color: Colors.green, size: 100),
            const SizedBox(height: 20),
            const Text(
              "🎉 Thanh toán thành công!",
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: Colors.green,
              ),
            ),
            const SizedBox(height: 10),
            const Text(
              "Cảm ơn bạn đã sử dụng dịch vụ của chúng tôi.",
              style: TextStyle(fontSize: 16),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 20),

            // ✅ Hiển thị email người nhận
            Text(
              "📧 Vé đã được gửi về: ${_displayEmail ?? 'email của bạn'}",
              style: const TextStyle(
                fontSize: 15,
                color: Colors.black87,
                fontStyle: FontStyle.italic,
              ),
              textAlign: TextAlign.center,
            ),

            const SizedBox(height: 30),
            ElevatedButton.icon(
              onPressed: () => _goHome(context),
              icon: const Icon(Icons.home, color: Colors.white),
              label: const Text(
                "Về trang chủ",
                style: TextStyle(color: Colors.white, fontSize: 16),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green,
                padding: const EdgeInsets.symmetric(
                    horizontal: 30, vertical: 14),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
