// lib/screens/admin/admin_products.dart
import 'package:flutter/material.dart';
import '../../services/api_service.dart';
import 'add_product.dart';
import 'admin_product_detail.dart';

class AdminProducts extends StatefulWidget {
  const AdminProducts({super.key});

  @override
  State<AdminProducts> createState() => _AdminProductsState();
}

class _AdminProductsState extends State<AdminProducts> {
  List products = [];
  bool loading = true;

  // tìm kiếm + lọc
  String searchText = '';
  List categories = [];
  List suppliers = [];
  int? selectedCategoryId; // null hoặc 0 = tất cả
  int? selectedSupplierId;
  bool loadingFilter = true;

  @override
  void initState() {
    super.initState();
    _loadProducts();
    _loadFilterData();
  }

  Future<void> _loadProducts() async {
    try {
      final data = await ApiService.getProducts();
      setState(() {
        products = data;
        loading = false;
      });
    } catch (e) {
      debugPrint("Lỗi load sản phẩm: $e");
      setState(() => loading = false);
    }
  }

  Future<void> _loadFilterData() async {
    try {
      final cats = await ApiService.getCategories();
      final sups = await ApiService.getSuppliers();
      setState(() {
        categories = cats;
        suppliers = sups;
        loadingFilter = false;
      });
    } catch (e) {
      debugPrint("Lỗi load bộ lọc: $e");
      setState(() => loadingFilter = false);
    }
  }

  Future<void> _confirmDelete(int id) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text("Xóa sản phẩm"),
        content: const Text("Bạn có chắc muốn xóa sản phẩm này không?"),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text("Hủy"),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text("Xóa", style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );

