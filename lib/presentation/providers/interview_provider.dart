
import 'package:flutter/material.dart';
import 'package:jobgo/data/models/interview_schedule_model.dart';
import 'package:jobgo/data/repositories/notification_repository.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class InterviewProvider extends ChangeNotifier {
  final supabase = Supabase.instance.client;

  List<InterviewScheduleModel> schedules = [];
  List<InterviewScheduleModel> candidateSchedules = [];
  bool isLoading = false;

  Future<void> loadSchedules() async {
    isLoading = true;
    notifyListeners();

    final data = await supabase
        .from('interview_schedule')
        .select('''
          i_id,
          i_interview_date,
          i_interview_type,
          i_location,
          i_contact_person,
          i_note,
          i_status,
          candidates (c_full_name),
          jobs (j_title)
        ''')
        .order('i_interview_date');

    schedules = (data as List)
        .map((e) => InterviewScheduleModel.fromMap(e))
        .toList();

    isLoading = false;
    notifyListeners();
  }

  Future<void> createSchedule({
    required DateTime date,
    required String type,
    required String location,
    required String contactPerson,
    required String note,
    required int cId,
    required int jId,
  }) async {
    // Tạo lịch phỏng vấn
    await supabase.from('interview_schedule').insert({
      'i_interview_date': date.toIso8601String(),
      'i_interview_type': type,
      'i_location': location,
      'i_contact_person': contactPerson,
      'i_note': note,
      'c_id': cId,
      'j_id': jId,
      'i_status': 'pending',
    });

    // Lấy u_id của candidate để gửi notification
    // try {
    //   final candidateRow = await supabase
    //       .from('candidates')
    //       .select('u_id')
    //       .eq('c_id', cId)
    //       .maybeSingle();

    //   final jobRow = await supabase
    //       .from('jobs')
    //       .select('j_title')
    //       .eq('j_id', jId)
    //       .maybeSingle();

    //   if (candidateRow != null) {
    //     final uId = candidateRow['u_id'] as int;
    //     final jobTitle = jobRow?['j_title'] ?? 'một vị trí';

    //     // INSERT notification cho candidate
    //     await supabase.from('notifications').insert({
    //       'n_type': 'interview',
    //       'n_content': 'Bạn có lịch phỏng vấn mới cho vị trí $jobTitle',
    //       'n_status': 'unread',
    //       'u_id': uId,
    //     });
    //   }
    // } catch (e) {
    //   print('Error sending notification: $e');
    // }


    // try {
    //   final candidateRow = await supabase
    //       .from('candidates')
    //       .select('u_id')
    //       .eq('c_id', cId)
    //       .maybeSingle();

    //   final jobRow = await supabase
    //       .from('jobs')
    //       .select('j_title')
    //       .eq('j_id', jId)
    //       .maybeSingle();

    //   if (candidateRow != null) {
    //     final uId = candidateRow['u_id'] as int;
    //     final jobTitle = jobRow?['j_title'] ?? 'một vị trí';

    //     // Đây là logic gửi notification → nên gọi NotificationRepository.sendInterviewNotification()
    //     await supabase.from('notifications').insert({
    //       'n_type': 'interview',
    //       'n_content': 'Bạn có lịch phỏng vấn mới cho vị trí $jobTitle',
    //       'n_status': 'unread',
    //       'u_id': uId,
    //     });
    //   }
    // } catch (e) {
    //   print('Error sending notification: $e');
    // }

    // await loadSchedules();
    // 2. Lấy job title
  final jobRow = await supabase
      .from('jobs')
      .select('j_title')
      .eq('j_id', jId)
      .maybeSingle();

  final jobTitle = jobRow?['j_title'] ?? 'một vị trí';

  // 3. Gọi NotificationRepository để gửi thông báo
  await NotificationRepository().sendInterviewNotification(
    candidateId: cId,
    jobTitle: jobTitle,
  );

  // 4. Reload schedules
  await loadSchedules();
  }

  Future<void> deleteSchedule(int id) async {
    await supabase
        .from('interview_schedule')
        .delete()
        .eq('i_id', id);
  }

  Future<void> loadCandidateSchedules() async {
    isLoading = true;
    notifyListeners();

    try {
      final authUser = supabase.auth.currentUser;
      if (authUser == null) return;

      final userRow = await supabase
          .from('users')
          .select('u_id')
          .or('auth_uid.eq.${authUser.id},u_email.eq.${authUser.email}')
          .maybeSingle();

      if (userRow == null) return;
      final uId = userRow['u_id'] as int;

      final candidateRow = await supabase
          .from('candidates')
          .select('c_id')
          .eq('u_id', uId)
          .maybeSingle();

      if (candidateRow == null) return;
      final cId = candidateRow['c_id'] as int;

      final data = await supabase
          .from('interview_schedule')
          .select('''
            i_id,
            i_interview_date,
            i_interview_type,
            i_location,
            i_contact_person,
            i_note,
            i_status,
            candidates (c_full_name),
            jobs (j_title)
          ''')
          .eq('c_id', cId)
          .order('i_interview_date');

      candidateSchedules = (data as List)
          .map((e) => InterviewScheduleModel.fromMap(e))
          .toList();

    } catch (e) {
      print('Error loading candidate schedules: $e');
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  Future<void> updateScheduleStatus({
    required int scheduleId,
    required String status,
  }) async {
    try {
      await supabase
          .from('interview_schedule')
          .update({'i_status': status})
          .eq('i_id', scheduleId);

      final index = candidateSchedules.indexWhere((s) => s.id == scheduleId);
      if (index != -1) {
        candidateSchedules[index] = InterviewScheduleModel(
          id: candidateSchedules[index].id,
          candidateName: candidateSchedules[index].candidateName,
          jobTitle: candidateSchedules[index].jobTitle,
          date: candidateSchedules[index].date,
          type: candidateSchedules[index].type,
          location: candidateSchedules[index].location,
          contactPerson: candidateSchedules[index].contactPerson,
          note: candidateSchedules[index].note,
          status: status,
        );
        notifyListeners();
      }
    } catch (e) {
      print('Error updating status: $e');
      rethrow;
    }
  }
  
}