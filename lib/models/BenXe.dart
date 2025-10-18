class BenXe {
  final int benXeId;
  final String benXeName;
  final int tinhThanhPhoId;

  BenXe({
    required this.benXeId,
    required this.benXeName,
    required this.tinhThanhPhoId,
  });

  factory BenXe.fromJson(Map<String, dynamic> json) {
    return BenXe(
      benXeId: json['BenXe_id'] is int
          ? json['BenXe_id']
          : int.tryParse(json['BenXe_id'].toString()) ?? 0,
      benXeName: json['BenXe_name'] ?? '',
      tinhThanhPhoId: json['TinhThanhPho_id'] is int
          ? json['TinhThanhPho_id']
          : int.tryParse(json['TinhThanhPho_id'].toString()) ?? 0,
    );
  }

  Map<String, dynamic> toJson() => {
    'BenXe_id': benXeId,
    'BenXe_name': benXeName,
    'TinhThanhPho_id': tinhThanhPhoId,
  };
}
