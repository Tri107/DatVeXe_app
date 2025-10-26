import 'package:datvexe_app/screens/khachhang/trip_info_screen.dart' hide Chuyen;
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../models/Chuyen.dart';
import '../../services/Trip_Service.dart';
import '../../themes/gradient.dart';

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
      backgroundColor: Colors.grey[100],
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(60),
        child: Container(
          decoration: const BoxDecoration(
            gradient: AppGradients.primary,
          ),
          child: AppBar(
            backgroundColor: Colors.transparent,
            elevation: 0,
            centerTitle: true,
            title: const Text(
              'Kết quả tìm kiếm',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ),
        ),
      ),

      body: FutureBuilder<List<Chuyen>>(
        future: _futureChuyenList,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(color: Color(0xFF1976D2)),
            );
          } else if (snapshot.hasError) {
            return Center(child: Text('Lỗi tải dữ liệu: ${snapshot.error}'));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(
              child: Text(
                'Không tìm thấy chuyến xe phù hợp',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
              ),
            );
          }

          final chuyenList = snapshot.data!;
          return ListView.builder(
            padding: const EdgeInsets.all(12),
            itemCount: chuyenList.length,
            itemBuilder: (context, index) {
              final chuyen = chuyenList[index];
              final thoiGian = DateFormat('HH:mm').format(chuyen.ngayGio);
              final ngay = DateFormat('dd/MM/yyyy').format(chuyen.ngayGio);
              final bool conCho =
              chuyen.tinhTrang.toLowerCase().contains('còn');

              return AnimatedContainer(
                duration: const Duration(milliseconds: 250),
                curve: Curves.easeOut,
                margin: const EdgeInsets.only(bottom: 12),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(14),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.withOpacity(0.2),
                      blurRadius: 6,
                      offset: const Offset(0, 3),
                    ),
                  ],
                ),
                child: InkWell(
                  borderRadius: BorderRadius.circular(14),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => TripInfoScreen(
                          chuyenId: chuyen.chuyenId,
                          phone: widget.phone,
                        ),
                      ),
                    );
                  },
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Phần đầu: Giờ và trạng thái
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Row(
                              children: [
                                const Icon(Icons.access_time,
                                    color: Colors.blueAccent, size: 22),
                                const SizedBox(width: 6),
                                Text(
                                  thoiGian,
                                  style: const TextStyle(
                                    fontSize: 20,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.blueAccent,
                                  ),
                                ),
                              ],
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 10, vertical: 4),
                              decoration: BoxDecoration(
                                color: conCho
                                    ? Colors.green.shade100
                                    : Colors.red.shade100,
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Text(
                                chuyen.tinhTrang,
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: conCho
                                      ? Colors.green.shade800
                                      : Colors.red.shade800,
                                ),
                              ),
                            ),
                          ],
                        ),

                        const SizedBox(height: 6),

                        Text(
                          chuyen.chuyenName,
                          style: const TextStyle(
                            fontSize: 17,
                            fontWeight: FontWeight.w600,
                            color: Colors.black87,
                          ),
                        ),

                        const SizedBox(height: 8),
                        const Divider(),
                        _buildInfoRow(
                          icon: Icons.route_outlined,
                          text: chuyen.tuyenDuongName,
                        ),
                        _buildInfoRow(
                          icon: Icons.calendar_today_outlined,
                          text: 'Ngày khởi hành: $ngay',
                        ),
                        _buildInfoRow(
                          icon: Icons.directions_bus_filled_outlined,
                          text: 'Loại xe: ${chuyen.loaiXeName}',
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