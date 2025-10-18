class TaiXe {
  final int taiXeId;
  final String taiXeName;
  final int taiXeAge;
  final String taiXeBangLai;
  final DateTime ngayVaoLam;
  final String sdt;

  TaiXe({
    required this.taiXeId,
    required this.taiXeName,
    required this.taiXeAge,
    required this.taiXeBangLai,
    required this.ngayVaoLam,
    required this.sdt,
  });

  factory TaiXe.fromJson(Map<String, dynamic> json) {
    return TaiXe(
      taiXeId: json['TaiXe_id'] is int
          ? json['TaiXe_id']
          : int.tryParse(json['TaiXe_id'].toString()) ?? 0,
      taiXeName: json['TaiXe_name'] ?? '',
      taiXeAge: json['TaiXe_age'] is int
          ? json['TaiXe_age']
          : int.tryParse(json['TaiXe_age'].toString()) ?? 0,
      taiXeBangLai: json['TaiXe_BangLai'] ?? '',
      ngayVaoLam: json['NgayVaoLam'] != null && json['NgayVaoLam'] != ''
          ? DateTime.parse(json['NgayVaoLam'])
          : DateTime(2000, 1, 1),
      sdt: json['SDT'] ?? '',
    );
  }

  Map<String, dynamic> toJson() => {
    'TaiXe_id': taiXeId,
    'TaiXe_name': taiXeName,
    'TaiXe_age': taiXeAge,
    'TaiXe_BangLai': taiXeBangLai,
    'NgayVaoLam': ngayVaoLam.toIso8601String(),
    'SDT': sdt,
  };
}
