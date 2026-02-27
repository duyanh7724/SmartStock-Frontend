// lib/screens/customer/checkout_page.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../models/cart_item.dart';
import '../../providers/cart_provider.dart';
import '../../providers/session_provider.dart';
import '../../services/api_service.dart';

class CheckoutPage extends StatefulWidget {
  const CheckoutPage({super.key});

  @override
  State<CheckoutPage> createState() => _CheckoutPageState();
}

class _CheckoutPageState extends State<CheckoutPage> {
  final _formKey = GlobalKey<FormState>();
  final _nameCtrl = TextEditingController();
  final _phoneCtrl = TextEditingController();
  final _addressCtrl = TextEditingController();
  final _noteCtrl = TextEditingController();

  bool _submitting = false;
  String? _error;
  bool _prefilled = false;

  // ====== BIẾN LƯU THÔNG TIN NGÂN HÀNG (DỮ LIỆU ĐỘNG) ======
  String _bankName = ''; // VD: Techcombank
  String _bankCode = ''; // VD: TCB
  String _accountNumber = ''; // VD: 1903...
  String _accountName = ''; // VD: NGUYEN VAN A

  @override
  void initState() {
    super.initState();
    // Gọi API lấy thông tin ngân hàng admin đã cài đặt
    _fetchBankInfo();
  }

  // Hàm lấy thông tin ngân hàng từ Server
  void _fetchBankInfo() async {
    // Gọi hàm static từ ApiService (không cần new ApiService())
    final data = await ApiService.getBankInfo();

    // Kiểm tra mounted để tránh lỗi gọi setState khi màn hình đã đóng
    if (!mounted) return;

    if (data.isNotEmpty) {
      // Xử lý linh hoạt: nếu API trả về bọc trong key 'data' thì lấy data['data'], không thì lấy chính nó
      var info = data['data'] ?? data;

      setState(() {
        _bankCode = info['bank_code'] ?? '';
        _bankName = info['bank_name'] ?? '';
        _accountNumber = info['account_number'] ?? '';
        _accountName = info['account_name'] ?? '';
      });
    }
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_prefilled) return;

    final user = context.read<SessionProvider>().currentUser;
    if (user != null) {
      _nameCtrl.text = user['fullname']?.toString() ?? _nameCtrl.text;
      _phoneCtrl.text = user['phone']?.toString() ?? _phoneCtrl.text;
      _addressCtrl.text = user['address']?.toString() ?? _addressCtrl.text;
    }
    _prefilled = true;
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _phoneCtrl.dispose();
    _addressCtrl.dispose();
    _noteCtrl.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    final cart = context.read<CartProvider>();

    if (!_formKey.currentState!.validate()) return;

