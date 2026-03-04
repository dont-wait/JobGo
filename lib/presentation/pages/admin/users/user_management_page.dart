import 'package:flutter/material.dart';
import 'package:jobgo/core/configs/theme/app_colors.dart';
import 'package:jobgo/data/models/admin_user_model.dart';
import 'package:jobgo/presentation/widgets/admin/users/user_type_tabs.dart';
import 'package:jobgo/presentation/widgets/admin/users/user_card.dart';
import 'package:jobgo/presentation/widgets/admin/users/user_detail_dialog.dart';

class UserManagementPage extends StatefulWidget {
  const UserManagementPage({super.key});

  @override
  State<UserManagementPage> createState() => _UserManagementPageState();
}

class _UserManagementPageState extends State<UserManagementPage> {
  String selectedTab = 'Candidates';
  String searchQuery = '';
  List<AdminUserModel> users = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadUsers();
  }

  void _loadUsers() {
    // Mock data - replace with actual API call
    setState(() {
      users = [
        AdminUserModel(
          id: '1',
          name: 'Alex Rivera',
          email: 'alex.rivera@icloud.com',
          role: 'candidate',
          status: 'active',
          title: 'Frontend Developer',
          createdAt: DateTime.now().subtract(const Duration(days: 10)),
          lastActive: DateTime.now().subtract(const Duration(hours: 2)),
        ),
        AdminUserModel(
          id: '2',
          name: 'Sarah Chen',
          email: 'sarah.chen@example.com',
          role: 'candidate',
          status: 'blocked',
          title: 'Senior Developer',
          createdAt: DateTime.now().subtract(const Duration(days: 30)),
          lastActive: DateTime.now().subtract(const Duration(days: 5)),
        ),
        AdminUserModel(
          id: '3',
          name: 'Jordan Smith',
          email: 'jordan.smith@acn.io',
          role: 'candidate',
          status: 'active',
          title: 'UX/UI Designer',
          createdAt: DateTime.now().subtract(const Duration(days: 5)),
          lastActive: DateTime.now().subtract(const Duration(minutes: 30)),
        ),
        AdminUserModel(
          id: '4',
          name: 'TechSolutions Inc',
          email: 'hr@techsolutions.com',
          role: 'employer',
          status: 'active',
          company: 'TechSolutions Inc',
          createdAt: DateTime.now().subtract(const Duration(days: 60)),
          lastActive: DateTime.now().subtract(const Duration(hours: 1)),
        ),
        AdminUserModel(
          id: '5',
          name: 'Digital Innovations',
          email: 'jobs@digitalinnovations.com',
          role: 'employer',
          status: 'active',
          company: 'Digital Innovations',
          createdAt: DateTime.now().subtract(const Duration(days: 45)),
          lastActive: DateTime.now().subtract(const Duration(days: 2)),
        ),
      ];
      isLoading = false;
    });
  }

  List<AdminUserModel> get filteredUsers {
    var filtered = users.where((user) {
      if (selectedTab == 'Candidates') return user.role == 'candidate';
      if (selectedTab == 'Employers') return user.role == 'employer';
      return true;
    }).toList();

    if (searchQuery.isNotEmpty) {
      filtered = filtered.where((user) {
        return user.name.toLowerCase().contains(searchQuery.toLowerCase()) ||
            user.email.toLowerCase().contains(searchQuery.toLowerCase());
      }).toList();
    }

    return filtered;
  }

  void _showUserDetail(AdminUserModel user) {
    showDialog(
      context: context,
      builder: (context) => UserDetailDialog(
        user: user,
        onBlock: () => _handleBlockUser(user),
        onUnblock: () => _handleUnblockUser(user),
        onDelete: () => _handleDeleteUser(user),
      ),
    );
  }

  void _handleBlockUser(AdminUserModel user) {
    setState(() {
      final index = users.indexWhere((u) => u.id == user.id);
      if (index != -1) {
        users[index] = user.copyWith(status: 'blocked');
      }
    });
    Navigator.of(context).pop();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('${user.name} has been blocked'),
        backgroundColor: AppColors.warning,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  void _handleUnblockUser(AdminUserModel user) {
    setState(() {
      final index = users.indexWhere((u) => u.id == user.id);
      if (index != -1) {
        users[index] = user.copyWith(status: 'active');
      }
    });
    Navigator.of(context).pop();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('${user.name} has been unblocked'),
        backgroundColor: AppColors.success,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  void _handleDeleteUser(AdminUserModel user) {
    setState(() {
      users.removeWhere((u) => u.id == user.id);
    });
    Navigator.of(context).pop();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('${user.name} has been deleted'),
        backgroundColor: AppColors.error,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        title: const Text(
          'User Management',
          style: TextStyle(
            color: AppColors.textPrimary,
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
        actions: [
          IconButton(
            onPressed: () {},
            icon: const Icon(
              Icons.notifications_none_outlined,
              color: AppColors.textPrimary,
            ),
          ),
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
                      setState(() {
                        searchQuery = value;
                      });
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
            selectedTab: selectedTab,
            onTabChanged: (tab) {
              setState(() {
                selectedTab = tab;
              });
            },
          ),

          // User List
          Expanded(
            child: isLoading
                ? const Center(child: CircularProgressIndicator())
                : filteredUsers.isEmpty
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
                              searchQuery.isEmpty
                                  ? 'No ${selectedTab.toLowerCase()} found'
                                  : 'No results for "$searchQuery"',
                              style: TextStyle(
                                fontSize: 16,
                                color: AppColors.textSecondary,
                              ),
                            ),
                          ],
                        ),
                      )
                    : ListView.builder(
                        padding: const EdgeInsets.all(16),
                        itemCount: filteredUsers.length,
                        itemBuilder: (context, index) {
                          final user = filteredUsers[index];
                          return UserCard(
                            user: user,
                            onTap: () => _showUserDetail(user),
                          );
                        },
                      ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Load more users...'),
              behavior: SnackBarBehavior.floating,
            ),
          );
        },
        backgroundColor: AppColors.primary,
        child: const Icon(Icons.add, color: AppColors.white),
      ),
    );
  }
}
