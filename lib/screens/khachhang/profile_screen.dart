import 'dart:io';
import 'package:flutter/material.dart';
import '../../models/KhachHang.dart';
import '../../services/KhachHang_Service.dart';
import '../../services/Auth_Services.dart';
import '../../themes/gradient.dart';
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

  Future<void> _loadUserInfo() async {
    try {
      setState(() => _isLoading = true);
      final currentUser = await AuthService.getCurrentUser();

      if (currentUser == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Không tìm thấy thông tin người dùng")),
        );
        return;
      }

      final phone = currentUser.sdt;
      setState(() => _phoneCtrl.text = phone);

      final khachHang = await KhachHangService.getKhachHangByPhone(phone);
      if (khachHang == null) {
        setState(() => _isLoading = false);
        return;
      }

      setState(() {
        _currentCustomer = khachHang;
        _nameCtrl.text = khachHang.khachHangName;
        _emailCtrl.text = khachHang.email;
        _isLoading = false;
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Lỗi tải thông tin: $e")),
      );
      setState(() => _isLoading = false);
    }
  }

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
              content: Text("Tạo mới thông tin khách hàng thành công"),
              backgroundColor: Colors.green),
        );
      } else {
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
              content: Text("Cập nhật thông tin thành công"),
              backgroundColor: Colors.green),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            content: Text("Lỗi khi lưu thông tin: $e"),
            backgroundColor: Colors.red),
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
      backgroundColor: Colors.grey[100],
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(60),
        child: Container(
          decoration: const BoxDecoration(gradient: AppGradients.primary),
          child: AppBar(
            backgroundColor: Colors.transparent,
            elevation: 0,
            centerTitle: true,
            leading: IconButton(
              icon: const Icon(Icons.arrow_back, color: Colors.white),
              onPressed: () => Navigator.pop(context),
            ),
            title: const Text(
              "Thông tin tài khoản",
              style: TextStyle(
                  fontWeight: FontWeight.bold, color: Colors.white),
            ),
          ),
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
        padding:
        const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.grey.withOpacity(0.15),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          padding:
          const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              GestureDetector(
                child: CircleAvatar(
                  radius: 55,
                  backgroundColor: Colors.blue.shade400,
                  backgroundImage: _avatarFile != null
                      ? FileImage(_avatarFile!)
                      : null,
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
              const SizedBox(height: 20),
              _buildTextField(
                label: "Họ và tên *",
                controller: _nameCtrl,
                keyboardType: TextInputType.name,
              ),
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 12, vertical: 14),
                    decoration: BoxDecoration(
                      border:
                      Border.all(color: Colors.grey.shade300),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Row(
                      children: [
                        Text("🇻🇳 ", style: TextStyle(fontSize: 18)),
                        SizedBox(width: 4),
                        Text("(+84)",
                            style: TextStyle(
                                fontWeight: FontWeight.bold)),
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
              const SizedBox(height: 25),
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue,
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
        readOnly: isPhoneField,
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
          fillColor: isPhoneField ? Colors.grey.shade100 : Colors.white,
          contentPadding:
          const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
        ),
      ),
    );
  }
}
