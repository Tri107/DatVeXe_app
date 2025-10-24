import 'package:flutter/material.dart';
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

  @override
  void initState() {
    super.initState();
    _loadVe();
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

  @override
  Widget build(BuildContext context) {
    if (loading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }
    if (ve == null) {
      return const Scaffold(
        body: Center(child: Text('Không tìm thấy vé')),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Chi tiết vé'),
        backgroundColor: const Color(0xFF1565C0),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [

            const SizedBox(height: 20),
            Text('Mã vé: ${ve!['Ve_id']}', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            Text('Khách hàng: ${ve!['KhachHang_name']}'),
            //Text('Chuyến: ${ve!['TuyenDuong_name']}'),
            Text('Tuyến: ${ve!['Ben_di_name']} - ${ve!['Ben_den_name']}'),
            Text('Ngày giờ: ${ve!['Ngay_gio']}'),
            Text('Giá vé: ${ve!['Ve_gia']}đ'),
            const Divider(height: 30),
            Text('Ghi chú: ${ve!['GhiChu'] ?? 'Không có'}'),
          ],
        ),
      ),
    );
  }
}
