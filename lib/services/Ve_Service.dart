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

  // Lấy chi tiết 1 vé theo ID
  static Future<Map<String, dynamic>> getVeById(int veId) async {
    try {
      final response = await Api.get('/ve/$veId');
      if (response.statusCode == 200) {
        return response.data;
      } else {
        throw Exception('Không thể tải chi tiết vé (${response.statusCode})');
      }
    } catch (e) {
      print(' [VeService] Lỗi tải vé: $e');
      rethrow;
    }
  }

  ///  Lấy danh sách vé theo SĐT khách hàng
  static Future<List<Map<String, dynamic>>> getByUser(String sdt) async {
    try {
      print('--- [VeService] Đang tải danh sách vé của user $sdt ---');
      final response = await Api.get('/ve/user/$sdt');

      if (response.statusCode == 200 && response.data is List) {
        final List<Map<String, dynamic>> veList =
        List<Map<String, dynamic>>.from(response.data);
        print('--- [VeService] Tải ${veList.length} vé thành công ---');
        return veList;
      } else {
        throw Exception('Phản hồi không hợp lệ từ server khi lấy danh sách vé.');
      }
    } catch (e) {
      print(' [VeService] Lỗi khi tải vé của user: $e');
      rethrow;
    }
  }
}
