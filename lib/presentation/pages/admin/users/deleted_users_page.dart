import 'package:flutter/material.dart';
import 'package:jobgo/core/configs/theme/app_colors.dart';
import 'package:jobgo/core/localization/app_localizations.dart';
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

  void _handleRestore(dynamic userId, String userName) async {
    final loc = AppLocalizations.of(context);
    final uIdStr = userId.toString();
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(loc.restoreAccountTitle),
        content: Text('${loc.restoreAccountConfirm} "$userName"? ${loc.restoreAccountNormal}'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: Text(loc.cancel)),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.success),
            onPressed: () => Navigator.pop(context, true),
            child: Text(loc.restoreAction, style: const TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );

    if (confirm != true || !mounted) return;

    final success = await context.read<AdminProvider>().restoreUser(uIdStr);
    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(success ? loc.restoreSuccess : loc.restoreError),
        backgroundColor: success ? AppColors.success : AppColors.error,
      ),
    );
  }

  void _handleHardDelete(dynamic userId, String userName) async {
    final loc = AppLocalizations.of(context);
    final uIdStr = userId.toString();
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(loc.hardDeleteTitle),
        content: Text('${loc.hardDeleteConfirm} "$userName" ${loc.hardDeleteUndone}'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: Text(loc.cancel)),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.error),
            onPressed: () => Navigator.pop(context, true),
            child: Text(loc.hardDeleteAction, style: const TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );

    if (confirm != true || !mounted) return;

    final success = await context.read<AdminProvider>().hardDeleteUser(uIdStr);
    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(success ? loc.hardDeleteSuccess : loc.hardDeleteError),
        backgroundColor: success ? AppColors.warning : AppColors.error,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context);
    return Scaffold(
      backgroundColor: AppColors.lightBackground,
      appBar: AppBar(
        title: Text(loc.accountTrashTitle),
        centerTitle: true,
        backgroundColor: Colors.white,
      ),
      body: Consumer<AdminProvider>(
        builder: (context, provider, child) {
          if (provider.isLoadingDeleted) {
            return const Center(child: CircularProgressIndicator());
          }

          if (provider.deletedUsers.isEmpty) {
            return Center(
              child: Text(
                loc.emptyTrash,
                style: const TextStyle(color: AppColors.textSecondary, fontSize: 16),
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
                  subtitle: Text('${user.email}\n${loc.rolePrefix} ${user.role}'),
                  isThreeLine: true,
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.restore, color: AppColors.success),
                        tooltip: loc.restoreAction,
                        onPressed: () => _handleRestore(user.id, user.name),
                      ),
                      IconButton(
                        icon: const Icon(Icons.delete_forever, color: AppColors.error),
                        tooltip: loc.hardDeleteAction,
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