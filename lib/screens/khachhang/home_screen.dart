import 'package:datvexe_app/screens/khachhang/trip_search_screen.dart';
import 'package:flutter/material.dart';
import '../../models/TaiKhoan.dart';
import '../../models/TinhThanhPho.dart';
import '../../services/Auth_Services.dart';
import '../../services/Trip_Service.dart';
import '../../services/tinh_thanh_pho_service.dart';
import '../auth/login_screen.dart';

import 'profile_screen.dart';

import '../khachhang/payment_screen.dart';
import '../khachhang/trip_info_screen.dart';
import 'map_screen.dart';


class HomeScreen extends StatefulWidget {
  final TaiKhoan user;
  const HomeScreen({super.key, required this.user});

  // tạm test với veId=1 (bạn đã insert trong DB)
  static const int demoVeId = 1;

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  DateTime? _selectedDate;
  int _currentIndex = 0;
  List<TinhThanhPho> _tinhThanhList = [];
  String? _fromSelected;
  String? _toSelected;

  final _tinhThanhService = TinhThanhPhoService();

  @override
  void initState() {
    super.initState();
    _loadTinhThanhPho();
  }

  /// Lấy danh sách tỉnh/thành phố từ API
  Future<void> _loadTinhThanhPho() async {
    try {
      final list = await _tinhThanhService.getAll();

      // 🔸 Lọc trùng theo tên (phòng trường hợp API trả về trùng)
      final distinctList = list.fold<List<TinhThanhPho>>([], (acc, e) {
        if (!acc.any((x) => x.tinhThanhPhoName == e.tinhThanhPhoName)) {
          acc.add(e);
        }
        return acc;
      });

      if (mounted) {
        setState(() {
          _tinhThanhList = distinctList;
          // Chọn mặc định 2 tỉnh đầu tiên (nếu có)
          if (_tinhThanhList.isNotEmpty) {
            _fromSelected = _tinhThanhList.first.tinhThanhPhoName;
            _toSelected = _tinhThanhList.length > 1
                ? _tinhThanhList[1].tinhThanhPhoName
                : _tinhThanhList.first.tinhThanhPhoName;
          }
        });
      }
    } catch (e) {
      debugPrint("❌ Lỗi tải danh sách tỉnh: $e");
    }
  }

