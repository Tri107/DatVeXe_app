import 'package:flutter/material.dart';
import '../../services/TaiXe_Service.dart';
import 'taixe_tripdetail_screen.dart';

class TaiXeTripListScreen extends StatefulWidget {
  final int taiXeId;

  const TaiXeTripListScreen({super.key, required this.taiXeId});

  @override
  State<TaiXeTripListScreen> createState() => _TaiXeTripListScreenState();
}

class _TaiXeTripListScreenState extends State<TaiXeTripListScreen> {
  bool isLoading = true;
  List<dynamic> trips = [];

  @override
  void initState() {
    super.initState();
    _loadTrips();
  }

  /// 🔹 Gọi API lấy danh sách chuyến xe của tài xế
  Future<void> _loadTrips() async {
    try {
      print("📦 Đang tải danh sách chuyến cho tài xế ID: ${widget.taiXeId}");
      final data = await TaiXeService.getChuyenList(widget.taiXeId);
      print("✅ Nhận được ${data.length} chuyến.");

      setState(() {
        trips = data;
        isLoading = false;
      });
    } catch (e) {
      print("❌ Lỗi tải chuyến: $e");
      setState(() => isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Lỗi tải danh sách chuyến: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      appBar: AppBar(
        title: const Text("Danh sách chuyến xe"),
        backgroundColor: Colors.blueAccent,
        elevation: 0,
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : trips.isEmpty
          ? const Center(
        child: Text(
          "Hiện tại bạn chưa có chuyến nào.",
          style: TextStyle(fontSize: 16, color: Colors.grey),
        ),
      )
          : RefreshIndicator(
        onRefresh: _loadTrips,
        child: ListView.builder(
          padding: const EdgeInsets.all(12),
          itemCount: trips.length,
          itemBuilder: (context, index) {
            final trip = trips[index];
            return Card(
              margin: const EdgeInsets.only(bottom: 12),
              elevation: 3,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
              child: ListTile(
                leading: const CircleAvatar(
                  backgroundColor: Colors.blueAccent,
                  child: Icon(Icons.directions_bus,
                      color: Colors.white),
                ),
                title: Text(
                  trip['Chuyen_name'] ?? 'Chuyến xe không tên',
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                subtitle: Text(
                  "${trip['Ben_di_name'] ?? ''} → ${trip['Ben_den_name'] ?? ''}\n"
                      "Thời gian: ${trip['Ngay_gio'] ?? 'Không rõ'}\n"
                      "Trạng thái: ${trip['Tinh_Trang'] ?? 'Không rõ'}",
                  style: const TextStyle(fontSize: 13, height: 1.4),
                ),
                isThreeLine: true,
                trailing:
                const Icon(Icons.arrow_forward_ios, size: 18),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => TaiXeTripDetailScreen(
                        chuyenId: trip['Chuyen_id'],
                      ),
                    ),
                  );
                },
              ),
            );
          },
        ),
      ),
    );
  }
}
