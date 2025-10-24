import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';

import '../../config/api.dart';

class ScanQRScreen extends StatefulWidget {
  const ScanQRScreen({super.key});

  @override
  State<ScanQRScreen> createState() => _ScanQRScreenState();
}

class _ScanQRScreenState extends State<ScanQRScreen> {
  bool isScanning = true;

  Future<void> _handleScan(String data) async {
    if (!isScanning) return;
    setState(() => isScanning = false);

    try {
      // Giải mã dữ liệu QR (chuỗi JSON được backend encode)
      final qr = json.decode(data);
      final veId = qr['Ve_id'];

      // ✅ Gọi API verifyQR qua Dio (v5.x phải dùng data:)
      final response = await Api.client.post(
        '/ve/verifyQR',
        data: {'ve_id': veId},
      );

      final result = response.data;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(result['message'] ?? 'Điểm danh thành công!')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Lỗi quét mã: $e')),
      );
    }

    // Cho phép quét lại sau 2 giây
    await Future.delayed(const Duration(seconds: 2));
    setState(() => isScanning = true);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Quét vé hành khách'),
        backgroundColor: const Color(0xFF1565C0),
      ),
      body: MobileScanner(
        onDetect: (capture) {
          final barcode = capture.barcodes.first;
          final String? value = barcode.rawValue;
          if (value != null) {
            _handleScan(value);
          }
        },
      ),
    );
  }
}
