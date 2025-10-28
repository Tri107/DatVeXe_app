import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:qr_flutter/qr_flutter.dart';
import '../../config/api.dart';
import '../../themes/gradient.dart';
import '../../services/Ve_Service.dart';

class TicketDetailScreen extends StatefulWidget {
  final int veId;
  const TicketDetailScreen({super.key, required this.veId});

  @override
  State<TicketDetailScreen> createState() => _TicketDetailScreenState();
}

class _TicketDetailScreenState extends State<TicketDetailScreen> {
  Map<String, dynamic>? ve;
  bool loading = true;
  String? qrImage;

  @override
  void initState() {
    super.initState();
    _loadVe();
    _loadQRCode();
  }

  Future<void> _loadVe() async {
    try {
      final data = await VeService.getVeById(widget.veId);
      setState(() {
        ve = data;
        loading = false;
      });
    } catch (e) {
      setState(() => loading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Lỗi tải chi tiết vé: $e')),
      );
    }
  }

  Future<void> _loadQRCode() async {
    try {
      final response = await Api.client.get('/ve/${widget.veId}/qr');
      if (response.statusCode == 200) {
        setState(() {
          qrImage = response.data['qrCode'];
        });
      }
    } catch (e) {
      print('Lỗi tải QR: $e');
    }
  }

  Widget _buildInfoRow(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          Icon(icon, color: Colors.blue[800]),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              '$label: ',
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
          Expanded(
            flex: 2,
            child: Text(value, textAlign: TextAlign.right),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (loading) {
      return Scaffold(
        backgroundColor: Colors.grey[100],
        body: Center(child: CircularProgressIndicator()),
      );
    }

    if (ve == null) {
      return Scaffold(
        backgroundColor: Colors.grey[100],
        body: Center(child: Text('Không tìm thấy vé')),
      );
    }

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
              'Chi tiết vé',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
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
          padding: const EdgeInsets.all(20),
          child: Column(
            children: [
              Text(
                'Mã vé: ${ve!['Ve_id']}',
                style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.blueAccent),
              ),
              const SizedBox(height: 20),
              const Divider(),
              _buildInfoRow(Icons.person, 'Khách hàng', ve!['KhachHang_name']),
              _buildInfoRow(Icons.location_on, 'Tuyến',
                  '${ve!['Ben_di_name']} - ${ve!['Ben_den_name']}'),
              _buildInfoRow(Icons.calendar_today, 'Ngày giờ', ve!['Ngay_gio']),
              _buildInfoRow(Icons.attach_money, 'Giá vé', '${ve!['Ve_gia']}đ'),
              _buildInfoRow(Icons.notes, 'Ghi chú',
                  ve!['GhiChu'] ?? 'Không có ghi chú'),

              const SizedBox(height: 30),
              const Divider(),
              const SizedBox(height: 10),

              // Hiển thị QR Code
              if (qrImage != null)
                Column(
                  children: [
                    Container(
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.blueAccent, width: 2),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      padding: const EdgeInsets.all(10),
                      child: Image.memory(
                        base64Decode(qrImage!.split(',').last),
                        width: 200,
                        height: 200,
                      ),
                    ),
                    const SizedBox(height: 10),
                    const Text(
                      'Quét mã QR để tài xế điểm danh',
                      style: TextStyle(
                          fontStyle: FontStyle.italic,
                          color: Colors.black54,
                          fontSize: 13),
                    ),
                  ],
                )
              else
                const Text('Đang tải mã QR...'),
            ],
          ),
        ),
      ),
    );
  }
}
