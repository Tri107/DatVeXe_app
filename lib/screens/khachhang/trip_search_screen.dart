import 'package:datvexe_app/screens/khachhang/trip_info_screen.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../models/Chuyen.dart';
import '../../services/Trip_Service.dart';

class ChuyenListScreen extends StatefulWidget {
  const ChuyenListScreen({Key? key}) : super(key: key);

  @override
  _ChuyenListScreenState createState() => _ChuyenListScreenState();
}

class _ChuyenListScreenState extends State<ChuyenListScreen> {
  late Future<List<Chuyen>> _futureChuyenList;

  @override
  void initState() {
    super.initState();
    _futureChuyenList = ChuyenService.fetchChuyenList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Danh sách chuyến xe'),
        centerTitle: true,
      ),
      body: FutureBuilder<List<Chuyen>>(
        future: _futureChuyenList,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Lỗi: ${snapshot.error}'));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text('Không có chuyến nào.'));
          }

          final chuyenList = snapshot.data!;

          return ListView.builder(
            itemCount: chuyenList.length,
            itemBuilder: (context, index) {
              final chuyen = chuyenList[index];
              final ngay = DateFormat('dd/MM/yyyy HH:mm').format(chuyen.ngayGio);

              return GestureDetector(
                onTap: () {
                  //  Khi nhấn vào chuyến, chuyển sang TripInfoScreen
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => TripInfoScreen(veId: chuyen.chuyenId),
                    ),
                  );
                },
                child: Card(
                  margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  elevation: 3,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(14.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          chuyen.chuyenName,
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.blueAccent,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            const Icon(Icons.route, color: Colors.grey, size: 18),
                            const SizedBox(width: 6),
                            Expanded(child: Text('Tuyến đường: ${chuyen.tuyenDuongName}')),
                          ],
                        ),
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            const Icon(Icons.directions_bus, color: Colors.grey, size: 18),
                            const SizedBox(width: 6),
                            Expanded(child: Text('Biển số xe: ${chuyen.bienSo}')),
                          ],
                        ),
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            const Icon(Icons.person, color: Colors.grey, size: 18),
                            const SizedBox(width: 6),
                            Expanded(child: Text('Tài xế: ${chuyen.taiXeName}')),
                          ],
                        ),
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            const Icon(Icons.access_time, color: Colors.grey, size: 18),
                            const SizedBox(width: 6),
                            Expanded(child: Text('Thời gian: $ngay')),
                          ],
                        ),
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            const Icon(Icons.info_outline, color: Colors.grey, size: 18),
                            const SizedBox(width: 6),
                            Expanded(child: Text('Tình trạng: ${chuyen.tinhTrang}')),
                          ],
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
