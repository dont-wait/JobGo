import 'package:supabase/supabase.dart';
import 'dart:io';

void main() async {
  final supabase = SupabaseClient(
    Platform.environment['SUPABASE_URL']!,
    Platform.environment['SUPABASE_ANON_KEY']!
  );
  
  final userId = 25;
  final rows = await supabase
      .from('messages')
      .select('m_id, sender_id, receiver_id, m_content, m_status, m_sent_at')
      .or('sender_id.eq.$userId,receiver_id.eq.$userId')
      .order('m_sent_at', ascending: false);

  final Map<int, List<dynamic>> grouped = {};
  for (final row in rows) {
    final senderId = row['sender_id'] as int;
    final receiverId = row['receiver_id'] as int;
    final otherId = senderId == userId ? receiverId : senderId;
    grouped.putIfAbsent(otherId, () => []);
    grouped[otherId]!.add(row);
  }

  final otherIds = grouped.keys.toList();
  final userRows = await supabase
      .from('users')
      .select('u_id, u_name, u_email, u_role, candidates(c_full_name), employers(e_company_name)')
      .filter('u_id', 'in', '(${otherIds.join(",")})');

  for (final u in userRows) {
    print('User: ${u['u_id']} | Role: ${u['u_role']} | Candidates: ${u['candidates']} | Employers: ${u['employers']}');
  }
}
