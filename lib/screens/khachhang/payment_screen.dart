import 'package:flutter/material.dart';
import '../../services/booking_service.dart';
import '../../models/trip_info.dart';

class PaymentScreen extends StatefulWidget {
  final int veId; // ví dụ: 1
  const PaymentScreen({super.key, required this.veId});

  @override
  State<PaymentScreen> createState() => _PaymentScreenState();
}

class _PaymentScreenState extends State<PaymentScreen> {
  final svc = BookingService();

  // ----- UI state -----
  final _couponCtrl = TextEditingController();
  String? _appliedCoupon;
  double _discountRate = 0.0; // 0 → không giảm, 0.1 → giảm 10%
  int _method = 0;            // 0: QR, 1: Thẻ
  bool _agree = true;

  //  Bảo hiểm tai nạn
  bool _insurance = false;
  static const num _insuranceFee = 10000; // 10.000đ

  @override
  void dispose() {
    _couponCtrl.dispose();
    super.dispose();
  }

  String _formatVND(num n) {
    final s = n.toStringAsFixed(0);
    final re = RegExp(r'\B(?=(\d{3})+(?!\d))');
    return s.replaceAllMapped(re, (m) => '.') + ' đ';
  }

  void _applyCoupon(num basePrice) {
    final code = _couponCtrl.text.trim().toUpperCase();
    double rate = 0.0;
    if (code == 'GIAM10') rate = 0.10;
    if (code == 'SALE20') rate = 0.20;

    setState(() {
      if (rate > 0) {
        _discountRate = rate;
        _appliedCoupon = code;
      } else {
        _discountRate = 0;
        _appliedCoupon = null;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Mã không hợp lệ')),
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Thanh toán')),
      backgroundColor: const Color(0xFFF8F8F8),
      body: FutureBuilder<TripInfoDTO>(
        //  chỉ gọi 1 API đã tổng hợp toàn bộ dữ liệu
        future: svc.buildTripInfoFromVe(widget.veId),
        builder: (ctx, snap) {
          if (snap.connectionState != ConnectionState.done) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snap.hasError) {
            return Center(child: Text('Lỗi: ${snap.error}'));
          }

          final trip = snap.data!;
          final basePrice = trip.giaVe;
          final discount = basePrice * _discountRate;
          final subTotal = basePrice - discount;
          final total = subTotal + (_insurance ? _insuranceFee : 0);

          return Column(
            children: [
              Expanded(
                child: ListView(
                  padding: const EdgeInsets.all(16),
                  children: [
                    // Thông tin chuyến đi
                    _card(
                      title: 'Thông tin chuyến đi',
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _row('Chuyến xe', trip.nhaXe),
                          _row('Loại xe', trip.loaiXe),
                          _row('Biển số', trip.bienSo),
                          _row('Giờ đi', trip.gioDi),
                          _row('Từ', trip.benDi),
                          _row('Đến', trip.benDen),
                          const Divider(height: 20),
                          _row('Khách hàng', trip.khName),
                          _row('Số điện thoại', trip.khSdt),
                          _row('Email', trip.khEmail),
                        ],
                      ),
                    ),
                    const SizedBox(height: 12),

                    // Mã giảm giá
                    _card(
                      title: 'Mã giảm giá',
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Expanded(
                                child: TextField(
                                  controller: _couponCtrl,
                                  decoration: const InputDecoration(
                                    hintText: 'Nhập mã (GIAM10, SALE20)',
                                    isDense: true,
                                    border: OutlineInputBorder(),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 8),
                              ElevatedButton(
                                onPressed: () => _applyCoupon(basePrice),
                                child: const Text('Áp dụng'),
                              )
                            ],
                          ),
                          if (_appliedCoupon != null) ...[
                            const SizedBox(height: 8),
                            Text(
                              'Đã áp dụng mã: $_appliedCoupon (-${(_discountRate * 100).toStringAsFixed(0)}%)',
                              style: const TextStyle(color: Colors.green),
                            ),
                          ]
                        ],
                      ),
                    ),
                    const SizedBox(height: 12),

                    //  Tiện ích bổ sung: Bảo hiểm tai nạn
                    _card(
                      title: 'Tiện ích bổ sung',
                      child: CheckboxListTile(
                        value: _insurance,
                        onChanged: (v) => setState(() => _insurance = v ?? false),
                        title: const Text('Bảo hiểm tai nạn'),
                        subtitle: Text(
                          'Hỗ trợ rủi ro khi di chuyển. Phí: ${_formatVND(_insuranceFee)}',
                          style: const TextStyle(color: Colors.black54),
                        ),
                        controlAffinity: ListTileControlAffinity.leading,
                        dense: true,
                      ),
                    ),
                    const SizedBox(height: 12),

                    // Phương thức thanh toán
                    _card(
                      title: 'Phương thức thanh toán',
                      child: Column(
                        children: [
                          RadioListTile<int>(
                            value: 0,
                            groupValue: _method,
                            onChanged: (v) => setState(() => _method = v ?? 0),
                            title: const Text(
                                'Chuyển khoản bằng mã QR (Momo, ViettelPay, ... )'),
                            secondary: const Icon(Icons.qr_code_2),
                            dense: true,
                          ),
                          RadioListTile<int>(
                            value: 1,
                            groupValue: _method,
                            onChanged: (v) => setState(() => _method = v ?? 1),
                            title: const Text('Thẻ ngân hàng (Visa/Master/JCB)'),
                            secondary: const Icon(Icons.credit_card),
                            dense: true,
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 12),

                    // Đồng ý điều khoản
                    _card(
                      child: CheckboxListTile(
                        value: _agree,
                        onChanged: (v) => setState(() => _agree = v ?? false),
                        title: const Text(
                            'Tôi đồng ý với Chính sách bảo mật thông tin và Quy chế.'),
                        controlAffinity: ListTileControlAffinity.leading,
                        dense: true,
                      ),
                    ),
                    const SizedBox(height: 16),
                  ],
                ),
              ),

              // Thanh tổng tiền + nút thanh toán
              Container(
                padding: const EdgeInsets.fromLTRB(16, 12, 16, 20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.06),
                      blurRadius: 8,
                      offset: const Offset(0, -3),
                    ),
                  ],
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Chi tiết nếu có giảm/ bảo hiểm
                    if (_discountRate > 0 || _insurance) ...[
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text('Tạm tính',
                              style: TextStyle(
                                  fontSize: 13, color: Colors.black54)),
                          Text(_formatVND(basePrice),
                              style: const TextStyle(
                                  decoration: TextDecoration.lineThrough,
                                  color: Colors.black45)),
                        ],
                      ),
                      const SizedBox(height: 4),
                      if (_discountRate > 0)
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text('Giảm giá',
                                style: TextStyle(
                                    fontSize: 13, color: Colors.black54)),
                            Text('- ${_formatVND(discount)}',
                                style: const TextStyle(color: Colors.green)),
                          ],
                        ),
                      if (_insurance) ...[
                        const SizedBox(height: 4),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text('Bảo hiểm tai nạn',
                                style: TextStyle(
                                    fontSize: 13, color: Colors.black54)),
                            Text('+ ${_formatVND(_insuranceFee)}',
                                style: const TextStyle(color: Colors.black87)),
                          ],
                        ),
                      ],
                      const SizedBox(height: 6),
                    ],
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text('Tổng tiền',
                            style: TextStyle(fontWeight: FontWeight.w700)),
                        Text(
                          _formatVND(total),
                          style: const TextStyle(
                            fontSize: 18,
                            color: Colors.orange,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.amber,
                              foregroundColor: Colors.black87,
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 28, vertical: 14),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                            ),
                            onPressed: !_agree
                                ? null
                                : () {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text(
                                      'Đã thanh toán ${_formatVND(total)} bằng ${_method == 0 ? 'QR' : 'Thẻ'}'),
                                ),
                              );
                            },
                            child: const Text('Thanh toán'),
                          ),
                        ),
                      ],
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

  // ------- widget phụ -------
  Widget _card({String? title, required Widget child}) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 6,
              offset: const Offset(0, 2)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (title != null)
            Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Text(title,
                  style: const TextStyle(
                      fontSize: 16, fontWeight: FontWeight.w600)),
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
      Flexible(
        child: Text(
          v,
          textAlign: TextAlign.right,
          style: const TextStyle(fontWeight: FontWeight.w600),
        ),
      ),
    ],
  );
}
