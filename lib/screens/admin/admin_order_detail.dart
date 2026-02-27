import 'package:flutter/material.dart';
import '../../services/api_service.dart';

class AdminOrderDetail extends StatefulWidget {
  final Map<String, dynamic> order;

  const AdminOrderDetail({super.key, required this.order});

  @override
  State<AdminOrderDetail> createState() => _AdminOrderDetailState();
}

class _AdminOrderDetailState extends State<AdminOrderDetail> {
  bool loading = true;
  List items = [];

  @override
  void initState() {
    super.initState();
    _loadDetail();
  }

  Future<void> _loadDetail() async {
    try {
      final id = int.tryParse(widget.order["id"].toString());
      if (id == null) return;

      final data = await ApiService.getOrderDetail(id);

      if (!mounted) return;
      setState(() {
        items = data;
        loading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        loading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Đơn hàng #${widget.order['id']}"),
      ),
      body: loading
          ? const Center(child: CircularProgressIndicator())
          : ListView(
              padding: const EdgeInsets.all(16),
              children: [
                // ======================
                // THÔNG TIN KHÁCH HÀNG
                // ======================
                Text(
                  "Thông tin khách hàng",
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                const SizedBox(height: 8),

                Text("👤 ${widget.order['fullname']}"),
                Text("📞 ${widget.order['phone']}"),
                Text("🏠 ${widget.order['address']}"),
                if (widget.order['note'] != null &&
                    widget.order['note'].toString().trim().isNotEmpty)
                  Text("📝 Ghi chú: ${widget.order['note']}"),

                const SizedBox(height: 20),

                // ======================
                // DANH SÁCH SẢN PHẨM
                // ======================
                Text(
                  "Sản phẩm đã mua",
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                const SizedBox(height: 8),

                ...items.map((i) {
                  return Card(
                    child: ListTile(
                      leading: Image.network(
                        i["image_url"] ?? "",
                        width: 50,
                        height: 50,
                        fit: BoxFit.cover,
                        errorBuilder: (_, __, ___) =>
                            const Icon(Icons.image_not_supported),
                      ),
                      title: Text(i["product_name"] ?? ""),
                      subtitle: Text(
                        "SL: ${i['quantity']}   •   Giá: ${i['price']} đ",
                      ),
                    ),
                  );
                }),

                const SizedBox(height: 20),

                Text(
                  "Tổng tiền: ${widget.order["total_amount"]} đ",
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.red,
                  ),
                )
              ],
            ),
    );
  }
}
