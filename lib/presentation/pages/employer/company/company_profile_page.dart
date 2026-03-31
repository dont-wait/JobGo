
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../../core/configs/theme/app_colors.dart';
import '../../../widgets/employer/company/company_profile_card.dart';

class CompanyProfilePage extends StatefulWidget {
  const CompanyProfilePage({super.key});

  @override
  State<CompanyProfilePage> createState() => _CompanyProfilePageState();
}

class _CompanyProfilePageState extends State<CompanyProfilePage> {
  Map<String, dynamic>? employer;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadCompany();
  }

  Future<void> _loadCompany() async {
    try {
      final supabase = Supabase.instance.client;
      final user = supabase.auth.currentUser;

      if (user == null) {
        throw Exception("Chưa đăng nhập");
      }

      // Lấy u_id từ users
      final userRow = await supabase
          .from('users')
          .select('u_id')
          .eq('auth_uid', user.id)
          .single();

      final uId = userRow['u_id'];

      // Lấy employer
      final data = await supabase
          .from('employers')
          .select()
          .eq('u_id', uId)
          .single();

      setState(() {
        employer = data;
        isLoading = false;
      });
    } catch (e) {
      print("Load company error: $e");
      setState(() => isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.lightBackground,
      appBar: AppBar(
        title: const Text("Hồ sơ công ty"),
        backgroundColor: AppColors.primary,
        foregroundColor: AppColors.white,
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : employer == null
              ? const Center(child: Text("Không có dữ liệu công ty"))
              : CompanyProfileCard(
                  companyName: employer!['e_company_name'] ?? 'Chưa có tên',
                  imagePath: employer!['e_logo_url'] ??
                      "assets/images/role_candidate1.jpg",
                  description:
                      employer!['e_company_description'] ?? 'Chưa có mô tả',
                  location:
                      employer!['e_company_address'] ?? 'Chưa có địa chỉ',
                  website:
                      employer!['e_website'] ?? 'Chưa có website',
                  email: 
                      employer!['e_email'] ?? '',
                  phone: 
                      employer!['e_phone'] ?? '',
                  companySize: 
                      employer!['e_company_size'] ?? '',
                ),
    );
  }
}