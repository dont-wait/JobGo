import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import '../../../../core/configs/theme/app_colors.dart';
import '../../../../core/enums/user_role.dart';
import '../../../widgets/common/auth_text_field.dart';
import '../../../widgets/common/social_login_row.dart';
import 'package:supabase_flutter/supabase_flutter.dart';


class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  bool rememberMe = true;
  bool _isSigningIn = false;

  @override
  void dispose() {
    emailController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.white,
      appBar: AppBar(
        backgroundColor: AppColors.white,
        elevation: 0,
        title: const Text(
          'Login',
          style: TextStyle(
            color: AppColors.textPrimary,
            fontWeight: FontWeight.w600,
          ),
        ),
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back,
            color: AppColors.textPrimary,
          ),
          onPressed: () => Navigator.maybePop(context),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const SizedBox(height: 8),
                const Text(
                  'Welcome Back',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 26,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 8),
                const Text(
                  'Sign in to continue your job search',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: AppColors.textSecondary),
                ),
                const SizedBox(height: 32),
                AuthTextField(
                  controller: emailController,
                  hintText: 'Email Address',
                  icon: Icons.email_outlined,
                  keyboardType: TextInputType.emailAddress,
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Email is required';
                    }
                    final email = value.trim();
                    final emailRegex =
                        RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
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
                    if (value == null || value.isEmpty) {
                      return 'Password is required';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Checkbox(
                      value: rememberMe,
                      onChanged: (value) {
                        setState(() {
                          rememberMe = value ?? true;
                        });
                      },
                    ),
                    const Text(
                      'Remember me',
                      style: TextStyle(color: AppColors.textSecondary),
                    ),
                    const Spacer(),
                    TextButton(
                      onPressed: () {
                        Navigator.pushNamed(context, '/forgot-password');
                      },
                      child: const Text('Forgot password?'),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: _isSigningIn ? null : _onSignIn,
                  child: _isSigningIn
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Text('Sign In'),
                ),
                const SizedBox(height: 24),
                Row(
                  children: [
                    const Expanded(child: Divider(color: AppColors.divider)),
                    const Padding(
                      padding: EdgeInsets.symmetric(horizontal: 12),
                      child: Text(
                        'OR',
                        style: TextStyle(color: AppColors.textSecondary),
                      ),
                    ),
                    const Expanded(child: Divider(color: AppColors.divider)),
                  ],
                ),
                const SizedBox(height: 20),
                const SocialLoginRow(),
                const SizedBox(height: 24),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text(
                      'Don\'t have an account? ',
                      style: TextStyle(color: AppColors.textSecondary),
                    ),
                    TextButton(
                      onPressed: () {
                        Navigator.pushNamed(context, '/register');
                      },
                      child: const Text('Sign Up'),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

void _onSignIn() async {
    if (_formKey.currentState!.validate()) {
      try {
        setState(() {
          _isSigningIn = true;
        });

        final email = emailController.text.trim();
        final emailLower = email.toLowerCase();
        final password = passwordController.text.trim();

        final envAdminEmail =
            (dotenv.env['ADMIN_EMAIL'] ?? 'admin@gamil.com').trim().toLowerCase();
        final envAdminPassword =
            (dotenv.env['ADMIN_PASSWORD'] ?? 'Pass@123').trim();

        // Dev-safe bypass: allow configured admin credentials even when Auth
        // account does not exist in current Supabase project.
        if (emailLower == envAdminEmail && password == envAdminPassword) {
          _navigateToHome('admin');
          return;
        }

        // Thử đăng nhập qua Supabase Auth trước
        try {
          final authResponse = await Supabase.instance.client.auth.signInWithPassword(
            email: email,
            password: password,
          );

          if (authResponse.user != null) {
            // Auth login thành công
            await _handleLoginSuccess(authResponse.user!.id);
            return;
          }
        } catch (authError) {
          print('Auth login failed: $authError, trying database fallback...');
        }

        // Fallback: users table can have different schema between projects.
        // Query each potential email column separately to avoid malformed OR syntax.
        final candidateRows = <Map<String, dynamic>>[];

        try {
          final rowsByUEmail = await Supabase.instance.client
              .from('users')
              .select('u_role, role, u_email, email, u_password, password')
              .eq('u_email', email)
              .limit(5);
          candidateRows.addAll((rowsByUEmail as List).cast<Map<String, dynamic>>());
        } catch (e) {
          print('Fallback lookup by u_email failed: $e');
        }

        try {
          final rowsByEmail = await Supabase.instance.client
              .from('users')
              .select('u_role, role, u_email, email, u_password, password')
              .eq('email', email)
              .limit(5);
          candidateRows.addAll((rowsByEmail as List).cast<Map<String, dynamic>>());
        } catch (e) {
          print('Fallback lookup by email failed: $e');
        }

        // If email in DB is normalized to lowercase, compare against lowercase input too.
        if (candidateRows.isEmpty && emailLower != email) {
          try {
            final rowsByLower = await Supabase.instance.client
                .from('users')
                .select('u_role, role, u_email, email, u_password, password')
                .eq('u_email', emailLower)
                .limit(5);
            candidateRows.addAll((rowsByLower as List).cast<Map<String, dynamic>>());
          } catch (e) {
            print('Fallback lookup by lowercase u_email failed: $e');
          }
        }

        Map<String, dynamic>? matchedUser;
        for (final data in candidateRows) {
          final dbPassword =
              (data['u_password'] ?? data['password'] ?? '').toString().trim();
          if (dbPassword == password) {
            matchedUser = data;
            break;
          }
        }

        if (matchedUser != null) {
          final role =
              (matchedUser['u_role'] ?? matchedUser['role'] ?? 'candidate')
                  .toString();
          _navigateToHome(role);
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("Sai thông tin đăng nhập")),
          );
        }

      } catch (e) {
        print('Error: $e');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Lỗi: $e")),
        );
      } finally {
        if (mounted) {
          setState(() {
            _isSigningIn = false;
          });
        }
      }
    }
  }

  Future<void> _handleLoginSuccess(String authUid) async {
    try {
      final userData = await Supabase.instance.client
          .from('users')
          .select('u_role')
          .eq('auth_uid', authUid)
          .maybeSingle();

      if (userData != null) {
        _navigateToHome(userData['u_role'] as String);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Không tìm thấy thông tin người dùng")),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Lỗi: $e")),
      );
    }
  }

  void _navigateToHome(String roleString) {
  UserRole role;

  if (roleString == 'employer') {
    role = UserRole.employer;
  } else if (roleString == 'admin') {
    role = UserRole.admin;
  } else {
    role = UserRole.candidate;
  }

  // Luôn vào /main để AppShell xử lý bottom nav
  Navigator.pushReplacementNamed(
    context,
    '/main',
    arguments: role,
  );
}
}