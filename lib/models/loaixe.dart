import '../utils/json_cast.dart';

class LoaiXe {
  final int id;
  final String name;
  final int sucChua;

  LoaiXe({required this.id, required this.name, required this.sucChua});

  factory LoaiXe.fromJson(Map<String, dynamic> j) => LoaiXe(
    id: asInt(j['LoaiXe_id']),
    name: asString(j['LoaiXe_name']),
    sucChua: asInt(j['Suc_chua']),
  );
}
