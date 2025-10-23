import 'package:dio/dio.dart';
import '../config/api.dart';

class TaiXeService {
  static const String basePath = '/taixe';

  /// 🔹 Lấy Dashboard tài xế (thông tin & chuyến hiện tại)
  static Future<Map<String, dynamic>> getDashboard(int taiXeId) async {
    try {
      final data = await Api.getJson('$basePath/dashboard/$taiXeId');
      return Map<String, dynamic>.from(data);
    } on DioException catch (e) {
      throw Exception(Api.handleError(e));
    }
  }

  /// 🔹 Lấy danh sách chuyến của tài xế
  static Future<List<Map<String, dynamic>>> getChuyenList(int taiXeId) async {
    try {
      print("📦 Đang tải danh sách chuyến cho tài xế ID: $taiXeId");
      final data = await Api.getJson('$basePath/chuyen-list/$taiXeId');
      print("✅ Dữ liệu chuyến nhận được: $data");
      return List<Map<String, dynamic>>.from(data);
    } on DioException catch (e) {
      print("❌ Lỗi khi tải danh sách chuyến: ${e.message}");
      throw Exception(Api.handleError(e));
    }
  }

  /// 🔹 Lấy chi tiết chuyến xe (bao gồm tuyến, trạm, hành khách)
  static Future<Map<String, dynamic>> getChuyenDetail(int chuyenId) async {
    try {
      print("🔎 Lấy chi tiết chuyến ID: $chuyenId");
      final data = await Api.getJson('$basePath/chuyen/detail/$chuyenId');
      print("✅ Dữ liệu chi tiết chuyến: $data");
      return Map<String, dynamic>.from(data);
    } on DioException catch (e) {
      print("❌ Lỗi khi tải chi tiết chuyến: ${e.message}");
      throw Exception(Api.handleError(e));
    }
  }

  /// 🔹 Thêm tài xế mới
  static Future<Map<String, dynamic>> createTaiXe(Map<String, dynamic> body) async {
    try {
      final data = await Api.postJson(basePath, body);
      return Map<String, dynamic>.from(data);
    } on DioException catch (e) {
      throw Exception(Api.handleError(e));
    }
  }

  /// 🔹 Cập nhật thông tin tài xế
  static Future<Map<String, dynamic>> updateTaiXe(int id, Map<String, dynamic> body) async {
    try {
      final response = await Api.put('$basePath/$id', body);
      return Map<String, dynamic>.from(response.data);
    } on DioException catch (e) {
      throw Exception(Api.handleError(e));
    }
  }

  /// 🔹 Xóa tài xế
  static Future<Map<String, dynamic>> deleteTaiXe(int id) async {
    try {
      final response = await Api.delete('$basePath/$id');
      return Map<String, dynamic>.from(response.data);
    } on DioException catch (e) {
      throw Exception(Api.handleError(e));
    }
  }

  /// 🔹 Lấy thông tin tài xế theo số điện thoại
  static Future<Map<String, dynamic>> getTaiXeByPhone(String sdt) async {
    try {
      print("📞 Gọi API lấy tài xế theo SDT: $sdt");
      final data = await Api.getJson('$basePath/by-phone/$sdt');
      print("✅ Thông tin tài xế: $data");
      return Map<String, dynamic>.from(data);
    } on DioException catch (e) {
      print("❌ Lỗi khi lấy tài xế theo SDT: ${e.message}");
      throw Exception(Api.handleError(e));
    }
  }
}
