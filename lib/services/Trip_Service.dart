import '../config/api.dart';
import '../models/Chuyen.dart';

class ChuyenService {

  static Future<List<Chuyen>> fetchChuyenList() async {
    try {
      final data = await Api.getJson('/chuyen');

      if (data is List) {
        return data.map((item) => Chuyen.fromJson(item)).toList();
      } else {
        throw Exception("Dữ liệu trả về không hợp lệ");
      }
    } catch (e) {
      print("Lỗi khi tải danh sách chuyến: $e");
      rethrow;
    }
  }

  // Tìm kiếm chuyến theo điểm đi, điểm đến, và ngày
  static Future<List<Chuyen>> fetchSearchTrip(
      String diemDi,
      String diemDen,
      DateTime? ngayGio,
      ) async {
    try {
      // Luôn gọi API mới để tránh dữ liệu cũ
      final data = await Api.getJson('/chuyen');

      if (data is! List) {
        throw Exception("Dữ liệu trả về không hợp lệ");
      }

      final chuyenList = data.map((item) => Chuyen.fromJson(item)).toList();

      final normalizedDiemDi = diemDi.toLowerCase().trim();
      final normalizedDiemDen = diemDen.toLowerCase().trim();

      final filtered = chuyenList.where((chuyen) {
        final matchDiemDi =
        chuyen.diemDi.toLowerCase().contains(normalizedDiemDi);
        final matchDiemDen =
        chuyen.diemDen.toLowerCase().contains(normalizedDiemDen);

        bool matchNgay = true;
        if (ngayGio != null) {
          final tripDate = chuyen.ngayGio;
          matchNgay = tripDate.year == ngayGio.year &&
              tripDate.month == ngayGio.month &&
              tripDate.day == ngayGio.day;
        }

        return matchDiemDi && matchDiemDen && matchNgay;
      }).toList();

      return filtered;
    } catch (e) {
      print("Lỗi khi tìm kiếm chuyến: $e");
      rethrow;
    }
  }
}
