import 'package:flutter/material.dart';
import '../../services/Auth_Services.dart';
import 'login_screen.dart';

class OtpScreen extends StatefulWidget {
  final String sdt;
  final String password;

  const OtpScreen({super.key, required this.sdt, required this.password});

  @override
  State<OtpScreen> createState() => _OtpScreenState();
}

class _OtpScreenState extends State<OtpScreen> {
  final _otpController = TextEditingController();
  bool _loading = false;
  String? _error;
  String? _message;

  Future<void> _verifyOtp() async {
    final otp = _otpController.text.trim();
    if (otp.isEmpty) {
      setState(() => _error = 'Vui lòng nhập mã OTP');
      return;
    }

    setState(() {
      _loading = true;
      _error = null;
    });

    final success =
    await AuthService.verifyOtp(widget.sdt, widget.password, otp);

    setState(() => _loading = false);

    if (success && mounted) {
      setState(() => _message = '🎉 Đăng ký thành công!');

      await Future.delayed(const Duration(seconds: 2));
      if (mounted) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const LoginScreen()),
        );
      }
    } else {
      setState(() => _error = 'Mã OTP không hợp lệ hoặc đã hết hạn');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Xác nhận OTP')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              'Nhập mã OTP được gửi tới số điện thoại ${widget.sdt}',
              style: const TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 20),
            TextField(
              controller: _otpController,
              decoration: const InputDecoration(labelText: 'Mã OTP'),
              keyboardType: TextInputType.number,
            ),
            const SizedBox(height: 20),
            if (_error != null)
              Text(_error!, style: const TextStyle(color: Colors.red)),
            if (_message != null)
              Text(_message!, style: const TextStyle(color: Colors.green)),
            const SizedBox(height: 10),
            ElevatedButton(
              onPressed: _loading ? null : _verifyOtp,
              child: _loading
                  ? const CircularProgressIndicator(color: Colors.white)
                  : const Text('Xác nhận OTP'),
            ),
          ],
        ),
      ),
    );
  }
}
