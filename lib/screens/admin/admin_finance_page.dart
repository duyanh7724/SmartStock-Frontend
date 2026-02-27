import 'package:flutter/material.dart';
import '../../services/api_service.dart';

class AdminFinancePage extends StatefulWidget {
  const AdminFinancePage({super.key});

  @override
  State<AdminFinancePage> createState() => _AdminFinancePageState();
}

class _AdminFinancePageState extends State<AdminFinancePage> {
  bool _isLoading = true;
  Map<String, dynamic> _totals = {};
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);
    try {
      final data = await ApiService.getDashboardFull();

      if (!mounted) return;

      final rootData =
          (data["data"] is Map<String, dynamic>) ? data["data"] : data;

      setState(() {
        _totals = Map<String, dynamic>.from(rootData["totals"] ?? {});
        _isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
  }

  String formatMoney(dynamic value) {
    if (value == null) return "0 đ";
    double numVal = double.tryParse(value.toString()) ?? 0;
    // Format: 1.000.000 đ
    return "${numVal.toStringAsFixed(0).replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]}.')} đ";
  }

  @override
  Widget build(BuildContext context) {
    double importCost =
        double.tryParse(_totals['total_import_cost']?.toString() ?? '0') ?? 0;
    double exportVal =
        double.tryParse(_totals['total_export_value']?.toString() ?? '0') ?? 0;
    double customerRev =
        double.tryParse(_totals['total_customer_revenue']?.toString() ?? '0') ??
            0;

    // Lợi nhuận = Doanh thu - Chi phí nhập
    double profit = customerRev - importCost;

    return Scaffold(
      appBar: AppBar(
        title: const Text("Báo cáo Tài chính"),
        backgroundColor: Colors.blue[800],
        foregroundColor: Colors.white,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: _loadData,
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                physics: const AlwaysScrollableScrollPhysics(),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (_error != null)
                      Text("Lỗi: $_error",
                          style: const TextStyle(color: Colors.red)),

                    const Text(
                      "Tổng quan dòng tiền",
                      style:
                          TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 16),

                    // 1. DOANH THU
                    _buildFinanceCard(
                      title: "Tổng thu bán hàng",
                      subtitle: "Doanh thu từ đơn khách hàng",
                      value: customerRev,
                      color: Colors.green,
                      icon: Icons.attach_money,
                    ),

                    const SizedBox(height: 16),

                    // 2. CHI PHÍ
                    _buildFinanceCard(
                      title: "Tổng chi nhập hàng",
                      subtitle: "Chi phí nhập kho từ nhà cung cấp",
                      value: importCost,
                      color: Colors.orange,
                      icon: Icons.money_off,
                    ),

                    const SizedBox(height: 16),

                    // 3. LỢI NHUẬN (ĐÃ FIX LỖI OVERFLOW)
                    Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: profit >= 0
                              ? [Colors.blue.shade800, Colors.blue.shade500]
                              : [Colors.red.shade800, Colors.red.shade500],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(
                            color: (profit >= 0 ? Colors.blue : Colors.red)
                                .withOpacity(0.3),
                            blurRadius: 10,
                            offset: const Offset(0, 5),
                          )
                        ],
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                "Lợi nhuận (Tạm tính)",
                                style: TextStyle(
                                    color: Colors.white70, fontSize: 16),
                              ),
                              SizedBox(height: 5),
                              Text(
                                "(Thu - Chi)",
                                style: TextStyle(
                                    color: Colors.white30, fontSize: 12),
                              ),
                            ],
                          ),
                          const SizedBox(width: 10),

                          // --- FIX: Dùng Expanded và FittedBox ---
                          Expanded(
                            child: FittedBox(
                              fit: BoxFit.scaleDown,
                              alignment: Alignment.centerRight,
                              child: Text(
                                formatMoney(profit),
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 26,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ),
                          // ---------------------------------------
                        ],
                      ),
                    ),

                    const SizedBox(height: 30),
                    const Text(
                      "Chỉ số khác",
                      style:
                          TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 10),

                    // 4. CHỈ SỐ KHÁC
                    Card(
                      elevation: 2,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12)),
                      child: ListTile(
                        contentPadding: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 8),
                        leading: Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                              color: Colors.purple.shade50,
                              borderRadius: BorderRadius.circular(8)),
                          child: const Icon(Icons.local_shipping,
                              color: Colors.purple),
                        ),
                        title: const Text("Giá trị xuất kho nội bộ",
                            style: TextStyle(fontSize: 14)),
                        subtitle: const Text(
                            "Hàng xuất đi nhưng không phải bán lẻ",
                            style: TextStyle(fontSize: 12)),
                        trailing: SizedBox(
                          width: 120, // Giới hạn chiều rộng cho text trailing
                          child: Text(
                            formatMoney(exportVal),
                            textAlign: TextAlign.right,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                                fontWeight: FontWeight.bold, fontSize: 15),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 10),
                    Card(
                      elevation: 2,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12)),
                      child: ListTile(
                        contentPadding: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 8),
                        leading: Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                              color: Colors.teal.shade50,
                              borderRadius: BorderRadius.circular(8)),
                          child:
                              const Icon(Icons.inventory, color: Colors.teal),
                        ),
                        title: const Text("Giá trị tồn kho hiện tại",
                            style: TextStyle(fontSize: 14)),
                        subtitle: const Text(
                            "Tổng giá trị hàng đang nằm trong kho",
                            style: TextStyle(fontSize: 12)),
                        trailing: SizedBox(
                          width: 120,
                          child: Text(
                            formatMoney(_totals['stock_value']),
                            textAlign: TextAlign.right,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                                fontWeight: FontWeight.bold, fontSize: 15),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
    );
  }

  Widget _buildFinanceCard({
    required String title,
    required String subtitle,
    required double value,
    required Color color,
    required IconData icon,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            blurRadius: 5,
            offset: const Offset(0, 3),
          )
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: color, size: 28),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title,
                    style: const TextStyle(
                        fontSize: 16, fontWeight: FontWeight.bold)),
                const SizedBox(height: 2),
                Text(subtitle,
                    style: const TextStyle(fontSize: 12, color: Colors.grey)),
              ],
            ),
          ),
          const SizedBox(width: 8),

          // --- FIX: Flexible và FittedBox ---
          Flexible(
            flex: 0,
            child: FittedBox(
              fit: BoxFit.scaleDown,
              child: Text(
                formatMoney(value),
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: color,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
