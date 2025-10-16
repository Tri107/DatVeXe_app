import 'package:dio/dio.dart';
import '../config/api.dart';
import '../models/TaiKhoan.dart';

class AuthService {
  // 🔹 Đăng nhập
  static Future<TaiKhoan?> login(String sdt, String password) async {
    try {
      final response = await Api.post('/auth/login', {
        'SDT': sdt,
        'password': password,
      });

      if (response.statusCode == 200) {
        final token = response.data['token'];
        final userData = response.data['user'];

        //  Lưu token vào SharedPreferences và gắn header
        await Api.setToken(token);

        return TaiKhoan.fromJson(userData);
      }
      return null;
    } on DioException catch (e) {
      print(' Lỗi đăng nhập: ${e.response?.data ?? e.message}');
      return null;
    }
  }

  // 🔹 Lấy thông tin người dùng hiện tại
  static Future<TaiKhoan?> me() async {
    try {
      await Api.loadToken(); // nạp lại token nếu có
      final response = await Api.get('/auth/me');
      if (response.statusCode == 200) {
        return TaiKhoan.fromJson(response.data['user']);
      }
    } on DioException catch (e) {
      print(' Lỗi xác thực token: ${e.response?.data ?? e.message}');
    }
    return null;
  }

  // 🔹 Đăng xuất
  static Future<void> logout() async {
    try {
      await Api.post('/auth/logout', {});
    } catch (_) {}
    await Api.clearToken();
  }
}
