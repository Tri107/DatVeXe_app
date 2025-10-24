import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:mobile_scanner/mobile_scanner.dart';

import '../../config/api.dart';

class ScanQRScreen extends StatefulWidget {
  final int chuyenId;
  const ScanQRScreen({super.key, required this.chuyenId});

  @override
  State<ScanQRScreen> createState() => _ScanQRScreenState();
}

class _ScanQRScreenState extends State<ScanQRScreen> {
  bool isScanning = true;
  bool _isSnackBarShown = false;

  Future<void> _handleScan(String data) async {
    if (!isScanning) return;
    setState(() => isScanning = false);

    try {
      // 🧩 Giải mã dữ liệu QR
      Map<String, dynamic> qr;
      try {
        qr = json.decode(data);
      } catch (_) {
        _showOnceSnackBar('Mã QR không hợp lệ!');
        _resetScan();
        return;
      }

      // 🧩 Kiểm tra các khóa cần thiết
      if (!qr.containsKey('Ve_id') || !qr.containsKey('Chuyen_id')) {
        _showOnceSnackBar('QR không chứa thông tin hợp lệ!');
        _resetScan();
        return;
      }

      final veId = int.tryParse(qr['Ve_id'].toString());
      final chuyenId = int.tryParse(qr['Chuyen_id'].toString());

      if (veId == null || chuyenId == null) {
        _showOnceSnackBar('Dữ liệu trong QR không hợp lệ!');
        _resetScan();
        return;
      }

      // 🧩 Kiểm tra chuyến khớp
      if (chuyenId != widget.chuyenId) {
        _showOnceSnackBar('Mã vé không thuộc chuyến này!');
        _resetScan();
        return;
      }

      // ✅ Gọi API xác thực QR
      final response = await Api.client.post(
        '/ve/verifyQR',
        data: {'ve_id': veId},
      );

      final result = response.data;

      // Rung nhẹ khi thành công
      HapticFeedback.mediumImpact();

      // Hiện thông báo kết quả từ server
      _showOnceSnackBar(result['message'] ?? 'Điểm danh thành công!');

      // ✅ Trả về veId cho màn trước (TripDetailScreen)
      if (mounted) Navigator.pop(context, veId);

    } catch (e) {
      _showOnceSnackBar('Lỗi quét mã: $e');
    }

    _resetScan();
  }

  void _showOnceSnackBar(String message) {
    if (_isSnackBarShown) return;
    _isSnackBarShown = true;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  Future<void> _resetScan() async {
    await Future.delayed(const Duration(seconds: 2));
    if (!mounted) return;
    setState(() {
      isScanning = true;
      _isSnackBarShown = false; // cho phép hiển thị lại khi quét mới
    });
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
