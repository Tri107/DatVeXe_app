// lib/services/khachhang_service.dart
import 'package:datvexe_app/config/api.dart';
import 'package:datvexe_app/models/KhachHang.dart';

class KhachHangService {
  /// Lấy thông tin khách hàng bằng SĐT.
  /// Trả về null nếu không tìm thấy hoặc có lỗi.
  Future<KhachHang?> getKhachHangByPhone(String phone) async {
    try {
      final response = await Api.get('/khachhang/phone/$phone');
      if (response.data != null && response.data is Map<String, dynamic>) {
        return KhachHang.fromJson(response.data);
      }
      return null;
    } catch (e) {
      print("[KhachHangService] Lỗi khi lấy khách hàng: $e");
      return null;
    }
  }

  /// Gọi API để tạo một khách hàng mới.
  Future<KhachHang> createKhachHang({
    required String name,
    required String phone,
    required String email,
  }) async {
    try {
      print('--- [KhachHangService] Đang tạo khách hàng mới...');
      final customerData = {'KhachHang_name': name, 'SDT': phone, 'email': email};
      final response = await Api.post('/khachhang', customerData);
      return KhachHang.fromJson(response.data);
    } catch (e) {
      print('--- [KhachHangService] Lỗi khi tạo khách hàng: $e');
      rethrow;
    }
  }

  /// Gọi API để cập nhật thông tin cho một khách hàng đã có.
  Future<KhachHang> updateKhachHang({
    required int customerId,
    required String name,
    required String phone,
    required String email,
  }) async {
    try {
      print('--- [KhachHangService] Đang cập nhật cho khách hàng ID: $customerId...');
      final customerData = {'KhachHang_name': name, 'SDT': phone, 'email': email};
      final response = await Api.put('/khachhang/$customerId', customerData);
      return KhachHang.fromJson(response.data);
    } catch (e) {
      print('--- [KhachHangService] Lỗi khi cập nhật khách hàng: $e');
      rethrow;
    }
  }
}
