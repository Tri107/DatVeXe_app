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
      Map<String, dynamic> qr;
      try {
        qr = json.decode(data);
      } catch (_) {
        _showOnceSnackBar('Mã QR không hợp lệ!');
        _resetScan();
        return;
      }

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

      if (chuyenId != widget.chuyenId) {
        _showOnceSnackBar('Mã vé không thuộc chuyến này!');
        _resetScan();
        return;
      }

      final response = await Api.client.post(
        '/ve/verifyQR',
        data: {'ve_id': veId},
      );

      final result = response.data;
      HapticFeedback.mediumImpact();

      _showOnceSnackBar(result['message'] ?? 'Điểm danh thành công!');

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
      _isSnackBarShown = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Quét vé hành khách'),
        backgroundColor: const Color(0xFF1565C0),
      ),
      body: Stack(
        children: [
          // Camera quét QR
          MobileScanner(
            onDetect: (capture) {
              final barcode = capture.barcodes.first;
              final String? value = barcode.rawValue;
              if (value != null) {
                _handleScan(value);
              }
            },
          ),

          // Lớp overlay tối mờ
          Container(
            color: Colors.black.withOpacity(0.4),
          ),

          // Khung chữ L ở 4 góc
          Align(
            alignment: const Alignment(0, -0.1), // đưa khung cao lên
            child: SizedBox(
              width: 260,
              height: 260,
              child: CustomPaint(
                painter: _CornerFramePainter(),
              ),
            ),
          ),

          // Icon quét QR ở giữa khung
          const Align(
            alignment: Alignment(0, -0.1),
            child: Icon(
              Icons.qr_code_scanner,
              color: Colors.white70,
              size: 80,
            ),
          ),

          // Hướng dẫn
          const Align(
            alignment: Alignment(0, 0.75),
            child: Text(
              'Đưa mã QR vào trong khung để quét',
              style: TextStyle(color: Colors.white, fontSize: 16),
            ),
          ),
        ],
      ),
    );
  }
}

// Vẽ 4 góc chữ L
class _CornerFramePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white
      ..strokeWidth = 4
      ..style = PaintingStyle.stroke;

    const cornerLength = 30.0;

    // Góc trên trái
    canvas.drawLine(Offset(0, 0), Offset(cornerLength, 0), paint);
    canvas.drawLine(Offset(0, 0), Offset(0, cornerLength), paint);

    // Góc trên phải
    canvas.drawLine(Offset(size.width, 0), Offset(size.width - cornerLength, 0), paint);
    canvas.drawLine(Offset(size.width, 0), Offset(size.width, cornerLength), paint);

    // Góc dưới trái
    canvas.drawLine(Offset(0, size.height), Offset(cornerLength, size.height), paint);
    canvas.drawLine(Offset(0, size.height), Offset(0, size.height - cornerLength), paint);

    // Góc dưới phải
    canvas.drawLine(Offset(size.width, size.height), Offset(size.width - cornerLength, size.height), paint);
    canvas.drawLine(Offset(size.width, size.height), Offset(size.width, size.height - cornerLength), paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
