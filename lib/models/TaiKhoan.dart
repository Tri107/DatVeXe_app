class TaiKhoan{
  final String sdt;
  final String role;

  TaiKhoan({
    required this.sdt,
    required this.role,
});

  factory TaiKhoan.fromJson(Map<String, dynamic> json) {
    return TaiKhoan(
      sdt: json['SDT'] ?? '',
      role: json['role'] ?? '',
    );
  }

  Map<String, dynamic> toJson() => {
    'SDT': sdt,
    'role': role,
  };

}


