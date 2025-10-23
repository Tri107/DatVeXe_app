import 'dart:convert';
import 'dart:async';
import 'package:http/http.dart' as http;
import 'package:jwt_decoder/jwt_decoder.dart';
import '../config/api.dart';
import '../models/TaiKhoan.dart';

class AuthService {
  // 🔹 Gửi OTP
  static Future<bool> sendOtp(String sdt) async {
    final url = Uri.parse("${Api.client.options.baseUrl}/auth/send-otp");
    print("📤 [AuthService] Gửi OTP tới: $url với SDT: $sdt");

    try {
      final response = await http
          .post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'SDT': sdt}),
      )
          .timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        print('✅ [AuthService] Gửi OTP thành công');
        return true;
      } else {
        print('❌ [AuthService] Lỗi gửi OTP: ${response.statusCode} - ${response.body}');
        return false;
      }
    } on TimeoutException {
      print('⏰ [AuthService] Hết thời gian chờ phản hồi server khi gửi OTP');
      return false;
    } catch (e) {
      print('⚠️ [AuthService] Lỗi gửi OTP: $e');
      return false;
    }
  }

  // 🔹 Xác thực OTP + Đăng ký
  static Future<bool> verifyOtp(String sdt, String password, String otp) async {
    final url = Uri.parse("${Api.client.options.baseUrl}/auth/verify-otp");
    print("📤 [AuthService] Xác thực OTP: $otp cho SDT: $sdt");

    try {
      final response = await http
          .post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'SDT': sdt, 'password': password, 'otp': otp}),
      )
          .timeout(const Duration(seconds: 10));

      if (response.statusCode == 201) {
        print('✅ [AuthService] Đăng ký tài khoản thành công');
        return true;
      } else {
        print('❌ [AuthService] Đăng ký thất bại: ${response.body}');
        return false;
      }
    } on TimeoutException {
      print('⏰ [AuthService] Hết thời gian chờ phản hồi server khi verify OTP');
      return false;
    } catch (e) {
      print('⚠️ [AuthService] Lỗi xác thực OTP: $e');
      return false;
    }
  }
  // 🔹 Đăng nhập
  static Future<TaiKhoan?> login(String sdt, String password) async {
    final url = Uri.parse("${Api.client.options.baseUrl}/auth/login");
    print("📤 [AuthService] Gửi yêu cầu đăng nhập: $url");
    print("📦 Dữ liệu gửi: SDT=$sdt, password=$password");

    try {
      final response = await http
          .post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'SDT': sdt, 'password': password}),
      )
          .timeout(const Duration(seconds: 10));

      print("📥 [AuthService] Status: ${response.statusCode}");

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final token = data['token'];
        final userData = data['user'];

        // 🔐 Lưu token
        await Api.setToken(token);
        print("🔑 [AuthService] Token đã được lưu thành công");

        // 🔍 Giải mã token để lấy role
        final decoded = JwtDecoder.decode(token);
        final role = decoded['role'] ?? 'User';

        final taiKhoan = TaiKhoan(
          sdt: userData['SDT'] ?? '',
          role: role,
        );

        print('✅ [AuthService] Đăng nhập thành công: ${taiKhoan.sdt} | Vai trò: ${taiKhoan.role}');
        return taiKhoan;
      } else {
        print('❌ [AuthService] Lỗi đăng nhập: ${response.statusCode} - ${response.body}');
        return null;
      }
    } on TimeoutException {
      print('⏰ [AuthService] Hết thời gian chờ phản hồi server khi đăng nhập');
      return null;
    } catch (e) {
      print('⚠️ [AuthService] Lỗi đăng nhập: $e');
      return null;
    }
  }
  // 🔹 Lấy thông tin người dùng hiện tại từ token
  static Future<TaiKhoan?> getCurrentUser() async {
    await Api.loadToken(); // load token từ SharedPreferences
    final token = Api.token;

    if (token == null) {
      print("⚠️ [AuthService] Không có token, người dùng chưa đăng nhập");
      return null;
    }

    try {
      final decoded = JwtDecoder.decode(token);
      final sdt = decoded['sdt'] ?? decoded['SDT'] ?? '';
      final role = decoded['role'] ?? 'User';

      print('📖 [AuthService] Token hợp lệ. SĐT: $sdt | Role: $role');
      return TaiKhoan(sdt: sdt, role: role);
    } catch (e) {
      print("❌ [AuthService] Token không hợp lệ hoặc bị lỗi: $e");
      return null;
    }
  }
  // 🔹 Lấy thông tin người dùng từ /auth/me (server kiểm tra token)
  static Future<TaiKhoan?> me() async {
    final url = Uri.parse("${Api.client.options.baseUrl}/auth/me");
    await Api.loadToken();
    final token = Api.token;

    if (token == null) {
      print("⚠️ [AuthService] Không có token để xác thực");
      return null;
    }

    try {
      final response = await http
          .get(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      )
          .timeout(const Duration(seconds: 10));
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final user = data['user'];
        print("✅ [AuthService] Lấy thông tin user thành công: $user");
        return TaiKhoan.fromJson(user);
      } else {
        print("❌ [AuthService] Token không hợp lệ hoặc hết hạn (${response.statusCode})");
      }
    } catch (e) {
      print("⚠️ [AuthService] Lỗi xác thực token: $e");
    }
    return null;
  }

  // 🔹 Đăng xuất
  static Future<void> logout() async {
    final url = Uri.parse("${Api.client.options.baseUrl}/auth/logout");
    await Api.loadToken();
    final token = Api.token;

    try {
      await http.post(
        url,
        headers: {
          'Content-Type': 'application/json',
          if (token != null) 'Authorization': 'Bearer $token',
        },
      );
      print("🚪 [AuthService] Đã gửi yêu cầu logout lên server");
    } catch (e) {
      print("⚠️ [AuthService] Lỗi khi logout: $e");
    }

    await Api.clearToken();
    print("🧹 [AuthService] Token đã được xóa khỏi bộ nhớ");
  }
}
