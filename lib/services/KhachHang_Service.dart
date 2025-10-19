import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/KhachHang.dart';

class KhachHangService {
  final String baseUrl = "http://10.0.2.2:3000/api/khachhang"; // ⚠️ Đổi nếu dùng máy thật

  Future<KhachHang?> getKhachHangByPhone(String phone) async {
    try {
      final res = await http.get(Uri.parse("$baseUrl/find-by-phone/$phone"));
      print("GET $baseUrl/find-by-phone/$phone");
      print("Response: ${res.body}");
      if (res.statusCode == 200) {
        final data = jsonDecode(res.body);
        return KhachHang.fromJson(data);
      }
      return null;
    } catch (e) {
      print("Lỗi khi gọi API: $e");
      return null;
    }
  }
}
