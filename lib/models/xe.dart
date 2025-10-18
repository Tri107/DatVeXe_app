import '../utils/json_cast.dart';

class Xe {
  final int id;
  final String bienSo;
  final int loaiXeId;

  Xe({required this.id, required this.bienSo, required this.loaiXeId});

  factory Xe.fromJson(Map<String, dynamic> j) => Xe(
    id: asInt(j['Xe_id']),
    bienSo: asString(j['Bien_so']),
    loaiXeId: asInt(j['LoaiXe_id']),
  );
}
