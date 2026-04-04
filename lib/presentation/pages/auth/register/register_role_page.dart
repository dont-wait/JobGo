import 'package:flutter/material.dart';
import '../../../../core/configs/theme/app_colors.dart';
import '../../../../core/enums/user_role.dart';
import '../../../../core/localization/app_localizations.dart';
import 'register_info_page.dart';
import '../../../widgets/common/role_card.dart';
import '../../../widgets/common/language_selector_button.dart';

class RegisterRolePage extends StatefulWidget {
  const RegisterRolePage({super.key});

  @override
  State<RegisterRolePage> createState() => _RegisterRolePageState();
}

class _RegisterRolePageState extends State<RegisterRolePage> {
  UserRole? selectedRole;

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context);
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          const LanguageSelectorButton(isCompact: true),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              loc.stepOfThree,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 12,
                letterSpacing: 1.2,
                color: AppColors.textSecondary,
              ),
            ),
            const SizedBox(height: 16),

            Text(
              loc.chooseYourRole,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.w700,
                color: AppColors.textPrimary,
              ),
            ),

            const SizedBox(height: 8),

            Text(
              loc.selectHowToUse,
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: AppColors.textSecondary,
              ),
            ),

            const SizedBox(height: 32),

            // CANDIDATE
            RoleCard(
              imagePath: 'assets/images/role_candidate1.jpg',
              title: loc.iAmCandidate,
              description: loc.candidateDescription,
              isSelected: selectedRole == UserRole.candidate,
              onTap: () {
                setState(() {
                  selectedRole = UserRole.candidate;
                });
              },
            ),

            // EMPLOYER
            RoleCard(
              imagePath: 'assets/images/role_employee.jpg',
              title: loc.iAmEmployer,
              description: loc.employerDescription,
              isSelected: selectedRole == UserRole.employer,
              onTap: () {
                setState(() {
                  selectedRole = UserRole.employer;
                });
              },
            ),

            const SizedBox(height: 24),

            ElevatedButton(
              onPressed: selectedRole == null
                  ? null
                  : () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => RegisterInfoPage(
                            role: selectedRole!,
                          ),
                        ),
                      );
                    },
              child: Text(loc.next),
            ),
            const SizedBox(height: 16),

            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  '${loc.alreadyHaveAccount} ',
                  style: const TextStyle(color: AppColors.textSecondary),
                ),
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: Text(loc.signIn),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
