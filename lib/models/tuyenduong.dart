import '../utils/json_cast.dart';

class TuyenDuong {
  final int id;
  final num quangDuong;
  final String thoiGian; // TIME/DATETIME dưới dạng string
  final int benDi;
  final int benDen;

  TuyenDuong({
    required this.id,
    required this.quangDuong,
    required this.thoiGian,
    required this.benDi,
    required this.benDen,
  });

  factory TuyenDuong.fromJson(Map<String, dynamic> j) => TuyenDuong(
    id: asInt(j['TuyenDuong_id']),
    quangDuong: asNum(j['Quang_duong']),
    thoiGian: asString(j['Thoi_gian']),
    benDi: asInt(j['Ben_di']),
    benDen: asInt(j['Ben_den']),
  );
}
