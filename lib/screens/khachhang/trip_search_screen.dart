import 'package:datvexe_app/screens/khachhang/trip_info_screen.dart' hide Chuyen;
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../models/Chuyen.dart';
import '../../services/Trip_Service.dart';

class TripSearchScreen extends StatefulWidget {
  final String from;
  final String to;
  final DateTime? date;
  final String? phone;

  const TripSearchScreen({
    Key? key,
    required this.from,
    required this.to,
    this.date,
    this.phone,
  }) : super(key: key);

  @override
  _TripSearchScreenState createState() => _TripSearchScreenState();
}

class _TripSearchScreenState extends State<TripSearchScreen> {
  late Future<List<Chuyen>> _futureChuyenList;

  @override
  void initState() {
    super.initState();
    _futureChuyenList = ChuyenService.fetchSearchTrip(
      widget.from,
      widget.to,
      widget.date,
    );
  }

  // Widget tái sử dụng để hiển thị một hàng thông tin có icon
  Widget _buildInfoRow({required IconData icon, required String text}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        children: [
          Icon(icon, color: Colors.grey.shade600, size: 18),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              text,
              style: TextStyle(fontSize: 15, color: Colors.grey.shade800),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Kết quả tìm kiếm'),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 1,
        centerTitle: true,
      ),
      backgroundColor: Colors.grey[200], // Đồng bộ màu nền
      body: FutureBuilder<List<Chuyen>>(
        future: _futureChuyenList,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Lỗi tải dữ liệu: ${snapshot.error}'));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(
              child: Text(
                'Không tìm thấy chuyến xe phù hợp.',
                style: TextStyle(fontSize: 16),
              ),
            );
          }

          final chuyenList = snapshot.data!;

          return ListView.builder(
            padding: const EdgeInsets.all(8), // Thêm padding cho ListView
            itemCount: chuyenList.length,
            itemBuilder: (context, index) {
              final chuyen = chuyenList[index];
              // Tách riêng giờ và ngày để trình bày đẹp hơn
              final thoiGian = DateFormat('HH:mm').format(chuyen.ngayGio);
              final ngay = DateFormat('dd/MM/yyyy').format(chuyen.ngayGio);

              return Card(
                margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
                elevation: 2,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                child: InkWell( // Dùng InkWell để có hiệu ứng đẹp khi nhấn
                  borderRadius: BorderRadius.circular(12),
                  onTap: () {
                    // SỬA LỖI Ở ĐÂY:
                    // Đổi tên tham số từ `veId` thành `chuyenId`
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => TripInfoScreen(chuyenId: chuyen.chuyenId, phone: widget.phone),
                      ),
                    );
                  },
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Hàng 1: Giờ khởi hành và Tên chuyến
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              thoiGian,
                              style: const TextStyle(
                                fontSize: 22,
                                fontWeight: FontWeight.bold,
                                color: Colors.blueAccent,
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: Text(
                                chuyen.chuyenName,
                                textAlign: TextAlign.right,
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const Divider(height: 20),

                        // Hàng 2: Các thông tin chi tiết
                        _buildInfoRow(icon: Icons.route_outlined, text: chuyen.tuyenDuongName),
                        _buildInfoRow(icon: Icons.calendar_today_outlined, text: 'Ngày: $ngay'),
                        _buildInfoRow(icon: Icons.directions_bus_outlined, text: 'Loại Xe: ${chuyen.loaiXeName}'),

                        const SizedBox(height: 10),

                        // Hàng 3: Tình trạng chuyến (được làm nổi bật)
                        Align(
                          alignment: Alignment.centerRight,
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                            decoration: BoxDecoration(
                              color: chuyen.tinhTrang.toLowerCase() == 'còn chỗ'
                                  ? Colors.green.shade100
                                  : Colors.red.shade100,
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Text(
                              chuyen.tinhTrang,
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: chuyen.tinhTrang.toLowerCase() == 'còn chỗ'
                                    ? Colors.green.shade800
                                    : Colors.red.shade800,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
