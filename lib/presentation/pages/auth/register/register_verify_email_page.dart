
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../../core/configs/theme/app_colors.dart';
import '../../../../core/enums/user_role.dart';
import '../../../../core/localization/app_localizations.dart';
import '../../../../core/utils/app_logger.dart';
import 'package:jobgo/main.dart'; //  để dùng isInRegisterFlow

class RegisterVerifyEmailPage extends StatefulWidget {
  final String email;
  final UserRole role;
  final String name;
  final String password;

  const RegisterVerifyEmailPage({
    super.key,
    required this.email,
    required this.role,
    required this.name,
    required this.password,
  });

  @override
  State<RegisterVerifyEmailPage> createState() => _RegisterVerifyEmailPageState();
}

class _RegisterVerifyEmailPageState extends State<RegisterVerifyEmailPage> {
  bool _isChecking = false;

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context);
    return Scaffold(
      backgroundColor: const Color(0xFFF9FAFB),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // HEADER
              Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.arrow_back_ios_new),
                    onPressed: () {
                      isInRegisterFlow = false;
                      Navigator.pop(context);
                    },
                  ),
                  const Spacer(),
                  Text(loc.stepOfThreeMsg.replaceAll('STEP 3 OF 3', loc.stepOfThreeMsg),
                    style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, letterSpacing: 1)),
                  const Spacer(flex: 2),
                ],
              ),

              const SizedBox(height: 40),

              // ICON
              Container(
                width: 120,
                height: 120,
                decoration: BoxDecoration(shape: BoxShape.circle, color: AppColors.primary),
                child: Center(
                  child: Container(
                    width: 64,
                    height: 64,
                    decoration: BoxDecoration(color: AppColors.primary, borderRadius: BorderRadius.circular(18)),
                    child: const Icon(Icons.verified_user, color: Colors.white, size: 32),
                  ),
                ),
              ),

              const SizedBox(height: 32),

              // TITLE - keep as is, not in localization yet
              Text(loc.otpVerification,
                style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),

              const SizedBox(height: 12),

              // SUBTITLE
              Text(
                "${loc.emailVerificationMessage}\n${widget.email}\n\n${loc.clickLinkMessage}",
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 14, color: AppColors.textSecondary, height: 1.6),
              ),

              const SizedBox(height: 32),

              // VERIFY BUTTON
              SizedBox(
                width: double.infinity,
                height: 52,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
                  ),
                  onPressed: _isChecking ? null : _checkVerified,
                  child: _isChecking
                      ? const CircularProgressIndicator(color: Colors.white)
                      : Text(loc.confirmedEmail,
                          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
                ),
              ),

              const Spacer(),

              // RESEND
              Column(
                children: [
                  Text(loc.didNotReceiveEmail,
                    style: const TextStyle(color: AppColors.textSecondary)),
                  const SizedBox(height: 6),
                  GestureDetector(
                    onTap: _resendEmail,
                    child: Text(loc.resendEmail,
                      style: const TextStyle(color: AppColors.primary, fontWeight: FontWeight.w600)),
                  ),
                  const SizedBox(height: 12),
                  Text("${loc.requestNewCode} 00:45",
                    style: const TextStyle(fontSize: 12, color: AppColors.textSecondary)),
                ],
              ),

              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _checkVerified() async {
    setState(() => _isChecking = true);
    try {
      final supabase = Supabase.instance.client;

      try {
        await supabase.auth.refreshSession();
      } catch (e, st) {
        AppLogger.warning('Refresh failed', error: e, stackTrace: st);
      }

      var currentUser = supabase.auth.currentUser;

      // Nếu chưa có session thì thử signIn
      if (currentUser == null) {
        final authResponse = await supabase.auth.signInWithPassword(
          email: widget.email,
          password: widget.password,
        );
        currentUser = authResponse.user;
      }

      if (currentUser?.emailConfirmedAt != null) {
        isInRegisterFlow = false;
        Navigator.pushNamedAndRemoveUntil(
          context,
          '/main',
          (route) => false,
          arguments: widget.role,
        );
      } else {
        final loc = AppLocalizations.of(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('${loc.error}: ${loc.verificationFailed}')),
        );
      }
    } catch (e) {
      final loc = AppLocalizations.of(context);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('${loc.error}: $e')),
      );
    } finally {
      setState(() => _isChecking = false);
    }
  }

  Future<void> _resendEmail() async {
    try {
      await Supabase.instance.client.auth.resend(
        type: OtpType.signup,
        email: widget.email,
      );
      final loc = AppLocalizations.of(context);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('${loc.success}: Email sent')),
      );
    } catch (e) {
      final loc = AppLocalizations.of(context);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('${loc.error}: $e')),
      );
    }
  }
}