// customer_home.dart
import 'package:flutter/material.dart';

class CustomerHome extends StatelessWidget {
  const CustomerHome({super.key});

  @override
  Widget build(BuildContext context) {
    final user =
        ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;

    return Scaffold(
      appBar: AppBar(title: const Text('Khách hàng SmartStock')),
      body: Center(child: Text('Xin chào: ${user?['fullname'] ?? ''}')),
    );
  }
}
