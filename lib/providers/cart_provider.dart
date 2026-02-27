import 'package:flutter/foundation.dart';

import '../models/cart_item.dart';

class CartProvider extends ChangeNotifier {
  final Map<int, CartItem> _items = {};

  List<CartItem> get items => _items.values.toList();

  int get totalItems =>
      _items.values.fold(0, (sum, item) => sum + item.quantity);

  double get subtotal =>
      _items.values.fold(0, (sum, item) => sum + item.total);

  void addProduct(Map<String, dynamic> product, {int quantity = 1}) {
    final id = int.tryParse(product['id']?.toString() ?? '');
    if (id == null) return;

    final price = double.tryParse(product['price']?.toString() ?? '0') ?? 0;
    final name = (product['name'] ?? '').toString();
    final image = (product['image'] ?? '').toString();

    if (_items.containsKey(id)) {
      final existing = _items[id]!;
      _items[id] = existing.copyWith(quantity: existing.quantity + quantity);
    } else {
      _items[id] = CartItem(
        productId: id,
        name: name,
        price: price,
        quantity: quantity,
        image: image,
      );
    }

    notifyListeners();
  }

  void removeProduct(int productId) {
    _items.remove(productId);
    notifyListeners();
  }

  void updateQuantity(int productId, int quantity) {
    if (!_items.containsKey(productId)) return;
    if (quantity <= 0) {
      removeProduct(productId);
      return;
    }
    _items[productId] = _items[productId]!.copyWith(quantity: quantity);
    notifyListeners();
  }

  void clear() {
    _items.clear();
    notifyListeners();
  }
}



