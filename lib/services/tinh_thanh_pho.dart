import 'package:http/http.dart' as http;
import 'dart:convert';
import '../models/TinhThanhPho.dart';
import '../config/api.dart';

class TinhThanhPhoService {
  Future<List<TinhThanhPho>> getAll() async {
    final response = await http.get(Uri.parse(Api.tinhThanhPho));

    if (response.statusCode == 200) {
      final List<dynamic> data = json.decode(response.body);
      return data.map((e) => TinhThanhPho.fromJson(e)).toList();
    } else {
      throw Exception('Không thể tải danh sách tỉnh thành');
    }
  }
}
