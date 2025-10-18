class Chuyen {
  final int chuyenId;
  final String chuyenName;
  final String tinhTrang;
  final DateTime ngayGio;
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

  factory Chuyen.fromJson(Map<String, dynamic> json) {
    return Chuyen(
      chuyenId: json['Chuyen_id'] is int
          ? json['Chuyen_id']
          : int.tryParse(json['Chuyen_id'].toString()) ?? 0,
      chuyenName: json['Chuyen_name'] ?? '',
      tinhTrang: json['Tinh_Trang'] ?? '',
      ngayGio: json['Ngay_gio'] != null && json['Ngay_gio'] != ''
          ? DateTime.parse(json['Ngay_gio'])
          : DateTime(2000, 1, 1),
      tuyenDuongId: json['TuyenDuong_id'] is int
          ? json['TuyenDuong_id']
          : int.tryParse(json['TuyenDuong_id'].toString()) ?? 0,
      xeId: json['Xe_id'] is int
          ? json['Xe_id']
          : int.tryParse(json['Xe_id'].toString()) ?? 0,
      taiXeId: json['TaiXe_id'] is int
          ? json['TaiXe_id']
          : int.tryParse(json['TaiXe_id'].toString()) ?? 0,
    );
  }

  Map<String, dynamic> toJson() => {
    'Chuyen_id': chuyenId,
    'Chuyen_name': chuyenName,
    'Tinh_Trang': tinhTrang,
    'Ngay_gio': ngayGio.toIso8601String(),
    'TuyenDuong_id': tuyenDuongId,
    'Xe_id': xeId,
    'TaiXe_id': taiXeId,
  };
}
