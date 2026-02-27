// lib/main.dart
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart'; // [MỚI] Import Messaging
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'providers/cart_provider.dart';
import 'providers/session_provider.dart';

import 'screens/login_page.dart';
import 'screens/register_page.dart';
import 'screens/admin/admin_home.dart';
import 'screens/staff_home.dart';
import 'screens/customer/customer_home.dart';
import 'screens/customer/customer_product_list.dart';
import 'screens/customer/customer_product_detail.dart';
import 'screens/customer/cart_page.dart';
import 'screens/customer/checkout_page.dart';
import 'screens/customer/order_success_page.dart';
import 'screens/customer/orders_history_page.dart';

// [QUAN TRỌNG] Hàm xử lý thông báo khi App đang tắt (Background)
// Phải để ở top-level (ngoài cùng), không nằm trong class nào
@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  // Nếu bạn cần dùng Firebase trong background (vd: Firestore), cần init lại ở đây
  await Firebase.initializeApp();
  print("Đã nhận thông báo ngầm: ${message.messageId}");
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // 1. Khởi tạo Firebase
  await Firebase.initializeApp();

  // 2. Đăng ký hàm xử lý background
  FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

  runApp(const SmartStockApp());
}

class SmartStockApp extends StatelessWidget {
  const SmartStockApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => CartProvider()),
        ChangeNotifierProvider(
          create: (_) => SessionProvider()..init(),
        ),
      ],
      child: Consumer<SessionProvider>(
        builder: (context, session, _) {
          Widget home;

          if (session.isLoading) {
            home = const SplashPage();
          } else if (session.currentUser == null) {
            home = const LoginPage();
          } else {
            // Điều hướng dựa trên vai trò (Role)
            final role = (session.currentUser!['role'] ?? '').toString();

            if (role == 'admin') {
              home = const AdminHome();
            } else if (role == 'staff') {
              home = const StaffHome();
            } else {
              home = const CustomerHome();
            }
          }

          return MaterialApp(
            title: 'SmartStock',
            debugShowCheckedModeBanner: false,
            theme: ThemeData(
              useMaterial3: true,
              colorSchemeSeed: Colors.blue,
            ),
            home: home,
            routes: {
              '/login': (context) => const LoginPage(),
              '/register': (context) => const RegisterPage(),
              '/admin': (context) => const AdminHome(),
              '/staff': (context) => const StaffHome(),

              // 🔥 2 ROUTE HOME CUSTOMER
              '/customer': (context) => const CustomerHome(),
              '/customer/home': (context) => const CustomerHome(),
            },
            onGenerateRoute: (settings) {
              switch (settings.name) {
                case '/customer/products':
                  final args = settings.arguments as Map<String, dynamic>?;
                  return MaterialPageRoute(
                    builder: (_) => CustomerProductListPage(
                      initialSearch: args?['initialSearch'] as String?,
                      category: args?['category'] as Map<String, dynamic>?,
                    ),
                  );

                case '/customer/product-detail':
                  final product =
                      settings.arguments as Map<String, dynamic>? ?? {};
                  return MaterialPageRoute(
                    builder: (_) => CustomerProductDetailPage(product: product),
                  );

                case '/customer/cart':
                  return MaterialPageRoute(builder: (_) => const CartPage());

                case '/customer/checkout':
                  return MaterialPageRoute(
                    builder: (_) => const CheckoutPage(),
                  );

                case '/customer/order-success':
                  final data = settings.arguments as Map<String, dynamic>?;
                  return MaterialPageRoute(
                    builder: (_) => OrderSuccessPage(orderData: data),
                  );

                case '/customer/orders':
                  final user = settings.arguments as Map<String, dynamic>?;
                  return MaterialPageRoute(
                    builder: (_) => OrdersHistoryPage(user: user),
                  );
              }
              return null;
            },
          );
        },
      ),
    );
  }
}

class SplashPage extends StatelessWidget {
  const SplashPage({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(child: CircularProgressIndicator()),
    );
  }
}