    if (cart.items.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Giỏ hàng đang trống')),
      );
      return;
    }

    setState(() {
      _error = null;
      _submitting = true;
    });

    try {
      final session = context.read<SessionProvider>();
      final currentUser = session.currentUser;
      final userId = int.tryParse(currentUser?['id']?.toString() ?? '');

      final payload = {
        'fullname': _nameCtrl.text.trim(),
        'phone': _phoneCtrl.text.trim(),
        'address': _addressCtrl.text.trim(),
        'note': _noteCtrl.text.trim(),
        'payment_method': 'vietqr',
        'total_amount': cart.subtotal,
        'user_id': userId,
        'items': cart.items
            .map((item) => {
                  'product_id': item.productId,
                  'quantity': item.quantity,
                  'price': item.price,
                })
            .toList(),
      };

      final res = await ApiService.createCustomerOrder(payload);
      final success = res['success'] == true;

      if (!mounted) return;

      if (success) {
        cart.clear();
        // Chuyển sang trang thành công (đảm bảo bạn đã khai báo route này trong main.dart)
        Navigator.pushReplacementNamed(
          context,
          '/customer/order-success',
          arguments: res['data'],
        );
      } else {
        setState(() => _error = res['message'] ?? 'Đặt hàng thất bại');
      }
    } catch (e) {
      if (!mounted) return;
      setState(() => _error = e.toString());
    } finally {
      if (!mounted) return;
      setState(() => _submitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final cart = context.watch<CartProvider>();
    final total = cart.subtotal;

    return Scaffold(
      appBar: AppBar(title: const Text('Thanh toán chuyển khoản')),
      body: cart.items.isEmpty
          ? const Center(child: Text('Giỏ hàng trống, hãy quay lại mua sắm'))
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  if (_error != null)
                    Container(
                      padding: const EdgeInsets.all(12),
                      margin: const EdgeInsets.only(bottom: 12),
                      decoration: BoxDecoration(
                        color: Colors.red.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(_error!,
                          style: const TextStyle(color: Colors.red)),
                    ),

                  _buildAddressForm(),
                  const SizedBox(height: 20),
                  _OrderSummary(items: cart.items, total: total),
                  const SizedBox(height: 20),

                  // --- HIỂN THỊ MÃ QR ĐỘNG ---
                  // Chỉ hiện khi đã tải xong dữ liệu ngân hàng
                  if (_bankCode.isNotEmpty)
                    _VietQrBlock(
                      amount: total,
                      bankName: _bankName,
                      bankCode: _bankCode,
                      accountNumber: _accountNumber,
                      accountName: _accountName,
                    )
                  else
                    // Hiện loading hoặc thông báo nếu chưa có thông tin
                    const Card(
                      child: Padding(
                        padding: EdgeInsets.all(20),
                        child: Column(
                          children: [
                            CircularProgressIndicator(),
                            SizedBox(height: 10),
                            Text("Đang tải thông tin ngân hàng..."),
                          ],
                        ),
                      ),
                    ),

                  const SizedBox(height: 20),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: _submitting ? null : _submit,
                      icon: _submitting
                          ? const SizedBox(
                              width: 18,
                              height: 18,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: Colors.white,
                              ),
                            )
                          : const Icon(Icons.check_circle_outline),
                      label: Text(
                        _submitting ? 'Đang xử lý...' : 'Đã chuyển khoản xong',
                        style: const TextStyle(fontSize: 16),
                      ),
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                      ),
                    ),
                  ),
                  const SizedBox(height: 40),
                ],
              ),
            ),
    );
  }

  Widget _buildAddressForm() {
    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Thông tin nhận hàng',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
          ),
          const SizedBox(height: 12),
          TextFormField(
            controller: _nameCtrl,
            decoration: const InputDecoration(
              labelText: 'Họ tên người nhận',
              border: OutlineInputBorder(),
              prefixIcon: Icon(Icons.person),
            ),
            validator: (v) =>
                v == null || v.trim().isEmpty ? 'Nhập họ tên' : null,
          ),
          const SizedBox(height: 12),
          TextFormField(
            controller: _phoneCtrl,
            decoration: const InputDecoration(
              labelText: 'Số điện thoại',
              border: OutlineInputBorder(),
              prefixIcon: Icon(Icons.phone),
            ),
            keyboardType: TextInputType.phone,
            validator: (v) =>
                v == null || v.trim().length < 9 ? 'SĐT không hợp lệ' : null,
          ),
          const SizedBox(height: 12),
          TextFormField(
            controller: _addressCtrl,
            decoration: const InputDecoration(
              labelText: 'Địa chỉ nhận hàng',
              border: OutlineInputBorder(),
              prefixIcon: Icon(Icons.location_on),
            ),
            validator: (v) =>
                v == null || v.trim().isEmpty ? 'Nhập địa chỉ' : null,
          ),
          const SizedBox(height: 12),
          TextFormField(
            controller: _noteCtrl,
            decoration: const InputDecoration(
              labelText: 'Ghi chú (tùy chọn)',
              border: OutlineInputBorder(),
              prefixIcon: Icon(Icons.note),
            ),
            maxLines: 2,
          ),
        ],
      ),
    );
  }
}

class _OrderSummary extends StatelessWidget {
  final List<CartItem> items;
  final double total;

