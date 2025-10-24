import 'dart:convert';
import 'package:datvexe_app/screens/khachhang/trip_search_screen.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../models/TaiKhoan.dart';
import '../../models/TinhThanhPho.dart';
import '../../services/Auth_Services.dart';
import '../../services/tinh_thanh_pho_service.dart';
import '../auth/login_screen.dart';
import 'my_tickets_screen.dart';
import 'profile_screen.dart';

class HomeScreen extends StatefulWidget {
  final TaiKhoan user;
  const HomeScreen({super.key, required this.user});

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

  /// 🔹 Danh sách tìm kiếm gần đây
  List<Map<String, dynamic>> _recentSearches = [];

  /// 🔹 Khóa lưu theo tài khoản (sdt hoặc id)
  String get _prefsKey =>
      'recent_searches_${widget.user.sdt ?? "unknown"}';


  @override
  void initState() {
    super.initState();
    _loadTinhThanhPho();
    _loadRecentSearches();
  }

  /// 🔹 Lấy danh sách Tỉnh/Thành phố
  Future<void> _loadTinhThanhPho() async {
    try {
      final list = await _tinhThanhService.getAll();
      final distinctList = list.fold<List<TinhThanhPho>>([], (acc, e) {
        if (!acc.any((x) => x.tinhThanhPhoName == e.tinhThanhPhoName)) {
          acc.add(e);
        }
        return acc;
      });

      if (mounted) {
        setState(() {
          _tinhThanhList = distinctList;
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

  /// 🔹 Lưu lịch sử tìm kiếm cho tài khoản hiện tại
  Future<void> _saveRecentSearches() async {
    final prefs = await SharedPreferences.getInstance();
    final jsonList = _recentSearches.map((item) => jsonEncode(item)).toList();
    await prefs.setStringList(_prefsKey, jsonList);
    debugPrint("💾 Đã lưu lịch sử tìm kiếm (${_recentSearches.length}) cho key: $_prefsKey");
  }

  /// 🔹 Đọc lịch sử tìm kiếm theo tài khoản hiện tại
  Future<void> _loadRecentSearches() async {
    final prefs = await SharedPreferences.getInstance();
    final listAsString = prefs.getStringList(_prefsKey);
    if (listAsString == null) {
      debugPrint("ℹ️ Không có lịch sử cho tài khoản này ($_prefsKey)");
      return;
    }

    final now = DateTime.now();
    final List<Map<String, dynamic>> restored = [];

    for (final jsonStr in listAsString) {
      try {
        final Map<String, dynamic> map = jsonDecode(jsonStr);
        if (map.containsKey('timestamp')) {
          final time = DateTime.tryParse(map['timestamp'] ?? '');
          if (time != null && now.difference(time).inDays <= 7) {
            restored.add(map);
          }
        }
      } catch (e) {
        debugPrint("⚠️ Lỗi khi parse lịch sử: $e");
      }
    }

    setState(() => _recentSearches = restored);

    // ✅ Dọn dữ liệu cũ
    final validJsonList = restored.map((item) => jsonEncode(item)).toList();
    await prefs.setStringList(_prefsKey, validJsonList);

    debugPrint("📜 Lịch sử cho tài khoản ${widget.user.sdt}: $_recentSearches");
  }

  /// 🔹 Chọn ngày đi
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
      setState(() => _selectedDate = picked);
    }
  }

  /// 🔹 Khi nhấn nút Tìm kiếm
  void _onSearch() async {
    if (_fromSelected == null || _toSelected == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Vui lòng chọn điểm đi và điểm đến!")),
      );
      return;
    }

    final search = {
      'from': _fromSelected!,
      'to': _toSelected!,
      'date': _selectedDate != null
          ? "${_selectedDate!.day}/${_selectedDate!.month}/${_selectedDate!.year}"
          : "Không chọn ngày",
      'timestamp': DateTime.now().toIso8601String(),
    };

    setState(() {
      _recentSearches.insert(0, search);
      final now = DateTime.now();
      _recentSearches = _recentSearches.where((e) {
        final time = DateTime.tryParse(e['timestamp']);
        return time != null && now.difference(time).inDays <= 7;
      }).toList();
    });

    await _saveRecentSearches();

    debugPrint("💾 Đã lưu lịch sử cho ${widget.user.sdt}: $_recentSearches");

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => TripSearchScreen(
          from: _fromSelected!,
          to: _toSelected!,
          date: _selectedDate,
        ),
      ),
    );
  }

  /// 🔹 Xóa toàn bộ lịch sử tài khoản này
  Future<void> _clearSearchHistory() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_prefsKey);
    setState(() => _recentSearches.clear());
    debugPrint("🗑️ Đã xóa lịch sử cho key: $_prefsKey");
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

            // Form tìm kiếm
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
                    onPressed: _onSearch,
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

            // Hiển thị lịch sử tìm kiếm gần đây
            if (_recentSearches.isNotEmpty) ...[
              Padding(
                padding: const EdgeInsets.symmetric(
                    horizontal: 16, vertical: 8),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text("Tìm kiếm gần đây",
                        style: TextStyle(
                            fontWeight: FontWeight.bold, fontSize: 16)),
                    IconButton(
                      onPressed: _clearSearchHistory,
                      icon: const Icon(Icons.delete_forever,
                          color: Colors.red),
                      tooltip: "Xóa lịch sử",
                    ),
                  ],
                ),
              ),
              for (var search in _recentSearches)
                _RecentSearch(
                  from: search['from']!,
                  to: search['to']!,
                  date: search['date']!,
                ),
            ],
            const SizedBox(height: 20),
          ],
        ),
      ),

      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) {
          if (index == 1) {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => MyTicketsScreen(sdt: widget.user.sdt),
              ),
            );
          } else if (index == 2) {
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

class _RecentSearch extends StatelessWidget {
  final String from;
  final String to;
  final String date;

  const _RecentSearch({
    required this.from,
    required this.to,
    required this.date,
  });

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
