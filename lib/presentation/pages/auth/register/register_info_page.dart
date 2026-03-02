import 'package:flutter/material.dart';
import '../../../../core/configs/theme/app_colors.dart';
import '../../../../core/enums/user_role.dart';
import '../../../widgets/common/auth_text_field.dart';
import '../../../widgets/common/social_login_row.dart';

import 'register_verify_email_page.dart';

class RegisterInfoPage extends StatefulWidget {
  final UserRole role;

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
    void dispose() {
      nameController.dispose();
      emailController.dispose();
      passwordController.dispose();
      confirmPasswordController.dispose();
      super.dispose();
    }
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
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Full name is required';
                  }
                  if (value.trim().length < 2) {
                    return 'Full name must be at least 2 characters';
                  }
                  return null;
                },
              ),

              const SizedBox(height: 16),
              AuthTextField(
                controller: emailController,
                hintText: 'Email Address',
                icon: Icons.email_outlined,
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Email is required';
                  }
                  final email = value.trim();
                  final emailRegex = RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$');
                  if (!emailRegex.hasMatch(email)) {
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
            role: widget.role,
          ),
        ),
      );
    }
  }

  Widget _buildHeader() {
    return Column(
      children:  [
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
          'Account Details ${widget.role}',
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
