// lib/screens/login_page.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../services/notification_service.dart'; // Import file xử lý thông báo

import '../providers/session_provider.dart';
import '../services/api_service.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});
  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _formKey = GlobalKey<FormState>();
  final _usernameCtrl = TextEditingController();
  final _passwordCtrl = TextEditingController();
  bool _loading = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final session = context.read<SessionProvider>();
      if (session.currentUser != null) {
        _goToRoleScreen(session.currentUser!);
      }
    });
  }

  // [ĐÃ SỬA] Hàm điều hướng + Kích hoạt thông báo đẩy
  void _goToRoleScreen(Map<String, dynamic> data) {
    // --- [MỚI] KÍCH HOẠT THÔNG BÁO ĐẨY ---
    // Lấy token và gửi lên server ngay khi biết user là ai
    final userId = int.tryParse(data['id'].toString());
    if (userId != null) {
      NotificationService().init(userId);
    }
    // -------------------------------------

    final role = (data['role'] ?? '').toString();
    String route = '/customer';
    if (role == 'admin') route = '/admin';
    if (role == 'staff') route = '/staff';

    // Xóa hết stack cũ để không back lại được màn login
    Navigator.pushNamedAndRemoveUntil(
      context,
      route,
      (r) => false,
      arguments: data,
    );
  }

  // --- HÀM XỬ LÝ ĐĂNG NHẬP THƯỜNG ---
  Future<void> _handleLogin() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() {
      _loading = true;
      _error = null;
    });

    try {
      final res = await ApiService.login(
        _usernameCtrl.text.trim(),
        _passwordCtrl.text.trim(),
      );
      if (res['success'] == true) {
        final data = Map<String, dynamic>.from(res['data'] as Map);
        context.read<SessionProvider>().setUser(data);
        if (!mounted) return;
        _goToRoleScreen(data);
      } else {
        setState(() => _error = res['message'] ?? 'Đăng nhập thất bại');
      }
    } catch (e) {
      setState(() => _error = 'Lỗi: $e');
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  // --- HÀM XỬ LÝ ĐĂNG NHẬP GOOGLE ---
  Future<void> _handleGoogleLogin() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final GoogleSignInAccount? googleUser = await GoogleSignIn().signIn();

      if (googleUser == null) {
        setState(() => _loading = false);
        return;
      }

      final GoogleSignInAuthentication googleAuth =
          await googleUser.authentication;
      final OAuthCredential credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      await FirebaseAuth.instance.signInWithCredential(credential);

      final String email = googleUser.email;
      final String googleId = googleUser.id;
      final String fullname = googleUser.displayName ?? "Người dùng Google";
      final String avatar = googleUser.photoUrl ?? "";
      final String fcmToken =
          ""; // Token sẽ được cập nhật sau bởi NotificationService

      final res = await ApiService.loginGoogle(
        email: email,
        googleId: googleId,
        fullname: fullname,
        avatar: avatar,
        fcmToken: fcmToken,
      );

      if (res['success'] == true) {
        final data = Map<String, dynamic>.from(res['data'] as Map);
        context.read<SessionProvider>().setUser(data);

        if (!mounted) return;
        _goToRoleScreen(data);
      } else {
        setState(() => _error = res['message']);
        await FirebaseAuth.instance.signOut();
        await GoogleSignIn().signOut();
      }
    } catch (e) {
      setState(() => _error = 'Lỗi Google Sign In: $e');
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.inventory_2, size: 80, color: Colors.blue),
              const SizedBox(height: 16),
              const Text('SmartStock',
                  style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              const Text('Đăng nhập hệ thống'),
              const SizedBox(height: 32),
              if (_error != null)
                Container(
                  padding: const EdgeInsets.all(12),
                  margin: const EdgeInsets.only(bottom: 12),
                  decoration: BoxDecoration(
                      color: Colors.red.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8)),
                  child:
                      Text(_error!, style: const TextStyle(color: Colors.red)),
                ),
              Form(
                key: _formKey,
                child: Column(
                  children: [
                    TextFormField(
                      controller: _usernameCtrl,
                      decoration: const InputDecoration(
                          labelText: 'Tên đăng nhập',
                          border: OutlineInputBorder(),
                          prefixIcon: Icon(Icons.person)),
                      validator: (v) => v!.isEmpty ? 'Nhập username' : null,
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _passwordCtrl,
                      obscureText: true,
                      decoration: const InputDecoration(
                          labelText: 'Mật khẩu',
                          border: OutlineInputBorder(),
                          prefixIcon: Icon(Icons.lock)),
                      validator: (v) => v!.isEmpty ? 'Nhập mật khẩu' : null,
                    ),
                    const SizedBox(height: 24),
                    SizedBox(
                      width: double.infinity,
                      height: 50,
                      child: ElevatedButton(
                        onPressed: _loading ? null : _handleLogin,
                        child: _loading
                            ? const CircularProgressIndicator(
                                color: Colors.white)
                            : const Text('Đăng nhập',
                                style: TextStyle(fontSize: 16)),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              const Row(children: [
                Expanded(child: Divider()),
                Padding(
                    padding: EdgeInsets.symmetric(horizontal: 10),
                    child: Text("HOẶC")),
                Expanded(child: Divider())
              ]),
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                height: 50,
                child: OutlinedButton.icon(
                  onPressed: _loading ? null : _handleGoogleLogin,
                  icon: Image.network(
                    'https://upload.wikimedia.org/wikipedia/commons/thumb/c/c1/Google_%22G%22_logo.svg/1200px-Google_%22G%22_logo.svg.png',
                    height: 24,
                    width: 24,
                    errorBuilder: (context, error, stackTrace) =>
                        const Icon(Icons.g_mobiledata),
                  ),
                  label: const Text("Đăng nhập bằng Google",
                      style: TextStyle(fontSize: 16, color: Colors.black87)),
                  style: OutlinedButton.styleFrom(
                    backgroundColor: Colors.white,
                    side: const BorderSide(color: Colors.grey),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              TextButton(
                onPressed: () => Navigator.pushNamed(context, '/register'),
                child: const Text('Chưa có tài khoản? Đăng ký ngay'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
