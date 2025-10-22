// lib/models/Chuyen.dart

class Chuyen {
  final int chuyenId;
  final String chuyenName;
  final String tuyenDuongName;
  final String diemDi;
  final String diemDen;
  final String tinhTrang;
  final DateTime ngayGio;
  final String loaiXeName;
  final String bienSo;
  final String taiXeName;

  Chuyen({
    required this.chuyenId,
    required this.chuyenName,
    required this.tuyenDuongName,
    required this.diemDi,
    required this.diemDen,
    required this.tinhTrang,
    required this.ngayGio,
    required this.loaiXeName,
    required this.bienSo,
    required this.taiXeName,
  });

  factory Chuyen.fromJson(Map<String, dynamic> json) {
    // KIỂM TRA KỸ CÁC KHÓA (KEY) TRONG NGOẶC VUÔNG '[]'
    // CHÚNG PHẢI KHỚP TUYỆT ĐỐI VỚI JSON TỪ API
    return Chuyen(
      chuyenId: json['Chuyen_id'],
      chuyenName: json['Chuyen_name'] ?? 'Không có tên',
      tuyenDuongName: json['TuyenDuong_name'] ?? 'Không rõ', // Lỗi có thể ở đây
      diemDi: json['DiemDi'] ?? 'Không rõ',                   // hoặc ở đây
      diemDen: json['DiemDen'] ?? 'Không rõ',                 // hoặc ở đây
      tinhTrang: json['Tinh_Trang'] ?? 'Không rõ',
      ngayGio: DateTime.parse(json['Ngay_gio']),
      loaiXeName: json['LoaiXe_name'] ?? 'Không rõ',
      bienSo: json['Bien_so'] ?? 'Không rõ',
      taiXeName: json['TaiXe_name'] ?? 'Không rõ',
    );
  }
}
