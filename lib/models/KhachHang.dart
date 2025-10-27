// lib/models/KhachHang.dart

class KhachHang {
  // SỬA: Đổi tên thuộc tính cho khớp với model và code hiện tại của bạn
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

  factory KhachHang.fromJson(Map<String, dynamic> json) {
    // SỬA: Cập nhật lại các khóa (key) để khớp 100% với JSON từ API
    return KhachHang(
      khachHangId: json['KhachHang_id'],
      khachHangName: json['KhachHang_name'] ?? '',
      email: json['email'] ?? '',
      sdt: json['SDT'] ?? '',
    );
  }
}
