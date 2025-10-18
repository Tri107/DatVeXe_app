import '../config/api.dart';
import '../models/Chuyen.dart';

class ChuyenService {
  // Lấy danh sách chuyến xe từ API
  static Future<List<Chuyen>> fetchChuyenList() async {
    try {
      final data = await Api.getJson('/chuyen');

      if (data is List) {
        return data.map((item) => Chuyen.fromJson(item)).toList();
      } else {
        throw Exception("Dữ liệu trả về không hợp lệ");
      }
    } catch (e) {
      print(" Lỗi khi tải danh sách chuyến: $e");
      rethrow;
    }
  }
}