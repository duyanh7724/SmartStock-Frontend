import 'package:flutter/material.dart';
import '../../services/api_service.dart';

class AdminUserActivityPage extends StatefulWidget {
  final int userId;
  final String? username;
  final String? fullname;

  const AdminUserActivityPage({
    super.key,
    required this.userId,
    this.username,
    this.fullname,
  });

  @override
  State<AdminUserActivityPage> createState() => _AdminUserActivityPageState();
}

class _AdminUserActivityPageState extends State<AdminUserActivityPage> {
  bool _loading = true;
  String? _error;
  Map<String, dynamic>? _user;
  List _logins = [];
  List _imports = [];
  List _exports = [];

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() {
      _loading = true;
      _error = null;
    });

    try {
      final res = await ApiService.getUserActivity(widget.userId);
      if (res['success'] == true) {
        final data = res['data'] ?? {};
        _user = data['user'];
        _logins = data['logins'] ?? [];
        _imports = data['imports'] ?? [];
        _exports = data['exports'] ?? [];
      } else {
        _error = res['message']?.toString() ?? 'Không lấy được dữ liệu';
      }
    } catch (e) {
      _error = e.toString();
    }

    if (!mounted) return;
    setState(() {
      _loading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final titleName = _user?['fullname'] ??
        widget.fullname ??
        widget.username ??
        'Hoạt động nhân viên';

    return Scaffold(
      appBar: AppBar(
        title: Text('Hoạt động - $titleName'),
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _error != null
              ? Center(
                  child: Text(
                    'Lỗi: $_error',
                    textAlign: TextAlign.center,
                  ),
                )
              : RefreshIndicator(
                  onRefresh: _loadData,
                  child: SingleChildScrollView(
                    physics: const AlwaysScrollableScrollPhysics(),
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildUserInfo(),
                        const SizedBox(height: 16),
                        _buildSectionTitle('Lịch sử đăng nhập gần đây'),
                        _buildLoginList(),
                        const SizedBox(height: 16),
                        _buildSectionTitle('Phiếu nhập do nhân viên tạo'),
                        _buildImportList(),
                        const SizedBox(height: 16),
                        _buildSectionTitle('Phiếu xuất do nhân viên tạo'),
                        _buildExportList(),
                      ],
                    ),
                  ),
                ),
    );
  }

  Widget _buildUserInfo() {
    if (_user == null) return const SizedBox.shrink();

    final fullname = (_user!['fullname'] ?? '').toString();
    final username = (_user!['username'] ?? '').toString();
    final role = (_user!['role'] ?? '').toString();
    final createdAt = (_user!['created_at'] ?? '').toString();

    return Card(
      elevation: 1,
      child: ListTile(
        leading: CircleAvatar(
          child: Text(
            fullname.isNotEmpty
                ? fullname[0].toUpperCase()
                : (username.isNotEmpty ? username[0].toUpperCase() : '?'),
          ),
        ),
        title: Text(fullname.isNotEmpty ? fullname : username),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (username.isNotEmpty) Text('Tài khoản: $username'),
            if (role.isNotEmpty) Text('Vai trò: $role'),
            if (createdAt.isNotEmpty) Text('Tạo lúc: $createdAt'),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String text) {
    return Text(
      text,
      style: const TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.bold,
      ),
    );
  }

  Widget _buildLoginList() {
    if (_logins.isEmpty) {
      return const Padding(
        padding: EdgeInsets.only(top: 8),
        child: Text('Chưa có log đăng nhập.'),
      );
    }

    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: _logins.length,
      itemBuilder: (_, i) {
        final l = _logins[i];
        final time = (l['time'] ?? '').toString();
        final ip = (l['ip_address'] ?? '').toString();

        return ListTile(
          contentPadding: const EdgeInsets.symmetric(vertical: 2),
          leading: const Icon(Icons.login),
          title: Text(time),
          subtitle: Text('IP: $ip'),
        );
      },
    );
  }

  Widget _buildImportList() {
    if (_imports.isEmpty) {
      return const Padding(
        padding: EdgeInsets.only(top: 8),
        child: Text('Nhân viên chưa tạo phiếu nhập nào.'),
      );
    }

    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: _imports.length,
      itemBuilder: (_, i) {
        final o = _imports[i];
        final id = o['id'];
        final time = (o['created_at'] ?? '').toString();
        final qty = o['total_qty'] ?? 0;
        final amount = o['total_amount'] ?? 0;

        return Card(
          margin: const EdgeInsets.only(top: 8),
          child: ListTile(
            leading: const Icon(Icons.inventory_2),
            title: Text('Phiếu nhập #$id'),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Thời gian: $time'),
                Text('Tổng SL: $qty'),
                Text('Tổng tiền: $amount'),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildExportList() {
    if (_exports.isEmpty) {
      return const Padding(
        padding: EdgeInsets.only(top: 8),
        child: Text('Nhân viên chưa tạo phiếu xuất nào.'),
      );
    }

    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: _exports.length,
      itemBuilder: (_, i) {
        final o = _exports[i];
        final id = o['id'];
        final time = (o['created_at'] ?? '').toString();
        final qty = o['total_qty'] ?? 0;
        final amount = o['total_amount'] ?? 0;

        return Card(
          margin: const EdgeInsets.only(top: 8),
          child: ListTile(
            leading: const Icon(Icons.outbox),
            title: Text('Phiếu xuất #$id'),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Thời gian: $time'),
                Text('Tổng SL: $qty'),
                Text('Tổng tiền: $amount'),
              ],
            ),
          ),
        );
      },
    );
  }
}
