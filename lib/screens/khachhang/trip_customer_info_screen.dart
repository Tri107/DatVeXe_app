import 'package:flutter/material.dart';
import 'package:datvexe_app/services/khachhang_service.dart';
import 'package:datvexe_app/models/KhachHang.dart';

class TripCustomerInfoScreen extends StatefulWidget {
  final String chuyenId;
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
  final khService = KhachHangService();

  final nameCtrl = TextEditingController();
  final phoneCtrl = TextEditingController();
  final emailCtrl = TextEditingController();

  @override
  void initState() {
    super.initState();
    if (widget.phone != null && widget.phone!.isNotEmpty) {
      phoneCtrl.text = widget.phone!;
      _loadKhachHang(widget.phone!);
    }
  }

  Future<void> _loadKhachHang(String phone) async {
    final kh = await khService.getKhachHangByPhone(phone);
    if (kh != null) {
      setState(() {
        nameCtrl.text = kh.khachHangName;
        emailCtrl.text = kh.email;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Thông tin liên hệ"),
        backgroundColor: Colors.blue,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text("Thông tin liên hệ",
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
              const SizedBox(height: 16),

              // Tên người đi
              TextFormField(
                controller: nameCtrl,
                decoration: const InputDecoration(
                  labelText: "Tên người đi *",
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 16),

              // Số điện thoại
              TextFormField(
                controller: phoneCtrl,
                decoration: const InputDecoration(
                  labelText: "Số điện thoại *",
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.phone,
              ),
              const SizedBox(height: 16),

              // Email
              TextFormField(
                controller: emailCtrl,
                decoration: const InputDecoration(
                  labelText: "Email để nhận thông tin vé *",
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.emailAddress,
              ),
              const SizedBox(height: 20),

              // Thông báo nhỏ
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.green.shade50,
                  border: Border.all(color: Colors.green),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Row(
                  children: [
                    Icon(Icons.check_circle, color: Colors.green),
                    SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        "Thông tin đơn hàng sẽ được gửi đến số điện thoại và email bạn cung cấp.",
                        style: TextStyle(color: Colors.green, fontSize: 13),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),

              // Nút tiếp tục
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.yellow.shade700,
                    minimumSize: const Size(double.infinity, 50)),
                onPressed: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text("Đã nhấn Tiếp tục"),
                      duration: Duration(seconds: 1),
                    ),
                  );
                },
                child: const Text(
                  "Tiếp tục",
                  style: TextStyle(color: Colors.black),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
