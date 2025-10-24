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
  Map<int, bool> trangThaiDiemDanh = {}; // vé_id -> có mặt / vắng

  @override
  void initState() {
    super.initState();
    _loadTripDetail();
  }

  Future<void> _loadTripDetail() async {
    try {
      print("Đang tải chi tiết chuyến ID: ${widget.chuyenId}");
      final data = await TaiXeService.getChuyenDetail(widget.chuyenId);
      final diemDanhList = await TaiXeService.getDiemDanhTam(widget.chuyenId);

      // Chuyển danh sách [{ve_id, coMat}] thành map {ve_id: coMat}
      final Map<int, bool> trangThai = {
        for (var item in diemDanhList) item['ve_id']: item['coMat'] ?? false
      };

      setState(() {
        chuyen = data['chuyen'];
        tramList = data['tram'] ?? [];
        khachList = data['khach'] ?? [];
        trangThaiDiemDanh = trangThai;
        isLoading = false;
      });
    } catch (e) {
      print("Lỗi khi tải chi tiết chuyến: $e");
      setState(() => isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Lỗi tải chi tiết chuyến: $e')),
      );
    }
  }

  Future<void> _capNhatTrangThai(int veId, bool coMat) async {
    try {
      print("Cập nhật điểm danh vé $veId: ${coMat ? 'Có mặt' : 'Vắng'}");
      await TaiXeService.capNhatDiemDanhTam(widget.chuyenId, veId, coMat);
      setState(() {
        trangThaiDiemDanh[veId] = coMat;
      });
    } catch (e) {
      print("Lỗi khi cập nhật điểm danh: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Lỗi khi cập nhật điểm danh: $e')),
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
            // Thông tin chuyến
            Card(
              elevation: 3,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
              child: ListTile(
                leading: const Icon(Icons.directions_bus,
                    color: Colors.blueAccent),
                title: Text(chuyen?['Chuyen_name'] ?? 'Chuyến xe'),
                subtitle: Text(
                  "Tuyến: ${chuyen?['Ben_di_name']} → ${chuyen?['Ben_den_name']}\n"
                      "Biển số: ${chuyen?['Bien_so'] ?? ''}\n"
                      "Thời gian: ${chuyen?['Ngay_gio'] ?? ''}\n"
                      "Trạng thái: ${chuyen?['Tinh_Trang'] ?? ''}",
                ),
              ),
            ),

            const SizedBox(height: 20),

            // Trạm dừng
            const Text(
              "Trạm dừng chân",
              style: TextStyle(
                  fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            if (tramList.isEmpty)
              const Text("Không có trạm dừng chân.")
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

            // Hành khách
            const Text(
              "Danh sách hành khách",
              style: TextStyle(
                  fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),

            if (khachList.isEmpty)
              const Text("Chưa có hành khách nào đặt vé.")
            else
              ...khachList.map((khach) {
                final veId = khach['Ve_id'];
                final coMat = trangThaiDiemDanh[veId] ?? false;

                return Card(
                  margin:
                  const EdgeInsets.symmetric(vertical: 6),
                  child: ListTile(
                    leading: const Icon(Icons.person,
                        color: Colors.green),
                    title: Text(khach['KhachHang_name']),
                    subtitle: Text(
                        "SĐT: ${khach['SDT']} | Vé: ${khach['Ve_id']}"),
                    trailing: Switch(
                      value: coMat,
                      activeColor: Colors.green,
                      onChanged: (value) {
                        _capNhatTrangThai(veId, value);
                      },
                    ),
                  ),
                );
              }).toList(),

            const SizedBox(height: 20),

            // Tổng kết
            Center(
              child: Text(
                "Đã điểm danh: ${trangThaiDiemDanh.values.where((v) => v).length}/${khachList.length}",
                style: const TextStyle(
                    fontSize: 16, fontWeight: FontWeight.bold),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
