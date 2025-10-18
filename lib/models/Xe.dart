class Xe {
  final int xeId;
  final String bienSo;
  final String trangThai;
  final int loaiXeId;

  Xe({
    required this.xeId,
    required this.bienSo,
    required this.trangThai,
    required this.loaiXeId,
  });

  factory Xe.fromJson(Map<String, dynamic> json) {
    return Xe(
      xeId: json['Xe_id'] is int
          ? json['Xe_id']
          : int.tryParse(json['Xe_id'].toString()) ?? 0,
      bienSo: json['Bien_so'] ?? '',
      trangThai: json['Trang_thai'] ?? '',
      loaiXeId: json['LoaiXe_id'] is int
          ? json['LoaiXe_id']
          : int.tryParse(json['LoaiXe_id'].toString()) ?? 0,
    );
  }

  Map<String, dynamic> toJson() => {
    'Xe_id': xeId,
    'Bien_so': bienSo,
    'Trang_thai': trangThai,
    'LoaiXe_id': loaiXeId,
  };
}
