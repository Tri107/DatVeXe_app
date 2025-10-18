class TripInfoDTO {
  final String nhaXe;         // từ LoaiXe/Xe nếu bạn có tên hãng riêng thì thay
  final String loaiXe;
  final String bienSo;
  final String gioDi;
  final String benDi;
  final String benDen;
  final num giaVe;
  final String khName;
  final String khSdt;
  final String khEmail;

  TripInfoDTO({
    required this.nhaXe,
    required this.loaiXe,
    required this.bienSo,
    required this.gioDi,
    required this.benDi,
    required this.benDen,
    required this.giaVe,
    required this.khName,
    required this.khSdt,
    required this.khEmail,
  });
}