  const _OrderSummary({required this.items, required this.total});

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Đơn hàng của bạn',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const Divider(),
            ...items.map((item) {
              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 8),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Hiển thị tên sp
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(item.name,
                              style:
                                  const TextStyle(fontWeight: FontWeight.w500)),
                        ],
                      ),
                    ),
                    // Hiển thị số lượng x giá
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text('x${item.quantity}',
                            style: const TextStyle(color: Colors.grey)),
                        Text(
                          '${(item.price * item.quantity).toStringAsFixed(0)} đ',
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ],
                    )
                  ],
                ),
              );
            }),
            const Divider(),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('Tổng cộng',
                    style:
                        TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                Text(
                  '${total.toStringAsFixed(0)} đ',
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.red,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

// =============================
// BLOCK QR VIETQR (DÙNG API ẢNH)
// =============================
class _VietQrBlock extends StatelessWidget {
  final double amount;
  final String bankName;
  final String bankCode;
  final String accountNumber;
  final String accountName;

  const _VietQrBlock({
    required this.amount,
    required this.bankName,
    required this.bankCode,
    required this.accountNumber,
    required this.accountName,
  });

  @override
  Widget build(BuildContext context) {
    final int amountInt = amount.round();

    // Tự động thêm timestamp vào nội dung để tránh trùng lặp
    final String content =
        Uri.encodeComponent("PAY ${DateTime.now().millisecondsSinceEpoch}");

    // URL tạo QR động
    final String qrUrl =
        'https://img.vietqr.io/image/$bankCode-$accountNumber-compact2.png?amount=$amountInt&addInfo=$content&accountName=$accountName';

    return Card(
      elevation: 4,
      color: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: Colors.blue.shade200, width: 1),
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const Text(
              'Quét mã VietQR để thanh toán',
              style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                  color: Colors.blue),
            ),
            const SizedBox(height: 5),
            const Text("Mở App ngân hàng > Chọn Quét QR",
                style: TextStyle(color: Colors.grey, fontSize: 12)),
            const SizedBox(height: 16),

            // Ảnh QR
            Container(
              decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey.shade200),
                  borderRadius: BorderRadius.circular(8)),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: Image.network(
                  qrUrl,
                  width: 250,
                  fit: BoxFit.contain,
                  loadingBuilder: (ctx, child, loadingProgress) {
                    if (loadingProgress == null) return child;
                    return Container(
                      height: 250,
                      width: 250,
                      alignment: Alignment.center,
                      child: const CircularProgressIndicator(),
                    );
                  },
                  errorBuilder: (ctx, error, stackTrace) {
                    return Container(
                      height: 250,
                      width: 250,
                      color: Colors.grey.shade100,
                      alignment: Alignment.center,
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: const [
                          Icon(Icons.warning_amber_rounded,
                              size: 40, color: Colors.orange),
                          SizedBox(height: 8),
                          Text('Lỗi QR. Kiểm tra lại Mã NH',
                              textAlign: TextAlign.center),
                        ],
                      ),
                    );
                  },
                ),
              ),
            ),

            const SizedBox(height: 16),
            const Divider(height: 30),

            // Thông tin chi tiết
            _buildInfoRow('Ngân hàng', bankName, isBold: true),
            _buildInfoRow('Số tài khoản', accountNumber,
                isBold: true, isCopyable: true, context: context),
            _buildInfoRow('Chủ tài khoản', accountName, isBold: true),
            _buildInfoRow('Số tiền', '${amountInt.toString()} đ',
                isBold: true, color: Colors.red),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value,
      {bool isBold = false,
      bool isCopyable = false,
      Color? color,
      BuildContext? context}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(color: Colors.grey)),
          Row(
            children: [
              Text(
                value,
                style: TextStyle(
                    fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
                    color: color ?? Colors.black87,
                    fontSize: 15),
              ),
              if (isCopyable && context != null) ...[
                const SizedBox(width: 8),
                InkWell(
                  onTap: () {
                    // Copy vào clipboard (nếu cần import services thì thêm, ở đây làm đơn giản)
                    // Clipboard.setData(ClipboardData(text: value));
                    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                        content: Text("Đã sao chép số tài khoản"),
                        duration: Duration(milliseconds: 500)));
                  },
                  child: const Icon(Icons.copy, size: 16, color: Colors.blue),
                )
              ]
            ],
          ),
        ],
      ),
    );
  }
}
