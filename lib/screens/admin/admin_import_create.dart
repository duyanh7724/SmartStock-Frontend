import 'package:flutter/material.dart';
import '../../services/api_service.dart';

class AdminImportCreate extends StatefulWidget {
  const AdminImportCreate({super.key});

  @override
  State<AdminImportCreate> createState() => _AdminImportCreateState();
}

class _AdminImportCreateState extends State<AdminImportCreate> {
  List products = [];
  bool loading = true;

  int? selectedProduct;
  final qtyCtrl = TextEditingController();
  final priceCtrl = TextEditingController();

  List<Map<String, dynamic>> importItems = [];

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
        qtyCtrl.text.trim().isEmpty ||
        priceCtrl.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Điền đủ dữ liệu")),
      );
      return;
    }

    importItems.add({
      "product_id": selectedProduct,
      "quantity": int.parse(qtyCtrl.text),
      "unit_price": double.parse(priceCtrl.text),
      "name": products.firstWhere(
          (p) => p["id"].toString() == selectedProduct.toString())["name"],
    });

    qtyCtrl.clear();
    priceCtrl.clear();

    setState(() {});
  }

  Future<void> _saveImportOrder() async {
    if (importItems.isEmpty) {
      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text("Chưa có sản phẩm")));
      return;
    }

    final ok = await ApiService.addImportOrder(importItems, 1);

    if (ok) {
      Navigator.pop(context, true);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Lưu phiếu nhập thất bại")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    if (loading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    return Scaffold(
      appBar: AppBar(title: const Text("Tạo phiếu nhập")),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            DropdownButtonFormField<int>(
              value: selectedProduct,
              decoration: const InputDecoration(labelText: "Chọn sản phẩm"),
              items: products.map((p) {
                return DropdownMenuItem(
                  value: int.parse(p["id"].toString()),
                  child: Text(p["name"]),
                );
              }).toList(),
              onChanged: (v) => setState(() => selectedProduct = v),
            ),
            TextField(
              controller: qtyCtrl,
              decoration: const InputDecoration(labelText: "Số lượng nhập"),
              keyboardType: TextInputType.number,
            ),
            TextField(
              controller: priceCtrl,
              decoration: const InputDecoration(labelText: "Đơn giá nhập"),
              keyboardType: TextInputType.number,
            ),
            const SizedBox(height: 15),
            ElevatedButton(
              onPressed: _addItem,
              child: const Text("Thêm vào phiếu"),
            ),
            const SizedBox(height: 20),
            Expanded(
              child: importItems.isEmpty
                  ? const Center(child: Text("Chưa có sản phẩm"))
                  : ListView.builder(
                      itemCount: importItems.length,
                      itemBuilder: (_, i) {
                        final item = importItems[i];
                        return Card(
                          child: ListTile(
                            title: Text(item["name"]),
                            subtitle: Text(
                                "SL: ${item['quantity']} • Giá: ${item['unit_price']} đ"),
                            trailing: IconButton(
                              icon: const Icon(Icons.delete, color: Colors.red),
                              onPressed: () {
                                importItems.removeAt(i);
                                setState(() {});
                              },
                            ),
                          ),
                        );
                      },
                    ),
            ),
            const SizedBox(height: 10),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _saveImportOrder,
                child: const Text("Lưu phiếu nhập"),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
