import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../../models/KhachHang.dart';
import '../../services/KhachHang_Service.dart';
import '../../services/Auth_Services.dart';
import '../auth/login_screen.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final TextEditingController _nameCtrl = TextEditingController();
  final TextEditingController _phoneCtrl = TextEditingController();
  final TextEditingController _emailCtrl = TextEditingController();
  File? _avatarFile;
  bool _isLoading = true;
  KhachHang? _currentCustomer;

  @override
  void initState() {
    super.initState();
    _loadUserInfo();
  }

  /// 🔹 Tải thông tin người dùng hiện tại dựa vào SĐT
  Future<void> _loadUserInfo() async {
    try {
      print('--- [ProfileScreen] Bắt đầu tải thông tin khách hàng ---');
      setState(() => _isLoading = true);

      final currentUser = await AuthService.getCurrentUser();
      if (currentUser == null) {
        print('[ProfileScreen] ⚠️ Không tìm thấy user hiện tại (null)');
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Không tìm thấy thông tin người dùng")),
        );
        return;
      }

      final phone = currentUser.sdt;
      print('[ProfileScreen] 🔍 Lấy thông tin theo SĐT: $phone');

      // ✅ Luôn hiển thị SĐT ngay cả khi chưa có trong bảng khachhang
      setState(() {
        _phoneCtrl.text = phone;
      });

      final khachHang = await KhachHangService.getKhachHangByPhone(phone);
      if (khachHang == null) {
        print('[ProfileScreen] ⚠️ Không tìm thấy khách hàng theo SĐT → Cho phép nhập mới');
        setState(() => _isLoading = false);
        return;
      }

      setState(() {
        _currentCustomer = khachHang;
        _nameCtrl.text = khachHang.khachHangName;
        _emailCtrl.text = khachHang.email;
        _isLoading = false;
      });

      print('[ProfileScreen] ✅ Dữ liệu khách hàng đã load xong');
    } catch (e) {
      print('[ProfileScreen] ❌ Lỗi khi tải thông tin: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Lỗi tải thông tin: $e")),
      );
      setState(() => _isLoading = false);
    }
  }

  /// 🔹 Chọn ảnh đại diện
  Future<void> _pickAvatar() async {
    final picker = ImagePicker();
    final picked =
    await picker.pickImage(source: ImageSource.gallery, imageQuality: 85);
    if (picked != null) {
      setState(() => _avatarFile = File(picked.path));
    }
  }

  /// 🔹 Tạo hoặc cập nhật thông tin khách hàng
  Future<void> _saveProfile() async {
    try {
      final name = _nameCtrl.text.trim();
      final phone = _phoneCtrl.text.trim();
      final email = _emailCtrl.text.trim();

      if (name.isEmpty || email.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Vui lòng nhập đầy đủ họ tên và email")),
        );
        return;
      }

      setState(() => _isLoading = true);

      final existingCustomer = await KhachHangService.getKhachHangByPhone(phone);

      if (existingCustomer == null) {
        // ✅ Nếu chưa có → tạo mới
        print("[ProfileScreen] 🟢 Chưa có khách hàng → tạo mới");
        final newCustomer = await KhachHangService.createKhachHang(
          name: name,
          phone: phone,
          email: email,
        );
        setState(() {
          _currentCustomer = newCustomer;
          _isLoading = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Tạo mới thông tin khách hàng thành công 🎉"),
            backgroundColor: Colors.green,
          ),
        );
      } else {
        // ✅ Nếu có → cập nhật
        print("[ProfileScreen] 🟡 Đã có khách hàng → cập nhật");
        final updated = await KhachHangService.updateKhachHang(
          customerId: existingCustomer.khachHangId,
          name: name,
          phone: phone,
          email: email,
        );
        setState(() {
          _currentCustomer = updated;
          _nameCtrl.text = updated.khachHangName;
          _emailCtrl.text = updated.email;
          _isLoading = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Cập nhật thông tin thành công 🎉"),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      print('[ProfileScreen] ❌ Lỗi khi lưu thông tin: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Lỗi khi lưu thông tin: $e"),
          backgroundColor: Colors.red,
        ),
      );
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final initials = _nameCtrl.text.isNotEmpty
        ? _nameCtrl.text
        .trim()
        .split(' ')
        .map((e) => e[0])
        .take(2)
        .join()
        .toUpperCase()
        : "U";

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: const Color(0xFF1565C0),
        elevation: 0,
        title: const Text(
          "Thông tin tài khoản",
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          TextButton(
            onPressed: () async {
              await AuthService.logout(); // ✅ Xóa session/token
              if (!context.mounted) return;

              // ✅ Điều hướng về Login và xóa stack (không quay lại được)
              Navigator.pushAndRemoveUntil(
                context,
                MaterialPageRoute(builder: (_) => const LoginScreen()),
                    (route) => false,
              );
            },
            child: const Text(
              "Đăng xuất",
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                decoration: TextDecoration.underline,
              ),
            ),
          ),
        ],

      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
        padding:
        const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const SizedBox(height: 10),
            GestureDetector(
              onTap: _pickAvatar,
              child: CircleAvatar(
                radius: 55,
                backgroundColor: Colors.pink.shade300,
                backgroundImage:
                _avatarFile != null ? FileImage(_avatarFile!) : null,
                child: _avatarFile == null
                    ? Text(
                  initials,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 36,
                    fontWeight: FontWeight.bold,
                  ),
                )
                    : null,
              ),
            ),
            const SizedBox(height: 10),
            const Text(
              "Nhấn để chọn ảnh đại diện",
              style: TextStyle(color: Colors.grey, fontSize: 13),
            ),
            const SizedBox(height: 20),

            _buildTextField(
                label: "Họ và tên *",
                controller: _nameCtrl,
                keyboardType: TextInputType.name),

            Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 12, vertical: 14),
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey.shade300),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Row(
                    children: [
                      Text("🇻🇳 ", style: TextStyle(fontSize: 18)),
                      SizedBox(width: 4),
                      Text("(+84)",
                          style: TextStyle(fontWeight: FontWeight.bold)),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: _buildTextField(
                    label: "Số điện thoại *",
                    controller: _phoneCtrl,
                    keyboardType: TextInputType.phone,
                  ),
                ),
              ],
            ),

            _buildTextField(
              label: "Email *",
              controller: _emailCtrl,
              keyboardType: TextInputType.emailAddress,
            ),

            const SizedBox(height: 30),
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF1565C0),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10)),
                ),
                onPressed: _saveProfile,
                child: const Text(
                  "Lưu",
                  style: TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTextField({
    required String label,
    required TextEditingController controller,
    TextInputType keyboardType = TextInputType.text,
  }) {
    final isPhoneField = label.contains("Số điện thoại");

    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8),
      child: TextField(
        controller: controller,
        keyboardType: keyboardType,
        readOnly: isPhoneField, // 🔒 Khóa ô SĐT
        style: TextStyle(
          color: isPhoneField ? Colors.grey.shade600 : Colors.black,
        ),
        decoration: InputDecoration(
          labelText: label,
          labelStyle: TextStyle(
            fontWeight: FontWeight.w500,
            color: isPhoneField ? Colors.grey : Colors.black87,
          ),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
          filled: isPhoneField,
          fillColor: isPhoneField ? Colors.grey.shade200 : Colors.white,
          contentPadding:
          const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
        ),
      ),
    );
  }
}
