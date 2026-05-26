
import 'package:flutter/material.dart';
import 'package:jobgo/core/configs/theme/app_colors.dart';
import 'package:jobgo/presentation/pages/employer/interview_schedule/create_interview_page.dart';
import 'package:jobgo/presentation/pages/employer/interview_schedule/edit_interview_page.dart';
import 'package:jobgo/presentation/pages/employer/interview_schedule/interview_detail_page.dart';
import 'package:jobgo/presentation/providers/interview_provider.dart';
import 'package:jobgo/presentation/widgets/employer/interview_schedule/interview_card.dart';
import 'package:provider/provider.dart';
import 'package:jobgo/core/localization/app_localizations.dart';

class InterviewSchedulePage extends StatefulWidget {
  const InterviewSchedulePage({super.key});

  @override
  State<InterviewSchedulePage> createState() =>
      _InterviewSchedulePageState();
}

class _InterviewSchedulePageState extends State<InterviewSchedulePage> {
  @override
  void initState() {
    super.initState();

    // load data sau khi build xong
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<InterviewProvider>().loadSchedules();
    });
  }

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context);
    final isVi = Localizations.localeOf(context).languageCode == 'vi';

    return Scaffold(
      backgroundColor: AppColors.lightBackground,

      appBar: AppBar(
        title: Text(loc.interviewScheduleTitle),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        elevation: 0,
      ),

      // Nút thêm lịch hẹn
      floatingActionButton: FloatingActionButton(
        backgroundColor: AppColors.primary,
        onPressed: () async {
          await Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => const CreateInterviewPage(),
            ),
          );

          // reload sau khi tạo xong
          context.read<InterviewProvider>().loadSchedules();
        },
        child: const Icon(Icons.add),
      ),

      body: Consumer<InterviewProvider>(
        builder: (context, provider, _) {
          // Loading
          if (provider.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          // Empty state (UI đẹp hơn)
          if (provider.schedules.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.event_busy,
                      size: 60, color: AppColors.textHint),
                  const SizedBox(height: 12),
                  Text(
                    loc.noInterviewsMessage,
                    style: const TextStyle(
                      fontSize: 16,
                      color: AppColors.textSecondary,
                    ),
                  ),
                  const SizedBox(height: 12),
                  ElevatedButton(
                    onPressed: () async {
                      await Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const CreateInterviewPage(),
                        ),
                      );

                      context
                          .read<InterviewProvider>()
                          .loadSchedules();
                    },
                    child: Text(isVi ? "Tạo lịch ngay" : "Create now"),
                  )
                ],
              ),
            );
          }

          // List data
          return ListView.builder(
            padding: const EdgeInsets.only(top: 10, bottom: 80),
            itemCount: provider.schedules.length,
            itemBuilder: (context, index) {
              final schedule = provider.schedules[index];

              return InterviewCard(
                  schedule: schedule,
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => InterviewDetailPage(schedule: schedule),
                      ),
                    );
                  },
                  onDelete: () {
                    showDialog(
                      context: context,
                      builder: (_) => AlertDialog(
                        title: Text(loc.deleteInterviewTitle),
                        content: Text(loc.deleteInterviewConfirm),
                        actions: [
                          TextButton(
                            onPressed: () => Navigator.pop(context),
                            child: Text(loc.cancel),
                          ),
                          TextButton(
                            onPressed: () async {
                              Navigator.pop(context);

                              await context
                                  .read<InterviewProvider>()
                                  .deleteSchedule(schedule.id);

                              // reload
                              context.read<InterviewProvider>().loadSchedules();

                              if (context.mounted) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(content: Text(loc.deleteSuccessMsg)),
                                );
                              }
                            },
                            child: Text(
                              loc.delete,
                              style: const TextStyle(color: Colors.red),
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                  onEdit: () async {
                    await Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => EditInterviewPage(schedule: schedule),
                      ),
                    );
                    if (context.mounted) {
                        context.read<InterviewProvider>().loadSchedules();
                      }                  
                  },
                );
            },
          );
        },
      ),
    );
  }
}