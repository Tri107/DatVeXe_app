import 'package:flutter/material.dart';
import 'package:datvexe_app/screens/khachhang/ticket_detail_screen.dart';
import '../../models/Ve.dart';
import '../../services/Ve_Service.dart';

class MyTicketsScreen extends StatefulWidget {
  final String sdt; // Số điện thoại người dùng đăng nhập
  const MyTicketsScreen({super.key, required this.sdt});

  @override
  State<MyTicketsScreen> createState() => _MyTicketsScreenState();
}

class _MyTicketsScreenState extends State<MyTicketsScreen> {
  bool loading = true;
  List<Ve> tickets = [];

  @override
  void initState() {
    super.initState();
    _fetchTickets();
  }

  /// 🔹 Tải danh sách vé của người dùng
  Future<void> _fetchTickets() async {
    try {
      final list = await VeService.getByUser(widget.sdt);

      // Nếu backend trả về List<Map>, ta map sang List<Ve>
      final veList = list.map((e) => Ve.fromJson(e)).toList();

      setState(() {
        tickets = veList;
        loading = false;
      });
    } catch (e) {
      setState(() => loading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Lỗi tải vé: $e")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Vé của tôi"),
        backgroundColor: const Color(0xFF1565C0),
      ),
      body: loading
          ? const Center(child: CircularProgressIndicator())
          : tickets.isEmpty
          ? const Center(child: Text("Bạn chưa có vé nào"))
          : ListView.builder(
        itemCount: tickets.length,
        itemBuilder: (context, index) {
          final v = tickets[index];
          return GestureDetector(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => TicketDetailScreen(veId: v.veId),
                ),
              );
            },
            child: Card(
              margin: const EdgeInsets.symmetric(
                  horizontal: 12, vertical: 8),
              elevation: 3,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
              child: ListTile(
                contentPadding: const EdgeInsets.all(12),
                title: Text(
                  v.chuyenName,
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                subtitle: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text("Bến: ${v.tuyenDuongName}"),
                    Text("Ngày đi: ${v.ngayGio}"),
                    Text(
                      "Giá vé: ${v.veGia.toStringAsFixed(0)}đ",
                      style: const TextStyle(color: Colors.redAccent),
                    ),
                  ],
                ),
                trailing:
                const Icon(Icons.arrow_forward_ios, size: 16),
              ),
            ),
          );
        },
      ),
    );
  }
}
