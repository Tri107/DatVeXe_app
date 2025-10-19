import 'package:flutter/material.dart';
import '../../config/api.dart';
import '../../models/trip_info.dart';
import 'payment_screen.dart';

class TripInfoScreen extends StatefulWidget {
  final int veId; // ví dụ: 1
  const TripInfoScreen({super.key, required this.veId});

  @override
  State<TripInfoScreen> createState() => _TripInfoScreenState();
}

class _TripInfoScreenState extends State<TripInfoScreen> {
  late Future<TripInfoDTO> _future;

  @override
  void initState() {
    super.initState();
    _future = _load(); // cache 1 lần
  }

  Future<TripInfoDTO> _load() async {
    final r = await Api.get('/booking/${widget.veId}/summary');
    return TripInfoDTO.fromSummary(r.data);
  }

  String _vnd(num n) =>
      n.toStringAsFixed(0).replaceAllMapped(RegExp(r'\B(?=(\d{3})+(?!\d))'), (m) => '.') + ' đ';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Thông tin chuyến đi')),
      body: FutureBuilder<TripInfoDTO>(
        future: _future,
        builder: (ctx, snap) {
          if (snap.connectionState != ConnectionState.done) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snap.hasError) return Center(child: Text('Lỗi: ${snap.error}'));
          final d = snap.data!;

          return Column(
            children: [
              Expanded(
                child: ListView(
                  padding: const EdgeInsets.all(16),
                  children: [
                    Text(d.nhaXe, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                    Text('${d.loaiXe} • Biển số ${d.bienSo}'),
                    const SizedBox(height: 12),
                    _tile('Giờ khởi hành', d.gioDi),
                    _tile('Bến đi', d.benDi),
                    _tile('Bến đến', d.benDen),
                    const Divider(height: 32),
                    const Text('Thông tin liên hệ', style: TextStyle(fontWeight: FontWeight.bold)),
                    _tile('Họ tên', d.khName),
                    _tile('Điện thoại', d.khSdt),
                    _tile('Email', d.khEmail),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                      const Text('Tạm tính', style: TextStyle(fontWeight: FontWeight.bold)),
                      Text(_vnd(d.price), style: const TextStyle(fontSize: 18, color: Colors.orange, fontWeight: FontWeight.bold)),
                    ]),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.amber,
                        foregroundColor: Colors.black87,
                        padding: const EdgeInsets.symmetric(horizontal: 26, vertical: 12),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                      ),
                      onPressed: () {
                        Navigator.push(context,
                            MaterialPageRoute(builder: (_) => PaymentScreen(veId: d.ticketId)));
                      },
                      child: const Text('Tiếp tục'),
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

  Widget _tile(String k, String v) => ListTile(
    dense: true,
    contentPadding: EdgeInsets.zero,
    title: Text(k, style: const TextStyle(color: Colors.black54)),
    trailing: Text(v, textAlign: TextAlign.right),
  );
}
