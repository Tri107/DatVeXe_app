import 'package:flutter/material.dart';
import '../../services/booking_service.dart';
import '../../models/trip_info.dart';
import 'payment_screen.dart';

class TripInfoScreen extends StatelessWidget {
  final int veId;
  const TripInfoScreen({super.key, required this.veId});

  @override
  Widget build(BuildContext context) {
    final svc = BookingService();

    return Scaffold(
      appBar: AppBar(title: const Text('Thông tin chuyến đi')),
      backgroundColor: const Color(0xFFF8F8F8),
      body: FutureBuilder<TripInfoDTO>(
        future: svc.buildTripInfoFromVe(veId),
        builder: (ctx, snap) {
          if (snap.connectionState != ConnectionState.done) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snap.hasError) {
            return Center(child: Text('Lỗi: ${snap.error}'));
          }
          final d = snap.data!;

          return Column(
            children: [
              Expanded(
                child: ListView(
                  padding: const EdgeInsets.all(16),
                  children: [
                    _sectionCard(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            d.nhaXe,
                            style: const TextStyle(
                                fontSize: 18, fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(height: 4),
                          Text('${d.loaiXe} • Biển số ${d.bienSo}',
                              style: const TextStyle(color: Colors.black54)),
                        ],
                      ),
                    ),
                    const SizedBox(height: 12),
                    _sectionCard(
                      title: 'Thông tin chuyến đi',
                      child: Column(
                        children: [
                          _tile('Giờ khởi hành', d.gioDi),
                          const Divider(height: 16),
                          _tile('Bến đi', d.benDi),
                          const SizedBox(height: 6),
                          _tile('Bến đến', d.benDen),
                        ],
                      ),
                    ),
                    const SizedBox(height: 12),
                    _sectionCard(
                      title: 'Thông tin liên hệ',
                      child: Column(
                        children: [
                          _tile('Họ tên', d.khName),
                          const SizedBox(height: 6),
                          _tile('Điện thoại', d.khSdt),
                          const SizedBox(height: 6),
                          _tile('Email', d.khEmail),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),
                  ],
                ),
              ),

              // --- Thanh tổng tiền cố định ---
              Container(
                padding: const EdgeInsets.fromLTRB(16, 12, 16, 20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      blurRadius: 8,
                      offset: const Offset(0, -3),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('Tạm tính',
                              style: TextStyle(
                                  color: Colors.black54, fontSize: 13)),
                          const SizedBox(height: 2),
                          Text(
                            _formatVND(d.giaVe),
                            style: const TextStyle(
                              fontSize: 18,
                              color: Colors.orange,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.amber,
                        foregroundColor: Colors.black87,
                        padding: const EdgeInsets.symmetric(
                            horizontal: 30, vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (_) => PaymentScreen(veId: veId)),
                        );
                      },
                      child: const Text(
                        'Tiếp tục',
                        style: TextStyle(fontSize: 16),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  // --- Widget phụ ---
  static Widget _sectionCard({String? title, required Widget child}) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 6,
              offset: const Offset(0, 2))
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (title != null)
            Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Text(
                title,
                style: const TextStyle(
                    fontSize: 16, fontWeight: FontWeight.w600),
              ),
            ),
          child,
        ],
      ),
    );
  }

  static Widget _tile(String key, String value) => Row(
    mainAxisAlignment: MainAxisAlignment.spaceBetween,
    children: [
      Text(key,
          style: const TextStyle(
              color: Colors.black54, fontSize: 14, height: 1.5)),
      Flexible(
        child: Text(value,
            textAlign: TextAlign.right,
            style:
            const TextStyle(fontSize: 15, fontWeight: FontWeight.w500)),
      ),
    ],
  );

  static String _formatVND(num n) {
    final s = n.toStringAsFixed(0);
    final re = RegExp(r'\B(?=(\d{3})+(?!\d))');
    return s.replaceAllMapped(re, (m) => '.') + ' đ';
  }
}
