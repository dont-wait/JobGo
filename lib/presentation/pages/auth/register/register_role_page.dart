import 'package:flutter/material.dart';
import '../../../../core/configs/theme/app_colors.dart';
import 'register_info_page.dart';
import '../../../widgets/common/role_card.dart';



enum UserRole { admin, candidate, employer }

class RegisterRolePage extends StatefulWidget {
  const RegisterRolePage({super.key});

  @override
  State<RegisterRolePage> createState() => _RegisterRolePageState();
}

class _RegisterRolePageState extends State<RegisterRolePage> {
  UserRole? selectedRole;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text(
              'STEP 1 OF 3',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 12,
                letterSpacing: 1.2,
                color: AppColors.textSecondary,
              ),
            ),
            const SizedBox(height: 16),

            const Text(
              'Choose your role',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.w700,
                color: AppColors.textPrimary,
              ),
            ),

            const SizedBox(height: 8),

            const Text(
              'Select how you want to use the platform',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: AppColors.textSecondary,
              ),
            ),

            const SizedBox(height: 32),

            // CANDIDATE
            RoleCard(
              imagePath: 'assets/images/role_candidate1.jpg',
              title: 'I am a Candidate',
              description:
                  'I’m looking for new career opportunities and want to showcase my talent.',
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
              title: 'I am an Employer',
              description:
                  'I want to post jobs, manage applications, and find talent.',
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
                            role: selectedRole!.name,
                          ),
                        ),
                      );
                    },
              child: const Text('Continue'),
            ),
            const SizedBox(height: 16),

            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text(
                  'Already have an account? ',
                  style: TextStyle(color: AppColors.textSecondary),
                ),
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Sign In'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
