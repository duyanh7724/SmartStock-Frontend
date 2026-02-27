// lib/screens/staff/staff_products.dart
import 'package:flutter/material.dart';
import '../../services/api_service.dart';

class StaffProducts extends StatefulWidget {
  const StaffProducts({
    super.key,
    required this.user,
  });

  final Map<String, dynamic> user;

  @override
  StaffProductsState createState() => StaffProductsState();
}

class StaffProductsState extends State<StaffProducts> {
  List _products = [];
  List _categories = [];
  List _suppliers = [];

  bool _loading = true;
  String _searchText = '';

  int? _selectedCategoryId; // lọc theo danh mục
  int? _selectedSupplierId; // lọc theo NCC

  @override
  void initState() {
    super.initState();
    _initData();
  }

  /// Load sản phẩm + danh mục + nhà cung cấp
  Future<void> _initData() async {
    try {
      final products = await ApiService.getProducts();
      final cats = await ApiService.getCategories();
      final sups = await ApiService.getSuppliers();

      if (!mounted) return;
      setState(() {
        _products = products;
        _categories = cats;
        _suppliers = sups;
        _loading = false;
      });
    } catch (e) {
      debugPrint('Lỗi load dữ liệu (staff products): $e');
      if (!mounted) return;
      setState(() {
        _loading = false;
      });
    }
  }

  /// Chỉ load lại sản phẩm (dùng cho kéo refresh)
  Future<void> _loadProducts() async {
    try {
      final data = await ApiService.getProducts();
      if (!mounted) return;
      setState(() {
        _products = data;
      });
    } catch (e) {
      debugPrint('Lỗi load sản phẩm (staff): $e');
    }
  }

  /// Hàm public để StaffHome gọi sau khi quét xong sản phẩm
  Future<void> reload() async {
    setState(() {
      _loading = true;
    });
    await _initData();
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const Center(child: CircularProgressIndicator());
    }

    // Áp dụng tìm kiếm + filter
    final filtered = _products.where((p) {
      // Tìm kiếm theo tên
      if (_searchText.isNotEmpty) {
        final name = (p['name'] ?? '').toString().toLowerCase();
        if (!name.contains(_searchText.toLowerCase())) return false;
      }

      // Lọc theo danh mục
      if (_selectedCategoryId != null) {
        final cid = int.tryParse(p['category_id']?.toString() ?? '');
        if (cid != _selectedCategoryId) return false;
      }

      // Lọc theo nhà cung cấp
      if (_selectedSupplierId != null) {
        final sid = int.tryParse(p['supplier_id']?.toString() ?? '');
        if (sid != _selectedSupplierId) return false;
      }

      return true;
    }).toList();

    return Column(
      children: [
        Container(
          width: double.infinity,
          color: Colors.grey.shade100,
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
          child: const Text(
            'Sản phẩm trong kho (Nhân viên)',
            style: TextStyle(
              fontWeight: FontWeight.w600,
            ),
          ),
        ),

        // THANH TÌM KIẾM
        Padding(
          padding: const EdgeInsets.all(16),
          child: TextField(
            decoration: InputDecoration(
              hintText: 'Tìm kiếm theo tên sản phẩm...',
              prefixIcon: const Icon(Icons.search),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              isDense: true,
            ),
            onChanged: (v) => setState(() => _searchText = v),
          ),
        ),

        // DROPDOWN LỌC DANH MỤC
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: DropdownButtonFormField<int?>(
            value: _selectedCategoryId,
            isDense: true,
            decoration: const InputDecoration(
              labelText: 'Danh mục',
              border: OutlineInputBorder(),
            ),
            items: [
              const DropdownMenuItem<int?>(
                value: null,
                child: Text('Tất cả'),
              ),
              ..._categories.map<DropdownMenuItem<int?>>((c) {
                final id = int.parse(c['id'].toString());
                return DropdownMenuItem<int?>(
                  value: id,
                  child: Text(c['name'] ?? ''),
                );
              }).toList(),
            ],
            onChanged: (v) {
              setState(() {
                _selectedCategoryId = v;
              });
            },
          ),
        ),

        const SizedBox(height: 8),

        // DROPDOWN LỌC NHÀ CUNG CẤP
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: DropdownButtonFormField<int?>(
            value: _selectedSupplierId,
            isDense: true,
            decoration: const InputDecoration(
              labelText: 'Nhà cung cấp',
              border: OutlineInputBorder(),
            ),
            items: [
              const DropdownMenuItem<int?>(
                value: null,
                child: Text('Tất cả'),
              ),
              ..._suppliers.map<DropdownMenuItem<int?>>((s) {
                final id = int.parse(s['id'].toString());
                return DropdownMenuItem<int?>(
                  value: id,
                  child: Text('${s['name']} (${s['code']})'),
                );
              }).toList(),
            ],
            onChanged: (v) {
              setState(() {
                _selectedSupplierId = v;
              });
            },
          ),
        ),

        const SizedBox(height: 8),

        // DANH SÁCH
        Expanded(
          child: RefreshIndicator(
            onRefresh: _loadProducts,
            child: filtered.isEmpty
                ? ListView(
                    children: const [
                      SizedBox(height: 80),
                      Center(child: Text('Không tìm thấy sản phẩm phù hợp')),
                    ],
                  )
                : ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    itemCount: filtered.length,
                    itemBuilder: (_, i) {
                      final p = filtered[i];

                      final img = (p['image'] ?? '').toString();
                      final String? imageUrl = img.isNotEmpty
                          ? '${ApiService.baseUrl}/uploads/$img'
                          : null;

                      return Card(
                        elevation: 1,
                        margin: const EdgeInsets.only(bottom: 12),
                        child: ExpansionTile(
                          leading: ClipRRect(
                            borderRadius: BorderRadius.circular(6),
                            child: imageUrl != null
                                ? Image.network(
                                    imageUrl,
                                    width: 55,
                                    height: 55,
                                    fit: BoxFit.cover,
                                    errorBuilder: (_, __, ___) => const Icon(
                                      Icons.broken_image,
                                      size: 40,
                                    ),
                                  )
                                : const Icon(Icons.image, size: 40),
                          ),
                          title: Text(
                            p['name'] ?? '',
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          subtitle: Text(
                            '${p['quantity']} cái • ${p['price']} đ',
                            style: TextStyle(
                              color: Colors.grey.shade600,
                            ),
                          ),
                          children: [
                            Padding(
                              padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    '📦 Danh mục: ${p['category_name'] ?? 'N/A'}',
                                  ),
                                  Text(
                                    '🏢 Nhà cung cấp: ${p['supplier_name'] ?? 'N/A'}',
                                  ),
                                  const SizedBox(height: 8),
                                  const Text(
                                    '📄 Mô tả:',
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  Text(
                                    p['description'] ?? 'Không có mô tả',
                                  ),
                                  const SizedBox(height: 8),
                                  const Text(
                                    'Ghi chú: Nhân viên không được sửa hoặc xoá sản phẩm.',
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: Colors.grey,
                                    ),
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
        ),
      ],
    );
  }
}
