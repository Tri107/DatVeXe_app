import 'TaiKhoan.dart';

class KhachHang {
  final int khachHangId;
  final String khachHangName;
  final String email;
  final String sdt;
  final TaiKhoan? taiKhoan;

  KhachHang({
    required this.khachHangId,
    required this.khachHangName,
    required this.email,
    required this.sdt,
    this.taiKhoan,
  });

  factory KhachHang.fromJson(Map<String, dynamic> json) {
    return KhachHang(
      khachHangId: json['KhachHang_id'] is int
          ? json['KhachHang_id']
          : int.tryParse(json['KhachHang_id'].toString()) ?? 0,
      khachHangName: json['KhachHang_name'] ?? '',
      email: json['email'] ?? '',
      sdt: json['SDT'] ?? '',
      taiKhoan: json['TaiKhoan'] != null
          ? TaiKhoan.fromJson(json['TaiKhoan'])
          : null,
    );
  }

  Map<String, dynamic> toJson() => {
    'KhachHang_id': khachHangId,
    'KhachHang_name': khachHangName,
    'email': email,
    'SDT': sdt,
    if (taiKhoan != null) 'TaiKhoan': taiKhoan!.toJson(),
  };
}
