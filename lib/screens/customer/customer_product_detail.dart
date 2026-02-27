import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../providers/cart_provider.dart';
import '../../services/api_service.dart';

class CustomerProductDetailPage extends StatefulWidget {
  final Map<String, dynamic> product;

  const CustomerProductDetailPage({super.key, required this.product});

  @override
  State<CustomerProductDetailPage> createState() =>
      _CustomerProductDetailPageState();
}

class _CustomerProductDetailPageState extends State<CustomerProductDetailPage> {
  int _quantity = 1;

  void _changeQuantity(int delta) {
    final stock =
        int.tryParse(widget.product['quantity']?.toString() ?? '1') ?? 1;
    setState(() {
      _quantity = (_quantity + delta).clamp(1, stock);
    });
  }

  void _addToCart() {
    final cart = context.read<CartProvider>();
    cart.addProduct(widget.product, quantity: _quantity);
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Đã thêm vào giỏ hàng')),
    );
  }

  void _checkoutNow() {
    _addToCart();
    Navigator.pushNamed(context, '/customer/cart');
  }

  @override
  Widget build(BuildContext context) {
    final product = widget.product;
    final name = (product['name'] ?? '').toString();
    final description = (product['description'] ?? '').toString();
    final price = double.tryParse(product['price']?.toString() ?? '0') ?? 0;
    final qty = int.tryParse(product['quantity']?.toString() ?? '0') ?? 0;
    final category = product['category_name']?.toString() ?? '';
    final supplier = product['supplier_name']?.toString() ?? '';
    final image = (product['image'] ?? '').toString();
    final imgUrl = image.isEmpty
        ? '${ApiService.baseUrl}/uploads/no_image.jpg'
        : '${ApiService.baseUrl}/uploads/$image';

    return Scaffold(
      appBar: AppBar(
        title: Text(
          name,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.share),
            onPressed: () {},
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(16),
              child: Image.network(
                imgUrl,
                width: double.infinity,
                height: 280,
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => Container(
                  height: 280,
                  color: Colors.grey.shade200,
                  child: const Icon(Icons.broken_image),
                ),
              ),
            ),
            const SizedBox(height: 16),
            Text(
              name,
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              '${price.toStringAsFixed(0)} đ',
              style: const TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: Colors.redAccent,
              ),
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Icon(Icons.category_outlined, color: Colors.grey.shade600),
                const SizedBox(width: 6),
                Expanded(child: Text('Danh mục: $category')),
              ],
            ),
            const SizedBox(height: 4),
            Row(
              children: [
                Icon(Icons.storefront_outlined, color: Colors.grey.shade600),
                const SizedBox(width: 6),
                Expanded(child: Text('Nhà cung cấp: $supplier')),
              ],
            ),
            const SizedBox(height: 16),
            const Text(
              'Mô tả sản phẩm',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 6),
            Text(
              description.isEmpty ? 'Chưa có mô tả' : description,
              style: const TextStyle(height: 1.4),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                const Text(
                  'Số lượng:',
                  style: TextStyle(fontWeight: FontWeight.w600),
                ),
                const SizedBox(width: 12),
                _QuantitySelector(
                  value: _quantity,
                  onDecrease: () => _changeQuantity(-1),
                  onIncrease: () => _changeQuantity(1),
                ),
                const Spacer(),
                Text('Kho còn: $qty'),
              ],
            ),
            const SizedBox(height: 80),
          ],
        ),
      ),
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
          child: Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: _addToCart,
                  child: const Text('Thêm giỏ'),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: ElevatedButton(
                  onPressed: _checkoutNow,
                  child: const Text('Mua ngay'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _QuantitySelector extends StatelessWidget {
  final int value;
  final VoidCallback onDecrease;
  final VoidCallback onIncrease;

  const _QuantitySelector({
    required this.value,
    required this.onDecrease,
    required this.onIncrease,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey.shade300),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          IconButton(
            icon: const Icon(Icons.remove),
            onPressed: onDecrease,
          ),
          Text(
            value.toString(),
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: onIncrease,
          ),
        ],
      ),
    );
  }
}

