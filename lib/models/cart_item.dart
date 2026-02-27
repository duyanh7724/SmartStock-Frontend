class CartItem {
  final int productId;
  final String name;
  final double price;
  final int quantity;
  final String image;

  CartItem({
    required this.productId,
    required this.name,
    required this.price,
    required this.quantity,
    required this.image,
  });

  CartItem copyWith({int? quantity}) {
    return CartItem(
      productId: productId,
      name: name,
      price: price,
      quantity: quantity ?? this.quantity,
      image: image,
    );
  }

  double get total => price * quantity;
}



