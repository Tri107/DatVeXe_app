import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:datvexe_app/models/TaiKhoan.dart';
import 'package:datvexe_app/screens/auth/login_screen.dart';
import 'package:datvexe_app/config/api.dart';
import 'package:datvexe_app/services/TaiXe_Service.dart';
import 'taixe_triplist_screen.dart';

class TaiXeHomeScreen extends StatefulWidget {
  final TaiKhoan user;

  const TaiXeHomeScreen({super.key, required this.user});

  @override
  State<TaiXeHomeScreen> createState() => _TaiXeHomeScreenState();
}

class _TaiXeHomeScreenState extends State<TaiXeHomeScreen> {
  Map<String, dynamic>? driver;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadDriverData();
  }

  /// 🔹 Lấy thông tin tài xế theo SĐT
  Future<void> _loadDriverData() async {
    try {
      print("📞 Gọi API lấy tài xế theo SDT: ${widget.user.sdt}");
      final data = await TaiXeService.getTaiXeByPhone(widget.user.sdt);
      print("✅ Dữ liệu tài xế: $data");
      setState(() {
        driver = data;
        isLoading = false;
      });
    } catch (e) {
      print("❌ Lỗi tải tài xế: $e");
      setState(() => isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Lỗi tải thông tin tài xế: $e')),
      );
    }
  }

  /// 🔹 Đăng xuất: xóa token và quay lại Login
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
        title: Text('Xin chào, ${widget.user.sdt} 👋'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            tooltip: 'Đăng xuất',
            onPressed: () => _logout(context),
          )
        ],
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Trang tài xế',
              style: TextStyle(
                  fontSize: 22, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            Text(
              'Chào mừng bạn quay lại, ${widget.user.sdt}',
              style: const TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 24),
            const Divider(),

            const SizedBox(height: 16),

            /// 🔹 Thông tin tài xế
            if (driver != null)
              Card(
                elevation: 2,
                child: ListTile(
                  leading: const Icon(Icons.account_circle,
                      color: Colors.blueAccent, size: 42),
                  title: Text(driver!['TaiXe_name'] ?? 'Không có tên'),
                  subtitle: Text(
                    'Bằng lái: ${driver!['TaiXe_BangLai'] ?? 'Chưa có'}\n'
                        'SĐT: ${driver!['SDT'] ?? ''}',
                  ),
                ),
              )
            else
              const Text('❌ Không tìm thấy thông tin tài xế.'),

            const SizedBox(height: 24),
            const Divider(),

            const SizedBox(height: 12),

            /// 📦 Danh sách chức năng
            Expanded(
              child: ListView(
                children: [
                  ListTile(
                    leading: const Icon(Icons.directions_bus,
                        color: Colors.blue),
                    title:
                    const Text('Danh sách chuyến xe của bạn'),
                    subtitle: const Text(
                        'Xem các chuyến sắp tới & đang chạy'),
                    onTap: () {
                      if (driver?['TaiXe_id'] != null) {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => TaiXeTripListScreen(
                              taiXeId: driver!['TaiXe_id'],
                            ),
                          ),
                        );
                      } else {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Không tìm thấy ID tài xế'),
                          ),
                        );
                      }
                    },
                  ),
                  ListTile(
                    leading: const Icon(Icons.assignment,
                        color: Colors.green),
                    title: const Text('Lịch sử chuyến đi'),
                    subtitle: const Text(
                        'Xem lại các chuyến đã hoàn thành'),
                    onTap: () {
                      // TODO: mở màn hình lịch sử chuyến đi
                    },
                  ),
                  ListTile(
                    leading: const Icon(Icons.person,
                        color: Colors.orange),
                    title: const Text('Thông tin cá nhân'),
                    subtitle: const Text(
                        'Xem và cập nhật hồ sơ tài xế'),
                    onTap: () {
                      // TODO: mở màn hình hồ sơ tài xế
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
