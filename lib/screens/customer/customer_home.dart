// lib/screens/customer/customer_home.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../providers/cart_provider.dart';
import '../../providers/session_provider.dart';
import '../../services/api_service.dart';
import '../../widgets/customer/category_chip.dart';
import '../../widgets/customer/product_card.dart';
import '../chat/chat_page.dart';

class CustomerHome extends StatefulWidget {
  const CustomerHome({super.key});

  @override
  State<CustomerHome> createState() => _CustomerHomeState();
}

class _CustomerHomeState extends State<CustomerHome> {
  bool _loading = true;
  String? _error;

  List<dynamic> _categories = [];
  List<dynamic> _products = [];
  Map<String, dynamic>? _user;

  final List<String> _banners = [
    'https://images.unsplash.com/photo-1523275335684-37898b6baf30',
    'https://images.unsplash.com/photo-1505740420928-5e560c06d30e',
    'https://images.unsplash.com/photo-1475180098004-ca77a66827be',
  ];
  bool _syncedSession = false;

  @override
  void initState() {
    super.initState();
    _fetchData();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final args =
        ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;
    if (args != null && _user == null) {
      setState(() {
        _user = args;
      });
    }

    if (!_syncedSession && _user != null) {
      _syncedSession = true;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted) return;
        context.read<SessionProvider>().setUser(_user!);
      });
    }
  }

  Future<void> _fetchData() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final results = await Future.wait([
        ApiService.getCategories(),
        ApiService.getProducts(),
      ]);
      if (!mounted) return;
      setState(() {
        _categories = results[0] as List<dynamic>;
        _products = results[1] as List<dynamic>;
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

  List<dynamic> get _flashSaleProducts {
    final sorted = [..._products];
    sorted.sort((a, b) {
      final qtyA = num.tryParse(a['quantity']?.toString() ?? '0') ?? 0;
      final qtyB = num.tryParse(b['quantity']?.toString() ?? '0') ?? 0;
      return qtyA.compareTo(qtyB);
    });
    return sorted.take(6).toList();
  }

  List<dynamic> get _recommendedProducts {
    if (_products.length <= 6) return [..._products];
    return _products.skip(6).toList();
  }

  void _openProductList({String? keyword, Map<String, dynamic>? category}) {
    Navigator.pushNamed(
      context,
      '/customer/products',
      arguments: {
        'initialSearch': keyword,
        'category': category,
      },
    );
  }

  void _openCart() {
    Navigator.pushNamed(context, '/customer/cart');
  }

  void _openOrders() {
    Navigator.pushNamed(
      context,
      '/customer/orders',
      arguments: _effectiveUser,
    );
  }

  void _openProductDetail(Map<String, dynamic> product) {
    Navigator.pushNamed(
      context,
      '/customer/product-detail',
      arguments: product,
    );
  }

  void _addToCart(Map<String, dynamic> product) {
    if (!mounted) return;
    context.read<CartProvider>().addProduct(product);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Đã thêm ${product['name']} vào giỏ')),
    );
  }

  void _logout() {
    context.read<CartProvider>().clear();
    context.read<SessionProvider>().logout();
    Navigator.pushNamedAndRemoveUntil(context, '/login', (route) => false);
  }

  void _openChat() {
    final user = _effectiveUser;
    if (user != null) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => ChatPage(
            chatRoomId: user['id'].toString(),
            chatTitle: "Chat với nhân viên hỗ trợ",
          ),
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Vui lòng đăng nhập để chat")),
      );
    }
  }

  Map<String, dynamic>? get _effectiveUser {
    try {
      return context.read<SessionProvider>().currentUser ?? _user;
    } catch (_) {
      return _user;
    }
  }

  @override
  Widget build(BuildContext context) {
    final greetingName =
        (context.watch<SessionProvider>().currentUser ?? _user)?['fullname'] ??
            'Smart Shopper';

    return Scaffold(
      backgroundColor: const Color(0xfff5f6fb),
      appBar: AppBar(
        titleSpacing: 0,
        // [SỬA LỖI] Bọc thanh tìm kiếm để không bị lỗi overflow
        title: GestureDetector(
          onTap: () => _openProductList(),
          child: Container(
            height: 40,
            margin: const EdgeInsets.only(left: 12), // Thêm lề trái
            padding: const EdgeInsets.symmetric(horizontal: 12),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Row(
              children: [
                Icon(Icons.search, color: Colors.grey),
                SizedBox(width: 8),
                // [QUAN TRỌNG] Expanded giúp text tự co lại nếu hết chỗ
                Expanded(
                  child: Text(
                    'Tìm sản phẩm...',
                    style: TextStyle(color: Colors.grey, fontSize: 14),
                    overflow: TextOverflow.ellipsis,
                    maxLines: 1,
                  ),
                ),
              ],
            ),
          ),
        ),
        actions: [
          IconButton(
            onPressed: _openChat,
            icon: const Icon(Icons.support_agent, color: Colors.blue),
            tooltip: 'Chat',
          ),
          IconButton(
            onPressed: _openOrders,
            icon: const Icon(Icons.receipt_long_outlined),
            tooltip: 'Đơn hàng',
          ),
          IconButton(
            onPressed: _openCart,
            icon: const Icon(Icons.shopping_cart_outlined),
            tooltip: 'Giỏ hàng',
          ),
          // Nút logout
          IconButton(
            onPressed: _logout,
            icon: const Icon(Icons.logout),
            tooltip: 'Đăng xuất',
          ),
          const SizedBox(width: 4),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: _fetchData,
        child: _loading
            ? const Center(child: CircularProgressIndicator())
            : _error != null
                ? ListView(
                    children: [
                      SizedBox(
                        height: MediaQuery.of(context).size.height * 0.4,
                        child: Center(
                          child: Text(
                            'Lỗi: $_error',
                            textAlign: TextAlign.center,
                          ),
                        ),
                      ),
                    ],
                  )
                : CustomScrollView(
                    physics: const AlwaysScrollableScrollPhysics(),
                    slivers: [
                      SliverToBoxAdapter(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _buildBannerCarousel(),
                            Padding(
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 16)
                                      .copyWith(top: 12),
                              child: Text(
                                'Xin chào, $greetingName',
                                style: const TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                            const SizedBox(height: 16),
                            _buildCategorySection(),
                            const SizedBox(height: 24),
                            Padding(
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 16),
                              child: const SectionHeader(
                                title: 'Flash Sale',
                              ),
                            ),
                            const SizedBox(height: 12),
                            _buildFlashSaleSection(),
                            const SizedBox(height: 24),
                            const Padding(
                              padding: EdgeInsets.symmetric(horizontal: 16),
                              child: SectionHeader(
                                title: 'Gợi ý hôm nay',
                              ),
                            ),
                            const SizedBox(height: 12),
                          ],
                        ),
                      ),
                      _buildRecommendedGrid(),
                      const SliverToBoxAdapter(child: SizedBox(height: 16)),
                    ],
                  ),
      ),
    );
  }

  Widget _buildBannerCarousel() {
    return SizedBox(
      height: 170,
      child: PageView.builder(
        itemCount: _banners.length,
        controller: PageController(viewportFraction: 0.92),
        itemBuilder: (_, index) {
          final image = _banners[index];
          return Padding(
            padding: const EdgeInsets.only(right: 12),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(16),
              child: Stack(
                fit: StackFit.expand,
                children: [
                  Image.network(
                    image,
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) => Container(
                      color: Colors.grey.shade300,
                    ),
                  ),
                  Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          Colors.black.withOpacity(0.6),
                          Colors.transparent,
                        ],
                        begin: Alignment.bottomCenter,
                        end: Alignment.center,
                      ),
                    ),
                  ),
                  const Positioned(
                    left: 16,
                    bottom: 16,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Deal hot nhất tuần',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          'Giảm đến 50% tất cả ngành hàng',
                          style: TextStyle(color: Colors.white70),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildCategorySection() {
    if (_categories.isEmpty) {
      return const Padding(
        padding: EdgeInsets.symmetric(horizontal: 16),
        child: Text('Chưa có danh mục nào.'),
      );
    }

    final icons = [
      Icons.phone_iphone,
      Icons.laptop_mac,
      Icons.watch_outlined,
      Icons.sports_esports,
      Icons.weekend_outlined,
      Icons.shopping_bag,
      Icons.kitchen_outlined,
      Icons.directions_bike,
    ];
    return SizedBox(
      height: 120,
      child: ListView.builder(
        itemCount: _categories.length,
        padding: const EdgeInsets.only(left: 16),
        scrollDirection: Axis.horizontal,
        itemBuilder: (_, index) {
          final cat = _categories[index] as Map<String, dynamic>;
          final icon = icons[index % icons.length];
          return CategoryChip(
            label: cat['name']?.toString() ?? '',
            icon: icon,
            onTap: () => _openProductList(category: cat),
          );
        },
      ),
    );
  }

  Widget _buildFlashSaleSection() {
    final flashSale = _flashSaleProducts;
    if (flashSale.isEmpty) {
      return const Padding(
        padding: EdgeInsets.symmetric(horizontal: 16),
        child: Text('Hiện chưa có sản phẩm flash sale.'),
      );
    }

    return SizedBox(
      height: 310,
      child: ListView.separated(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        scrollDirection: Axis.horizontal,
        itemBuilder: (_, index) {
          final product = flashSale[index] as Map<String, dynamic>;
          return ProductCard(
            product: product,
            onTap: () => _openProductDetail(product),
            onAddToCart: () => _addToCart(product),
          );
        },
        separatorBuilder: (_, __) => const SizedBox(width: 12),
        itemCount: flashSale.length,
      ),
    );
  }

  SliverGrid _buildRecommendedGrid() {
    final items = _recommendedProducts;
    return SliverGrid(
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        mainAxisSpacing: 12,
        crossAxisSpacing: 12,
        childAspectRatio: 0.55,
      ),
      delegate: SliverChildBuilderDelegate(
        (context, index) {
          final product = items[index] as Map<String, dynamic>;
          return ProductCard(
            product: product,
            onTap: () => _openProductDetail(product),
            onAddToCart: () => _addToCart(product),
          );
        },
        childCount: items.length,
      ),
    );
  }
}

class SectionHeader extends StatelessWidget {
  final String title;
  const SectionHeader({
    super.key,
    required this.title,
  });
  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          title,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }
}
