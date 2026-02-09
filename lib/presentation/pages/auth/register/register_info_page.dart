import 'package:flutter/material.dart';
import '../../../../core/configs/theme/app_colors.dart';
import '../../../widgets/common/auth_text_field.dart';
import '../../../widgets/common/social_login_row.dart';

import 'register_verify_email_page.dart';

class RegisterInfoPage extends StatefulWidget {
  final String role;

  const RegisterInfoPage({
    super.key,
    required this.role,
  });

  @override
  State<RegisterInfoPage> createState() => _RegisterInfoPageState();
}

class _RegisterInfoPageState extends State<RegisterInfoPage> {
  final _formKey = GlobalKey<FormState>();

  final TextEditingController nameController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController confirmPasswordController = TextEditingController();

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
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _buildHeader(),
              const SizedBox(height: 32),

              AuthTextField(
                controller: nameController,
                hintText: 'Full Name',
                icon: Icons.person_outline,
              ),
              const SizedBox(height: 16),
              AuthTextField(
                controller: emailController,
                hintText: 'Email Address',
                icon: Icons.email_outlined,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Email is required';
                  }
                  if (!value.contains('@')) {
                    return 'Invalid email format';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              AuthTextField(
                controller: passwordController,
                hintText: 'Password',
                icon: Icons.lock_outline,
                obscureText: true,
                validator: (value) {
                  if (value == null || value.length < 6) {
                    return 'Password must be at least 6 characters';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              AuthTextField(
                controller: confirmPasswordController,
                hintText: 'Confirm Password',
                icon: Icons.lock_outline,
                obscureText: true,
                validator: (value) {
                  if (value != passwordController.text) {
                    return 'Passwords do not match';
                  }
                  return null;
                },
              ),

              const SizedBox(height: 32),

              ElevatedButton(
                onPressed: _onContinue,
                child: const Text('Continue'),
              ),

              const SizedBox(height: 24),

              const SocialLoginRow(),
            ],
          ),
        ),
      ),
    );
  }

  //  METHODS
  void _onContinue() {
    if (_formKey.currentState!.validate()) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => RegisterVerifyEmailPage(
            email: emailController.text,
          ),
        ),
      );
    }
  }

  Widget _buildHeader() {
    return Column(
      children: const [
        Text(
          'STEP 2 OF 3',
          style: TextStyle(
            fontSize: 12,
            letterSpacing: 1.2,
            color: AppColors.textSecondary,
          ),
        ),
        SizedBox(height: 16),
        Text(
          'Account Details',
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.w700,
            color: AppColors.textPrimary,
          ),
        ),
        SizedBox(height: 8),
        Text(
          'Set up your login credentials',
          style: TextStyle(
            color: AppColors.textSecondary,
          ),
        ),
      ],
    );
  }
}
