import 'dart:io';

void main() async {
  final url = Platform.environment['SUPABASE_URL']! + '/rest/v1/users?select=u_id,u_name,u_email,u_role,candidates(c_full_name),employers(e_company_name)&u_id=in.(18,25,27)';
  final key = Platform.environment['SUPABASE_ANON_KEY']!;
  final request = await HttpClient().getUrl(Uri.parse(url));
  request.headers.add('apikey', key);
  request.headers.add('Authorization', 'Bearer \$key');
  final response = await request.close();
  final content = await response.transform(Utf8Decoder()).join();
  print(content);
}
