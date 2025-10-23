import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:jwt_decoder/jwt_decoder.dart';
import '../config/api.dart';
import '../models/TaiKhoan.dart';

class AuthService {
  // 🔹 Gửi OTP
  static Future<bool> sendOtp(String sdt) async {
    final url = Uri.parse("${Api.client.options.baseUrl}/auth/send-otp");
    try {
      final response = await http.post(
        url,
        headers: {
          'Content-Type': 'application/json',
        },
        body: jsonEncode({'SDT': sdt}),
      );

      if (response.statusCode == 200) {
        print(' OTP sent successfully');
        return true;
      } else {
        print(' Send OTP failed: ${response.body}');
        return false;
      }
    } catch (e) {
      print(' Lỗi gửi OTP: $e');
      return false;
    }
  }

  // 🔹 Xác thực OTP + đăng ký tài khoản
  static Future<bool> verifyOtp(String sdt, String password, String otp) async {
    final url = Uri.parse("${Api.client.options.baseUrl}/auth/verify-otp");
    try {
      final response = await http.post(
        url,
        headers: {
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'SDT': sdt,
          'password': password,
          'otp': otp,
        }),
      );

      if (response.statusCode == 201) {
        print('✅ Đăng ký thành công');
        return true;
      } else {
        print('❌ Lỗi đăng ký: ${response.body}');
        return false;
      }
    } catch (e) {
      print('⚠️ Lỗi xác thực OTP: $e');
      return false;
    }
  }

  // 🔹 Đăng nhập
  static Future<TaiKhoan?> login(String sdt, String password) async {
    final url = Uri.parse("${Api.client.options.baseUrl}/auth/login");
    print('🔗 API base URL hiện tại: ${Api.client.options.baseUrl}');
    print('📤 Request gửi tới: $url');

    try {
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'SDT': sdt,
          'password': password,
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final token = data['token'];
        final userData = data['user'];

        // 🔐 Lưu token vào SharedPreferences + cập nhật header
        await Api.setToken(token);

        // 🔍 Giải mã token để lấy role
        final decoded = JwtDecoder.decode(token);
        final role = decoded['role'];
        print('👤 Role từ token: $role');

        // ✅ Truyền role vào model TaiKhoan (model đã có field role)
        final taiKhoan = TaiKhoan(
          sdt: userData['SDT'] ?? '',
          role: role,
        );

        print('✅ Đăng nhập thành công với vai trò: ${taiKhoan.role}');
        return taiKhoan;
      } else {
        print('❌ Lỗi đăng nhập: ${response.body}');
        return null;
      }
    } catch (e) {
      print('⚠️ Lỗi đăng nhập: $e');
      return null;
    }
  }

  // 🔹 Lấy thông tin người dùng hiện tại
  static Future<TaiKhoan?> me() async {
    final url = Uri.parse("${Api.client.options.baseUrl}/auth/me");
    await Api.loadToken();

    try {
      final response = await http.get(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': Api.client.options.headers['Authorization'] ?? '',
        },
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return TaiKhoan.fromJson(data['user']);
      } else {
        print('❌ Token không hợp lệ hoặc hết hạn');
      }
    } catch (e) {
      print('⚠️ Lỗi xác thực token: $e');
    }
    return null;
  }

  // 🔹 Đăng xuất
  static Future<void> logout() async {
    final url = Uri.parse("${Api.client.options.baseUrl}/auth/logout");
    try {
      await http.post(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': Api.client.options.headers['Authorization'] ?? '',
        },
      );
    } catch (_) {}
    await Api.clearToken();
  }
}
