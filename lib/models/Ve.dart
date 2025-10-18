class Ve {
  final int veId;
  final double veGia;
  final DateTime ngayTao;
  final String ghiChu;
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

  factory Ve.fromJson(Map<String, dynamic> json) {
    return Ve(
      veId: json['Ve_id'] is int
          ? json['Ve_id']
          : int.tryParse(json['Ve_id'].toString()) ?? 0,
      veGia: json['Ve_gia'] is num
          ? (json['Ve_gia'] as num).toDouble()
          : double.tryParse(json['Ve_gia'].toString()) ?? 0.0,
      ngayTao: json['NgayTao'] != null && json['NgayTao'] != ''
          ? DateTime.parse(json['NgayTao'])
          : DateTime(2000, 1, 1),
      ghiChu: json['GhiChu'] ?? '',
      khachHangId: json['KhachHang_id'] is int
          ? json['KhachHang_id']
          : int.tryParse(json['KhachHang_id'].toString()) ?? 0,
      chuyenId: json['Chuyen_id'] is int
          ? json['Chuyen_id']
          : int.tryParse(json['Chuyen_id'].toString()) ?? 0,
    );
  }

  Map<String, dynamic> toJson() => {
    'Ve_id': veId,
    'Ve_gia': veGia,
    'NgayTao': ngayTao.toIso8601String(),
    'GhiChu': ghiChu,
    'KhachHang_id': khachHangId,
    'Chuyen_id': chuyenId,
  };
}
