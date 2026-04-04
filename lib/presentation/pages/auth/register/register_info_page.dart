import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../../core/configs/theme/app_colors.dart';
import '../../../../core/enums/user_role.dart';
import '../../../widgets/common/auth_text_field.dart';
import '../../../widgets/common/social_login_row.dart';
import 'register_verify_email_page.dart';
import 'package:jobgo/main.dart'; // để dùng isInRegisterFlow
import '../../../../data/repositories/auth_repository.dart';

class RegisterInfoPage extends StatefulWidget {
  final UserRole role;
  const RegisterInfoPage({super.key, required this.role});

  @override
  State<RegisterInfoPage> createState() => _RegisterInfoPageState();
}

class _RegisterInfoPageState extends State<RegisterInfoPage> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController nameController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController confirmPasswordController =
      TextEditingController();
  final _authRepository = AuthRepository();
  bool _isLoading = false;

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
      body: Stack(
        children: [
          SingleChildScrollView(
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
                      if (value == null || value.trim().isEmpty)
                        return 'Full name is required';
                      if (value.trim().length < 2)
                        return 'Full name must be at least 2 characters';
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),
                  AuthTextField(
                    controller: emailController,
                    hintText: 'Email Address',
                    icon: Icons.email_outlined,
                    validator: (value) {
                      if (value == null || value.trim().isEmpty)
                        return 'Email is required';
                      final emailRegex = RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$');
                      if (!emailRegex.hasMatch(value.trim()))
                        return 'Invalid email format';
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
                      if (value == null || value.length < 6)
                        return 'Password must be at least 6 characters';
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
                      if (value != passwordController.text)
                        return 'Passwords do not match';
                      return null;
                    },
                  ),
                  const SizedBox(height: 32),
                  ElevatedButton(
                    onPressed: _onContinue,
                    child: const Text('Continue'),
                  ),
                  const SizedBox(height: 24),
                  SocialLoginRow(
                    onGoogleTap: _onGoogleSignIn,
                    onFacebookTap: _onFacebookSignIn,
                  ),
                ],
              ),
            ),
          ),
          if (_isLoading) const Center(child: CircularProgressIndicator()),
        ],
      ),
    );
  }

  void _onGoogleSignIn() async {
    setState(() => _isLoading = true);
    try {
      await _authRepository.signInWithGoogle();
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("Google Sign-In Error: $e")));
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _onFacebookSignIn() async {
    setState(() => _isLoading = true);
    try {
      await _authRepository.signInWithFacebook();
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("Facebook Login Error: $e")));
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _onContinue() async {
    if (_formKey.currentState!.validate()) {
      final supabase = Supabase.instance.client;
      try {
        final response = await supabase.auth.signUp(
          email: emailController.text.trim(),
          password: passwordController.text.trim(),
        );

        // if (response.user != null)
        // {
        //   // Insert vào bảng users ngay
        //   await supabase.from('users').insert({
        //     'auth_uid': response.user!.id,
        //     'u_email': emailController.text.trim(),
        //     'u_name': nameController.text.trim(),
        //     'u_role': widget.role.name,
        //     'u_password': passwordController.text.trim(),
        //   });

        //   if (mounted) {
        //     isInRegisterFlow = true; // bật flag
        //     Navigator.push(
        //       context,
        //       MaterialPageRoute(
        //         builder: (_) => RegisterVerifyEmailPage(
        //           email: emailController.text.trim(),
        //           role: widget.role,
        //           name: nameController.text.trim(),
        //           password: passwordController.text.trim(),
        //         ),
        //       ),
        //     );
        //   }
        // }
        if (response.user != null) {
          // Insert vào bảng users trước
          final insertedUser = await supabase
              .from('users')
              .insert({
                'auth_uid': response.user!.id,
                'u_email': emailController.text.trim(),
                'u_name': nameController.text.trim(),
                'u_role': widget.role.name,
                'u_password': passwordController.text.trim(),
              })
              .select('u_id')
              .single(); // ✅ lấy u_id vừa tạo

          final uId = insertedUser['u_id'] as int;

          // Insert vào bảng candidates hoặc employers tùy role
          if (widget.role == UserRole.candidate) {
            await supabase.from('candidates').insert({
              'c_full_name': nameController.text.trim(),
              'u_id': uId,
            });
          } else if (widget.role == UserRole.employer) {
            await supabase.from('employers').insert({'u_id': uId});
          }

          if (mounted) {
            isInRegisterFlow = true;
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => RegisterVerifyEmailPage(
                  email: emailController.text.trim(),
                  role: widget.role,
                  name: nameController.text.trim(),
                  password: passwordController.text.trim(),
                ),
              ),
            );
          }
        }
      } on AuthApiException catch (e) {
        if (!mounted) return;
        if (e.code == 'over_email_send_rate_limit') {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Quá nhiều lần thử, vui lòng thử lại sau.'),
            ),
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Đăng ký thất bại: ${e.message}')),
          );
        }
      } catch (e) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Có lỗi xảy ra: $e')));
      }
    }
  }

  Widget _buildHeader() {
    return Column(
      children: [
        Text(
          'STEP 2 OF 3',
          style: TextStyle(
            fontSize: 12,
            letterSpacing: 1.2,
            color: AppColors.textSecondary,
          ),
        ),
        const SizedBox(height: 16),
        Text(
          'Account Details (${widget.role.name})',
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.w700,
            color: AppColors.textPrimary,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'Set up your login credentials',
          style: TextStyle(color: AppColors.textSecondary),
        ),
      ],
    );
  }
}
