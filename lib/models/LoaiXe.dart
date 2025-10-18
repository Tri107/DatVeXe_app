class LoaiXe {
  final int loaiXeId;
  final String loaiXeName;
  final int sucChua;

  LoaiXe({
    required this.loaiXeId,
    required this.loaiXeName,
    required this.sucChua,
  });

  factory LoaiXe.fromJson(Map<String, dynamic> json) {
    return LoaiXe(
      loaiXeId: json['LoaiXe_id'] is int
          ? json['LoaiXe_id']
          : int.tryParse(json['LoaiXe_id'].toString()) ?? 0,
      loaiXeName: json['LoaiXe_name'] ?? '',
      sucChua: json['Suc_chua'] is int
          ? json['Suc_chua']
          : int.tryParse(json['Suc_chua'].toString()) ?? 0,
    );
  }

  Map<String, dynamic> toJson() => {
    'LoaiXe_id': loaiXeId,
    'LoaiXe_name': loaiXeName,
    'Suc_chua': sucChua,
  };
}
