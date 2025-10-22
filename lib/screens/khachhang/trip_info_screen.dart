// lib/screens/khachhang/trip_info_screen.dart
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart'; // ✅ thêm import
import '../../models/Chuyen.dart';
import '../../services/Trip_Service.dart';
import 'map_screen.dart';
import 'trip_customer_info_screen.dart'; // ✅ import đúng màn hình

class TripInfoScreen extends StatefulWidget {
  final int chuyenId;
  final String? phone;
  const TripInfoScreen({super.key, required this.chuyenId,this.phone});

  @override
  State<TripInfoScreen> createState() => _TripInfoScreenState();
}

class _TripInfoScreenState extends State<TripInfoScreen> {
  late Future<Chuyen> _futureChuyen;

  // GIẢ ĐỊNH GIÁ VÉ - bạn có thể thay bằng giá thực tế từ API chuyến đi
  final double giaVe = 200000;

  @override
  void initState() {
    super.initState();
    _futureChuyen = ChuyenService.fetchTripById(widget.chuyenId);
  }

  String _formatDateTime(DateTime dt) {
    return DateFormat('HH:mm - EEEE, dd/MM/yyyy', 'vi_VN').format(dt);
  }

  String _vnd(num n) =>
      NumberFormat.currency(locale: 'vi_VN', symbol: 'đ').format(n);

  // ✅ HÀM MỚI: Lấy SĐT từ SharedPreferences và chuyển sang màn TripCustomerInfo
  Future<void> _handleContinue() async {
    final userPhone = widget.phone;

    if (userPhone == null || userPhone.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Không tìm thấy số điện thoại người dùng!')),
      );
      return;
    }

    print('📱 [TripInfoScreen] Truyền SDT qua TripCustomerInfo: $userPhone');

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => TripCustomerInfoScreen(
          chuyenId: widget.chuyenId,
          gia: giaVe,
          phone: userPhone, // ✅ truyền đúng dữ liệu nhận được từ Login
        ),
      ),
    );
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Thông tin chuyến đi'),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 1,
      ),
      backgroundColor: Colors.grey[200],
      body: FutureBuilder<Chuyen>(
        future: _futureChuyen,
        builder: (ctx, snap) {
          if (snap.connectionState != ConnectionState.done) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snap.hasError) {
            return Center(child: Text('Lỗi: ${snap.error}'));
          }

          final chuyen = snap.data!;

          return Column(
            children: [
              Expanded(
                child: ListView(
                  padding: const EdgeInsets.fromLTRB(12, 12, 12, 0),
                  children: [
                    _buildTripInfoCard(chuyen),
                    const SizedBox(height: 12),
                    _buildVehicleInfoCard(chuyen),
                    const SizedBox(height: 20),
                    ElevatedButton.icon(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => MapScreen(
                              startName: chuyen.diemDi,
                              endName: chuyen.diemDen,
                            ),
                          ),
                        );
                      },
                      icon: const Icon(Icons.map_outlined),
                      label: const Text('Xem Bản Đồ Đường Đi'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blueAccent,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        textStyle: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    const SizedBox(height: 100),
                  ],
                ),
              ),
              _buildPaymentSection(),
            ],
          );
        },
      ),
    );
  }

  Widget _buildPaymentSection() {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            spreadRadius: 0,
            blurRadius: 10,
          ),
        ],
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(16),
          topRight: Radius.circular(16),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Giá vé', style: TextStyle(color: Colors.black54)),
              Text(
                _vnd(giaVe),
                style: const TextStyle(
                  fontSize: 20,
                  color: Colors.deepOrange,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.amber,
              foregroundColor: Colors.black87,
              padding:
              const EdgeInsets.symmetric(horizontal: 48, vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              textStyle: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            onPressed: _handleContinue, // ✅ Sửa: dùng hàm mới
            child: const Text('Tiếp tục'),
          ),
        ],
      ),
    );
  }

  Widget _buildTripInfoCard(Chuyen chuyen) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              chuyen.chuyenName,
              style: Theme.of(context)
                  .textTheme
                  .headlineSmall
                  ?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            _infoRow(Icons.event_available_outlined, 'Khởi hành',
                _formatDateTime(chuyen.ngayGio)),
            const Divider(height: 20),
            _infoRow(Icons.route_outlined, 'Tuyến đường', chuyen.tuyenDuongName),
            const SizedBox(height: 8),
            _infoRow(Icons.location_on_outlined, 'Điểm đi', chuyen.diemDi),
            _infoRow(Icons.flag_outlined, 'Điểm đến', chuyen.diemDen),
            const Divider(height: 20),
            _infoRow(
              Icons.chair_outlined,
              'Tình trạng',
              chuyen.tinhTrang,
              valueColor: chuyen.tinhTrang.toLowerCase() == 'còn chỗ'
                  ? Colors.green.shade700
                  : Colors.red.shade700,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildVehicleInfoCard(Chuyen chuyen) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Thông tin phương tiện',
                style: Theme.of(context).textTheme.titleLarge),
            const Divider(height: 20),
            _infoRow(Icons.directions_bus_outlined, 'Loại xe', chuyen.loaiXeName),
            _infoRow(Icons.pin_outlined, 'Biển số', chuyen.bienSo),
            _infoRow(Icons.person_outline, 'Tài xế', chuyen.taiXeName),
          ],
        ),
      ),
    );
  }

  Widget _infoRow(IconData icon, String label, String value,
      {Color? valueColor}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: Colors.grey.shade600, size: 22),
          const SizedBox(width: 16),
          Text('$label:',
              style: TextStyle(fontSize: 15, color: Colors.grey.shade800)),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              value,
              textAlign: TextAlign.right,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: valueColor ?? Colors.black87,
              ),
              softWrap: true,
            ),
          ),
        ],
      ),
    );
  }
}
