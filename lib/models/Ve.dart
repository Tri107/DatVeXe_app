// lib/models/Ve.dart

class Ve {
  final int veId;
  final double veGia;
  final String ngayTao;
  final String ghiChu;
  final int khachHangId;
  final int chuyenId;
  final String khachHangName;
  final String chuyenName;
  final String SDT;
  final DateTime? ngayGio;
  final String benDi;
  final String benDen;

  Ve({
    required this.veId,
    required this.veGia,
    required this.ngayTao,
    required this.ghiChu,
    required this.khachHangId,
    required this.chuyenId,
    required this.khachHangName,
    required this.chuyenName,
    required this.SDT,
    this.ngayGio,
    required this.benDi,
    required this.benDen,
  });

  factory Ve.fromJson(Map<String, dynamic> json) {
    num giaVeParsed = 0;
    if (json['Ve_gia'] is String) {
      giaVeParsed = num.tryParse(json['Ve_gia']) ?? 0;
    } else if (json['Ve_gia'] is num) {
      giaVeParsed = json['Ve_gia'];
    }

    DateTime? ngayGioParsed;
    if (json['NgayGio'] != null && json['NgayGio'] is String) {
      ngayGioParsed = DateTime.tryParse(json['NgayGio']);
    }

    return Ve(
      veId: json['Ve_id'] as int? ?? 0,
      veGia: giaVeParsed.toDouble(),
      ngayTao: json['NgayTao'] as String? ?? '',
      ghiChu: json['GhiChu'] as String? ?? '',
      khachHangId: json['KhachHang_id'] as int? ?? 0,
      chuyenId: json['Chuyen_id'] as int? ?? 0,
      khachHangName: json['KhachHang_name'] as String? ?? 'N/A',
      chuyenName: json['Chuyen_name'] as String? ?? 'N/A',
      SDT: json['SDT'] as String? ?? 'N/A',
      ngayGio: ngayGioParsed,
      benDi: json['BenDi'] as String? ?? 'N/A',
      benDen: json['BenDen'] as String? ?? 'N/A',
    );
  }
}
