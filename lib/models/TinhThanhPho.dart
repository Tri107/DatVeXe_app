class TinhThanhPho {
  final int id;
  final String name;

  TinhThanhPho({required this.id, required this.name});

  factory TinhThanhPho.fromJson(Map<String, dynamic> json) {
    return TinhThanhPho(
      id: json['tinhThanhPho_id'] ?? json['id'] ?? 0,
      name: json['tinhThanhPho_name'] ?? json['name'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'tinhThanhPho_id': id,
      'tinhThanhPho_name': name,
    };
  }
}
