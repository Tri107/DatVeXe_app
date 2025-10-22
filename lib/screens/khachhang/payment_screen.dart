import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../config/api.dart';
import '../../models/Ve.dart';
import '../../services/Payment_Service.dart';

class PaymentScreen extends StatefulWidget {
  final int veId;
  const PaymentScreen({super.key, required this.veId});

  @override
  State<PaymentScreen> createState() => _PaymentScreenState();
}

class _PaymentScreenState extends State<PaymentScreen> {
  late Future<Ve> _futureVeSummary;
  num _basePrice = 0;
  num _insuranceFee = 0;
  num _totalPrice = 0;
  bool _useInsurance = false;
  int _paymentMethod = 0; // 0: MoMo, 1: VNPAY
  bool _isProcessing = false;

  @override
  void initState() {
    super.initState();
    _futureVeSummary = _loadSummary();
    _futureVeSummary.then((ve) {
      if (mounted) {
        setState(() {
          _basePrice = ve.veGia;
          _calculateTotal(); // Tính toán tổng tiền ban đầu
        });
      }
    }).catchError((error) {
      print("Lỗi không thể tải thông tin vé: $error");
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text('Lỗi: Không thể tải thông tin vé. $error'),
              backgroundColor: Colors.red),
        );
      }
    });
  }

  Future<Ve> _loadSummary() async {
    // Sửa endpoint để lấy thông tin lồng nhau nếu cần
    final response = await Api.get('/ve/${widget.veId}');
    return Ve.fromJson(response.data);
  }

  void _calculateTotal() {
    _insuranceFee = _useInsurance ? (_basePrice * 0.05) : 0;
    _totalPrice = _basePrice + _insuranceFee;
  }

  Future<void> _handleCheckout() async {
    setState(() => _isProcessing = true);
    // TODO: Thêm logic gọi API thanh toán MoMo/VNPAY
    if (_paymentMethod == 1) {
      final paymentUrl = await PaymentService.createVNPay(widget.veId, _totalPrice.toDouble());
      if (paymentUrl != null) {
        final uri = Uri.parse(paymentUrl);
        if (!await launchUrl(uri, mode: LaunchMode.externalApplication)) {
          throw Exception('Không thể mở liên kết $uri');
        }
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Không tạo được liên kết thanh toán VNPay')),
        );
      }
      return;
    }

    await Future.delayed(const Duration(seconds: 2));
    setState(() => _isProcessing = false);

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Chức năng thanh toán đang được phát triển.'),
        backgroundColor: Colors.blue,
      ),
    );
  }

  String _formatCurrency(num n) {
    return NumberFormat.currency(locale: 'vi_VN', symbol: 'đ').format(n);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Xác nhận và Thanh toán')),
      backgroundColor: const Color(0xFFF4F6F9),
      body: FutureBuilder<Ve>(
        future: _futureVeSummary,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError || !snapshot.hasData) {
            return Center(child: Text('Không thể tải dữ liệu vé. Vui lòng thử lại.'));
          }

          final ve = snapshot.data!;
          // === SỬA LỖI: Khai báo biến khachHang và chuyen ở đây ===

          return Column(
            children: [
              Expanded(
                child: ListView(
                  padding: const EdgeInsets.all(12.0),
                  children: [
                    _buildSectionCard(
                      title: 'Thông tin hành khách',
                      icon: Icons.person_outline,
                      children: [
                        // Sử dụng toán tử '??' để xử lý trường hợp null an toàn
                        _buildInfoRow('Họ và tên', ve.khachHangName ?? 'Không rõ'),
                        _buildInfoRow('Số điện thoại', ve.SDT ?? 'Không rõ'),
                      ],
                    ),
                    const SizedBox(height: 12),
                    _buildSectionCard(
                      title: 'Thông tin chuyến đi',
                      icon: Icons.directions_bus_outlined,
                      children: [
                        _buildInfoRow('Mã vé', '#${ve.veId}'),
                        _buildInfoRow('Tuyến xe', ve.chuyenName),

                        // SỬA Ở ĐÂY: Xử lý trường hợp ve.ngayGio là null


                        const Divider(height: 16),
                        _buildInfoRow(
                          'Giá vé gốc',
                          _formatCurrency(ve.veGia),
                          valueColor: Colors.black,
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    _buildSectionCard(
                      title: 'Tiện ích bổ sung',
                      icon: Icons.add_circle_outline,
                      children: [
                        CheckboxListTile(
                          value: _useInsurance,
                          onChanged: (value) {
                            setState(() {
                              _useInsurance = value ?? false;
                              _calculateTotal(); // Tính lại tổng tiền
                            });
                          },
                          title: const Text('Bảo hiểm chuyến đi', style: TextStyle(fontWeight: FontWeight.w500)),
                          subtitle: Text(
                            'Phí bảo hiểm: 5% giá vé (${_formatCurrency(_basePrice * 0.05)})',
                            style: TextStyle(color: Colors.grey[600]),
                          ),
                          controlAffinity: ListTileControlAffinity.leading,
                          dense: true,
                          contentPadding: EdgeInsets.zero,
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    _buildSectionCard(
                      title: 'Chọn phương thức thanh toán',
                      icon: Icons.payment_outlined,
                      children: [
                        RadioListTile<int>(
                          value: 0,
                          groupValue: _paymentMethod,
                          onChanged: (v) => setState(() => _paymentMethod = v ?? 0),
                          title: const Text('Thanh toán qua Ví MoMo'),
                          secondary: Image.network(
                            'https://cdn.haitrieu.com/wp-content/uploads/2022/10/Logo-MoMo-Circle.png',
                            width: 28, height: 28,
                            loadingBuilder: (context, child, progress) => progress == null ? child : CircularProgressIndicator(),
                            errorBuilder: (context, error, stackTrace) => Icon(Icons.payment),
                          ),
                        ),
                        RadioListTile<int>(
                          value: 1,
                          groupValue: _paymentMethod,
                          onChanged: (v) => setState(() => _paymentMethod = v ?? 1),
                          title: const Text('Thanh toán qua VNPAY'),
                          secondary: Image.network(
                            'https://vinadesign.vn/uploads/images/2023/05/vnpay-logo-vinadesign-25-12-57-55.jpg',
                            width: 28, height: 28,
                            loadingBuilder: (context, child, progress) => progress == null ? child : CircularProgressIndicator(),
                            errorBuilder: (context, error, stackTrace) => Icon(Icons.payment),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              _buildBottomBar(),
            ],
          );
        },
      ),
    );
  }

  // --- WIDGET HELPER ---
  Widget _buildSectionCard({ required String title, required IconData icon, required List<Widget> children,}) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 10, offset: const Offset(0, 4))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: Theme.of(context).primaryColor, size: 20),
              const SizedBox(width: 8),
              Text(title, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            ],
          ),
          const Divider(height: 20),
          ...children,
        ],
      ),
    );
  }

  Widget _buildInfoRow(String label, String value, {Color? valueColor}) => Padding(
    padding: const EdgeInsets.symmetric(vertical: 4.0),
    child: Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: const TextStyle(color: Colors.black54)),
        Flexible(
          child: Text(
            value,
            textAlign: TextAlign.right,
            style: TextStyle(fontWeight: FontWeight.w600, color: valueColor ?? Colors.black87),
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    ),
  );

  Widget _buildBottomBar() {
    return Container(
      padding: EdgeInsets.fromLTRB(16, 12, 16, MediaQuery.of(context).padding.bottom + 12),
      decoration: const BoxDecoration(
        color: Colors.white,
        boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 10, offset: Offset(0, -2))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        mainAxisSize: MainAxisSize.min,
        children: [
          _buildInfoRow('Giá vé gốc', _formatCurrency(_basePrice)),
          if (_useInsurance) _buildInfoRow('Phí bảo hiểm', '+ ${_formatCurrency(_insuranceFee)}'),
          const Divider(),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('Tổng cộng', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              Text(
                _formatCurrency(_totalPrice),
                style: const TextStyle(fontSize: 20, color: Colors.orange, fontWeight: FontWeight.bold),
              ),
            ],
          ),
          const SizedBox(height: 12),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.amber, foregroundColor: Colors.black87,
              padding: const EdgeInsets.symmetric(vertical: 14),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
            onPressed: _isProcessing ? null : _handleCheckout,
            child: _isProcessing
                ? const SizedBox(width: 24, height: 24, child: CircularProgressIndicator(strokeWidth: 3, color: Colors.black87))
                : Text('Thanh toán ${_formatCurrency(_totalPrice)}', style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }
}