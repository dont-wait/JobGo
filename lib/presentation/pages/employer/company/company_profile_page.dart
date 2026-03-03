import 'package:flutter/material.dart';
import '../../../../core/configs/theme/app_colors.dart';
import '../../../widgets/employer/company/company_profile_card.dart';

class CompanyProfilePage extends StatelessWidget {
  const CompanyProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.lightBackground,
      appBar: AppBar(
        title: const Text("Hồ sơ công ty"),
        backgroundColor: AppColors.primary,
        foregroundColor: AppColors.white,
      ),
      body: const CompanyProfileCard(
        companyName: "Global Design Systems",
        imagePath: "assets/images/role_candidate1.jpg",
        description:
            "Global Design Systems là công ty hàng đầu trong lĩnh vực thiết kế sản phẩm và trải nghiệm người dùng. "
            "Chúng tôi tập trung vào đổi mới sáng tạo, mang đến giải pháp thiết kế hiện đại cho khách hàng toàn cầu.",
        location: "London, United Kingdom",
        website: "www.globaldesign.com",
      ),
    );
  }
}