import 'package:flutter/material.dart';
import '../../services/api_service.dart';

class AdminBankPage extends StatefulWidget {
  const AdminBankPage({super.key});

  @override
  State<AdminBankPage> createState() => _AdminBankPageState();
}

class _AdminBankPageState extends State<AdminBankPage> {
  final _formKey = GlobalKey<FormState>();

  // Controllers
  final _bankCodeController = TextEditingController();
  final _bankNameController = TextEditingController();
  final _accNumController = TextEditingController();
  final _accNameController = TextEditingController();

  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _loadCurrentInfo();
  }

  // Load dữ liệu cũ
  void _loadCurrentInfo() async {
    // SỬA LỖI 1: Gọi trực tiếp ApiService.getBankInfo (bỏ dấu ngoặc đơn sau ApiService)
    final data = await ApiService.getBankInfo();

    if (data.isNotEmpty && data['status'] != 'error') {
      // API php thường trả về data bọc trong 1 key, ví dụ data['data']
      // Nếu file php trả thẳng row thì dùng data, nếu bọc thì dùng data['data']
      var info = data['data'] ?? data;

      // Kiểm tra mounted để tránh lỗi async gap
      if (!mounted) return;

      setState(() {
        _bankCodeController.text = info['bank_code'] ?? '';
        _bankNameController.text = info['bank_name'] ?? '';
        _accNumController.text = info['account_number'] ?? '';
        _accNameController.text = info['account_name'] ?? '';
      });
    }
  }

  // Hàm lưu
  void _saveBankInfo() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    // SỬA LỖI 2:
    // - Gọi ApiService.updateBankInfo (bỏ dấu ngoặc đơn sau class)
    // - Truyền tham số có tên (bankCode: ..., bankName: ...)
    bool success = await ApiService.updateBankInfo(
      bankCode: _bankCodeController.text,
      bankName: _bankNameController.text,
      accountNumber: _accNumController.text,
      accountName: _accNameController.text,
    );

    // Kiểm tra mounted trước khi setState hoặc showSnackBar
    if (!mounted) return;

    setState(() => _isLoading = false);

    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text('Cập nhật thành công! QR Code sẽ thay đổi.')),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Cập nhật thất bại!')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Cấu hình Ngân hàng (QR)")),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              const Text(
                "Thông tin này sẽ dùng để tạo mã VietQR",
                style: TextStyle(color: Colors.grey),
              ),
              const SizedBox(height: 20),
              TextFormField(
                controller: _bankCodeController,
                decoration: const InputDecoration(
                  labelText: "Mã Ngân hàng (BinCode)",
                  hintText: "VD: TCB, VCB, MB...",
                  border: OutlineInputBorder(),
                  helperText:
                      "Nhập đúng mã viết tắt (Ví dụ: Techcombank là TCB)",
                ),
                validator: (v) => v!.isEmpty ? "Không được để trống" : null,
              ),
              const SizedBox(height: 15),
              TextFormField(
                controller: _bankNameController,
                decoration: const InputDecoration(
                  labelText: "Tên hiển thị Ngân hàng",
                  hintText: "VD: Techcombank",
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 15),
              TextFormField(
                controller: _accNumController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: "Số tài khoản",
                  border: OutlineInputBorder(),
                ),
                validator: (v) => v!.isEmpty ? "Không được để trống" : null,
              ),
              const SizedBox(height: 15),
              TextFormField(
                controller: _accNameController,
                decoration: const InputDecoration(
                  labelText: "Tên chủ tài khoản (Viết hoa không dấu)",
                  hintText: "NGUYEN VAN A",
                  border: OutlineInputBorder(),
                ),
                validator: (v) => v!.isEmpty ? "Không được để trống" : null,
              ),
              const SizedBox(height: 30),
              SizedBox(
                height: 50,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _saveBankInfo,
                  child: _isLoading
                      ? const CircularProgressIndicator()
                      : const Text("Lưu thay đổi",
                          style: TextStyle(fontSize: 18)),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}
