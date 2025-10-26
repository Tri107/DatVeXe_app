import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../models/Chuyen.dart';
import '../../services/Trip_Service.dart';
import '../../services/Auth_Services.dart';
import '../../themes/gradient.dart';
import 'map_screen.dart';
import 'trip_customer_info_screen.dart';

class TripInfoScreen extends StatefulWidget {
  final int chuyenId;
  final String? phone;

  const TripInfoScreen({super.key, required this.chuyenId, this.phone});

  @override
  State<TripInfoScreen> createState() => _TripInfoScreenState();
}

class _TripInfoScreenState extends State<TripInfoScreen> {
  late Future<Chuyen> _futureChuyen;
  String? _userPhone;
  final double giaVe = 200000;

  @override
  void initState() {
    super.initState();
    _futureChuyen = ChuyenService.fetchTripById(widget.chuyenId);
    _loadUserInfo();
  }

  Future<void> _loadUserInfo() async {
    try {
      final user = await AuthService.getCurrentUser();
      if (user != null) {
        setState(() => _userPhone = user.sdt);
      } else {
        final prefs = await SharedPreferences.getInstance();
        setState(() => _userPhone = prefs.getString('user_phone'));
      }
    } catch (e) {
      print("⚠️ Lỗi load user: $e");
    }
  }

  String _formatDateTime(DateTime dt) =>
      DateFormat('HH:mm - EEEE, dd/MM/yyyy', 'vi_VN').format(dt);

  String _vnd(num n) =>
      NumberFormat.currency(locale: 'vi_VN', symbol: 'đ').format(n);

  Future<void> _handleContinue() async {
    final userPhone = _userPhone ?? widget.phone;
    if (userPhone == null || userPhone.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Không tìm thấy số điện thoại người dùng!'),
        ),
      );
      return;
    }
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => TripCustomerInfoScreen(
          chuyenId: widget.chuyenId,
          gia: giaVe,
          phone: userPhone,
        ),
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
          decoration: const BoxDecoration(gradient: AppGradients.primary),
          child: AppBar(
            backgroundColor: Colors.transparent,
            elevation: 0,
            centerTitle: true,
            title: const Text(
              'Chi tiết chuyến đi',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ),
        ),
      ),
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

          return Stack(
            children: [
              Column(
                children: [
                  Expanded(
                    child: ListView(
                      padding: const EdgeInsets.all(16),
                      children: [
                        _buildHeaderCard(chuyen),
                        const SizedBox(height: 16),
                        _buildTripInfoCard(chuyen),
                        const SizedBox(height: 16),
                        _buildVehicleInfoCard(chuyen),
                        const SizedBox(height: 120),
                      ],
                    ),
                  ),
                  _buildPaymentSection(),
                ],
              ),

              // Nút xem bản đồ nổi
              Positioned(
                right: 24,
                bottom: 110,
                child: FloatingActionButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => MapScreen(
                          startName: chuyen.benDiName,
                          endName: chuyen.benDenName,
                        ),
                      ),
                    );
                  },
                  backgroundColor: Colors.blueAccent,
                  elevation: 6,
                  child: const Icon(Icons.map_outlined, color: Colors.white),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildHeaderCard(Chuyen chuyen) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.grey[100],
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.blueAccent.withOpacity(0.3)),
      ),
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            chuyen.chuyenName,
            style: const TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
            softWrap: true,
          ),
          const SizedBox(height: 8),
          Text(
            _formatDateTime(chuyen.ngayGio),
            style: const TextStyle(color: Colors.black54, fontSize: 15),
          ),
          const SizedBox(height: 10),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Icon(Icons.location_on, color: Colors.blueAccent, size: 20),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  '${chuyen.benDiName} → ${chuyen.benDenName}',
                  style: const TextStyle(
                    color: Colors.black87,
                    fontSize: 15,
                    fontWeight: FontWeight.w500,
                  ),
                  softWrap: true,
                  overflow: TextOverflow.visible,
                  maxLines: null,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildTripInfoCard(Chuyen chuyen) {
    return _buildSectionCard(
      title: 'Thông tin chuyến đi',
      icon: Icons.event_available_outlined,
      children: [
        _infoRow(Icons.route_outlined, 'Tuyến đường', chuyen.tuyenDuongName),
        _infoRow(Icons.location_on_outlined, 'Điểm đi', chuyen.diemDi),
        _infoRow(Icons.flag_outlined, 'Điểm đến', chuyen.diemDen),
        _infoRow(
          Icons.chair_outlined,
          'Tình trạng',
          chuyen.tinhTrang,
          valueColor: chuyen.tinhTrang.toLowerCase().contains('còn')
              ? Colors.green
              : Colors.red,
        ),
      ],
    );
  }

  Widget _buildVehicleInfoCard(Chuyen chuyen) {
    return _buildSectionCard(
      title: 'Thông tin phương tiện',
      icon: Icons.directions_bus_filled,
      children: [
        _infoRow(Icons.directions_bus, 'Loại xe', chuyen.loaiXeName),
        _infoRow(Icons.confirmation_number_outlined, 'Biển số', chuyen.bienSo),
        _infoRow(Icons.person_outline, 'Tài xế', chuyen.taiXeName),
      ],
    );
  }

  Widget _buildSectionCard({
    required String title,
    required IconData icon,
    required List<Widget> children,
  }) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, color: Colors.blueAccent, size: 22),
                const SizedBox(width: 8),
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const Divider(height: 20),
            ...children,
          ],
        ),
      ),
    );
  }

  Widget _infoRow(
    IconData icon,
    String label,
    String value, {
    Color? valueColor,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: Colors.grey.shade600, size: 22),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey.shade700,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  value,
                  style: TextStyle(
                    fontSize: 15.5,
                    fontWeight: FontWeight.bold,
                    color: valueColor ?? Colors.black87,
                  ),
                  softWrap: true,
                  overflow: TextOverflow.visible,
                  maxLines: null,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPaymentSection() {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 14, 16, 24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(16),
          topRight: Radius.circular(16),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 10,
            offset: const Offset(0, -2),
          ),
        ],
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
                  fontSize: 22,
                  color: Colors.deepOrange,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          ElevatedButton(
            onPressed: _handleContinue,
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.amber,
              foregroundColor: Colors.black87,
              padding: const EdgeInsets.symmetric(horizontal: 48, vertical: 14),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14),
              ),
              textStyle: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            child: const Text('Tiếp tục'),
          ),
        ],
      ),
    );
  }
}
