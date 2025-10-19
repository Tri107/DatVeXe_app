class KhachHang {
  final int? khachHangId;
  final String khachHangName;
  final String email;
  final String sdt;

  KhachHang({
    this.khachHangId,
    required this.khachHangName,
    required this.email,
    required this.sdt,
  });

  // 🧭 Chuyển từ JSON sang Object
  factory KhachHang.fromJson(Map<String, dynamic> json) {
    return KhachHang(
      khachHangId: json['KhachHang_id'],
      khachHangName: json['KhachHang_name'] ?? '',
      email: json['email'] ?? '',
      sdt: json['SDT'] ?? '',
    );
  }

  // 🔄 Chuyển từ Object sang JSON
  Map<String, dynamic> toJson() {
    return {
      'KhachHang_id': khachHangId,
      'KhachHang_name': khachHangName,
      'email': email,
      'SDT': sdt,
    };
  }
}
