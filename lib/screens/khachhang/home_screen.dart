import 'package:flutter/material.dart';
import '../../models/TaiKhoan.dart';
import '../khachhang/trip_info_screen.dart';
import '../khachhang/payment_screen.dart';
import '../../services/Auth_Services.dart';
import '../auth/login_screen.dart';

class HomeScreen extends StatelessWidget {
  final TaiKhoan user;
  const HomeScreen({super.key, required this.user});

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
            ElevatedButton(
              onPressed: () {
                Navigator.push(context, MaterialPageRoute(
                  builder: (_) => const TripInfoScreen(veId: 1),
                ));
              },
              child: const Text('Thông tin chuyến đi (test veId=1)'),
            ),
            const SizedBox(height: 12),
            ElevatedButton(
              onPressed: () {
                Navigator.push(context, MaterialPageRoute(
                  builder: (_) => const PaymentScreen(veId: 1),
                ));
              },
              child: const Text('Thanh toán (test veId=1)'),
            ),
          ],
        ),
      ),
    );
  }
}
