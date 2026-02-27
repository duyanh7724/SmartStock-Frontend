import 'package:flutter/material.dart';
import '../../services/api_service.dart';
import 'admin_order_detail.dart';

class AdminOrders extends StatefulWidget {
  const AdminOrders({super.key});

  @override
  State<AdminOrders> createState() => _AdminOrdersState();
}

class _AdminOrdersState extends State<AdminOrders> {
  bool loading = true;
  bool _updating = false;
  List orders = [];

  @override
  void initState() {
    super.initState();
    _loadOrders();
  }

  // ============================================================
  // LẤY DANH SÁCH ĐƠN (ADMIN)
  // ============================================================
  Future<void> _loadOrders() async {
    try {
      final data = await ApiService.getAllOrders();
      if (!mounted) return;

      setState(() {
        orders = data;
        loading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        loading = false;
      });
    }
  }

  // ============================================================
  // CẬP NHẬT TRẠNG THÁI ĐƠN
  // ============================================================
  Future<void> _setStatus(int id, String status) async {
    setState(() => _updating = true);

    final ok = await ApiService.updateOrderStatus(id: id, status: status);

    if (!mounted) return;

    setState(() => _updating = false);

    if (ok) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Đã cập nhật đơn #$id")),
      );
      _loadOrders(); // load lại danh sách
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Không thể cập nhật trạng thái")),
      );
    }
  }

  // ============================================================
  // XÓA ĐƠN
  // ============================================================
  Future<void> _deleteOrder(int id) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text("Xóa đơn hàng"),
        content: const Text("Bạn chắc chắn muốn xóa đơn này?"),
        actions: [
          TextButton(
            child: const Text("Hủy"),
            onPressed: () => Navigator.pop(context, false),
          ),
          TextButton(
            child: const Text("Xóa", style: TextStyle(color: Colors.red)),
            onPressed: () => Navigator.pop(context, true),
          ),
        ],
      ),
    );

    if (confirm != true) return;

    final ok = await ApiService.deleteOrder(id);

    if (ok) {
      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text("Đã xóa đơn")));
      _loadOrders();
    } else {
      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text("Xóa thất bại")));
    }
  }

  // ============================================================
  // GIAO DIỆN
  // ============================================================
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Đơn hàng khách")),
      body: loading
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                if (_updating) const LinearProgressIndicator(minHeight: 2),
                if (orders.isEmpty)
                  const Expanded(
                    child: Center(child: Text("Chưa có đơn hàng")),
                  )
                else
                  Expanded(
                    child: ListView.builder(
                      padding: const EdgeInsets.all(16),
                      itemCount: orders.length,
                      itemBuilder: (_, i) {
                        final o = orders[i];
                        final id = int.tryParse(o["id"].toString()) ?? 0;
                        final status = o["status"]?.toString() ?? "pending";
                        final total = double.tryParse(
                                o["total_amount"]?.toString() ?? "0") ??
                            0;

                        return Card(
                          child: ListTile(
                            title: Text(o["fullname"] ?? ""),
                            subtitle: Text(
                              "Ngày: ${o["created_at"]}\n"
                              "Địa chỉ: ${o["address"]}",
                            ),
                            isThreeLine: true,
                            leading: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  "${total.toStringAsFixed(0)} đ",
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: Colors.blue,
                                  ),
                                ),
                                const SizedBox(height: 6),
                                _StatusChip(status: status),
                              ],
                            ),
                            trailing: PopupMenuButton<String>(
                              onSelected: (value) {
                                if (value == "approve") {
                                  _setStatus(id, "approved");
                                } else if (value == "reject") {
                                  _setStatus(id, "rejected");
                                } else if (value == "delete") {
                                  _deleteOrder(id);
                                }
                              },
                              itemBuilder: (_) => const [
                                PopupMenuItem(
                                    value: "approve", child: Text("Duyệt đơn")),
                                PopupMenuItem(
                                    value: "reject", child: Text("Từ chối")),
                                PopupMenuItem(
                                  value: "delete",
                                  child: Text("Xóa đơn",
                                      style: TextStyle(color: Colors.red)),
                                ),
                              ],
                            ),
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => AdminOrderDetail(order: o),
                                ),
                              );
                            },
                          ),
                        );
                      },
                    ),
                  ),
              ],
            ),
    );
  }
}

// ============================================================
// STATUS CHIP
// ============================================================
class _StatusChip extends StatelessWidget {
  final String status;
  const _StatusChip({required this.status});

  Color get _color {
    switch (status) {
      case "approved":
        return Colors.green;
      case "rejected":
        return Colors.red;
      default:
        return Colors.orange;
    }
  }

  String get _label {
    switch (status) {
      case "approved":
        return "Đã duyệt";
      case "rejected":
        return "Từ chối";
      default:
        return "Chờ duyệt";
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: _color.withOpacity(0.12),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        _label,
        style: TextStyle(
          color: _color,
          fontWeight: FontWeight.w600,
          fontSize: 12,
        ),
      ),
    );
  }
}