    if (ok == true) {
      await ApiService.deleteProduct(id);
      _loadProducts();
    }
  }

  List get _filteredProducts {
    return products.where((p) {
      // lọc theo tên
      if (searchText.isNotEmpty) {
        final name = p['name']?.toString().toLowerCase() ?? '';
        if (!name.contains(searchText.toLowerCase())) return false;
      }

      // lọc theo danh mục
      if (selectedCategoryId != null && selectedCategoryId != 0) {
        final catId = int.tryParse(p['category_id']?.toString() ?? '') ?? 0;
        if (catId != selectedCategoryId) return false;
      }

      // lọc theo nhà cung cấp
      if (selectedSupplierId != null && selectedSupplierId != 0) {
        final supId = int.tryParse(p['supplier_id']?.toString() ?? '') ?? 0;
        if (supId != selectedSupplierId) return false;
      }

      return true;
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final filtered = _filteredProducts;

    return Scaffold(
      appBar: AppBar(title: const Text("Quản lý sản phẩm")),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          final added = await Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const AddProductPage()),
          );
          if (added == true) _loadProducts();
        },
        child: const Icon(Icons.add),
      ),
      body: loading
          ? const Center(child: CircularProgressIndicator())
          : products.isEmpty
              ? const Center(child: Text("Không có sản phẩm nào"))
              : Column(
                  children: [
                    // thanh tìm kiếm
                    Padding(
                      padding: const EdgeInsets.fromLTRB(16.0, 16.0, 16.0, 8.0),
                      child: TextField(
                        decoration: InputDecoration(
                          hintText: 'Tìm kiếm theo tên sản phẩm...',
                          prefixIcon: const Icon(Icons.search),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          isDense: true,
                        ),
                        onChanged: (v) {
                          setState(() => searchText = v);
                        },
                      ),
                    ),

                    // bộ lọc danh mục + NCC
                    if (!loadingFilter)
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16.0),
                        child: Row(
                          children: [
                            // lọc danh mục
                            Expanded(
                              child: DropdownButtonFormField<int>(
                                value: selectedCategoryId ?? 0,
                                isExpanded: true,
                                decoration: const InputDecoration(
                                  labelText: "Danh mục",
                                  isDense: true,
                                ),
                                items: [
                                  const DropdownMenuItem(
                                    value: 0,
                                    child: Text("Tất cả"),
                                  ),
                                  ...categories.map<DropdownMenuItem<int>>((c) {
                                    return DropdownMenuItem(
                                      value: int.parse(c["id"].toString()),
                                      child: Text(c["name"].toString()),
                                    );
                                  }).toList(),
                                ],
                                onChanged: (v) {
                                  setState(() => selectedCategoryId = v);
                                },
                              ),
                            ),
                            const SizedBox(width: 12),
                            // lọc nhà cung cấp
                            Expanded(
                              child: DropdownButtonFormField<int>(
                                value: selectedSupplierId ?? 0,
                                isExpanded: true,
                                decoration: const InputDecoration(
                                  labelText: "Nhà cung cấp",
                                  isDense: true,
                                ),
                                items: [
                                  const DropdownMenuItem(
                                    value: 0,
                                    child: Text("Tất cả"),
                                  ),
                                  ...suppliers.map<DropdownMenuItem<int>>((s) {
                                    return DropdownMenuItem(
                                      value: int.parse(s["id"].toString()),
                                      child:
                                          Text("${s['name']} (${s['code']})"),
                                    );
                                  }).toList(),
                                ],
                                onChanged: (v) {
                                  setState(() => selectedSupplierId = v);
                                },
                              ),
                            ),
                          ],
                        ),
                      ),

                    const SizedBox(height: 8),

                    // danh sách sản phẩm
                    Expanded(
                      child: filtered.isEmpty
                          ? const Center(
                              child: Text("Không tìm thấy sản phẩm phù hợp"),
                            )
                          : ListView.builder(
                              padding: const EdgeInsets.all(16),
                              itemCount: filtered.length,
                              itemBuilder: (_, i) {
                                final p = filtered[i];
                                final img = p['image'];
                                final imageUrl = (img != null && img != "")
                                    ? "${ApiService.baseUrl}/uploads/$img"
                                    : null;

                                return Card(
                                  elevation: 2,
                                  margin: const EdgeInsets.only(bottom: 16),
                                  child: ExpansionTile(
                                    leading: imageUrl != null
                                        ? ClipRRect(
                                            borderRadius:
                                                BorderRadius.circular(6),
                                            child: Image.network(
                                              imageUrl,
                                              width: 55,
                                              height: 55,
                                              fit: BoxFit.cover,
                                              errorBuilder: (_, __, ___) =>
                                                  const Icon(
                                                Icons.broken_image,
                                                size: 40,
                                              ),
                                            ),
                                          )
                                        : const Icon(Icons.image, size: 40),
                                    title: Text(
                                      p['name'] ?? "",
                                      style: const TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    subtitle: Text(
                                      "${p['quantity']} cái • ${p['price']} đ",
                                      style: TextStyle(
                                        color: Colors.grey.shade600,
                                      ),
                                    ),
                                    children: [
                                      Padding(
                                        padding: const EdgeInsets.all(14),
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              "📦 Danh mục: ${p['category_name'] ?? 'N/A'}",
                                            ),
                                            Text(
                                              "🏢 Nhà cung cấp: ${p['supplier_name'] ?? 'N/A'}",
                                            ),
                                            const SizedBox(height: 10),
                                            const Text(
                                              "📄 Mô tả:",
                                              style: TextStyle(
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                            Text(p['description'] ??
                                                "Không có mô tả"),
                                            const SizedBox(height: 15),
                                            Row(
                                              children: [
                                                ElevatedButton.icon(
                                                  onPressed: () async {
                                                    final updated =
                                                        await Navigator.push(
                                                      context,
                                                      MaterialPageRoute(
                                                        builder: (_) =>
                                                            AdminProductDetail(
                                                          product: p,
                                                        ),
                                                      ),
                                                    );
                                                    if (updated == true) {
                                                      _loadProducts();
                                                    }
                                                  },
                                                  icon: const Icon(Icons.edit),
                                                  label: const Text("Sửa"),
                                                ),
                                                const SizedBox(width: 12),
                                                OutlinedButton.icon(
                                                  onPressed: () =>
                                                      _confirmDelete(
                                                    int.parse(
                                                        p['id'].toString()),
                                                  ),
                                                  icon: const Icon(
                                                    Icons.delete,
                                                    color: Colors.red,
                                                  ),
                                                  label: const Text(
                                                    "Xóa",
                                                    style: TextStyle(
                                                      color: Colors.red,
                                                    ),
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
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
