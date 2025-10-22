// lib/services/Ve_Service.dart
import '../config/api.dart';

class VeService {
  static Future<int> createVe({
    required int chuyenId,
    required int khachHangId,
    required double giaVe,
  }) async {
    try {
      print("--- [VeService] Đang chuẩn bị tạo vé với dữ liệu: ChuyenID=$chuyenId, KhachHangID=$khachHangId, Gia=$giaVe ---");

      final Map<String, dynamic> veData = {
        'Ve_gia': giaVe,
        'NgayTao': DateTime.now().toIso8601String(),
        'GhiChu': 'Đặt vé qua ứng dụng',
        'KhachHang_id': khachHangId,
        'Chuyen_id': chuyenId,
      };

      // === SỬA LỖI Ở ĐÂY ===
      // Endpoint đúng của bạn là '/ve', không phải '/ve/create'
      final response = await Api.post('/ve', veData);

      if (response.data != null && response.data['Ve_id'] != null) {
        final int veId = response.data['Ve_id'];
        print('--- [VeService] TẠO VÉ THÀNH CÔNG với ID: $veId ---');
        return veId;
      } else {
        print('--- [VeService] Lỗi: Phản hồi từ backend không chứa Ve_id. Data: ${response.data}');
        throw Exception('Phản hồi từ server không hợp lệ khi tạo vé.');
      }
    } catch (e) {
      print('--- [VeService] LỖI NGHIÊM TRỌNG KHI TẠO VÉ: $e ---');
      rethrow;
    }
  }
}
