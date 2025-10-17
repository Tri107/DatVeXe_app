import '../utils/json_cast.dart';

class Chuyen {
  final int chuyenId;
  final String chuyenName;
  final String tinhTrang;
  final String ngayGio;     // string cho đơn giản
  final int tuyenDuongId;
  final int xeId;
  final int taiXeId;

  Chuyen({
    required this.chuyenId,
    required this.chuyenName,
    required this.tinhTrang,
    required this.ngayGio,
    required this.tuyenDuongId,
    required this.xeId,
    required this.taiXeId,
  });

  factory Chuyen.fromJson(Map<String, dynamic> j) => Chuyen(
    chuyenId: asInt(j['Chuyen_id']),
    chuyenName: asString(j['Chuyen_name']),
    tinhTrang: asString(j['Tinh_Trang']),
    ngayGio: asString(j['Ngay_gio']),
    tuyenDuongId: asInt(j['TuyenDuong_id']),
    xeId: asInt(j['Xe_id']),
    taiXeId: asInt(j['TaiXe_id']),
  );
}
