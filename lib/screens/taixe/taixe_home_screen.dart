import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:datvexe_app/models/TaiKhoan.dart';
import 'package:datvexe_app/screens/auth/login_screen.dart';
import 'package:datvexe_app/config/api.dart';

class TaiXeHomeScreen extends StatelessWidget {
  final TaiKhoan user;

  const TaiXeHomeScreen({super.key, required this.user});

  /// Hàm đăng xuất: xóa token, quay lại LoginScreen
  Future<void> _logout(BuildContext context) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('token');
    Api.token = null;
    Api.client.options.headers.remove('Authorization');

    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (_) => const LoginScreen()),
          (route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      appBar: AppBar(
        backgroundColor: Colors.blueAccent,
        title: Text('Xin chào, ${user.sdt} 👋'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () => _logout(context),
            tooltip: 'Đăng xuất',
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Trang tài xế',
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              'Chào mừng bạn quay lại, ${user.sdt}',
              style: const TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 24),
            const Divider(),
            const SizedBox(height: 24),

            // 📦 Gợi ý các khu vực mở rộng sau này
            Expanded(
              child: ListView(
                children: [
                  ListTile(
                    leading: const Icon(Icons.directions_bus, color: Colors.blue),
                    title: const Text('Danh sách chuyến xe của bạn'),
                    subtitle: const Text('Xem các chuyến xe sắp tới và đang chạy'),
                    onTap: () {
                      // TODO: chuyển sang màn hình danh sách chuyến xe
                    },
                  ),
                  ListTile(
                    leading: const Icon(Icons.assignment, color: Colors.green),
                    title: const Text('Lịch sử chuyến đi'),
                    subtitle: const Text('Xem lại các chuyến đã hoàn thành'),
                    onTap: () {
                      // TODO: chuyển sang màn hình lịch sử
                    },
                  ),
                  ListTile(
                    leading: const Icon(Icons.account_circle, color: Colors.orange),
                    title: const Text('Thông tin cá nhân'),
                    subtitle: const Text('Xem và cập nhật hồ sơ tài xế'),
                    onTap: () {
                      // TODO: chuyển sang màn hình hồ sơ tài xế
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
