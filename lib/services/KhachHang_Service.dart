import 'package:datvexe_app/config/api.dart';
import 'package:datvexe_app/models/KhachHang.dart';

class KhachHangService {
  static Future<KhachHang?> getKhachHangByPhone(String phone) async {
    print('--- [KhachHangService] Gọi API: /khachhang/find-by-phone/$phone');

    try {
      final response = await Api.get('/khachhang/find-by-phone/$phone');
      print('[KhachHangService]  Response status: ${response.statusCode}');
      print('[KhachHangService]  Raw data: ${response.data}');

      final data = response.data;

      if (data == null) {
        print('[KhachHangService] ️ Response.data = null');
        return null;
      }

      if (data is Map<String, dynamic>) {
        print('[KhachHangService]  Tìm thấy khách hàng: ${data}');
        return KhachHang.fromJson(data);
      } else {
        print(
            '[KhachHangService]  Response không phải Map<String, dynamic>: ${data
                .runtimeType}');
        return null;
      }
    } catch (e) {
      print('[KhachHangService]  Lỗi khi lấy khách hàng: $e');
      return null;
    }
  }

  static Future<KhachHang> createKhachHang({
    required String name,
    required String phone,
    required String email,
  }) async {
    try {
      print('--- [KhachHangService] Gọi API tạo khách hàng mới ---');
      final customerData = {
        'KhachHang_name': name,
        'SDT': phone,
        'email': email
      };
      print('[KhachHangService]  Body gửi lên: $customerData');

      final response = await Api.post('/khachhang', customerData);
      print('[KhachHangService]  Response khi tạo: ${response.data}');

      return KhachHang.fromJson(response.data);
    } catch (e) {
      print('[KhachHangService]  Lỗi khi tạo khách hàng: $e');
      rethrow;
    }
  }

  static Future<KhachHang> updateKhachHang({
    required int customerId,
    required String name,
    required String phone,
    required String email,
  }) async {
    try {
      print(
          '--- [KhachHangService] Gọi API cập nhật khách hàng ID: $customerId ---');
      final customerData = {
        'KhachHang_name': name,
        'SDT': phone,
        'email': email
      };
      print('[KhachHangService]  Body gửi lên: $customerData');

      final response = await Api.put('/khachhang/$customerId', customerData);
      print('[KhachHangService]  Response khi cập nhật: ${response.data}');

      return KhachHang.fromJson(response.data);
    } catch (e) {
      print('[KhachHangService]  Lỗi khi cập nhật khách hàng: $e');
      rethrow;
    }
  }
}
