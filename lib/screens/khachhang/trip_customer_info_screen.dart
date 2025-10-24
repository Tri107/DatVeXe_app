// lib/screens/khachhang/trip_customer_info_screen.dart
import 'package:datvexe_app/models/KhachHang.dart';
import 'package:datvexe_app/screens/khachhang/payment_screen.dart';
import 'package:datvexe_app/services/Ve_Service.dart';
import 'package:flutter/material.dart';
import 'package:datvexe_app/services/KhachHang_Service.dart';
import 'package:email_validator/email_validator.dart';

class TripCustomerInfoScreen extends StatefulWidget {
  final int chuyenId;
  final double gia;
  final String? phone;

  const TripCustomerInfoScreen({
    super.key,
    required this.chuyenId,
    required this.gia,
    this.phone,
  });

  @override
  State<TripCustomerInfoScreen> createState() => _TripCustomerInfoScreenState();
}

class _TripCustomerInfoScreenState extends State<TripCustomerInfoScreen> {
  final _formKey = GlobalKey<FormState>();
  final _khService = KhachHangService();

  final nameCtrl = TextEditingController();
  final phoneCtrl = TextEditingController();
  final emailCtrl = TextEditingController();

  int? _existingCustomerId;
  bool _isProcessing = false;
  bool _isLoadingData = true;

  @override
  void initState() {
    super.initState();
    String? phoneToLoad = widget.phone;

    if (phoneToLoad != null && phoneToLoad.isNotEmpty) {
      phoneCtrl.text = phoneToLoad;
      _loadInitialKhachHang(phoneToLoad);
    } else {
      setState(() {
        _isLoadingData = false;
      });
    }
  }

  Future<void> _loadInitialKhachHang(String phone) async {
    print("--- [UI] Đang tải thông tin khách hàng ban đầu với SĐT: $phone ---");
    final kh = await KhachHangService.getKhachHangByPhone(phone);
    if (mounted) {
      setState(() {
        if (kh != null) {
          print("--- [UI] Tìm thấy khách hàng ID: ${kh.khachHangId}. Đổ dữ liệu vào UI. ---");
          nameCtrl.text = kh.khachHangName;
          emailCtrl.text = kh.email;
          _existingCustomerId = kh.khachHangId;
        } else {
          print("--- [UI] Không tìm thấy khách hàng. Hiển thị form để tạo mới. ---");
          _existingCustomerId = null;
        }
        _isLoadingData = false;
      });
    }
  }

  Future<KhachHang> _processCustomerInfo() {
    if (_existingCustomerId != null) {
      print("--- [UI Logic] UPDATE Khách hàng ID: $_existingCustomerId ---");
      return KhachHangService.updateKhachHang(
        customerId: _existingCustomerId!,
        name: nameCtrl.text,
        phone: phoneCtrl.text,
        email: emailCtrl.text,
      );
    } else {
      print("--- [UI Logic] CREATE Khách hàng mới ---");
      return KhachHangService.createKhachHang(
        name: nameCtrl.text,
        phone: phoneCtrl.text,
        email: emailCtrl.text,
      );
    }
  }

  Future<void> _handleConfirmAndContinue() async {
    if (!_formKey.currentState!.validate() || _isProcessing) return;
    setState(() {
      _isProcessing = true;
    });

    print("\n--- [UI] Bắt đầu quá trình xác nhận và tiếp tục ---");

    try {
      final KhachHang customer = await _processCustomerInfo();
      print("--- [UI] Nhận được Khách hàng ID: ${customer.khachHangId} ---");

      final int veId = await VeService.createVe(
        chuyenId: widget.chuyenId,
        khachHangId: customer.khachHangId,
        giaVe: widget.gia,
      );
      print("--- [UI] Đã tạo Vé ID: $veId ---");

      // ✅ Lưu email vào SharedPreferences để PaymentSuccessful có thể dùng
      //    hoặc truyền trực tiếp sang PaymentScreen (cách tốt hơn)
      final String email = emailCtrl.text.trim();

      // ✅ ĐÃ SỬA: Truyền email sang PaymentScreen
      if (mounted) {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(
            builder: (context) => PaymentScreen(
              veId: veId,
              email: email, // ✅ TRUYỀN EMAIL
            ),
          ),
        );
      }
    } catch (e) {
      print("--- [UI] LỖI: ${e.toString()} ---");
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Đã xảy ra lỗi: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isProcessing = false;
        });
      }
      print("--- [UI] Kết thúc quá trình xác nhận và tiếp tục ---\n");
    }
  }

  @override
  Widget build(BuildContext context) {
    final bool hasExistingCustomer = _existingCustomerId != null;

    return Scaffold(
      appBar: AppBar(
        title: const Text("Thông tin hành khách"),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 1,
      ),
      body: _isLoadingData
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                hasExistingCustomer
                    ? "Vui lòng xác nhận thông tin của bạn"
                    : "Vui lòng nhập thông tin hành khách",
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                ),
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: nameCtrl,
                decoration: const InputDecoration(
                  labelText: "Tên người đi *",
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.person_outline),
                ),
                validator: (value) =>
                (value == null || value.isEmpty) ? 'Vui lòng nhập tên' : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: phoneCtrl,
                decoration: const InputDecoration(
                  labelText: "Số điện thoại *",
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.phone_outlined),
                ),
                keyboardType: TextInputType.phone,
                validator: (value) =>
                (value == null || value.isEmpty) ? 'Vui lòng nhập số điện thoại' : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: emailCtrl,
                decoration: const InputDecoration(
                  labelText: "Email để nhận thông tin vé *",
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.email_outlined),
                ),
                keyboardType: TextInputType.emailAddress,
                validator: (value) {
                  if (value == null || value.isEmpty) return 'Vui lòng nhập email';
                  if (!EmailValidator.validate(value)) return 'Email không hợp lệ';
                  return null;
                },
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.amber,
                  foregroundColor: Colors.black87,
                  minimumSize: const Size(double.infinity, 50),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                onPressed: _isProcessing ? null : _handleConfirmAndContinue,
                child: _isProcessing
                    ? const CircularProgressIndicator(color: Colors.black54)
                    : Text(
                  hasExistingCustomer ? "Xác nhận & Tiếp tục" : "Lưu & Tiếp tục",
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
