import 'package:flutter/material.dart';
import '../../services/api_service.dart';

class ProductCard extends StatelessWidget {
  final Map<String, dynamic> product;
  final VoidCallback? onTap;
  final VoidCallback? onAddToCart;
  final bool showAddButton;

  const ProductCard({
    super.key,
    required this.product,
    this.onTap,
    this.onAddToCart,
    this.showAddButton = true,
  });

  @override
  Widget build(BuildContext context) {
    final name = (product['name'] ?? '').toString();
    final price = num.tryParse(product['price']?.toString() ?? '0') ?? 0;
    final image = (product['image'] ?? '').toString();
    final sold = num.tryParse(product['sold']?.toString() ?? '0') ?? 0;
    final qty = num.tryParse(product['quantity']?.toString() ?? '0') ?? 0;

    final imgUrl = image.isEmpty
        ? '${ApiService.baseUrl}/uploads/no_image.jpg'
        : '${ApiService.baseUrl}/uploads/$image';

    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 160,
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.04),
              blurRadius: 8,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize:
              MainAxisSize.min, // Giúp Column chỉ chiếm chiều cao vừa đủ
          children: [
            // --- [SỬA LỖI Ở ĐÂY] ---
            // Thay AspectRatio(aspectRatio: 1) bằng SizedBox(height: 105)
            // AspectRatio(1) -> Ảnh vuông (160x160) -> Quá cao -> Tràn 41px
            // SizedBox(105) -> Ảnh chữ nhật (160x105) -> Tiết kiệm 55px -> Hết lỗi
            ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: SizedBox(
                height: 105, // Chiều cao cố định an toàn
                width: double.infinity,
                child: Image.network(
                  imgUrl,
                  fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) => Container(
                    color: Colors.grey.shade200,
                    child: const Icon(Icons.image_not_supported),
                  ),
                ),
              ),
            ),
            // -----------------------

            const SizedBox(height: 8),

            // Tên sản phẩm
            SizedBox(
              height: 36, // Cố định chiều cao text (2 dòng) để card đều nhau
              child: Text(
                name,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            const SizedBox(height: 4),

            // Giá tiền
            Text(
              '${price.toStringAsFixed(0)} đ',
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: Colors.redAccent,
              ),
            ),
            const SizedBox(height: 2),

            // Số lượng
            Text(
              sold > 0 ? 'Đã bán $sold' : 'Còn $qty sp',
              style: TextStyle(
                fontSize: 11,
                color: Colors.grey.shade600,
              ),
            ),

            // Nút thêm
            if (showAddButton) ...[
              const SizedBox(height: 8),
              SizedBox(
                width: double.infinity,
                height: 32, // Giảm chiều cao nút xuống chút cho gọn
                child: ElevatedButton.icon(
                  onPressed: onAddToCart,
                  icon: const Icon(Icons.add_shopping_cart, size: 16),
                  label: const Text('Thêm', style: TextStyle(fontSize: 12)),
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 0),
                  ),
                ),
              ),
            ]
          ],
        ),
      ),
    );
  }
}
