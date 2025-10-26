import 'dart:math';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:confetti/confetti.dart';
import 'package:animate_do/animate_do.dart';
import 'package:lottie/lottie.dart';
import '../../services/Auth_Services.dart';
import '../../config/api.dart';
import '../../themes/gradient.dart';
import 'home_screen.dart';

class PaymentSuccessful extends StatefulWidget {
  final String? email;

  const PaymentSuccessful({super.key, this.email});

  @override
  State<PaymentSuccessful> createState() => _PaymentSuccessfulState();
}

class _PaymentSuccessfulState extends State<PaymentSuccessful> {
  bool _isSending = false;
  String? _displayEmail;

  late ConfettiController _confettiCenter;
  late ConfettiController _confettiLeft;
  late ConfettiController _confettiRight;

  @override
  void initState() {
    super.initState();
    _confettiCenter = ConfettiController(duration: const Duration(seconds: 5));
    _confettiLeft = ConfettiController(duration: const Duration(seconds: 5));
    _confettiRight = ConfettiController(duration: const Duration(seconds: 5));
    _loadEmailAndSend();

    Future.delayed(const Duration(milliseconds: 500), () {
      _confettiCenter.play();
      _confettiLeft.play();
      _confettiRight.play();
    });
  }

  @override
  void dispose() {
    _confettiCenter.dispose();
    _confettiLeft.dispose();
    _confettiRight.dispose();
    super.dispose();
  }

  Future<void> _loadEmailAndSend() async {
    final prefs = await SharedPreferences.getInstance();
    String? email = widget.email;

    if (email != null && email.isNotEmpty) {
      await prefs.setString('last_email', email);
    } else {
      email = prefs.getString('last_email');
    }

    setState(() => _displayEmail = email ?? 'email của bạn');

    if (email == null || email.isEmpty) {
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

    await _sendEmailAfterPayment(email);
  }

  Future<void> _sendEmailAfterPayment(String email) async {
    try {
      setState(() => _isSending = true);
      final response = await Api.client.post(
        '/email/send-ticket-email',
        data: {'email': email},
      );

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
      backgroundColor: Colors.grey[100],
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(60),
        child: Container(
          decoration: const BoxDecoration(gradient: AppGradients.primary),
          child: AppBar(
            backgroundColor: Colors.transparent,
            elevation: 0,
            centerTitle: true,
            title: const Text(
              'Thanh toán thành công',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ),
        ),
      ),
      body: Stack(
        children: [
          // Hiệu ứng ánh sáng nhẹ bằng Lottie
          Positioned.fill(
            child: IgnorePointer(
              child: Opacity(
                opacity: 0.4,
                child: Lottie.asset(
                  'assets/animations/Celebrations.json',
                  fit: BoxFit.cover,
                ),
              ),
            ),
          ),

          // Pháo hoa nổ từ dưới lên
          Align(
            alignment: Alignment.bottomCenter,
            child: ConfettiWidget(
              confettiController: _confettiCenter,
              blastDirection: -pi / 2,
              emissionFrequency: 0.05,
              numberOfParticles: 25,
              maxBlastForce: 25,
              minBlastForce: 10,
              gravity: 0.2,
            ),
          ),
          Align(
            alignment: Alignment.bottomLeft,
            child: ConfettiWidget(
              confettiController: _confettiLeft,
              blastDirection: -pi / 3,
              emissionFrequency: 0.05,
              numberOfParticles: 20,
              gravity: 0.25,
            ),
          ),
          Align(
            alignment: Alignment.bottomRight,
            child: ConfettiWidget(
              confettiController: _confettiRight,
              blastDirection: -2 * pi / 3,
              emissionFrequency: 0.05,
              numberOfParticles: 20,
              gravity: 0.25,
            ),
          ),

          // Nội dung chính
          Center(
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
                      BounceInDown(
                        duration: const Duration(milliseconds: 800),
                        child: const Icon(
                          Icons.check_circle,
                          color: Colors.green,
                          size: 120,
                        ),
                      ),
                      const SizedBox(height: 20),

                      FadeInUp(
                        duration: const Duration(milliseconds: 1000),
                        child: const Text(
                          "Thanh toán thành công!",
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: Colors.green,
                          ),
                        ),
                      ),
                      const SizedBox(height: 10),

                      FadeInUp(
                        duration: const Duration(milliseconds: 1200),
                        child: const Text(
                          "Cảm ơn bạn đã sử dụng dịch vụ của chúng tôi.",
                          style: TextStyle(fontSize: 16, color: Colors.black87),
                          textAlign: TextAlign.center,
                        ),
                      ),
                      const SizedBox(height: 20),

                      FadeInUp(
                        duration: const Duration(milliseconds: 1300),
                        child: Text(
                          "Vé đã được gửi về: ${_displayEmail ?? 'email của bạn'}",
                          style: const TextStyle(
                            fontSize: 16,
                            color: Colors.black87,
                            fontStyle: FontStyle.italic,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                      const SizedBox(height: 40),

                      ZoomIn(
                        duration: const Duration(milliseconds: 1000),
                        child: ElevatedButton.icon(
                          onPressed: () => _goHome(context),
                          icon: const Icon(Icons.home, color: Colors.white),
                          label: const Text(
                            "Về trang chủ",
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.blue,
                            padding: const EdgeInsets.symmetric(
                              horizontal: 40,
                              vertical: 16,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            elevation: 8,
                            shadowColor: Colors.black45,
                          ),
                        ),
                      ),
                    ],
                  ),
          ),
        ],
      ),
    );
  }
}
