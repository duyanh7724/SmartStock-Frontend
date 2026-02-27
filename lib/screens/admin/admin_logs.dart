import 'package:flutter/material.dart';
import '../../services/api_service.dart';
import 'admin_user_activity.dart';

class AdminLogsPage extends StatefulWidget {
  const AdminLogsPage({super.key});

  @override
  State<AdminLogsPage> createState() => _AdminLogsPageState();
}

class _AdminLogsPageState extends State<AdminLogsPage> {
  bool _loading = true;
  String? _error;
  List _logs = [];

  @override
  void initState() {
    super.initState();
    _loadLogs();
  }

  Future<void> _loadLogs() async {
    setState(() {
      _loading = true;
      _error = null;
    });

    try {
      final res = await ApiService.getLogs();
      if (res['success'] == true) {
        _logs = res['data'] ?? [];
      } else {
        _error = res['message']?.toString() ?? 'Không lấy được log';
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
    if (_loading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_error != null) {
      return Center(
        child: Text(
          'Không load được log:\n$_error',
          textAlign: TextAlign.center,
        ),
      );
    }

    if (_logs.isEmpty) {
      return const Center(
        child: Text('Chưa có log đăng nhập nào'),
      );
    }

    return RefreshIndicator(
      onRefresh: _loadLogs,
      child: ListView.separated(
        padding: const EdgeInsets.all(16),
        itemCount: _logs.length,
        separatorBuilder: (_, __) => const SizedBox(height: 8),
        itemBuilder: (_, i) {
          final log = _logs[i];

          final username = (log['username'] ?? 'Không rõ').toString();
          final fullname = (log['fullname'] ?? '').toString();
          final role = (log['role'] ?? '').toString();

          final ip = (log['ip_address'] ?? '').toString();
          final time = (log['time'] ?? '').toString();
          final userId = log['user_id'];

          final isSuccess = userId != null;

          return Card(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            child: ListTile(
              onTap: () {
                if (userId == null) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Log này không gắn với tài khoản cụ thể'),
                    ),
                  );
                  return;
                }

                final id = int.tryParse(userId.toString());
                if (id == null) return;

                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => AdminUserActivityPage(
                      userId: id,
                      username: username,
                      fullname: fullname,
                    ),
                  ),
                );
              },
              leading: CircleAvatar(
                child: Text(
                  username.isNotEmpty ? username[0].toUpperCase() : '?',
                ),
              ),
              title: Text(
                fullname.isNotEmpty ? fullname : username,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              subtitle: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (role.isNotEmpty) Text('Vai trò: $role'),
                  Text('IP: $ip'),
                  Text('Thời gian: $time'),
                ],
              ),
              trailing: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    isSuccess ? Icons.check_circle : Icons.error,
                    color: isSuccess ? Colors.green : Colors.red,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    isSuccess ? 'Thành công' : 'Thất bại',
                    style: TextStyle(
                      fontSize: 11,
                      color: isSuccess ? Colors.green : Colors.red,
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
}
