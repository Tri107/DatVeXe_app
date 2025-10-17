import 'package:flutter/material.dart';
import '../../models/TaiKhoan.dart';
import '../../services/Auth_Services.dart';
import '../auth/login_screen.dart';
import '../khachhang/payment_screen.dart';
import '../khachhang/trip_info_screen.dart';

class HomeScreen extends StatelessWidget {
  final TaiKhoan user;
  const HomeScreen({super.key, required this.user});

  // tạm test với veId=1 (bạn đã insert trong DB)
  static const int demoVeId = 1;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Trang chính'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () async {
              await AuthService.logout();
              if (!context.mounted) return;
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (_) => const LoginScreen()),
              );
            },
          ),
        ],
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text('Đã đăng nhập: ${user.sdt} (${user.role})'),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              icon: const Icon(Icons.info_outline),
              label: const Text('Trip Info (API)'),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const TripInfoScreen(veId: demoVeId),
                  ),
                );
              },
            ),
            const SizedBox(height: 12),
            ElevatedButton.icon(
              icon: const Icon(Icons.payment),
              label: const Text('Payment (API)'),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const PaymentScreen(veId: demoVeId),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
