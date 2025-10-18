class TinhThanhPho {
  final int tinhThanhPhoId;
  final String tinhThanhPhoName;

  TinhThanhPho({
    required this.tinhThanhPhoId,
    required this.tinhThanhPhoName,
  });

  factory TinhThanhPho.fromJson(Map<String, dynamic> json) {
    return TinhThanhPho(
      tinhThanhPhoId: json['TinhThanhPho_id'] is int
          ? json['TinhThanhPho_id']
          : int.tryParse(json['TinhThanhPho_id'].toString()) ?? 0,
      tinhThanhPhoName: json['TinhThanhPho_name'] ?? '',
    );
  }

  Map<String, dynamic> toJson() => {
    'TinhThanhPho_id': tinhThanhPhoId,
    'TinhThanhPho_name': tinhThanhPhoName,
  };
}
