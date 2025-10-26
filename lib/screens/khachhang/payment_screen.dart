import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../config/api.dart';
import '../../models/Ve.dart';
import '../../services/Payment_Service.dart';
import '../../themes/gradient.dart';
import 'payment_successful.dart';

class PaymentScreen extends StatefulWidget {
  final int veId;
  final String email; // vẫn giữ để không lỗi chỗ khác
  final int chuyenId;
  final double gia;

  const PaymentScreen({
    super.key,
    required this.veId,
    required this.email,
    required this.chuyenId,
    required this.gia,
  });

  @override
  State<PaymentScreen> createState() => _PaymentScreenState();
}

class _PaymentScreenState extends State<PaymentScreen> {
  late Future<Ve> _futureVeSummary;
  num _basePrice = 0;
  num _insuranceFee = 0;
  num _totalPrice = 0;
  bool _useInsurance = false;
  bool _isProcessing = false;

  @override
  void initState() {
    super.initState();
    _futureVeSummary = _loadSummary();
    _futureVeSummary.then((ve) {
      if (mounted) {
        setState(() {
          _basePrice = ve.veGia;
          _calculateTotal();
        });
      }
    }).catchError((error) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Không thể tải thông tin vé. $error')),
        );
      }
    });
  }

  Future<Ve> _loadSummary() async {
    final response = await Api.get('/ve/${widget.veId}');
    return Ve.fromJson(response.data);
  }

  void _calculateTotal() {
    _insuranceFee = _useInsurance ? (_basePrice * 0.05) : 0;
    _totalPrice = _basePrice + _insuranceFee;
  }

  /// 🔹 Xử lý thanh toán VNPay
  Future<void> _handleCheckout() async {
    setState(() => _isProcessing = true);

    try {
      final paymentUrl = await PaymentService.createVNPay(
        widget.veId,
        _totalPrice.toDouble(),
      );

      if (paymentUrl != null) {
        final uri = Uri.parse(paymentUrl);
        if (await canLaunchUrl(uri)) {
          await launchUrl(uri, mode: LaunchMode.externalApplication);
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text("Đang chờ xác nhận thanh toán từ VNPay..."),
              backgroundColor: Colors.blue,
            ),
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Không thể mở VNPay.')),
          );
        }
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Không tạo được liên kết VNPay.')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Lỗi khi xử lý thanh toán: $e')),
      );
    } finally {
      setState(() => _isProcessing = false);
    }
  }

  /// ✅ Khi backend xác nhận thanh toán thành công
  void _onPaymentSuccess() {
    // 🔹 Giữ nguyên code cũ để không conflict
    // Navigator.pushReplacement(
    //   context,
    //   MaterialPageRoute(builder: (_) => PaymentSuccessful(email: widget.email)),
    // );

    // 🔹 Code mới — gửi đúng mã vé để backend gửi mail đúng người
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (_) => PaymentSuccessful(veId: widget.veId),
      ),
    );
  }

  String _formatCurrency(num n) =>
      NumberFormat.currency(locale: 'vi_VN', symbol: '₫').format(n);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(60),
        child: Container(
          decoration: const BoxDecoration(gradient: AppGradients.primary),
          child: AppBar(
            backgroundColor: Colors.transparent,
            elevation: 0,
            centerTitle: true,
            leading: IconButton(
              icon: const Icon(Icons.arrow_back, color: Colors.white),
              onPressed: () {
                Navigator.pop(context, true);
              },
            ),
            title: const Text(
              'Xác nhận và Thanh toán',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ),
        ),
      ),
      body: FutureBuilder<Ve>(
        future: _futureVeSummary,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (!snapshot.hasData) {
            return const Center(child: Text('Không thể tải dữ liệu vé.'));
          }

          final ve = snapshot.data!;
          return Column(
            children: [
              Expanded(
                child: ListView(
                  padding: const EdgeInsets.all(12),
                  children: [
                    _buildSectionCard(
                      title: 'Thông tin hành khách',
                      icon: Icons.person_outline,
                      children: [
                        _buildInfoRow(
                          'Họ và tên',
                          ve.khachHangName ?? 'Không rõ',
                        ),
                        _buildInfoRow('Số điện thoại', ve.SDT ?? 'Không rõ'),
                      ],
                    ),
                    const SizedBox(height: 12),
                    _buildSectionCard(
                      title: 'Thông tin chuyến đi',
                      icon: Icons.directions_bus_outlined,
                      children: [
                        _buildInfoRow('Mã vé', '#${ve.veId}'),
                        _buildInfoRow('Tuyến xe', ve.chuyenName ?? 'Không rõ'),
                        const Divider(height: 16),
                        _buildInfoRow('Giá vé gốc', _formatCurrency(ve.veGia)),
                      ],
                    ),
                    const SizedBox(height: 12),
                    _buildSectionCard(
                      title: 'Tiện ích bổ sung',
                      icon: Icons.add_circle_outline,
                      children: [
                        CheckboxListTile(
                          value: _useInsurance,
                          onChanged: (v) {
                            setState(() {
                              _useInsurance = v ?? false;
                              _calculateTotal();
                            });
                          },
                          title: const Text('Bảo hiểm chuyến đi'),
                          subtitle: const Text('Phí bảo hiểm: 5% giá vé gốc'),
                          controlAffinity: ListTileControlAffinity.leading,
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    _buildSectionCard(
                      title: 'Phương thức thanh toán',
                      icon: Icons.payment_outlined,
                      children: [
                        ListTile(
                          leading: Image.network(
                            'https://vinadesign.vn/uploads/images/2023/05/vnpay-logo-vinadesign-25-12-57-55.jpg',
                            width: 32,
                            height: 32,
                          ),
                          title: const Text('Thanh toán qua VNPay'),
                          subtitle: const Text(
                            'Hỗ trợ thanh toán an toàn, nhanh chóng.',
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

  Widget _buildSectionCard({
    required String title,
    required IconData icon,
    required List<Widget> children,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 8),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: Colors.blue),
              const SizedBox(width: 8),
              Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
            ],
          ),
          const Divider(),
          ...children,
        ],
      ),
    );
  }

  Widget _buildInfoRow(String label, String value, {Color? valueColor}) =>
      Padding(
        padding: const EdgeInsets.symmetric(vertical: 4),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(label, style: const TextStyle(color: Colors.black54)),
            Flexible(
              child: Text(
                value,
                textAlign: TextAlign.right,
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                  color: valueColor ?? Colors.black,
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      );

  Widget _buildBottomBar() {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
      decoration: const BoxDecoration(
        color: Colors.white,
        boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 8)],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _buildInfoRow('Giá vé gốc', _formatCurrency(_basePrice)),
          if (_useInsurance)
            _buildInfoRow(
              'Phí bảo hiểm',
              '+ ${_formatCurrency(_insuranceFee)}',
            ),
          const Divider(),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Tổng cộng',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
              ),
              Text(
                _formatCurrency(_totalPrice),
                style: const TextStyle(
                  color: Colors.orange,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          ElevatedButton(
            onPressed: _isProcessing ? null : _handleCheckout,
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.amber,
              padding: const EdgeInsets.symmetric(vertical: 14),
            ),
            child: _isProcessing
                ? const CircularProgressIndicator(color: Colors.black)
                : Text(
              'Thanh toán ${_formatCurrency(_totalPrice)}',
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
