// lib/screens/staff/staff_export_create.dart
import 'package:flutter/material.dart';
import '../../services/api_service.dart';

class StaffExportCreate extends StatefulWidget {
  final int userId;

  const StaffExportCreate({super.key, required this.userId});

  @override
  State<StaffExportCreate> createState() => _StaffExportCreateState();
}

class _StaffExportCreateState extends State<StaffExportCreate> {
  List products = [];
  bool loading = true;

  int? selectedProduct;
  final qtyCtrl = TextEditingController();
  final priceCtrl = TextEditingController();

  List<Map<String, dynamic>> exportItems = [];

  @override
  void initState() {
    super.initState();
    _loadProducts();
  }

  Future<void> _loadProducts() async {
    products = await ApiService.getProducts();
    setState(() => loading = false);
  }

  void _addItem() {
    if (selectedProduct == null ||
        qtyCtrl.text.isEmpty ||
        priceCtrl.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Nhập đủ dữ liệu')),
      );
      return;
    }

    exportItems.add({
      'product_id': selectedProduct,
      'quantity': int.parse(qtyCtrl.text),
      'price': double.parse(priceCtrl.text),
      'name': products.firstWhere(
          (p) => p['id'].toString() == selectedProduct.toString())['name'],
    });

    qtyCtrl.clear();
    priceCtrl.clear();
    setState(() {});
  }

  Future<void> _save() async {
    if (exportItems.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Chưa có sản phẩm trong phiếu')),
      );
      return;
    }

    final ok = await ApiService.addExportOrder(exportItems, widget.userId);

    if (ok) {
      Navigator.pop(context, true);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Tạo phiếu xuất thất bại')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    if (loading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      appBar: AppBar(title: const Text('Tạo phiếu xuất (Nhân viên)')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            DropdownButtonFormField<int>(
              value: selectedProduct,
              decoration: const InputDecoration(labelText: 'Chọn sản phẩm'),
              items: products.map((p) {
                return DropdownMenuItem(
                  value: int.parse(p['id'].toString()),
                  child: Text(p['name']),
                );
              }).toList(),
              onChanged: (v) => setState(() => selectedProduct = v),
            ),
            TextField(
              controller: qtyCtrl,
              decoration: const InputDecoration(labelText: 'Số lượng xuất'),
              keyboardType: TextInputType.number,
            ),
            TextField(
              controller: priceCtrl,
              decoration: const InputDecoration(labelText: 'Đơn giá xuất'),
              keyboardType: TextInputType.number,
            ),
            const SizedBox(height: 15),
            ElevatedButton(
              onPressed: _addItem,
              child: const Text('Thêm sản phẩm'),
            ),
            const SizedBox(height: 20),
            Expanded(
              child: exportItems.isEmpty
                  ? const Center(child: Text('Chưa có sản phẩm'))
                  : ListView.builder(
                      itemCount: exportItems.length,
                      itemBuilder: (_, i) {
                        final item = exportItems[i];
                        return Card(
                          child: ListTile(
                            title: Text(item['name']),
                            subtitle: Text(
                                'SL: ${item['quantity']} • Giá: ${item['price']} đ'),
                            trailing: IconButton(
                              icon: const Icon(Icons.delete, color: Colors.red),
                              onPressed: () {
                                exportItems.removeAt(i);
                                setState(() {});
                              },
                            ),
                          ),
                        );
                      },
                    ),
            ),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _save,
                child: const Text('Lưu phiếu xuất'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
