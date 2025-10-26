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

  Future<void> _loadDriverData() async {
    try {
      final data = await TaiXeService.getTaiXeByPhone(widget.user.sdt);
      setState(() {
        driver = data;
        isLoading = false;
      });
    } catch (e) {
      setState(() => isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Lỗi tải thông tin tài xế: $e')),
      );
    }
  }

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
      backgroundColor: const Color(0xFFF4F7FC),
      appBar: AppBar(
        backgroundColor: Colors.blueAccent,
        title: const Text('Trang chủ'),
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
          : SingleChildScrollView(
        child: Padding(
          padding:
          const EdgeInsets.symmetric(horizontal: 20.0, vertical: 28),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // Ảnh minh họa ở đầu
              SizedBox(
                height: 180,
                child: Image.asset(
                  'assets/images/bus.jpg',
                  fit: BoxFit.contain,
                ),
              ),

              const SizedBox(height: 24),

              // Thông tin tài xế
              if (driver != null)
                Card(
                  elevation: 4,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Row(
                      children: [
                        const Icon(Icons.account_circle,
                            color: Colors.blueAccent, size: 56),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                driver!['TaiXe_name'] ?? 'Không có tên',
                                style: const TextStyle(
                                    fontSize: 20,
                                    fontWeight: FontWeight.bold),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                'Bằng lái: ${driver!['TaiXe_BangLai'] ?? 'Chưa có'}\n'
                                    'SĐT: ${driver!['SDT'] ?? ''}',
                                style: const TextStyle(fontSize: 15),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                )
              else
                const Text(' Không tìm thấy thông tin tài xế.'),

              const SizedBox(height: 40),

              // Nút chính
              SizedBox(
                width: double.infinity,
                height: 65,
                child: ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blueAccent,
                    elevation: 5,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                  onPressed: () {
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
                  icon: const Icon(Icons.directions_bus,
                      size: 30, color: Colors.white),
                  label: const Text(
                    'Danh sách chuyến xe của bạn',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 40),

              // Gợi ý nhỏ ở cuối trang
              const Text(
                'Hãy kiểm tra danh sách chuyến xe của bạn\nvà đảm bảo mọi thứ sẵn sàng trước khi khởi hành 🚍',
                textAlign: TextAlign.center,
                style: TextStyle(
                    fontSize: 15,
                    color: Colors.black54,
                    fontStyle: FontStyle.italic),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
