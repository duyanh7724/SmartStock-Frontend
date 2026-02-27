// lib/screens/admin/admin_dashboard.dart
import 'package:flutter/material.dart';
import '../../services/api_service.dart';

class AdminDashboard extends StatefulWidget {
  const AdminDashboard({super.key});

  @override
  State<AdminDashboard> createState() => _AdminDashboardState();
}

class _AdminDashboardState extends State<AdminDashboard> {
  Map<String, dynamic>? _data;
  bool _loading = true;
  String? _error;

  List<Map<String, dynamic>> allProducts = [];
  String searchText = "";

  @override
  void initState() {
    super.initState();
    _loadDashboard();
  }

  Future<void> _loadDashboard() async {
    if (!mounted) return;
    setState(() {
      _loading = true;
      _error = null;
    });

    try {
      final data = await ApiService.getDashboardFull();
      final list = await ApiService.getProducts();

      if (!mounted) return;

      setState(() {
        _data = data;
        allProducts = List<Map<String, dynamic>>.from(list);
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

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_error != null) {
      return Center(child: Text("Lỗi: $_error"));
    }

    final root = _data ?? {};
    final data = (root["data"] is Map<String, dynamic>)
        ? Map<String, dynamic>.from(root["data"])
        : Map<String, dynamic>.from(root);

    final totals = (data["totals"] ?? {}) as Map<String, dynamic>;

    final recent =
        List<Map<String, dynamic>>.from(data["recent_products"] ?? []);
    final lowStock = List<Map<String, dynamic>>.from(data["low_stock"] ?? []);
    final topSelling =
        List<Map<String, dynamic>>.from(data["top_selling"] ?? []);

    final searchResults = allProducts.where((p) {
      return p['name']
          .toString()
          .toLowerCase()
          .contains(searchText.toLowerCase());
    }).toList();

    // [ĐÃ SỬA] Bỏ Scaffold và AppBar, chỉ trả về RefreshIndicator
    return RefreshIndicator(
      onRefresh: _loadDashboard,
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // [ĐÃ SỬA] Đổi tiêu đề chung chung
            const Text(
              "Tổng quan kho hàng",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 12),

            // SEARCH BAR
            TextField(
              decoration: InputDecoration(
                hintText: "Tìm kiếm sản phẩm...",
                prefixIcon: const Icon(Icons.search),
                filled: true,
                fillColor: Colors.grey.shade200,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
              ),
              onChanged: (t) => setState(() => searchText = t),
            ),
            const SizedBox(height: 20),

            if (searchText.isNotEmpty) ...[
              const Text(
                "Kết quả tìm kiếm",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 10),
              _horizontalList(searchResults),
              const SizedBox(height: 30),
            ],

            if (searchText.isEmpty) ...[
              _statGrid(totals),
              const SizedBox(height: 25),
              const Text("Sản phẩm mới thêm",
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              const SizedBox(height: 10),
              _horizontalList(recent),
              const SizedBox(height: 25),
              const Text("Sắp hết hàng (≤5)",
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              const SizedBox(height: 10),
              _horizontalList(lowStock, highlightLowStock: true),
              const SizedBox(height: 25),
              const Text("Top bán chạy",
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              const SizedBox(height: 10),
              _horizontalList(topSelling, showSoldBadge: true),
            ]
          ],
        ),
      ),
    );
  }

  // ============================
  // GRID THỐNG KÊ
  // ============================
  Widget _statGrid(Map<String, dynamic> totals) {
    int getInt(String key) {
      final v = totals[key];
      if (v == null) return 0;
      return int.tryParse(v.toString()) ?? 0;
    }

    String money(String key) {
      final v = totals[key];
      final numVal = num.tryParse(v?.toString() ?? '0') ?? 0;
      final formatted = numVal.toStringAsFixed(0).replaceAllMapped(
          RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]}.');

      return "$formatted đ";
    }

    final items = [
      ["Sản phẩm", Icons.inventory_2, getInt("products").toString()],
      ["Phiếu nhập", Icons.add, getInt("imports").toString()],
      ["Phiếu xuất", Icons.outbox, getInt("exports").toString()],
      ["Đơn hàng", Icons.shopping_cart, getInt("orders").toString()],
      ["Nhà cung cấp", Icons.store, getInt("suppliers").toString()],
      ["Người dùng", Icons.people, getInt("users").toString()],
      ["Giá trị tồn kho", Icons.trending_up, money("stock_value")],
      ["Doanh thu tuần", Icons.show_chart, money("weekly_revenue")],
      ["Doanh thu tháng", Icons.bar_chart, money("monthly_revenue")],
    ];

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: items.length,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: 2.4,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
      ),
      itemBuilder: (_, i) {
        final it = items[i];
        return _statCard(it[0] as String, it[1] as IconData, it[2] as String);
      },
    );
  }

  Widget _statCard(String label, IconData icon, String value) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.blue.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(icon, size: 24, color: Colors.blue),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(label,
                      style: const TextStyle(fontSize: 12, color: Colors.grey)),
                  const SizedBox(height: 4),
                  Text(
                    value,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87),
                  )
                ],
              ),
            )
          ],
        ),
      ),
    );
  }

  // ============================
  // HORIZONTAL PRODUCT LIST
  // ============================
  Widget _horizontalList(
    List<Map<String, dynamic>> items, {
    bool highlightLowStock = false,
    bool showSoldBadge = false,
  }) {
    if (items.isEmpty) {
      return Container(
        height: 100,
        alignment: Alignment.center,
        child:
            const Text("Chưa có dữ liệu", style: TextStyle(color: Colors.grey)),
      );
    }

    return SizedBox(
      height: 220,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: items.length,
        separatorBuilder: (_, __) => const SizedBox(width: 12),
        itemBuilder: (_, i) {
          return _productCard(
            items[i],
            highlightLowStock: highlightLowStock,
            showSoldBadge: showSoldBadge,
          );
        },
      ),
    );
  }

  // ============================
  // PRODUCT CARD
  // ============================
  Widget _productCard(
    Map<String, dynamic> p, {
    bool highlightLowStock = false,
    bool showSoldBadge = false,
  }) {
    final name = p["name"]?.toString() ?? "";

    final imageName = p["image"]?.toString() ?? "";
    final imgUrl = imageName.isEmpty
        ? "${ApiService.baseUrl}/uploads/no_image.jpg"
        : "${ApiService.baseUrl}/uploads/$imageName";

    final price = num.tryParse(p["price"].toString()) ?? 0;
    final qty = num.tryParse(p["quantity"]?.toString() ?? "0") ??
        (num.tryParse(p["sold"]?.toString() ?? "0") ?? 0);

    final priceText =
        "${price.toStringAsFixed(0).replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]}.')} đ";

    final isLow = highlightLowStock && qty <= 5;

    return Container(
      width: 160,
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: Image.network(
              imgUrl,
              height: 100,
              width: double.infinity,
              fit: BoxFit.cover,
              errorBuilder: (_, __, ___) => Container(
                height: 100,
                color: Colors.grey.shade300,
                child: const Icon(Icons.broken_image, color: Colors.grey),
              ),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            name,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
          ),
          const Spacer(),
          Text(
            priceText,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              color: Colors.blue,
              fontSize: 14,
            ),
          ),
          const SizedBox(height: 4),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
            decoration: BoxDecoration(
              color: isLow
                  ? Colors.red.withOpacity(0.1)
                  : Colors.grey.withOpacity(0.1),
              borderRadius: BorderRadius.circular(4),
            ),
            child: Text(
              showSoldBadge ? "Đã bán: $qty" : "Kho: $qty",
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w500,
                color: isLow ? Colors.red : Colors.black87,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
