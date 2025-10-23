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

  // === SỬA LỖI 1: Thay thế `_loadedCustomer` bằng một biến ID rõ ràng ===
  // Biến này sẽ quyết định hành động là CREATE hay UPDATE.
  // Nó chỉ được gán giá trị một lần duy nhất trong initState.
  int? _existingCustomerId;

  bool _isProcessing = false;
  bool _isLoadingData = true;

  @override
  void initState() {
    super.initState();
    String? phoneToLoad = widget.phone;

    if (phoneToLoad != null && phoneToLoad.isNotEmpty) {
      phoneCtrl.text = phoneToLoad;
      _loadInitialKhachHang(phoneToLoad); // Đổi tên hàm để rõ ràng hơn
    } else {
      setState(() {
        _isLoadingData = false;
      });
    }
  }

  // Hàm này chỉ chạy 1 lần để tải dữ liệu ban đầu
  Future<void> _loadInitialKhachHang(String phone) async {
    print("--- [UI] Đang tải thông tin khách hàng ban đầu với SĐT: $phone ---");
    final kh = await KhachHangService.getKhachHangByPhone(phone);
    if (mounted) {
      setState(() {
        if (kh != null) {
          print("--- [UI] Tìm thấy khách hàng ID: ${kh.khachHangId}. Đổ dữ liệu vào UI. ---");
          nameCtrl.text = kh.khachHangName;
          emailCtrl.text = kh.email;

          // === SỬA LỖI 2: Gán ID vào biến quyết định ===
          // Đây là bước quan trọng nhất
          _existingCustomerId = kh.khachHangId;
        } else {
          print("--- [UI] Không tìm thấy khách hàng. Hiển thị form để tạo mới. ---");
          _existingCustomerId = null; // Đảm bảo là null nếu không tìm thấy
        }
        _isLoadingData = false;
      });
    }
  }

  // === SỬA LỖI 3: Viết lại logic xử lý thông tin ===
  Future<KhachHang> _processCustomerInfo() {
    // Logic bây giờ rất đơn giản và an toàn:
    // - Nếu có `_existingCustomerId`, chắc chắn đó là lệnh UPDATE.
    // - Nếu không, chắc chắn đó là lệnh CREATE.

    if (_existingCustomerId != null) {
      print("--- [UI Logic] Quyết định: UPDATE vì có `_existingCustomerId` (${_existingCustomerId}) ---");
      return KhachHangService.updateKhachHang(
        customerId: _existingCustomerId!, // Dùng ID đã lưu
        name: nameCtrl.text,              // Dùng dữ liệu mới nhất từ UI
        phone: phoneCtrl.text,
        email: emailCtrl.text,
      );
    } else {
      print("--- [UI Logic] Quyết định: CREATE vì `_existingCustomerId` là null ---");
      return KhachHangService.createKhachHang(
        name: nameCtrl.text,
        phone: phoneCtrl.text,
        email: emailCtrl.text,
      );
    }
  }

  Future<void> _handleConfirmAndContinue() async {
    if (!_formKey.currentState!.validate() || _isProcessing) return;
    setState(() { _isProcessing = true; });

    print("\n--- [UI] Bắt đầu quá trình xác nhận và tiếp tục ---");

    try {
      // BƯỚC 1: XỬ LÝ THÔNG TIN KHÁCH HÀNG
      print("--- [UI] Bước 1: Đang gọi _processCustomerInfo... ---");
      final KhachHang customer = await _processCustomerInfo();
      print("--- [UI] Bước 1 THÀNH CÔNG. Nhận được Khách hàng ID: ${customer.khachHangId} ---");

      // BƯỚC 2: TẠO VÉ
      print("--- [UI] Bước 2: Đang gọi VeService.createVe... ---");
      final int veId = await VeService.createVe(
        chuyenId: widget.chuyenId,
        khachHangId: customer.khachHangId,
        giaVe: widget.gia,
      );
      print("--- [UI] Bước 2 THÀNH CÔNG. Nhận được Vé ID: $veId ---");

      // BƯỚC 3: CHUYỂN TRANG
      print("--- [UI] Bước 3: Đang điều hướng đến PaymentScreen... ---");
      if (mounted) {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (context) => PaymentScreen(veId: veId)),
        );
      }
    } catch (e) {
      // NẾU CÓ LỖI Ở BẤT KỲ BƯỚC NÀO, NÓ SẼ NHẢY VÀO ĐÂY
      print("--- [UI] GẶP LỖI NGHIÊM TRỌNG: ${e.toString()} ---");
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Đã xảy ra lỗi: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      // Dù thành công hay thất bại, luôn dừng vòng xoay xử lý
      if (mounted) {
        setState(() { _isProcessing = false; });
      }
      print("--- [UI] Kết thúc quá trình xác nhận và tiếp tục ---\n");
    }
  }

  @override
  Widget build(BuildContext context) {
    // UI không cần thay đổi, nhưng sẽ hoạt động đúng hơn nhờ logic `_existingCustomerId`
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
                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: nameCtrl,
                decoration: const InputDecoration(labelText: "Tên người đi *", border: OutlineInputBorder(), prefixIcon: Icon(Icons.person_outline)),
                validator: (value) => (value == null || value.isEmpty) ? 'Vui lòng nhập tên' : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: phoneCtrl,
                decoration: const InputDecoration(labelText: "Số điện thoại *", border: OutlineInputBorder(), prefixIcon: Icon(Icons.phone_outlined)),
                keyboardType: TextInputType.phone,
                validator: (value) => (value == null || value.isEmpty) ? 'Vui lòng nhập số điện thoại' : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: emailCtrl,
                decoration: const InputDecoration(labelText: "Email để nhận thông tin vé *", border: OutlineInputBorder(), prefixIcon: Icon(Icons.email_outlined)),
                keyboardType: TextInputType.emailAddress,
                validator: (value) {
                  if (value == null || value.isEmpty) return 'Vui lòng nhập email';
                  if (!EmailValidator.validate(value)) return 'Email không hợp lệ';
                  return null;
                },
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                style: ElevatedButton.styleFrom(backgroundColor: Colors.amber, foregroundColor: Colors.black87, minimumSize: const Size(double.infinity, 50), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
                onPressed: _isProcessing ? null : _handleConfirmAndContinue,
                child: _isProcessing
                    ? const CircularProgressIndicator(color: Colors.black54)
                    : Text(
                  hasExistingCustomer ? "Xác nhận & Tiếp tục" : "Lưu & Tiếp tục",
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
