import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../services/TaiXe_Service.dart';
import 'scan_qr_screen.dart';

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
  Map<int, bool> trangThaiDiemDanh = {};

  @override
  void initState() {
    super.initState();
    _loadTripDetail();
  }

  Future<void> _loadTripDetail() async {
    try {
      final data = await TaiXeService.getChuyenDetail(widget.chuyenId);
      final diemDanhList = await TaiXeService.getDiemDanhTam(widget.chuyenId);

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
      setState(() => isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Lỗi tải chi tiết chuyến: $e')),
      );
    }
  }

  Future<void> _capNhatTrangThai(int veId, bool coMat) async {
    try {
      await TaiXeService.capNhatDiemDanhTam(widget.chuyenId, veId, coMat);
      setState(() {
        trangThaiDiemDanh[veId] = coMat;
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Lỗi khi cập nhật điểm danh: $e')),
      );
    }
  }

  String _formatDateTime(String? dateTimeString) {
    if (dateTimeString == null || dateTimeString.isEmpty) return "Không rõ";
    try {
      final dt = DateTime.parse(dateTimeString);
      return DateFormat('dd/MM/yyyy HH:mm').format(dt);
    } catch (_) {
      return dateTimeString;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        title: const Text("Chi tiết chuyến xe"),
        backgroundColor: Colors.blueAccent,
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : chuyen == null
          ? const Center(child: Text('Không tìm thấy thông tin chuyến xe.'))
          : Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // --- Thông tin chuyến ---
            Card(
              elevation: 3,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            chuyen?['Chuyen_name'] ?? 'Chuyến xe',
                            style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            "Tuyến: ${chuyen?['Ben_di_name']} → ${chuyen?['Ben_den_name']}",
                            style: const TextStyle(fontSize: 15),
                          ),
                          Text(
                            "Biển số: ${chuyen?['Bien_so'] ?? ''}",
                            style: const TextStyle(fontSize: 15),
                          ),
                          Text(
                            "Thời gian: ${_formatDateTime(chuyen?['Ngay_gio'])}",
                            style: const TextStyle(fontSize: 15),
                          ),
                        ],
                      ),
                    ),
                    const Icon(Icons.directions_bus,
                        color: Colors.blueAccent, size: 40),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 16),

            // --- Trạm dừng ---
            const Text(
              "Trạm dừng chân",
              style: TextStyle(
                  fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
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

            const SizedBox(height: 16),

            // --- Danh sách hành khách ---
            const Text(
              "Danh sách hành khách",
              style: TextStyle(
                  fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Expanded(
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(8),
                  boxShadow: const [
                    BoxShadow(
                        color: Colors.black12,
                        blurRadius: 3,
                        offset: Offset(0, 2))
                  ],
                ),
                child: khachList.isEmpty
                    ? const Center(
                  child: Text(
                      "Chưa có hành khách nào đặt vé."),
                )
                    : ListView.builder(
                  itemCount: khachList.length,
                  itemBuilder: (context, index) {
                    final khach = khachList[index];
                    final veId = khach['Ve_id'];
                    final coMat =
                        trangThaiDiemDanh[veId] ?? false;

                    return ListTile(
                      leading: const Icon(Icons.person,
                          color: Colors.green),
                      title: Text(khach['KhachHang_name']),
                      subtitle: Text(
                          "SĐT: ${khach['SDT']} | Vé: ${khach['Ve_id']}"),
                      trailing: GestureDetector(
                        onTap: () {
                          _capNhatTrangThai(veId, !coMat);
                        },
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 300),
                          width: 60,
                          height: 30,
                          padding: const EdgeInsets.symmetric(horizontal: 4),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(20),
                            gradient: LinearGradient(
                              colors: coMat
                                  ? [Colors.greenAccent.shade400, Colors.green.shade700]
                                  : [Colors.grey.shade300, Colors.grey.shade400],
                            ),
                            boxShadow: coMat
                                ? [
                              BoxShadow(
                                color: Colors.greenAccent.withOpacity(0.5),
                                blurRadius: 8,
                                offset: const Offset(0, 3),
                              ),
                            ]
                                : [],
                          ),
                          child: AnimatedAlign(
                            duration: const Duration(milliseconds: 300),
                            alignment: coMat ? Alignment.centerRight : Alignment.centerLeft,
                            curve: Curves.easeInOut,
                            child: Container(
                              width: 24,
                              height: 24,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: Colors.white,
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black26,
                                    blurRadius: 4,
                                    offset: const Offset(0, 2),
                                  ),
                                ],
                              ),
                              child: Icon(
                                coMat ? Icons.check : Icons.circle_outlined,
                                color: coMat ? Colors.green : Colors.grey,
                                size: 18,
                              ),
                            ),
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
            ),

            const SizedBox(height: 10),

            // --- Tổng kết điểm danh ---
            Center(
              child: Text(
                "Đã điểm danh: ${trangThaiDiemDanh.values.where((v) => v).length}/${khachList.length}",
                style: const TextStyle(
                    fontSize: 16, fontWeight: FontWeight.bold),
              ),
            ),

            const SizedBox(height: 60), // Chừa chỗ cho floating button
          ],
        ),
      ),
      floatingActionButtonLocation:
      FloatingActionButtonLocation.centerFloat,
      floatingActionButton: ElevatedButton.icon(
        onPressed: () async {
          final veId = await Navigator.push<int>(
            context,
            MaterialPageRoute(
              builder: (_) => ScanQRScreen(chuyenId: widget.chuyenId),
            ),
          );

          if (veId != null) {
            await _capNhatTrangThai(veId, true);
          }
        },
        icon: const Icon(Icons.qr_code_scanner),
        label: const Text("Quét mã QR vé"),
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.blueAccent,
          foregroundColor: Colors.white,
          padding:
          const EdgeInsets.symmetric(vertical: 14, horizontal: 24),
          shape:
          RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          textStyle: const TextStyle(fontSize: 16,),
        ),
      ),
    );
  }
}
