import 'package:flutter/material.dart';
import 'package:jobgo/presentation/pages/employer/company/company_detail_page.dart';
import 'package:jobgo/core/localization/app_localizations.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:jobgo/core/utils/app_logger.dart';
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
    } catch (e, st) {
      AppLogger.error('Load company error', error: e, stackTrace: st);
      setState(() => isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context);

    return Scaffold(
      backgroundColor: AppColors.lightBackground,
      appBar: AppBar(
        title: Text(loc.companyProfile),
        backgroundColor: AppColors.primary,
        foregroundColor: AppColors.white,
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : employer == null
          ? Center(child: Text(loc.noCompanyData))
          : InkWell(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => CompanyDetailPage(employer: employer!),
                  ),
                );
              },
              child: CompanyProfileCard(
                companyName: employer!['e_company_name'] ?? loc.unnamedCompany,
                imagePath:
                    employer!['e_logo_url'] ??
                    "assets/images/role_candidate1.jpg",
                description:
                    employer!['e_company_description'] ??
                    loc.noCompanyDescription,
                location:
                    employer!['e_company_address'] ?? loc.noCompanyAddress,
                website: employer!['e_website'] ?? loc.noCompanyWebsite,
                email: employer!['e_email'] ?? loc.noCompanyEmail,
                phone: employer!['e_phone'] ?? loc.noCompanyPhone,
                companySize: employer!['e_company_size'] ?? loc.noCompanySize,
              ),
            ),
    );
  }
}
