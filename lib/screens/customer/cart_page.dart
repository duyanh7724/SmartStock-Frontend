import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../providers/cart_provider.dart';
import '../../services/api_service.dart';

class CartPage extends StatelessWidget {
  const CartPage({super.key});

  void _checkout(BuildContext context) {
    if (context.read<CartProvider>().items.isEmpty) return;
    Navigator.pushNamed(context, '/customer/checkout');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Giỏ hàng')),
      body: Consumer<CartProvider>(
        builder: (_, cart, __) {
          if (cart.items.isEmpty) {
            return const Center(child: Text('Giỏ hàng đang trống'));
          }

          return Column(
            children: [
              Expanded(
                child: ListView.separated(
                  padding: const EdgeInsets.all(16),
                  itemCount: cart.items.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 12),
                  itemBuilder: (_, index) {
                    final item = cart.items[index];
                    final imgUrl = item.image.isEmpty
                        ? '${ApiService.baseUrl}/uploads/no_image.jpg'
                        : '${ApiService.baseUrl}/uploads/${item.image}';

                    return Card(
                      child: ListTile(
                        leading: ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child: Image.network(
                            imgUrl,
                            width: 56,
                            height: 56,
                            fit: BoxFit.cover,
                            errorBuilder: (_, __, ___) => const Icon(
                              Icons.image_not_supported,
                            ),
                          ),
                        ),
                        title: Text(item.name),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              '${item.price.toStringAsFixed(0)} đ',
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                color: Colors.redAccent,
                              ),
                            ),
                            const SizedBox(height: 6),
                            Row(
                              children: [
                                IconButton(
                                  icon: const Icon(Icons.remove_circle_outline),
                                  onPressed: () => cart.updateQuantity(
                                    item.productId,
                                    item.quantity - 1,
                                  ),
                                ),
                                Text(item.quantity.toString()),
                                IconButton(
                                  icon: const Icon(Icons.add_circle_outline),
                                  onPressed: () => cart.updateQuantity(
                                    item.productId,
                                    item.quantity + 1,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                        trailing: IconButton(
                          icon: const Icon(Icons.delete_outline),
                          onPressed: () => cart.removeProduct(item.productId),
                        ),
                      ),
                    );
                  },
                ),
              ),
              _CartSummary(
                total: context.watch<CartProvider>().subtotal,
                onCheckout: () => _checkout(context),
              ),
            ],
          );
        },
      ),
    );
  }
}

class _CartSummary extends StatelessWidget {
  final double total;
  final VoidCallback onCheckout;

  const _CartSummary({
    required this.total,
    required this.onCheckout,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('Tổng tạm tính',
                  style: TextStyle(fontWeight: FontWeight.w600)),
              Text(
                '${total.toStringAsFixed(0)} đ',
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.redAccent,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: total == 0 ? null : onCheckout,
              child: const Text('Tiến hành thanh toán'),
            ),
          ),
        ],
      ),
    );
  }
}


