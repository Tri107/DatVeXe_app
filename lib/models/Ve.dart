import '../utils/json_cast.dart';

class Ve {
  final int veId;
  final num veGia;
  final String ngayTao; // giữ dạng string để hiển thị
  final String? ghiChu;
  final int khachHangId;
  final int chuyenId;

  Ve({
    required this.veId,
    required this.veGia,
    required this.ngayTao,
    required this.ghiChu,
    required this.khachHangId,
    required this.chuyenId,
  });

  factory Ve.fromJson(Map<String, dynamic> j) => Ve(
    veId: asInt(j['Ve_id']),
    veGia: asNum(j['Ve_gia']),
    ngayTao: asString(j['NgayTao'] ?? j['Create_at']),
    ghiChu: j['GhiChu']?.toString() ?? j['note']?.toString(),
    khachHangId: asInt(j['KhachHang_id']),
    chuyenId: asInt(j['Chuyen_id']),
  );
}
