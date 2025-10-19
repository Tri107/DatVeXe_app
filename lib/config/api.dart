import 'package:dio/dio.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:shared_preferences/shared_preferences.dart';

class Api {
  static const String taiKhoan = '/TaiKhoan';
  static const String tinhThanhPho = '/TinhThanhPho';


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

  // 🔹 Lưu token
  static Future<void> setToken(String token) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('token', token);
    _dio.options.headers['Authorization'] = 'Bearer $token';
  }

  // 🔹 Tải token từ bộ nhớ
  static Future<void> loadToken() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');
    if (token != null) {
      _dio.options.headers['Authorization'] = 'Bearer $token';
    }
  }

  // 🔹 Xóa token
  static Future<void> clearToken() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('token');
    _dio.options.headers.remove('Authorization');
  }
  static String _p(String path) => path.startsWith('/') ? path : '/$path';

  // ---------- Low-level ----------
  static Future<Response> get(String path, {Map<String, dynamic>? query}) =>
      _dio.get(_p(path), queryParameters: query);

  static Future<Response> post(String path, dynamic data) =>
      _dio.post(_p(path), data: data);

  static Future<Response> put(String path, dynamic data) =>
      _dio.put(_p(path), data: data);

  static Future<Response> delete(String path) =>
      _dio.delete(_p(path));

  // ---------- Helper trả data & ném lỗi 4xx ----------
  static Future<dynamic> getJson(String path,
      {Map<String, dynamic>? query}) async {
    final r = await get(path, query: query);
    _throwIfClientError(r);
    return r.data;
  }

  static Future<dynamic> postJson(String path, dynamic data) async {
    final r = await post(path, data);
    _throwIfClientError(r);
    return r.data;
  }

  static void _throwIfClientError(Response r) {
    if (r.statusCode != null && r.statusCode! >= 400) {
      final uri = r.requestOptions.uri;
      print('⚠️ HTTP ${r.statusCode} @ $uri');
      print('Response: ${r.data}');
      throw DioException.badResponse(
        statusCode: r.statusCode!,
        requestOptions: r.requestOptions,
        response: r,
      );

  }
  }

}
