import 'package:flutter/material.dart';
import 'package:jobgo/core/configs/theme/app_colors.dart';
import 'package:jobgo/presentation/providers/admin_provider.dart';
import 'package:provider/provider.dart';

class DeletedUsersPage extends StatefulWidget {
  const DeletedUsersPage({super.key});

  @override
  State<DeletedUsersPage> createState() => _DeletedUsersPageState();
}

class _DeletedUsersPageState extends State<DeletedUsersPage> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<AdminProvider>().loadDeletedUsers();
    });
  }

  void _handleRestore(String userId, String userName) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Khôi phục tài khoản'),
        content: Text('Bạn muốn khôi phục tài khoản "$userName"? Tài khoản này sẽ hoạt động lại bình thường.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Hủy')),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.success),
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Khôi phục', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );

    if (confirm != true || !mounted) return;

    final success = await context.read<AdminProvider>().restoreUser(userId);
    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(success ? 'Đã khôi phục tài khoản thành công.' : 'Lỗi khi khôi phục.'),
        backgroundColor: success ? AppColors.success : AppColors.error,
      ),
    );
  }

  void _handleHardDelete(String userId, String userName) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Xóa VĨNH VIỄN'),
        content: Text('CẢNH BÁO: Hành động này sẽ xóa vĩnh viễn "$userName" khỏi cơ sở dữ liệu Supabase và không thể hoàn tác. Bạn có chắc chắn không?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Hủy')),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.error),
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Xóa vĩnh viễn', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );

    if (confirm != true || !mounted) return;

    final success = await context.read<AdminProvider>().hardDeleteUser(userId);
    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(success ? 'Đã xóa vĩnh viễn khỏi hệ thống.' : 'Lỗi khi xóa vĩnh viễn.'),
        backgroundColor: success ? AppColors.warning : AppColors.error,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.lightBackground,
      appBar: AppBar(
        title: const Text('Thùng rác tài khoản'),
        centerTitle: true,
        backgroundColor: Colors.white,
      ),
      body: Consumer<AdminProvider>(
        builder: (context, provider, child) {
          if (provider.isLoadingDeleted) {
            return const Center(child: CircularProgressIndicator());
          }

          if (provider.deletedUsers.isEmpty) {
            return const Center(
              child: Text(
                'Thùng rác trống',
                style: TextStyle(color: AppColors.textSecondary, fontSize: 16),
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: provider.deletedUsers.length,
            itemBuilder: (context, index) {
              final user = provider.deletedUsers[index];
              return Card(
                margin: const EdgeInsets.only(bottom: 12),
                child: ListTile(
                  leading: CircleAvatar(child: Text(user.name.isNotEmpty ? user.name[0].toUpperCase() : 'U')),
                  title: Text(user.name, style: const TextStyle(fontWeight: FontWeight.bold)),
                  subtitle: Text('${user.email}\nVai trò: ${user.role}'),
                  isThreeLine: true,
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.restore, color: AppColors.success),
                        tooltip: 'Khôi phục',
                        onPressed: () => _handleRestore(user.id, user.name),
                      ),
                      IconButton(
                        icon: const Icon(Icons.delete_forever, color: AppColors.error),
                        tooltip: 'Xóa vĩnh viễn',
                        onPressed: () => _handleHardDelete(user.id, user.name),
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}