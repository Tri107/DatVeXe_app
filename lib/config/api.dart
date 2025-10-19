import 'package:dio/dio.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:shared_preferences/shared_preferences.dart';

class Api {
  static const String taiKhoan = '/TaiKhoan';
  static const String tinhThanhPho = '/TinhThanhPho';
  static const String khachHang = '/KhachHang';

  static final Dio _dio = Dio(
    BaseOptions(
      baseUrl: dotenv.env['API_BASE_URL'] ??
          'https://p7jpjljn-3000.asse.devtunnels.ms/api',
      connectTimeout: const Duration(seconds: 10),
      receiveTimeout: const Duration(seconds: 10),
      headers: {'Content-Type': 'application/json'},
    ),
  );

  static Dio get client => _dio;

  static Future<void> setToken(String token) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('token', token);
    _dio.options.headers['Authorization'] = 'Bearer $token';
  }

  static Future<void> loadToken() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');
    if (token != null) {
      _dio.options.headers['Authorization'] = 'Bearer $token';
    }
  }

  static Future<void> clearToken() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('token');
    _dio.options.headers.remove('Authorization');
  }

  static Future<Response> getTinhThanhPho() async {
    try {
      await loadToken();
      return await _dio.get(tinhThanhPho);
    } on DioException catch (e) {
      throw Exception(_handleError(e));
    }
  }

  static Future<Response> getTaiKhoan() async {
    try {
      await loadToken();
      return await _dio.get(taiKhoan);
    } on DioException catch (e) {
      throw Exception(_handleError(e));
    }
  }

  static Future<Response> get(String path,
      {Map<String, dynamic>? query}) async {
    try {
      await loadToken();
      return await _dio.get(path, queryParameters: query);
    } on DioException catch (e) {
      throw Exception(_handleError(e));
    }
  }

  static Future<Response> post(String path, dynamic data) async {
    try {
      await loadToken();
      return await _dio.post(path, data: data);
    } on DioException catch (e) {
      throw Exception(_handleError(e));
    }
  }

  static Future<Response> put(String path, dynamic data) async {
    try {
      await loadToken();
      return await _dio.put(path, data: data);
    } on DioException catch (e) {
      throw Exception(_handleError(e));
    }
  }

  static Future<Response> delete(String path) async {
    try {
      await loadToken();
      return await _dio.delete(path);
    } on DioException catch (e) {
      throw Exception(_handleError(e));
    }
  }

  static String _handleError(DioException e) {
    if (e.response != null) {
      return "Lỗi ${e.response?.statusCode}: ${e.response?.data}";
    } else {
      return "Không thể kết nối tới server. Vui lòng thử lại.";
    }
  }
}
