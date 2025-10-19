class TramDungChan {
  final int tramDungChanId;
  final String tramDungChanName;
  final int thoiGianDung;

  TramDungChan({
    required this.tramDungChanId,
    required this.tramDungChanName,
    required this.thoiGianDung,
  });

  factory TramDungChan.fromJson(Map<String, dynamic> json) {
    return TramDungChan(
      tramDungChanId: json['TramDungChan_id'] is int
          ? json['TramDungChan_id']
          : int.tryParse(json['TramDungChan_id'].toString()) ?? 0,
      tramDungChanName: json['TramDungChan_name'] ?? '',
      thoiGianDung: json['Thoi_gian_dung'] is int
          ? json['Thoi_gian_dung']
          : int.tryParse(json['Thoi_gian_dung'].toString()) ?? 0,
    );
  }

  Map<String, dynamic> toJson() => {
    'TramDungChan_id': tramDungChanId,
    'TramDungChan_name': tramDungChanName,
    'Thoi_gian_dung': thoiGianDung,
  };
}