  ///  Chọn ngày đi
  Future<void> _chonNgayDi(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      locale: const Locale('vi', 'VN'),
      initialDate: _selectedDate ?? DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: Color(0xFF1565C0),
              onPrimary: Colors.white,
              onSurface: Colors.black,
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(60),
        child: Container(
          color: const Color(0xFF1565C0),
          padding:
          const EdgeInsets.only(top: 35, left: 16, right: 16, bottom: 10),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(children: const [
                Icon(Icons.directions_bus, color: Colors.white, size: 26),
                SizedBox(width: 6),
                Text(
                  "VeXeRom",
                  style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: Colors.white),
                ),
              ]),
              GestureDetector(
                onTap: () async {
                  await AuthService.logout();
                  if (!context.mounted) return;
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(builder: (_) => const LoginScreen()),
                  );
                },
                child: const Text(
                  "Đăng xuất",
                  style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      decoration: TextDecoration.underline),
                ),
              ),
            ],
          ),
        ),
      ),

      // Nội dung chính
      body: _tinhThanhList.isEmpty
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              color: const Color(0xFF1565C0),
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              child: const Text(
                "Cam kết KHÔNG hoàn tiền nếu nhà xe không cung cấp dịch vụ vận chuyển",
                style: TextStyle(color: Colors.white, fontSize: 14),
                textAlign: TextAlign.center,
              ),
            ),

            //Form tìm kiếm
            Container(
              margin: const EdgeInsets.symmetric(
                  horizontal: 16, vertical: 10),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.shade300,
                    blurRadius: 6,
                    offset: const Offset(0, 2),
                  )
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text("Nơi xuất phát",
                      style: TextStyle(color: Colors.grey)),
                  DropdownButton<String>(
                    isExpanded: true,
                    value: _fromSelected,
                    items: _tinhThanhList
                        .map((e) => DropdownMenuItem(
                      value: e.tinhThanhPhoName,
                      child: Text(e.tinhThanhPhoName),
                    ))
                        .toList(),
                    onChanged: (val) {
                      setState(() => _fromSelected = val);
                    },
                  ),
                  const Divider(),
                  const Text("Bạn muốn đi đâu?",
                      style: TextStyle(color: Colors.grey)),
                  DropdownButton<String>(
                    isExpanded: true,
                    value: _toSelected,
                    items: _tinhThanhList
                        .map((e) => DropdownMenuItem(
                      value: e.tinhThanhPhoName,
                      child: Text(e.tinhThanhPhoName),
                    ))
                        .toList(),
                    onChanged: (val) {
                      setState(() => _toSelected = val);
                    },
                  ),
                  const Divider(),

                  // Chọn ngày đi
                  GestureDetector(
                    onTap: () => _chonNgayDi(context),
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            _selectedDate != null
                                ? "Ngày đi: ${_selectedDate!.day}/${_selectedDate!.month}/${_selectedDate!.year}"
                                : "Chọn ngày đi",
                            style: TextStyle(
                              color: _selectedDate != null
                                  ? Colors.black87
                                  : Colors.grey,
                              fontSize: 16,
                              fontWeight: _selectedDate != null
                                  ? FontWeight.w600
                                  : FontWeight.normal,
                            ),
                          ),
                          const Icon(Icons.calendar_month,
                              color: Colors.grey),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 16),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFFFC107),
                      minimumSize: const Size(double.infinity, 48),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8)),
                    ),
                    onPressed: () {
                      if (_fromSelected == null || _toSelected == null) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text("Vui lòng chọn điểm đi và điểm đến!")),
                        );
                        return;
                      }

                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => TripSearchScreen(
                            from: _fromSelected!,
                            to: _toSelected!,
                            date: _selectedDate, // <-- Cho phép null
                            phone: widget.user.sdt,
                          ),
                        ),
                      );
                    },

                    child: const Text(
                      "Tìm kiếm",
                      style: TextStyle(
                          color: Colors.black,
                          fontWeight: FontWeight.bold,
                          fontSize: 16),
                    ),
                  ),
                ],
              ),
            ),

            const Padding(
              padding:
              EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Text("Tìm kiếm gần đây",
                  style: TextStyle(
                      fontWeight: FontWeight.bold, fontSize: 16)),
            ),
            const _RecentSearch(
                from: "Hồ Chí Minh",
                to: "Đắk Lắk",
                date: "CN, 12/10/2025"),
            const _RecentSearch(
                from: "Hồ Chí Minh",
                to: "Đắk Lắk",
                date: "CN, 05/10/2025"),
            const SizedBox(height: 20),
          ],
        ),
      ),

      //Bottom Navigation
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) {
          if (index == 2) {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const ProfileScreen()),
            );
          } else {
            setState(() => _currentIndex = index);
          }
        },
        selectedItemColor: const Color(0xFF1565C0),
        unselectedItemColor: Colors.grey,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.search), label: "Tìm kiếm"),
          BottomNavigationBarItem(
              icon: Icon(Icons.receipt_long), label: "Vé của tôi"),
          BottomNavigationBarItem(
              icon: Icon(Icons.person_outline), label: "Tài khoản"),
        ],
      ),
    );
  }
}

//Widget phụ
class _RecentSearch extends StatelessWidget {
  final String from;
  final String to;
  final String date;
  const _RecentSearch(
      {required this.from, required this.to, required this.date});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey.shade300),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Row(children: [
              const Icon(Icons.circle, size: 10, color: Colors.blue),
              const SizedBox(width: 6),
              Text(from, style: const TextStyle(fontWeight: FontWeight.bold))
            ]),
            const SizedBox(height: 4),
            Row(children: [
              const Icon(Icons.circle, size: 10, color: Colors.red),
              const SizedBox(width: 6),
              Text(to, style: const TextStyle(fontWeight: FontWeight.bold))
            ]),
            const SizedBox(height: 4),
            Text(date,
                style: const TextStyle(color: Colors.grey, fontSize: 13))
          ]),
          const Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey),
        ],
      ),
    );
  }
}