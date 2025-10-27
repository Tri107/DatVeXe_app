import 'package:http/http.dart' as http;
import 'dart:convert';
import '../models/TinhThanhPho.dart';
import '../config/api.dart';

class TinhThanhPhoService {
  static const String tinhThanhPho = '/TinhThanhPho';
  ///  Lấy danh sách tất cả Tỉnh/Thành phố
  Future<List<TinhThanhPho>> getAll() async {
    try {
      // Ghép URL gốc và endpoint
      final String baseUrl = Api.client.options.baseUrl;
      final String endpoint = tinhThanhPho.startsWith('/')
          ? tinhThanhPho
          : '/$tinhThanhPho';
      final Uri url = Uri.parse('$baseUrl$endpoint');

      // Gửi request GET
      final response = await http.get(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': Api.client.options.headers['Authorization'] ?? '',
        },
      );

      //  Nếu thành công
      if (response.statusCode == 200) {
        final body = jsonDecode(response.body);

        // Kiểm tra nếu API trả về dạng List hoặc có 'data'
        List<dynamic> data;
        if (body is List) {
          data = body;
        } else if (body is Map && body.containsKey('data')) {
          data = body['data'];
        } else {
          throw Exception("Phản hồi không đúng định dạng JSON mảng.");
        }

        // Chuyển JSON sang List<TinhThanhPho>
        final list = data.map((e) => TinhThanhPho.fromJson(e)).toList();

        // Lọc bỏ bản ghi null hoặc trống tên
        final distinctList = list
            .where((e) =>
        e.tinhThanhPhoName.isNotEmpty && e.tinhThanhPhoId > 0)
            .toList();

        return distinctList;
      } else {
        throw Exception(
            'Không thể tải danh sách tỉnh/thành (Mã lỗi: ${response.statusCode})');
      }
    } catch (e) {
      throw Exception(' Lỗi khi tải tỉnh/thành phố: $e');
    }
  }
}
