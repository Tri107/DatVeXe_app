import 'package:flutter/material.dart';
import '../../services/TaiXe_Service.dart';

class TaiXeTripDetailScreen extends StatefulWidget {
  final int chuyenId;

  const TaiXeTripDetailScreen({super.key, required this.chuyenId});

  @override
  State<TaiXeTripDetailScreen> createState() => _TaiXeTripDetailScreenState();
}

class _TaiXeTripDetailScreenState extends State<TaiXeTripDetailScreen> {
  bool isLoading = true;
  Map<String, dynamic>? chuyen;
  List<dynamic> tramList = [];
  List<dynamic> khachList = [];

  @override
  void initState() {
    super.initState();
    _loadTripDetail();
  }

  /// 🔹 Gọi API backend để lấy chi tiết chuyến
  Future<void> _loadTripDetail() async {
    try {
      print("🔎 Đang tải chi tiết chuyến ID: ${widget.chuyenId}");
      final data = await TaiXeService.getChuyenDetail(widget.chuyenId);

      setState(() {
        chuyen = data['chuyen'];
        tramList = data['tram'] ?? [];
        khachList = data['khach'] ?? [];
        isLoading = false;
      });
    } catch (e) {
      print("❌ Lỗi khi tải chi tiết chuyến: $e");
      setState(() => isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Lỗi tải chi tiết chuyến: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      appBar: AppBar(
        title: const Text("Chi tiết chuyến xe"),
        backgroundColor: Colors.blueAccent,
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : chuyen == null
          ? const Center(child: Text('Không tìm thấy thông tin chuyến xe.'))
          : SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 🔹 Thông tin chuyến
            Card(
              elevation: 3,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
              child: ListTile(
                leading: const Icon(Icons.directions_bus,
                    color: Colors.blueAccent),
                title:
                Text(chuyen?['Chuyen_name'] ?? 'Chuyến xe chưa rõ'),
                subtitle: Text(
                  "Tuyến: ${chuyen?['Ben_di_name']} → ${chuyen?['Ben_den_name']}\n"
                      "Biển số: ${chuyen?['Bien_so'] ?? ''}\n"
                      "Thời gian: ${chuyen?['Ngay_gio'] ?? ''}\n"
                      "Trạng thái: ${chuyen?['Tinh_Trang'] ?? ''}",
                ),
              ),
            ),

            const SizedBox(height: 20),

            // 🔹 Danh sách trạm dừng
            const Text(
              "Trạm dừng chân",
              style: TextStyle(
                  fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            if (tramList.isEmpty)
              const Text("Không có trạm dừng chân nào.")
            else
              ...tramList.map((tram) => Card(
                margin:
                const EdgeInsets.symmetric(vertical: 6),
                child: ListTile(
                  leading: const Icon(Icons.location_on,
                      color: Colors.redAccent),
                  title: Text(tram['TramDungChan_name']),
                  subtitle: Text(
                      "Thời gian dừng: ${tram['Thoi_gian_dung']} phút"),
                ),
              )),

            const SizedBox(height: 20),

            // 🔹 Danh sách hành khách
            const Text(
              "Danh sách hành khách",
              style: TextStyle(
                  fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            if (khachList.isEmpty)
              const Text("Chưa có hành khách nào đặt vé.")
            else
              ...khachList.map((khach) => Card(
                margin:
                const EdgeInsets.symmetric(vertical: 6),
                child: ListTile(
                  leading: const Icon(Icons.person,
                      color: Colors.green),
                  title: Text(khach['KhachHang_name']),
                  subtitle: Text(
                      "SĐT: ${khach['SDT']} | Vé: ${khach['Ve_id']}"),
                ),
              )),
          ],
        ),
      ),
    );
  }
}
