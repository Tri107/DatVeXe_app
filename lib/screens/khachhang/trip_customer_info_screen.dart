import 'package:datvexe_app/models/KhachHang.dart';
import 'package:datvexe_app/screens/khachhang/payment_screen.dart';
import 'package:datvexe_app/services/Ve_Service.dart';
import 'package:flutter/material.dart';
import 'package:datvexe_app/services/khachhang_service.dart';
import 'package:email_validator/email_validator.dart';

class TripCustomerInfoScreen extends StatefulWidget {
  final int chuyenId;
  final double gia;
  final String? phone; // SĐT người dùng đã đăng nhập

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
    if (widget.phone != null && widget.phone!.isNotEmpty) {
      print('--- [TripCustomerInfo] Nhận SĐT từ login: ${widget.phone} ---');
      phoneCtrl.text = widget.phone!;
      _loadKhachHang(widget.phone!);
    } else {
      print('[TripCustomerInfo] ⚠️ Không nhận được SĐT từ widget.phone');
      _isLoadingData = false;
    }
  }

  /// 🔍 Lấy thông tin khách hàng theo SDT
  Future<void> _loadKhachHang(String phone) async {
    print('--- [TripCustomerInfo] Gọi API lấy khách hàng theo SĐT: $phone ---');

    try {
      final kh = await _khService.getKhachHangByPhone(phone);

      if (!mounted) return;

      setState(() {
        if (kh != null) {
          // Có dữ liệu khách hàng → đổ lên form
          nameCtrl.text = kh.khachHangName;
          emailCtrl.text = kh.email;
          phoneCtrl.text = kh.sdt;

          _loadedCustomer = kh;
          _hasExistingCustomer = true;

          print('[TripCustomerInfo] ✅ Đã load dữ liệu khách hàng thành công!');
        } else {
          // Không có → cho nhập mới
          _loadedCustomer = null;
          _hasExistingCustomer = false;
          print('[TripCustomerInfo] ⚠️ Không tìm thấy khách hàng với SĐT: $phone');

          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Không tìm thấy khách hàng với số $phone')),
          );
        }
        _isLoadingData = false;
      });
    } catch (e) {
      print('[TripCustomerInfo] ❌ Lỗi khi load khách hàng: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Lỗi khi lấy thông tin khách hàng: $e')),
        );
      }
      setState(() => _isLoadingData = false);
    }
  }

  /// 📦 Xử lý create / update khách hàng
  Future<KhachHang> _processCustomerInfo() async {
    if (_loadedCustomer != null) {
      print("--- [TripCustomerInfo] Update Khách Hàng ID: ${_loadedCustomer!.khachHangId}");
      return await _khService.updateKhachHang(
        customerId: _loadedCustomer!.khachHangId,
        name: nameCtrl.text.trim(),
        phone: phoneCtrl.text.trim(),
        email: emailCtrl.text.trim(),
      );
    } else {
      print("--- [TripCustomerInfo] Create Khách Hàng Mới ---");
      return await _khService.createKhachHang(
        name: nameCtrl.text.trim(),
        phone: phoneCtrl.text.trim(),
        email: emailCtrl.text.trim(),
      );
    }
  }

  /// 💳 Lưu thông tin và chuyển sang màn hình thanh toán
  Future<void> _handleConfirmAndContinue() async {
    if (!_formKey.currentState!.validate() || _isProcessing) return;

    setState(() => _isProcessing = true);

    try {
      final KhachHang customer = await _processCustomerInfo();

      print("[TripCustomerInfo] ✅ Xử lý xong khách hàng: ${customer.khachHangId}");

      final int veId = await VeService.createVe(
        chuyenId: widget.chuyenId,
        khachHangId: customer.khachHangId,
        giaVe: widget.gia,
      );

      print("[TripCustomerInfo] 🎫 Vé được tạo với ID: $veId");

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
      if (mounted) setState(() => _isProcessing = false);
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
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                ),
              ),
              const SizedBox(height: 16),

              /// --- TÊN KHÁCH HÀNG ---
              TextFormField(
                controller: nameCtrl,
                decoration: const InputDecoration(
                  labelText: "Tên người đi *",
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.person_outline),
                ),
                validator: (value) =>
                (value == null || value.isEmpty)
                    ? 'Vui lòng nhập tên'
                    : null,
              ),
              const SizedBox(height: 16),

              /// --- SỐ ĐIỆN THOẠI ---
              TextFormField(
                controller: phoneCtrl,
                decoration: const InputDecoration(
                  labelText: "Số điện thoại *",
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.phone_outlined),
                ),
                readOnly: _hasExistingCustomer, // Khóa nếu đã login sẵn
                keyboardType: TextInputType.phone,
                validator: (value) =>
                (value == null || value.isEmpty)
                    ? 'Vui lòng nhập số điện thoại'
                    : null,
              ),
              const SizedBox(height: 16),

              /// --- EMAIL ---
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

              /// --- NÚT XÁC NHẬN ---
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
                  _hasExistingCustomer
                      ? "Xác nhận & Tiếp tục"
                      : "Lưu & Tiếp tục",
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
