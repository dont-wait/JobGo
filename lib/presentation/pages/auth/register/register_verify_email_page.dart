
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../../core/configs/theme/app_colors.dart';
import '../../../../core/enums/user_role.dart';
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
    return Scaffold(
      backgroundColor: const Color(0xFFF9FAFB),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // HEADER - giữ nguyên giao diện gốc
              Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.arrow_back_ios_new),
                    onPressed: () {
                      isInRegisterFlow = false; // tắt flag khi back
                      Navigator.pop(context);
                    },
                  ),
                  const Spacer(),
                  const Text("STEP 3 OF 3",
                    style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, letterSpacing: 1)),
                  const Spacer(flex: 2),
                ],
              ),

              const SizedBox(height: 40),

              // ICON - giữ nguyên giao diện gốc
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

              // TITLE
              const Text("OTP Verification",
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),

              const SizedBox(height: 12),

              // SUBTITLE
              Text(
                "We sent a confirmation link to\n${widget.email}\n\nClick the link in your email to activate your account.",
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 14, color: AppColors.textSecondary, height: 1.6),
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
                      : const Text("I've confirmed my email",
                          style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
                ),
              ),

              const Spacer(),

              // RESEND - giữ nguyên giao diện gốc
              Column(
                children: [
                  Text("Didn't receive the email?",
                    style: TextStyle(color: AppColors.textSecondary)),
                  const SizedBox(height: 6),
                  GestureDetector(
                    onTap: _resendEmail,
                    child: const Text("Resend email",
                      style: TextStyle(color: AppColors.primary, fontWeight: FontWeight.w600)),
                  ),
                  const SizedBox(height: 12),
                  Text("Request new code in 00:45",
                    style: TextStyle(fontSize: 12, color: AppColors.textSecondary)),
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
      } catch (e) {
        print('Refresh failed: $e');
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
        isInRegisterFlow = false; // tắt flag
        Navigator.pushNamedAndRemoveUntil(
          context,
          '/main',  // vào AppShell
          (route) => false,
          arguments: widget.role,
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Email chưa được xác nhận, vui lòng click link trong email')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Email chưa được xác nhận, vui lòng click link trong email')),
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
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Email xác nhận đã được gửi lại')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Gửi lại thất bại: $e')),
      );
    }
  }
}