import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../providers/session_provider.dart';
import '../../services/api_service.dart';

class OrdersHistoryPage extends StatefulWidget {
  final Map<String, dynamic>? user;

  const OrdersHistoryPage({super.key, this.user});

  @override
  State<OrdersHistoryPage> createState() => _OrdersHistoryPageState();
}

class _OrdersHistoryPageState extends State<OrdersHistoryPage> {
  bool _loading = true;
  String? _error;
  List<dynamic> _orders = [];
  int? _userId;
  bool _initialized = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    if (_initialized) return;

    final sessionUser = context.read<SessionProvider>().currentUser;

    _userId = int.tryParse(
      widget.user?['id']?.toString() ?? sessionUser?['id']?.toString() ?? '',
    );

    _initialized = true;
    _loadOrders();
  }

  Future<void> _loadOrders() async {
    if (_userId == null) {
      setState(() {
        _loading = false;
        _error = "Không tìm thấy thông tin tài khoản.";
      });
      return;
    }

    setState(() {
      _loading = true;
      _error = null;
    });

    try {
      final data = await ApiService.getOrders(_userId!);

      if (!mounted) return;
      setState(() {
        _orders = data;
        _loading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _error = e.toString();
        _loading = false;
      });
    }
  }

  Color _statusColor(String status) {
    switch (status) {
      case 'approved':
        return Colors.green;
      case 'rejected':
        return Colors.red;
      default:
        return Colors.orange;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Đơn hàng của tôi")),
      body: RefreshIndicator(
        onRefresh: _loadOrders,
        child: _loading
            ? const Center(child: CircularProgressIndicator())
            : _error != null
                ? ListView(
                    children: [
                      SizedBox(
                        height: MediaQuery.of(context).size.height * 0.4,
                        child: Center(child: Text("Lỗi: $_error")),
                      ),
                    ],
                  )
                : _orders.isEmpty
                    ? ListView(
                        children: const [
                          SizedBox(height: 120),
                          Center(child: Text("Bạn chưa có đơn hàng nào.")),
                        ],
                      )
                    : ListView.builder(
                        padding: const EdgeInsets.all(16),
                        itemCount: _orders.length,
                        itemBuilder: (_, index) {
                          final order = _orders[index];
                          final status =
                              (order['status'] ?? 'pending').toString();
                          final total = double.tryParse(
                                  order['total_amount']?.toString() ?? '0') ??
                              0;

                          return Card(
                            margin: const EdgeInsets.only(bottom: 12),
                            child: ListTile(
                              title: Text("Đơn #${order['id']}"),
                              subtitle: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text("Ngày tạo: ${order['created_at']}"),
                                  Text(
                                      "Tổng tiền: ${total.toStringAsFixed(0)} đ"),
                                ],
                              ),
                              trailing: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(Icons.circle,
                                      color: _statusColor(status), size: 12),
                                  const SizedBox(height: 4),
                                  Text(
                                    status == 'approved'
                                        ? "Đã duyệt"
                                        : status == 'rejected'
                                            ? "Bị từ chối"
                                            : "Chờ duyệt",
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: _statusColor(status),
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ],
                              ),
                              onTap: () => _showOrderItems(order),
                            ),
                          );
                        },
                      ),
      ),
    );
  }

  void _showOrderItems(Map<String, dynamic> order) {
    final id = int.tryParse(order['id']?.toString() ?? '');
    if (id == null) return;

    showModalBottomSheet(
      context: context,
      builder: (_) => FutureBuilder<List<dynamic>>(
        future: ApiService.getOrderDetail(id),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const SizedBox(
              height: 200,
              child: Center(child: CircularProgressIndicator()),
            );
          }

          final details = snapshot.data ?? [];

          return SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    "Chi tiết đơn #$id",
                    style: const TextStyle(
                        fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 12),
                  if (details.isEmpty) const Text("Không có dữ liệu chi tiết."),
                  ...details.map((item) {
                    return ListTile(
                      contentPadding: EdgeInsets.zero,
                      title: Text(item['product_name']?.toString() ?? ''),
                      subtitle: Text(
                          "SL: ${item['quantity']} • Giá: ${item['price']} đ"),
                    );
                  }),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
