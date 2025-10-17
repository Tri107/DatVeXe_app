import 'package:flutter/material.dart';
import '../../models/TaiKhoan.dart';
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
        child: Text('Đã đăng nhập: ${user.sdt} (${user.role})'),
      ),
    );
  }
}
