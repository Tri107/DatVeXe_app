import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../models/TaiKhoan.dart';
import '../../models/TinhThanhPho.dart';
import '../../services/Auth_Services.dart';
import '../../services/tinh_thanh_pho_service.dart';
import '../../themes/gradient.dart';
import '../auth/login_screen.dart';
import 'my_tickets_screen.dart';
import 'profile_screen.dart';
import 'trip_search_screen.dart';

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

  // Lịch sử tìm kiếm
  List<Map<String, dynamic>> _recentSearches = [];
  String get _prefsKey => 'recent_searches_${widget.user.sdt ?? "unknown"}';

  @override
  void initState() {
    super.initState();
    _loadTinhThanhPho();
    _loadRecentSearches();
  }

  // ==========================================================
  // Load danh sách tỉnh thành
  // ==========================================================
  Future<void> _loadTinhThanhPho() async {
    try {
      final list = await _tinhThanhService.getAll();

      // Loại bỏ trùng lặp
      final distinctList = list.fold<List<TinhThanhPho>>([], (acc, e) {
        if (!acc.any((x) => x.tinhThanhPhoName == e.tinhThanhPhoName)) acc.add(e);
        return acc;
      });

      if (!mounted) return;

      setState(() {
        _tinhThanhList = distinctList;

        //  Mặc định chưa chọn gì → giá trị null
        _fromSelected = null;
        _toSelected = null;
      });
    } catch (e) {
      debugPrint(" Lỗi tải danh sách tỉnh: $e");
    }
  }

  // ==========================================================
  // Lưu / tải lịch sử tìm kiếm
  // ==========================================================
  Future<void> _saveRecentSearches() async {
    final prefs = await SharedPreferences.getInstance();
    final jsonList = _recentSearches.map(jsonEncode).toList();
    await prefs.setStringList(_prefsKey, jsonList);
  }

  Future<void> _loadRecentSearches() async {
    final prefs = await SharedPreferences.getInstance();
    final listAsString = prefs.getStringList(_prefsKey);
    if (listAsString == null) return;

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
      } catch (_) {}
    }

    setState(() => _recentSearches = restored);
    await prefs.setStringList(_prefsKey, restored.map(jsonEncode).toList());
  }

  // ==========================================================
  // Chọn ngày đi
  // ==========================================================
  Future<void> _chonNgayDi(BuildContext context) async {
    final picked = await showDatePicker(
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

  // ==========================================================
  // Xử lý tìm kiếm
  // ==========================================================
  Future<void> _onSearch() async {
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

    setState(() => _recentSearches.insert(0, search));
    await _saveRecentSearches();

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

  Future<void> _clearSearchHistory() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_prefsKey);
    setState(() => _recentSearches.clear());
  }

  // ==========================================================
  // UI chính
  // ==========================================================
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF4F7FB),
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(60),
        child: Container(
          decoration: const BoxDecoration(
            gradient: AppGradients.primary,
          ),
          padding: const EdgeInsets.only(top: 35, left: 16, right: 16, bottom: 10),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: const [
                  Icon(Icons.directions_bus, color: Colors.white, size: 26),
                  SizedBox(width: 6),
                  Text(
                    "Vexesmart",
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
              IconButton(
                icon: const Icon(Icons.logout, color: Colors.white),
                tooltip: "Đăng xuất",
                onPressed: () async {
                  await AuthService.logout();
                  if (!context.mounted) return;
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(builder: (_) => const LoginScreen()),
                  );
                },
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
            _buildWarningBanner(),
            _buildSearchForm(),
            _buildRecentSearches(),
            const SizedBox(height: 20),
          ],
        ),
      ),

      bottomNavigationBar: _buildBottomNavBar(),
    );
  }
  // ==========================================================
  // Widget con
  // ==========================================================
  Widget _buildWarningBanner() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: const BoxDecoration(
        gradient: AppGradients.primary,
      ),
      child: const Text(
        "Cam kết KHÔNG hoàn tiền nếu nhà xe không cung cấp dịch vụ vận chuyển",
        style: TextStyle(color: Colors.white, fontSize: 14),
        textAlign: TextAlign.center,
      ),
    );
  }

  Widget _buildSearchForm() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      padding: const EdgeInsets.all(16),
      decoration: _cardDecoration(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text("Nơi xuất phát", style: TextStyle(color: Colors.grey)),
          _buildDropdown(_fromSelected, (val) => setState(() => _fromSelected = val), placeholder: "Chọn điểm xuất phát"),
          const Divider(),

          const Text("Bạn muốn đi đâu?", style: TextStyle(color: Colors.grey)),
          _buildDropdown(_toSelected, (val) => setState(() => _toSelected = val), placeholder: "Chọn điểm đến"),
          const Divider(),

          GestureDetector(
            onTap: () => _chonNgayDi(context),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  _selectedDate != null
                      ? "Ngày đi: ${_selectedDate!.day}/${_selectedDate!.month}/${_selectedDate!.year}"
                      : "Chọn ngày đi",
                  style: TextStyle(
                    color: _selectedDate != null ? Colors.black87 : Colors.grey,
                    fontSize: 16,
                    fontWeight: _selectedDate != null
                        ? FontWeight.w600
                        : FontWeight.normal,
                  ),
                ),
                const Icon(Icons.calendar_month, color: Colors.grey),
              ],
            ),
          ),

          const SizedBox(height: 16),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFFFC107),
              minimumSize: const Size(double.infinity, 48),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            ),
            onPressed: _onSearch,
            child: const Text(
              "Tìm kiếm",
              style: TextStyle(
                color: Colors.black,
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDropdown(String? value, ValueChanged<String?> onChanged, {required String placeholder}) {
    return DropdownButton<String>(
      isExpanded: true,
      value: value,
      hint: Text(placeholder, style: const TextStyle(color: Colors.grey)),
      items: [
        ..._tinhThanhList.map((e) => DropdownMenuItem(
          value: e.tinhThanhPhoName,
          child: Text(e.tinhThanhPhoName),
        )),
      ],
      onChanged: onChanged,
    );
  }

  Widget _buildRecentSearches() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      padding: const EdgeInsets.all(16),
      decoration: _cardDecoration(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildRecentSearchHeader(),
          if (_recentSearches.isEmpty)
            const Padding(
              padding: EdgeInsets.only(top: 8),
              child: Text(
                "Chưa có lịch sử tìm kiếm",
                style: TextStyle(color: Colors.grey),
              ),
            )
          else
            SizedBox(
              // Giới hạn chiều cao phần Recent Searches
              height: 200,
              child: ListView.builder(
                shrinkWrap: true,
                physics: const BouncingScrollPhysics(),
                itemCount: _recentSearches.length,
                itemBuilder: (context, index) {
                  final s = _recentSearches[index];
                  return _RecentSearch(
                    from: s['from']!,
                    to: s['to']!,
                    date: s['date']!,
                    onTap: () {
                      setState(() {
                        _fromSelected = s['from'];
                        _toSelected = s['to'];
                      });
                      _onSearch();
                    },
                  );
                },
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildRecentSearchHeader() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        const Text(
          "Tìm kiếm gần đây",
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 16,
            color: Color(0xFF1A237E),
          ),
        ),
        if (_recentSearches.isNotEmpty)
          IconButton(
            onPressed: _clearSearchHistory,
            icon: const Icon(Icons.delete_forever, color: Colors.red),
            tooltip: "Xóa lịch sử",
          ),
      ],
    );
  }

  Widget _buildBottomNavBar() {
    return BottomNavigationBar(
      currentIndex: _currentIndex,
      selectedItemColor: const Color(0xFF1565C0),
      unselectedItemColor: Colors.grey,
      onTap: (index) {
        if (index == 1) {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => MyTicketsScreen(sdt: widget.user.sdt)),
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
      items: const [
        BottomNavigationBarItem(icon: Icon(Icons.search), label: "Tìm kiếm"),
        BottomNavigationBarItem(icon: Icon(Icons.receipt_long), label: "Vé của tôi"),
        BottomNavigationBarItem(icon: Icon(Icons.person_outline), label: "Tài khoản"),
      ],
    );
  }

  BoxDecoration _cardDecoration() {
    return BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(12),
      boxShadow: [
        BoxShadow(
          color: Colors.grey.shade300,
          blurRadius: 6,
          offset: const Offset(0, 2),
        ),
      ],
    );
  }
}

// ==========================================================
// Widget hiển thị kết quả tìm kiếm gần đây
// ==========================================================
class _RecentSearch extends StatelessWidget {
  final String from;
  final String to;
  final String date;
  final VoidCallback onTap;

  const _RecentSearch({
    required this.from,
    required this.to,
    required this.date,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 6),
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
                Text(from, style: const TextStyle(fontWeight: FontWeight.bold)),
              ]),
              const SizedBox(height: 4),
              Row(children: [
                const Icon(Icons.circle, size: 10, color: Colors.red),
                const SizedBox(width: 6),
                Text(to, style: const TextStyle(fontWeight: FontWeight.bold)),
              ]),
              const SizedBox(height: 4),
              Text(date, style: const TextStyle(color: Colors.grey, fontSize: 13)),
            ]),
            const Icon(Icons.search, size: 20, color: Colors.grey),
          ],
        ),
      ),
    );
  }
}
