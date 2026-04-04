import 'package:flutter/material.dart';
import '../../../../core/configs/theme/app_colors.dart';
import '../../../../core/enums/user_role.dart';
import '../../../../core/localization/app_localizations.dart';
import '../../../widgets/common/auth_text_field.dart';
import '../../../widgets/common/social_login_row.dart';
import '../../../widgets/common/language_selector_button.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../../data/repositories/auth_repository.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final _authRepository = AuthRepository();
  bool rememberMe = true;
  bool _isLoading = false;

  @override
  void dispose() {
    emailController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context);
    
    return Scaffold(
      backgroundColor: AppColors.white,
      appBar: AppBar(
        backgroundColor: AppColors.white,
        elevation: 0,
        title: Text(
          loc.login,
          style: const TextStyle(
            color: AppColors.textPrimary,
            fontWeight: FontWeight.w600,
          ),
        ),
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.textPrimary),
          onPressed: () => Navigator.maybePop(context),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16),
            child: LanguageSelectorButton(isCompact: true),
          ),
        ],
      ),
      body: SafeArea(
        child: Stack(
          children: [
            SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const SizedBox(height: 8),
                    Text(
                      loc.welcomeBack,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        fontSize: 26,
                        fontWeight: FontWeight.w700,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      loc.signInToContinue,
                      textAlign: TextAlign.center,
                      style: const TextStyle(color: AppColors.textSecondary),
                    ),
                    const SizedBox(height: 32),
                    AuthTextField(
                      controller: emailController,
                      hintText: loc.emailAddressHint,
                      icon: Icons.email_outlined,
                      keyboardType: TextInputType.emailAddress,
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return loc.emailRequired;
                        }
                        final email = value.trim();
                        final emailRegex = RegExp(
                          r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$',
                        );
                        if (!emailRegex.hasMatch(email)) {
                          return loc.invalidEmailFormat;
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                    AuthTextField(
                      controller: passwordController,
                      hintText: loc.passwordHint,
                      icon: Icons.lock_outline,
                      obscureText: true,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return loc.passwordRequired;
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
                        Text(
                          loc.rememberMe,
                          style: const TextStyle(color: AppColors.textSecondary),
                        ),
                        const Spacer(),
                        TextButton(
                          onPressed: () {
                            Navigator.pushNamed(context, '/forgot-password');
                          },
                          child: Text(loc.forgotPassword),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: _onSignIn,
                      child: Text(loc.signIn),
                    ),
                    const SizedBox(height: 24),
                    Row(
                      children: [
                        const Expanded(
                          child: Divider(color: AppColors.divider),
                        ),
                        const Padding(
                          padding: EdgeInsets.symmetric(horizontal: 12),
                          child: Text(
                            'OR',
                            style: TextStyle(color: AppColors.textSecondary),
                          ),
                        ),
                        const Expanded(
                          child: Divider(color: AppColors.divider),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                    SocialLoginRow(
                      onGoogleTap: _onGoogleSignIn,
                      onFacebookTap: _onFacebookSignIn,
                    ),
                    const SizedBox(height: 24),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          '${loc.dontHaveAccount} ',
                          style: const TextStyle(color: AppColors.textSecondary),
                        ),
                        TextButton(
                          onPressed: () {
                            Navigator.pushNamed(context, '/register');
                          },
                          child: Text(loc.signUp),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            if (_isLoading) const Center(child: CircularProgressIndicator()),
          ],
        ),
      ),
    );
  }

  void _onSignIn() async {
    if (_formKey.currentState!.validate()) {
      try {
        final loc = AppLocalizations.of(context);
        final email = emailController.text.trim();
        final password = passwordController.text;

        // Thử đăng nhập qua Supabase Auth trước
        try {
          final authResponse = await Supabase.instance.client.auth
              .signInWithPassword(email: email, password: password);

          if (authResponse.user != null) {
            // Auth login thành công
            await _handleLoginSuccess(authResponse.user!.id);
            return;
          }
        } catch (authError) {
          print('Auth login failed: $authError, trying database fallback...');
        }

        // Fallback: Query bảng users với email + password
        final userData = await Supabase.instance.client
            .from('users')
            .select('u_role')
            .eq('u_email', email)
            .eq('u_password', password)
            .maybeSingle();

        if (userData != null) {
          _navigateToHome(userData['u_role'] as String);
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(loc.invalidCredentials)),
          );
        }
      } catch (e) {
        print('Error: $e');
        final loc = AppLocalizations.of(context);
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text("${loc.error}: $e")));
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
        final loc = AppLocalizations.of(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(loc.somethingWentWrong)),
        );
      }
    } catch (e) {
      final loc = AppLocalizations.of(context);
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("${loc.error}: $e")));
    }
  }

  void _onGoogleSignIn() async {
    setState(() => _isLoading = true);
    try {
      await _authRepository.signInWithGoogle();
      // Auth state listener in main.dart handles navigation
    } catch (e) {
      if (!mounted) return;
      final loc = AppLocalizations.of(context);
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("${loc.error}: $e")));
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _onFacebookSignIn() async {
    setState(() => _isLoading = true);
    try {
      await _authRepository.signInWithFacebook();
      // Auth state listener in main.dart handles navigation
    } catch (e) {
      if (!mounted) return;
      final loc = AppLocalizations.of(context);
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("${loc.error}: $e")));
    } finally {
      if (mounted) setState(() => _isLoading = false);
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
    Navigator.pushReplacementNamed(context, '/main', arguments: role);
  }
}
