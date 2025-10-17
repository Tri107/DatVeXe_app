import 'package:dio/dio.dart';
import '../config/api.dart';
import '../models/TaiKhoan.dart';

class AuthService {
  // 🔹 Gửi OTP
  static Future<bool> sendOtp(String sdt) async {
    try {
      final response = await Api.post('/auth/send-otp', {'SDT': sdt});
      if (response.statusCode == 200) {
        print(' OTP sent successfully');
        return true;
      } else {
        print(' Send OTP failed: ${response.data}');
        return false;
      }
    } on DioException catch (e) {
      print(' Lỗi gửi OTP: ${e.response?.data ?? e.message}');
      return false;
    }
  }

  // 🔹 Xác thực OTP + đăng ký tài khoản
  static Future<bool> verifyOtp(String sdt, String password, String otp) async {
    try {
      final response = await Api.post('/auth/verify-otp', {
        'SDT': sdt,
        'password': password,
        'otp': otp,
      });

      if (response.statusCode == 201) {
        print(' Đăng ký thành công');
        return true;
      } else {
        print(' Lỗi đăng ký: ${response.data}');
        return false;
      }
    } on DioException catch (e) {
      print(' Lỗi xác thực OTP: ${e.response?.data ?? e.message}');
      return false;
    }
  }

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

        // Lưu token vào SharedPreferences và gắn header
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
