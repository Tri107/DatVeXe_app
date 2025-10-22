// lib/screens/khachhang/trip_customer_info_screen.dart
import 'package:datvexe_app/models/KhachHang.dart';
import 'package:datvexe_app/screens/khachhang/payment_screen.dart';
import 'package:datvexe_app/services/Ve_Service.dart';
import 'package:flutter/material.dart';
import 'package:datvexe_app/services/khachhang_service.dart';
import 'package:email_validator/email_validator.dart';

class TripCustomerInfoScreen extends StatefulWidget {
  final int chuyenId;
  final double gia;
  final String? phone; // SĐT của người dùng đang đăng nhập

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

  KhachHang? _loadedCustomer;

  bool _isProcessing = false;
  bool _isLoadingData = true;
  bool _hasExistingCustomer = false;

  @override
  void initState() {
    super.initState();
    String? phoneToLoad = widget.phone;

    // Quan trọng: Phải có SĐT được truyền vào từ màn hình trước thì mới tự động load
    if (phoneToLoad != null && phoneToLoad.isNotEmpty) {
      phoneCtrl.text = phoneToLoad;
      _loadKhachHang(phoneToLoad);
    } else {
      // Nếu không có SĐT, không làm gì cả và hiển thị màn hình nhập mới
      setState(() {
        _isLoadingData = false;
      });
    }
  }

  Future<void> _loadKhachHang(String phone) async {
    final kh = await _khService.getKhachHangByPhone(phone);
    if (mounted) {
      setState(() {
        if (kh != null) {
          // Nếu tìm thấy khách hàng, đổ dữ liệu vào UI
          nameCtrl.text = kh.khachHangName;
          emailCtrl.text = kh.email;
          _hasExistingCustomer = true;
          _loadedCustomer = kh; // Lưu lại khách hàng để quyết định update
        } else {
          // Nếu không tìm thấy, UI sẽ là các ô trống để nhập mới
          _hasExistingCustomer = false;
          _loadedCustomer = null;
        }
        _isLoadingData = false; // Hoàn tất loading
      });
    }
  }

  Future<KhachHang> _processCustomerInfo() {
    // Dựa vào việc `_loadedCustomer` có tồn tại hay không để quyết định
    if (_loadedCustomer != null) {
      // NẾU CÓ: Gọi hàm UPDATE.
      print("--- Logic: Khách hàng đã tồn tại. Sẽ gọi hàm UPDATE. ---");
      return _khService.updateKhachHang(
        customerId: _loadedCustomer!.khachHangId,
        name: nameCtrl.text, // Lấy giá trị mới từ ô nhập liệu
        phone: phoneCtrl.text,
        email: emailCtrl.text,
      );
    } else {
      // NẾU KHÔNG CÓ: Gọi hàm CREATE.
      print("--- Logic: Khách hàng chưa tồn tại. Sẽ gọi hàm CREATE. ---");
      return _khService.createKhachHang(
        name: nameCtrl.text,
        phone: phoneCtrl.text,
        email: emailCtrl.text,
      );
    }
  }

  Future<void> _handleConfirmAndContinue() async {
    if (!_formKey.currentState!.validate() || _isProcessing) {
      return;
    }
    setState(() { _isProcessing = true; });

    try {
      final KhachHang customer = await _processCustomerInfo();
      final int veId = await VeService.createVe(
        chuyenId: widget.chuyenId,
        khachHangId: customer.khachHangId,
        giaVe: widget.gia,
      );

      if (mounted) {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (context) => PaymentScreen(veId: veId)),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Đã xảy ra lỗi: ${e.toString()}')),
        );
      }
    } finally {
      if (mounted) {
        setState(() { _isProcessing = false; });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
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
                _hasExistingCustomer
                    ? "Vui lòng xác nhận thông tin của bạn"
                    : "Vui lòng nhập thông tin hành khách",
                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: nameCtrl,
                decoration: const InputDecoration(
                  labelText: "Tên người đi *",
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.person_outline),
                ),
                validator: (value) => (value == null || value.isEmpty) ? 'Vui lòng nhập tên' : null,
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
                validator: (value) => (value == null || value.isEmpty) ? 'Vui lòng nhập số điện thoại' : null,
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
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
                onPressed: _isProcessing ? null : _handleConfirmAndContinue,
                child: _isProcessing
                    ? const CircularProgressIndicator(color: Colors.black54)
                    : Text(
                  _hasExistingCustomer ? "Xác nhận & Tiếp tục" : "Lưu & Tiếp tục",
                  style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
