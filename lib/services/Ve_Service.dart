// lib/services/Ve_Service.dart
import '../config/api.dart';

class VeService {
  /// Hàm tạo một vé mới.
  /// Trả về ID của vé vừa được tạo.
  static Future<int> createVe({
    required int chuyenId,
    required int khachHangId,
    required double giaVe,
  }) async {
    try {
      print('--- [VeService] Đang tạo vé...');

      // SỬA: Bỏ dấu '?' để đảm bảo veData không bao giờ là null
      final Map<String, dynamic> veData = {
        'Ve_gia': giaVe,
        'NgayTao': DateTime.now().toIso8601String(),
        'GhiChu': 'Đặt vé qua ứng dụng',
        'KhachHang_id': khachHangId,
        'Chuyen_id': chuyenId,
      };

      // SỬA: Loại bỏ nhãn 'data:' để khớp với định nghĩa Api.post
      final response = await Api.post('/ve/create', veData);

      final int veId = response.data['Ve_id'];
      print('--- [VeService] Tạo vé thành công với ID: $veId ---');
      return veId;

    } catch (e) {
      print('--- [VeService] Lỗi khi tạo vé: $e');
      // Ném lại lỗi để UI có thể bắt và hiển thị thông báo
      rethrow;
    }
  }
}
