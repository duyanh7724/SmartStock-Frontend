import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/session_provider.dart';

class OrderSuccessPage extends StatelessWidget {
  final Map<String, dynamic>? orderData;

  const OrderSuccessPage({super.key, this.orderData});

  @override
  Widget build(BuildContext context) {
    final code = orderData?['code']?.toString();

    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: const Text("Đặt hàng thành công"),
        centerTitle: true,
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(
                Icons.check_circle,
                size: 90,
                color: Colors.green,
              ),
              const SizedBox(height: 16),

              Text(
                code != null
                    ? "Mã đơn của bạn: $code"
                    : "Đơn hàng đã được gửi thành công!",
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),

              const SizedBox(height: 8),
              const Text(
                "Vui lòng chờ admin xác nhận thanh toán.",
                textAlign: TextAlign.center,
              ),

              const SizedBox(height: 32),

              // Nút Tiếp tục mua sắm
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.pushNamedAndRemoveUntil(
                      context,
                      '/customer', // 🔥 route HOME CUSTOMER
                      (route) => false,
                    );
                  },
                  child: const Text("Tiếp tục mua sắm"),
                ),
              ),

              const SizedBox(height: 12),

              // Nút xem đơn hàng
              TextButton(
                onPressed: () {
                  final user = context.read<SessionProvider>().currentUser;

                  Navigator.pushNamed(
                    context,
                    '/customer/orders',
                    arguments: user,
                  );
                },
                child: const Text("Xem đơn hàng của tôi"),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
