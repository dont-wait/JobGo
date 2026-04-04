import 'package:flutter/material.dart';
import 'package:jobgo/core/configs/theme/app_colors.dart';
import 'package:jobgo/core/enums/user_role.dart';
import 'package:jobgo/data/models/admin_user_model.dart';
import 'package:jobgo/presentation/widgets/admin/users/user_type_tabs.dart';
import 'package:jobgo/presentation/widgets/admin/users/user_card.dart';
import 'package:jobgo/presentation/widgets/admin/users/user_detail_dialog.dart';
import 'package:jobgo/presentation/widgets/common/profile_avatar.dart';
import 'package:jobgo/presentation/providers/admin_provider.dart';
import 'package:provider/provider.dart';

class UserManagementPage extends StatefulWidget {
  const UserManagementPage({super.key});

  @override
  State<UserManagementPage> createState() => _UserManagementPageState();
}

class _UserManagementPageState extends State<UserManagementPage> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final adminProvider = context.read<AdminProvider>();
      final roleFilter = adminProvider.selectedUserFilter == 'Candidates'
          ? 'candidate'
          : adminProvider.selectedUserFilter == 'Employers'
          ? 'employer'
          : null;
      adminProvider.loadUsers(roleFilter: roleFilter);
    });
  }

  void _showUserDetail(AdminUserModel user, AdminProvider adminProvider) {
    showDialog(
      context: context,
      builder: (context) => UserDetailDialog(
        user: user,
        onBlock: () => _handleBlockUser(user, adminProvider),
        onUnblock: () => _handleUnblockUser(user, adminProvider),
        onDelete: () => _handleDeleteUser(user, adminProvider),
      ),
    );
  }

  void _handleBlockUser(
    AdminUserModel user,
    AdminProvider adminProvider,
  ) async {
    try {
      Navigator.of(context).pop();
      final blocked = await adminProvider.blockUser(user.id, 'Blocked by admin');

      if (blocked) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('${user.name} has been blocked'),
            backgroundColor: AppColors.warning,
            behavior: SnackBarBehavior.floating,
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Block failed: missing users.u_status column or update permission denied'),
            backgroundColor: AppColors.error,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error blocking user: $e'),
          backgroundColor: AppColors.error,
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  void _handleUnblockUser(
    AdminUserModel user,
    AdminProvider adminProvider,
  ) async {
    try {
      Navigator.of(context).pop();
      final unblocked = await adminProvider.unblockUser(user.id);

      if (unblocked) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('${user.name} has been unblocked'),
            backgroundColor: AppColors.success,
            behavior: SnackBarBehavior.floating,
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Unblock failed: missing users.u_status column or update permission denied'),
            backgroundColor: AppColors.error,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error unblocking user: $e'),
          backgroundColor: AppColors.error,
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  void _handleDeleteUser(
    AdminUserModel user,
    AdminProvider adminProvider,
  ) async {
    try {
      Navigator.of(context).pop();
      final deleted = await adminProvider.deleteUser(user.id);

      if (deleted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('${user.name} has been deleted'),
            backgroundColor: AppColors.error,
            behavior: SnackBarBehavior.floating,
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Delete failed: user record was not found'),
            backgroundColor: AppColors.warning,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error deleting user: $e'),
          backgroundColor: AppColors.error,
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<AdminProvider>(
      builder: (context, adminProvider, child) => Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          backgroundColor: Colors.white,
          elevation: 0,
          centerTitle: true,
          automaticallyImplyLeading: false,
          title: const Text(
            'User Management',
            style: TextStyle(
              color: AppColors.textPrimary,
              fontSize: 18,
              fontWeight: FontWeight.w600,
            ),
          ),
          actions: [
            const ProfileAvatar(role: UserRole.admin),
            const SizedBox(width: 8),
          ],
        ),
        body: Column(
          children: [
            // Search Bar
            Container(
              color: AppColors.white,
              padding: const EdgeInsets.fromLTRB(20, 8, 20, 16),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      onChanged: (value) {
                        adminProvider.setUserSearchQuery(value);
                      },
                      decoration: InputDecoration(
                        hintText: 'Search users, emails, or roles...',
                        hintStyle: TextStyle(
                          color: AppColors.textHint,
                          fontSize: 14,
                        ),
                        prefixIcon: const Icon(
                          Icons.search,
                          color: AppColors.textSecondary,
                        ),
                        filled: true,
                        fillColor: AppColors.lightBackground,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide.none,
                        ),
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 12,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  IconButton(
                    icon: const Icon(Icons.filter_list),
                    onPressed: () {},
                    style: IconButton.styleFrom(
                      backgroundColor: AppColors.lightBackground,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // Tabs
            UserTypeTabs(
              selectedTab: adminProvider.selectedUserFilter,
              onTabChanged: (tab) {
                adminProvider.setUserFilter(tab);
                final roleFilter = tab == 'Candidates'
                    ? 'candidate'
                    : 'employer';
                adminProvider.loadUsers(roleFilter: roleFilter);
              },
            ),

            // User List
            Expanded(
              child: adminProvider.isLoadingUsers
                  ? const Center(child: CircularProgressIndicator())
                  : adminProvider.users.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.people_outline,
                            size: 64,
                            color: AppColors.textHint,
                          ),
                          const SizedBox(height: 16),
                          Text(
                            adminProvider.userLoadError != null
                                ? 'Failed to load users'
                                : adminProvider.userSearchQuery.isEmpty
                                ? 'No ${adminProvider.selectedUserFilter.toLowerCase()} found'
                                : 'No results for "${adminProvider.userSearchQuery}"',
                            style: TextStyle(
                              fontSize: 16,
                              color: AppColors.textSecondary,
                            ),
                          ),
                          if (adminProvider.userLoadError != null) ...[
                            const SizedBox(height: 8),
                            Padding(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 24,
                              ),
                              child: Text(
                                adminProvider.userLoadError!,
                                textAlign: TextAlign.center,
                                style: const TextStyle(
                                  fontSize: 12,
                                  color: AppColors.textHint,
                                ),
                              ),
                            ),
                            const SizedBox(height: 12),
                            OutlinedButton(
                              onPressed: () {
                                final roleFilter =
                                    adminProvider.selectedUserFilter ==
                                        'Candidates'
                                    ? 'candidate'
                                    : 'employer';
                                adminProvider.loadUsers(roleFilter: roleFilter);
                              },
                              child: const Text('Retry'),
                            ),
                          ],
                        ],
                      ),
                    )
                  : ListView.builder(
                      padding: const EdgeInsets.all(16),
                      itemCount: adminProvider.users.length,
                      itemBuilder: (context, index) {
                        final user = adminProvider.users[index];
                        return UserCard(
                          user: user,
                          onTap: () => _showUserDetail(user, adminProvider),
                        );
                      },
                    ),
            ),
          ],
        ),
        floatingActionButton: FloatingActionButton(
          onPressed: () {
            adminProvider.loadMoreUsers();
          },
          backgroundColor: AppColors.primary,
          child: const Icon(Icons.add, color: AppColors.white),
        ),
      ),
    );
  }
}
