import 'package:flutter/material.dart';
import 'package:jobgo/data/models/interview_schedule_model.dart';
import 'package:jobgo/data/repositories/candidate_repository.dart';
import 'package:jobgo/data/repositories/interview_repository.dart';
import 'package:jobgo/data/repositories/notification_repository.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class InterviewProvider extends ChangeNotifier {
  final supabase = Supabase.instance.client;
  final _interviewRepo = InterviewRepository();
  final _notificationRepo = NotificationRepository();
  final _candidateRepo = CandidateRepository();

  List<InterviewScheduleModel> schedules = [];
  List<InterviewScheduleModel> candidateSchedules = [];
  bool isLoading = false;

  Future<void> loadSchedules() async {
    isLoading = true;
    notifyListeners();
    final data = await _interviewRepo.loadSchedules();
    schedules = data.map((e) => InterviewScheduleModel.fromMap(e)).toList();

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
    // 1. Gọi repo để insert lịch
    await _interviewRepo.createSchedule(
      date: date,
      type: type,
      location: location,
      contactPerson: contactPerson,
      note: note,
      cId: cId,
      jId: jId,
    );
    
    // 2. Lấy job title qua repo
    final jobTitle = await _interviewRepo.getJobTitle(jId);

    // 3. Gọi NotificationRepository để gửi thông báo
    await _notificationRepo.sendInterviewNotification(
      candidateId: cId,
      jobTitle: jobTitle,
    );

    // 4. Reload schedules
    await loadSchedules();
  }

  Future<void> deleteSchedule(int id) async {
    await supabase.from('interview_schedule').delete().eq('i_id', id);
  }

  Future<void> loadCandidateSchedules() async {
    isLoading = true;
    notifyListeners();

    try {
      final cId = await _candidateRepo.getCandidateIdByAuthUser();
      if (cId == null) return;

      final data = await _candidateRepo.loadCandidateSchedules(cId);
      candidateSchedules = data
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

  void clearSchedules() {
    schedules = [];
    candidateSchedules = [];
    isLoading = false;
    notifyListeners();
  }

  Future<void> updateSchedule({
    required int scheduleId,
    required DateTime date,
    required String type,
    required String location,
    required String contactPerson,
    required String note,
  }) async {
    await supabase.from('interview_schedule').update({
      'i_interview_date': date.toIso8601String(),
      'i_interview_type': type,
      'i_location': location,
      'i_contact_person': contactPerson,
      'i_note': note,
    }).eq('i_id', scheduleId);

    await loadSchedules();
  }
  // Candidate yêu cầu đổi lịch
  Future<void> requestReschedule({
    required int scheduleId,
    required DateTime requestedDate,
  }) async {
    try {
      await supabase
          .from('interview_schedule')
          .update({
            'i_status': 'reschedule',
            'i_requested_date': requestedDate.toIso8601String(),
          })
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
          status: 'reschedule',
          requestedDate: requestedDate,
        );
        notifyListeners();
      }
    } catch (e) {
      print('Error requesting reschedule: $e');
      rethrow;
    }
  }

  // Employer xác nhận đổi lịch
  Future<void> confirmReschedule(int scheduleId) async {
    try {
      // Lấy requested date
      final data = await supabase
          .from('interview_schedule')
          .select('i_requested_date')
          .eq('i_id', scheduleId)
          .single();

      final requestedDate = data['i_requested_date'] as String?;
      if (requestedDate == null) return;

      // UPDATE i_interview_date = i_requested_date
      await supabase
          .from('interview_schedule')
          .update({
            'i_interview_date': requestedDate,
            'i_status': 'accepted',
            'i_requested_date': null,
          })
          .eq('i_id', scheduleId);

      await loadSchedules();
    } catch (e) {
      print('Error confirming reschedule: $e');
      rethrow;
    }
  }

  // Employer từ chối đổi lịch
  Future<void> rejectReschedule(int scheduleId) async {
    try {
      await supabase
          .from('interview_schedule')
          .update({
            'i_status': 'rejected',
            'i_requested_date': null,
          })
          .eq('i_id', scheduleId);

      await loadSchedules();
    } catch (e) {
      print('Error rejecting reschedule: $e');
      rethrow;
    }
  }
}
