import 'package:flutter/material.dart';
import 'package:jobgo/core/configs/theme/app_colors.dart';
import 'package:jobgo/core/enums/user_role.dart';
import 'package:jobgo/presentation/providers/admin_provider.dart';
import 'package:jobgo/presentation/widgets/common/profile_avatar.dart';
import 'package:provider/provider.dart';

class AdminSupportIssuePage extends StatefulWidget {
  const AdminSupportIssuePage({super.key});

  @override
  State<AdminSupportIssuePage> createState() => _AdminSupportIssuePageState();
}

class _AdminSupportIssuePageState extends State<AdminSupportIssuePage> {
  String _activeFilter = 'all';

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadTickets();
    });
  }

  Future<void> _loadTickets() async {
    await context.read<AdminProvider>().loadSupportTickets(
      status: _activeFilter == 'all' ? null : _activeFilter,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<AdminProvider>(
      builder: (context, adminProvider, _) {
        final tickets = adminProvider.supportTickets;

        return Scaffold(
          backgroundColor: Colors.white,
          appBar: AppBar(
            backgroundColor: Colors.white,
            elevation: 0,
            centerTitle: true,
            automaticallyImplyLeading: false,
            title: const Text(
              'Support Issues',
              style: TextStyle(
                color: AppColors.textPrimary,
                fontSize: 18,
                fontWeight: FontWeight.w600,
              ),
            ),
            actions: const [
              ProfileAvatar(role: UserRole.admin),
              SizedBox(width: 8),
            ],
          ),
          body: Column(
            children: [
              _buildFilters(adminProvider),
              Container(
                width: double.infinity,
                color: AppColors.lightBackground,
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 10,
                ),
                child: Text(
                  'Unresolved: ${adminProvider.unresolvedTicketsCount}',
                  style: const TextStyle(
                    color: AppColors.textSecondary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              Expanded(
                child: adminProvider.isLoadingTickets
                    ? const Center(child: CircularProgressIndicator())
                    : tickets.isEmpty
                    ? const Center(
                        child: Text(
                          'No support issues found',
                          style: TextStyle(color: AppColors.textSecondary),
                        ),
                      )
                    : RefreshIndicator(
                        onRefresh: _loadTickets,
                        child: ListView.builder(
                          padding: const EdgeInsets.all(16),
                          itemCount: tickets.length,
                          itemBuilder: (context, index) =>
                              _ticketCard(tickets[index], adminProvider),
                        ),
                      ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildFilters(AdminProvider adminProvider) {
    const filters = [
      ('All', 'all'),
      ('Open', 'open'),
      ('In Progress', 'in_progress'),
      ('Resolved', 'resolved'),
    ];

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.fromLTRB(16, 10, 16, 8),
      child: Row(
        children: filters.map((f) {
          final selected = _activeFilter == f.$2;
          return Padding(
            padding: const EdgeInsets.only(right: 8),
            child: ChoiceChip(
              label: Text(f.$1),
              selected: selected,
              selectedColor: AppColors.primary,
              labelStyle: TextStyle(
                color: selected ? Colors.white : AppColors.textSecondary,
                fontWeight: FontWeight.w600,
              ),
              onSelected: (_) {
                setState(() => _activeFilter = f.$2);
                adminProvider.setSupportFilter(f.$2);
                adminProvider.loadSupportTickets(
                  status: f.$2 == 'all' ? null : f.$2,
                );
              },
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _ticketCard(Map<String, dynamic> t, AdminProvider adminProvider) {
    final status = (t['status'] ?? 'open').toString().toLowerCase();

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.divider),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  (t['title'] ?? 'Issue').toString(),
                  style: const TextStyle(
                    fontWeight: FontWeight.w700,
                    color: AppColors.textPrimary,
                  ),
                ),
              ),
              _statusBadge(status),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            (t['description'] ?? '').toString(),
            style: const TextStyle(color: AppColors.textSecondary),
          ),
          const SizedBox(height: 10),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              _chip('ID: ${(t['id'] ?? '').toString()}'),
              _chip('Category: ${(t['category'] ?? 'other').toString()}'),
              _chip('Priority: ${(t['priority'] ?? 'medium').toString()}'),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              if (status == 'open')
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => adminProvider.updateSupportTicketStatus(
                      ticketId: (t['id'] ?? '').toString(),
                      status: 'in_progress',
                      adminNote: 'Issue is being handled by admin',
                    ),
                    child: const Text('In Progress'),
                  ),
                ),
              if (status == 'open') const SizedBox(width: 10),
              if (status != 'resolved' && status != 'closed')
                Expanded(
                  child: ElevatedButton(
                    onPressed: () => _resolveDialog(
                      (t['id'] ?? '').toString(),
                      adminProvider,
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.success,
                      foregroundColor: Colors.white,
                    ),
                    child: const Text('Resolve'),
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }

  Future<void> _resolveDialog(String id, AdminProvider adminProvider) async {
    final controller = TextEditingController();
    final result = await showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Resolve Issue'),
        content: TextField(
          controller: controller,
          maxLines: 4,
          decoration: const InputDecoration(hintText: 'Resolution note...'),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, controller.text.trim()),
            child: const Text('Resolve'),
          ),
        ],
      ),
    );

    if (result == null) return;
    await adminProvider.resolveTicket(
      id,
      result.isEmpty ? 'Resolved by admin' : result,
    );
  }

  Widget _statusBadge(String status) {
    Color bg;
    Color fg;
    String label;

    switch (status) {
      case 'resolved':
        bg = AppColors.success.withValues(alpha: 0.15);
        fg = AppColors.success;
        label = 'RESOLVED';
        break;
      case 'in_progress':
        bg = AppColors.primary.withValues(alpha: 0.15);
        fg = AppColors.primary;
        label = 'IN PROGRESS';
        break;
      default:
        bg = AppColors.warning.withValues(alpha: 0.15);
        fg = AppColors.warning;
        label = 'OPEN';
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        label,
        style: TextStyle(color: fg, fontWeight: FontWeight.w700, fontSize: 10),
      ),
    );
  }

  Widget _chip(String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
      decoration: BoxDecoration(
        color: AppColors.lightBackground,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        text,
        style: const TextStyle(fontSize: 11, color: AppColors.textSecondary),
      ),
    );
  }
}
