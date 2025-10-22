import 'package:flutter/material.dart';
import '../../config/api.dart';
import '../../models/trip_info.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../services/Payment_Service.dart';

class PaymentScreen extends StatefulWidget {
  final int veId;
  const PaymentScreen({super.key, required this.veId});

  @override
  State<PaymentScreen> createState() => _PaymentScreenState();
}

class _PaymentScreenState extends State<PaymentScreen> {

  late Future<TripInfoDTO> _futureSummary;
  num _basePrice = 0;
  num _total = 0;


  final _couponCtrl = TextEditingController();
  String? _appliedCoupon;
  bool _insurance = false;
  int _method = 0;
  bool _agree = true;

  @override
  void initState() {
    super.initState();
    _futureSummary = _loadSummary();
    _futureSummary.then((s) {
      if (!mounted) return;
      setState(() {
        _basePrice = s.price;
        _total = s.price;
      });
    });
  }

  @override
  void dispose() {
    _couponCtrl.dispose();
    super.dispose();
  }

  Future<TripInfoDTO> _loadSummary() async {
    final r = await Api.get('/booking/${widget.veId}/summary');
    return TripInfoDTO.fromSummary(r.data);
  }

  Future<void> _recalcTotal() async {
    final r = await Api.post('/booking/${widget.veId}/quote', {
      'coupon': _appliedCoupon,
      'insurance': _insurance,
    });
    setState(() => _total = (r.data['total'] as num?) ?? _basePrice);
  }

  Future<void> _checkout() async {
    if (!_agree) return;


    if (_method == 0) {
      final paymentUrl = await PaymentService.createVNPay(widget.veId, _total.toDouble());
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


    final r = await Api.post('/booking/${widget.veId}/checkout', {
      'coupon': _appliedCoupon,
      'insurance': _insurance,
      'method': _method == 0 ? 'qr' : 'card',
    });

    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('${r.data['message'] ?? 'Thanh toán thành công'}')),
    );
  }


  String _vnd(num n) =>
      n.toStringAsFixed(0).replaceAllMapped(RegExp(r'\B(?=(\d{3})+(?!\d))'), (m) => '.') + ' đ';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Thanh toán')),
      backgroundColor: const Color(0xFFF8F8F8),
      body: FutureBuilder<TripInfoDTO>(
        future: _futureSummary,
        builder: (ctx, snap) {
          if (snap.connectionState != ConnectionState.done) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snap.hasError) return Center(child: Text('Lỗi: ${snap.error}'));
          final s = snap.data!;

          return Column(
            children: [
              Expanded(
                child: ListView(
                  padding: const EdgeInsets.all(16),
                  children: [
                    _card(
                      child: Column(
                        children: [
                          _row('Mã vé', '#${s.ticketId}'),
                          const Divider(height: 20),
                          _row('Khách hàng', s.khName),
                          const SizedBox(height: 6),
                          _row('Số điện thoại', s.khSdt),
                        ],
                      ),
                    ),
                    const SizedBox(height: 12),
                    _card(
                      title: 'Mã giảm giá',
                      child: Row(
                        children: [
                          Expanded(
                            child: TextField(
                              controller: _couponCtrl,
                              decoration: const InputDecoration(
                                isDense: true,
                                hintText: 'Nhập mã (GIAM10, SALE20)',
                                border: OutlineInputBorder(),
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          ElevatedButton(
                            onPressed: () async {
                              final code = _couponCtrl.text.trim().toUpperCase();
                              setState(() => _appliedCoupon = code.isEmpty ? null : code);
                              await _recalcTotal();
                            },
                            child: const Text('Áp dụng'),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 12),
                    _card(
                      title: 'Tiện ích bổ sung',
                      child: CheckboxListTile(
                        value: _insurance,
                        onChanged: (v) async {
                          setState(() => _insurance = v ?? false);
                          await _recalcTotal();
                        },
                        title: const Text('Bảo hiểm tai nạn'),
                        subtitle: const Text('Phí: 10.000 đ'),
                        controlAffinity: ListTileControlAffinity.leading,
                        dense: true,
                      ),
                    ),
                    const SizedBox(height: 12),
                    _card(
                      title: 'Phương thức thanh toán',
                      child: Column(
                        children: [
                          RadioListTile<int>(
                            value: 0,
                            groupValue: _method,
                            onChanged: (v) => setState(() => _method = v ?? 0),
                            title: const Text('Chuyển khoản mã QR'),
                            secondary: const Icon(Icons.qr_code_2),
                            dense: true,
                          ),
                          RadioListTile<int>(
                            value: 1,
                            groupValue: _method,
                            onChanged: (v) => setState(() => _method = v ?? 1),
                            title: const Text('Thẻ ngân hàng (Visa/Master)'),
                            secondary: const Icon(Icons.credit_card),
                            dense: true,
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 12),
                    _card(
                      child: CheckboxListTile(
                        value: _agree,
                        onChanged: (v) => setState(() => _agree = v ?? false),
                        title: const Text('Tôi đồng ý với Chính sách và Quy chế.'),
                        controlAffinity: ListTileControlAffinity.leading,
                        dense: true,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.fromLTRB(16, 12, 16, 20),
                color: Colors.white,
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('Tổng tiền', style: TextStyle(fontWeight: FontWeight.w700)),
                          Text(_vnd(_total),
                              style: const TextStyle(
                                  fontSize: 18, color: Colors.orange, fontWeight: FontWeight.bold)),
                        ],
                      ),
                    ),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.amber,
                        foregroundColor: Colors.black87,
                        padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 14),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                      ),
                      onPressed: !_agree ? null : _checkout,
                      child: const Text('Thanh toán'),
                    ),
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _card({String? title, required Widget child}) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 6, offset: const Offset(0, 2))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (title != null)
            Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Text(title, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
            ),
          child,
        ],
      ),
    );
  }

  Widget _row(String k, String v) => Row(
    mainAxisAlignment: MainAxisAlignment.spaceBetween,
    children: [
      Text(k, style: const TextStyle(color: Colors.black54)),
      Flexible(child: Text(v, textAlign: TextAlign.right, style: const TextStyle(fontWeight: FontWeight.w600))),
    ],
  );
}
