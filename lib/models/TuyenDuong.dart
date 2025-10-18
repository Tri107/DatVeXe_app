class TuyenDuong {
  final int tuyenDuongId;
  final int quangDuong;
  final DateTime thoiGian;
  final int benDi;
  final int benDen;

  TuyenDuong({
    required this.tuyenDuongId,
    required this.quangDuong,
    required this.thoiGian,
    required this.benDi,
    required this.benDen,
  });

  factory TuyenDuong.fromJson(Map<String, dynamic> json) {
    return TuyenDuong(
      tuyenDuongId: json['TuyenDuong_id'] is int
          ? json['TuyenDuong_id']
          : int.tryParse(json['TuyenDuong_id'].toString()) ?? 0,
      quangDuong: json['Quang_duong'] is int
          ? json['Quang_duong']
          : int.tryParse(json['Quang_duong'].toString()) ?? 0,
      thoiGian: json['Thoi_gian'] != null && json['Thoi_gian'] != ''
          ? DateTime.parse(json['Thoi_gian'])
          : DateTime(2000, 1, 1),
      benDi: json['Ben_di'] is int
          ? json['Ben_di']
          : int.tryParse(json['Ben_di'].toString()) ?? 0,
      benDen: json['Ben_den'] is int
          ? json['Ben_den']
          : int.tryParse(json['Ben_den'].toString()) ?? 0,
    );
  }

  Map<String, dynamic> toJson() => {
    'TuyenDuong_id': tuyenDuongId,
    'Quang_duong': quangDuong,
    'Thoi_gian': thoiGian.toIso8601String(),
    'Ben_di': benDi,
    'Ben_den': benDen,
  };
}
