import 'package:flutter/material.dart';
import 'package:email_validator/email_validator.dart';
import 'package:datvexe_app/models/KhachHang.dart';
import 'package:datvexe_app/screens/khachhang/payment_screen.dart';
import 'package:datvexe_app/services/KhachHang_Service.dart';
import 'package:datvexe_app/services/Ve_Service.dart';
import '../../themes/gradient.dart';

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
  final nameCtrl = TextEditingController();
  final phoneCtrl = TextEditingController();
  final emailCtrl = TextEditingController();

  int? _existingCustomerId;
  bool _isProcessing = false;
  bool _isLoadingData = true;

  @override
  void initState() {
    super.initState();
    final phoneToLoad = widget.phone;

    if (phoneToLoad != null && phoneToLoad.isNotEmpty) {
      phoneCtrl.text = phoneToLoad;
      _loadInitialKhachHang(phoneToLoad);
    } else {
      _isLoadingData = false;
    }
  }

  Future<void> _loadInitialKhachHang(String phone) async {
    final kh = await KhachHangService.getKhachHangByPhone(phone);
    if (!mounted) return;

    setState(() {
      if (kh != null) {
        nameCtrl.text = kh.khachHangName;
        emailCtrl.text = kh.email;
        _existingCustomerId = kh.khachHangId;
      } else {
        _existingCustomerId = null;
      }
      _isLoadingData = false;
    });
  }

  Future<KhachHang> _processCustomerInfo() {
    if (_existingCustomerId != null) {
      return KhachHangService.updateKhachHang(
        customerId: _existingCustomerId!,
        name: nameCtrl.text,
        phone: phoneCtrl.text,
        email: emailCtrl.text,
      );
    } else {
      return KhachHangService.createKhachHang(
        name: nameCtrl.text,
        phone: phoneCtrl.text,
        email: emailCtrl.text,
      );
    }
  }

  Future<void> _handleConfirmAndContinue() async {
    if (!_formKey.currentState!.validate() || _isProcessing) return;

    setState(() => _isProcessing = true);

    try {
      final KhachHang customer = await _processCustomerInfo();

      final int veId = await VeService.createVe(
        chuyenId: widget.chuyenId,
        khachHangId: customer.khachHangId,
        giaVe: widget.gia,
      );

      if (!mounted) return;
      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (context) =>
              PaymentScreen(veId: veId, email: emailCtrl.text.trim(), chuyenId: widget.chuyenId, gia: widget.gia,),
        ),
      );
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Đã xảy ra lỗi: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isProcessing = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final bool hasExistingCustomer = _existingCustomerId != null;

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
            title: const Text(
              'Thông tin hành khách',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ),
        ),
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

              // --- Thông tin khách hàng trong khung ---
              Card(
                elevation: 3,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    children: [
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

                      TextFormField(
                        controller: phoneCtrl,
                        decoration: const InputDecoration(
                          labelText: "Số điện thoại *",
                          border: OutlineInputBorder(),
                          prefixIcon: Icon(Icons.phone_outlined),
                        ),
                        keyboardType: TextInputType.phone,
                        validator: (value) =>
                        (value == null || value.isEmpty)
                            ? 'Vui lòng nhập số điện thoại'
                            : null,
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
                          if (value == null || value.isEmpty) {
                            return 'Vui lòng nhập email';
                          }
                          if (!EmailValidator.validate(value)) {
                            return 'Email không hợp lệ';
                          }
                          return null;
                        },
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 100),
            ],
          ),
        ),
      ),

      // --- Floating form (bottom container cố định) ---
      bottomNavigationBar: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.black26.withOpacity(0.1),
              blurRadius: 8,
              offset: const Offset(0, -2),
            ),
          ],
        ),
        child: SafeArea(
          child: ElevatedButton(
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
              hasExistingCustomer
                  ? "Xác nhận & Tiếp tục"
                  : "Lưu & Tiếp tục",
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
