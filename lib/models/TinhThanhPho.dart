class TinhThanhPho {
  final int tinhThanhPhoId;
  final String tinhThanhPhoName;

  TinhThanhPho({
    required this.tinhThanhPhoId,
    required this.tinhThanhPhoName,
  });

  factory TinhThanhPho.fromJson(Map<String, dynamic> json) {
    return TinhThanhPho(
      tinhThanhPhoId: json['TinhThanhPho_id'] ?? json['tinhThanhPho_id'] ?? 0,
      tinhThanhPhoName:
      json['TinhThanhPho_name'] ?? json['tinhThanhPho_name'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'TinhThanhPho_id': tinhThanhPhoId,
      'TinhThanhPho_name': tinhThanhPhoName,
    };
  }
}
