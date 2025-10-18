// models/KhachHang.dart
import '../utils/json_cast.dart';

class KhachHang {
  final int khachHangId;
  final String khachHangName;
  final String email;
  final String sdt;

  KhachHang({
    required this.khachHangId,
    required this.khachHangName,
    required this.email,
    required this.sdt,
  });

  factory KhachHang.fromJson(Map<String, dynamic> json) => KhachHang(
    khachHangId: json['KhachHang_id'],
    khachHangName: json['KhachHang_name'],
    email: json['email'],
    sdt: json['SDT'],
  );
}
