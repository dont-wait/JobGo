import 'package:flutter/material.dart';
import 'package:jobgo/data/models/interview_schedule_model.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class InterviewProvider extends ChangeNotifier {
  final supabase = Supabase.instance.client;

  List<InterviewScheduleModel> schedules = [];
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
    await supabase.from('interview_schedule').insert({
      'i_interview_date': date.toIso8601String(),
      'i_interview_type': type,
      'i_location': location,
      'i_contact_person': contactPerson,
      'i_note': note,
      'c_id': cId,
      'j_id': jId,
    });

    await loadSchedules();
  }

  Future<void> deleteSchedule(int id) async {
    final supabase = Supabase.instance.client;

    await supabase
        .from('interview_schedule')
        .delete()
        .eq('i_id', id);
  }
}