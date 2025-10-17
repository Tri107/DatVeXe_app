import '../utils/json_cast.dart';

class BenXe {
  final int id;
  final String name;

  BenXe({required this.id, required this.name});

  factory BenXe.fromJson(Map<String, dynamic> j) =>
      BenXe(id: asInt(j['BenXe_id']), name: asString(j['BenXe_name']));
}
