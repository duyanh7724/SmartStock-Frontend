import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../providers/cart_provider.dart';
import '../../services/api_service.dart';
import '../../widgets/customer/product_card.dart';

class CustomerProductListPage extends StatefulWidget {
  final String? initialSearch;
  final Map<String, dynamic>? category;

  const CustomerProductListPage({
    super.key,
    this.initialSearch,
    this.category,
  });

  @override
  State<CustomerProductListPage> createState() =>
      _CustomerProductListPageState();
}

class _CustomerProductListPageState extends State<CustomerProductListPage> {
  bool _loading = true;
  String? _error;
  List<dynamic> _products = [];
  List<dynamic> _categories = [];

  late TextEditingController _searchCtrl;
  int? _selectedCategoryId;

  @override
  void initState() {
    super.initState();
    _searchCtrl = TextEditingController(text: widget.initialSearch ?? '');
    _selectedCategoryId =
        int.tryParse(widget.category?['id']?.toString() ?? '') ?? null;
    _loadData();
  }

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  Future<void> _loadData() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final results = await Future.wait([
        ApiService.getProducts(),
        ApiService.getCategories(),
      ]);
      if (!mounted) return;
      setState(() {
        _products = results[0] as List<dynamic>;
        _categories = results[1] as List<dynamic>;
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

  List<dynamic> get _filteredProducts {
    return _products.where((p) {
      final name = (p['name'] ?? '').toString().toLowerCase();
      final keyword = _searchCtrl.text.trim().toLowerCase();
      if (keyword.isNotEmpty && !name.contains(keyword)) return false;

      if (_selectedCategoryId != null) {
        final catId = int.tryParse(p['category_id']?.toString() ?? '');
        if (catId != _selectedCategoryId) return false;
      }

      return true;
    }).toList();
  }

  void _openFilterDialog() async {
    final selected = await showModalBottomSheet<int?>(
      context: context,
      builder: (_) => _CategoryFilterSheet(
        categories: _categories,
        currentValue: _selectedCategoryId,
      ),
    );
    if (selected != null) {
      setState(() {
        _selectedCategoryId = selected == 0 ? null : selected;
      });
    }
  }

  void _openProductDetail(Map<String, dynamic> product) {
    Navigator.pushNamed(
      context,
      '/customer/product-detail',
      arguments: product,
    );
  }

  @override
  Widget build(BuildContext context) {
    final cart = context.watch<CartProvider>();
    final products = _filteredProducts;

    return Scaffold(
      appBar: AppBar(
        titleSpacing: 0,
        title: TextField(
          controller: _searchCtrl,
          decoration: const InputDecoration(
            hintText: 'Tìm kiếm sản phẩm...',
            border: InputBorder.none,
          ),
          onChanged: (_) => setState(() {}),
        ),
        actions: [
          IconButton(
            onPressed: _openFilterDialog,
            icon: const Icon(Icons.tune),
          ),
          Stack(
            alignment: Alignment.topRight,
            children: [
              IconButton(
                onPressed: () => Navigator.pushNamed(context, '/customer/cart'),
                icon: const Icon(Icons.shopping_cart_outlined),
              ),
              if (cart.totalItems > 0)
                Positioned(
                  right: 6,
                  top: 6,
                  child: Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(
                      color: Colors.redAccent,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      cart.totalItems.toString(),
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 11,
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: _loadData,
        child: _loading
            ? const Center(child: CircularProgressIndicator())
            : _error != null
                ? ListView(
                    children: [
                      SizedBox(
                        height: MediaQuery.of(context).size.height * 0.4,
                        child: Center(child: Text('Lỗi: $_error')),
                      ),
                    ],
                  )
                : products.isEmpty
                    ? ListView(
                        children: const [
                          SizedBox(height: 120),
                          Center(child: Text('Không có sản phẩm phù hợp')),
                        ],
                      )
                    : GridView.builder(
                        padding: const EdgeInsets.all(16),
                        gridDelegate:
                            const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2,
                          mainAxisSpacing: 12,
                          crossAxisSpacing: 12,
                          childAspectRatio: 0.68,
                        ),
                        itemCount: products.length,
                        itemBuilder: (_, index) {
                          final product =
                              products[index] as Map<String, dynamic>;
                          return ProductCard(
                            product: product,
                            onTap: () => _openProductDetail(product),
                            onAddToCart: () {
                              cart.addProduct(product);
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text(
                                      'Đã thêm ${product['name']} vào giỏ'),
                                ),
                              );
                            },
                          );
                        },
                      ),
      ),
    );
  }
}

class _CategoryFilterSheet extends StatelessWidget {
  final List<dynamic> categories;
  final int? currentValue;

  const _CategoryFilterSheet({
    required this.categories,
    required this.currentValue,
  });

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Padding(
            padding: EdgeInsets.all(16),
            child: Text(
              'Chọn danh mục',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
          ),
          ListTile(
            title: const Text('Tất cả'),
            trailing: currentValue == null
                ? const Icon(Icons.check, color: Colors.blue)
                : null,
            onTap: () => Navigator.pop(context, 0),
          ),
          ...categories.map((cat) {
            final id = int.tryParse(cat['id']?.toString() ?? '');
            return ListTile(
              title: Text(cat['name']?.toString() ?? ''),
              trailing: id == currentValue
                  ? const Icon(Icons.check, color: Colors.blue)
                  : null,
              onTap: () => Navigator.pop(context, id),
            );
          }).toList(),
          const SizedBox(height: 16),
        ],
      ),
    );
  }
}


