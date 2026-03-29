// import 'package:flutter/material.dart';
// import 'package:jobgo/core/configs/theme/app_colors.dart';

// class ForgotPasswordScreen extends StatefulWidget {
//   const ForgotPasswordScreen({super.key});

//   @override
//   State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
// }

// class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
//   final _formKey = GlobalKey<FormState>();
//   final TextEditingController _emailController = TextEditingController();

//   @override
//   void dispose() {
//     _emailController.dispose();
//     super.dispose();
//   }

//   void _onSubmit() {
//     if (_formKey.currentState!.validate()) {
//       // TODO: Xử lí reset password
//       ScaffoldMessenger.of(context).showSnackBar(
//         SnackBar(
//           content: Text('Sending reset link to ${_emailController.text}'),
//           backgroundColor: AppColors.success,
//         ),
//       );
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: AppColors.white,
//       appBar: AppBar(
//         backgroundColor: AppColors.white,
//         elevation: 0,
//         leading: IconButton(
//           icon: const Icon(
//             Icons.arrow_back_ios_new,
//             color: AppColors.textPrimary,
//           ),
//           onPressed: () => Navigator.maybePop(context),
//         ),
//       ),
//       body: SafeArea(
//         child: LayoutBuilder(
//           builder: (context, constraints) {
//             return SingleChildScrollView(
//               child: ConstrainedBox(
//                 constraints: BoxConstraints(minHeight: constraints.maxHeight),
//                 child: Padding(
//                   padding: const EdgeInsets.symmetric(horizontal: 24.0),
//                   child: Form(
//                     key: _formKey,
//                     child: Column(
//                       mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                       children: [
//                         Column(
//                           crossAxisAlignment: CrossAxisAlignment.center,
//                           children: [
//                             const SizedBox(height: 20),
//                             _buildLogoIcon(),

//                             const SizedBox(height: 40),

//                             const Text(
//                               "Forgot Password?",
//                               style: TextStyle(
//                                 fontSize: 28,
//                                 fontWeight: FontWeight.bold,
//                                 color: AppColors.textPrimary,
//                               ),
//                             ),

//                             const SizedBox(height: 12),

//                             const Text(
//                               "Enter the email address associated with your account and we'll send an email with instructions to reset your password.",
//                               textAlign: TextAlign.center,
//                               style: TextStyle(
//                                 fontSize: 14,
//                                 color: AppColors.textSecondary,
//                                 height: 1.5,
//                               ),
//                             ),

//                             const SizedBox(height: 40),

//                             const Align(
//                               alignment: Alignment.centerLeft,
//                               child: Text(
//                                 "Email Address",
//                                 style: TextStyle(
//                                   fontWeight: FontWeight.bold,
//                                   color: AppColors.textPrimary,
//                                 ),
//                               ),
//                             ),
//                             const SizedBox(height: 8),

//                             _buildEmailTextField(),

//                             const SizedBox(height: 24),

//                             SizedBox(
//                               width: double.infinity,
//                               height: 56,
//                               child: ElevatedButton(
//                                 onPressed: _onSubmit,
//                                 style: ElevatedButton.styleFrom(
//                                   backgroundColor: AppColors.primary,
//                                   shape: RoundedRectangleBorder(
//                                     borderRadius: BorderRadius.circular(16),
//                                   ),
//                                   elevation: 4,
//                                   shadowColor: AppColors.primary.withValues(
//                                     alpha: 0.4,
//                                   ),
//                                 ),
//                                 child: const Text(
//                                   "Send Reset Link",
//                                   style: TextStyle(
//                                     fontSize: 16,
//                                     fontWeight: FontWeight.bold,
//                                     color: AppColors.white,
//                                   ),
//                                 ),
//                               ),
//                             ),
//                           ],
//                         ),

//                         Padding(
//                           padding: const EdgeInsets.symmetric(vertical: 24.0),
//                           child: Row(
//                             mainAxisAlignment: MainAxisAlignment.center,
//                             children: [
//                               const Text(
//                                 "Remembered your password? ",
//                                 style: TextStyle(
//                                   color: AppColors.textSecondary,
//                                 ),
//                               ),
//                               TextButton(
//                                 onPressed: () => Navigator.maybePop(context),
//                                 style: TextButton.styleFrom(
//                                   padding: EdgeInsets.zero,
//                                   minimumSize: Size.zero,
//                                   tapTargetSize:
//                                       MaterialTapTargetSize.shrinkWrap,
//                                   overlayColor: AppColors.primary.withValues(
//                                     alpha: 0.1,
//                                   ),
//                                 ),
//                                 child: const Text(
//                                   "Back to Login",
//                                   style: TextStyle(
//                                     color: AppColors.primary,
//                                     fontWeight: FontWeight.bold,
//                                   ),
//                                 ),
//                               ),
//                             ],
//                           ),
//                         ),
//                       ],
//                     ),
//                   ),
//                 ),
//               ),
//             );
//           },
//         ),
//       ),
//     );
//   }

//   Widget _buildLogoIcon() {
//     return Container(
//       width: 120,
//       height: 120,
//       decoration: BoxDecoration(
//         color: AppColors.primary.withValues(alpha: 0.1),
//         shape: BoxShape.circle,
//       ),
//       child: Center(
//         child: Container(
//           width: 60,
//           height: 60,
//           decoration: BoxDecoration(
//             color: AppColors.primary,
//             borderRadius: BorderRadius.circular(16),
//             boxShadow: [
//               BoxShadow(
//                 color: AppColors.primary.withValues(alpha: 0.3),
//                 blurRadius: 10,
//                 offset: const Offset(0, 5),
//               ),
//             ],
//           ),
//           child: const Icon(
//             Icons.lock_reset_outlined,
//             color: AppColors.white,
//             size: 32,
//           ),
//         ),
//       ),
//     );
//   }

//   Widget _buildEmailTextField() {
//     return Container(
//       decoration: BoxDecoration(
//         color: AppColors.white,
//         borderRadius: BorderRadius.circular(12),
//         border: Border.all(color: AppColors.border),
//         boxShadow: [
//           BoxShadow(
//             color: AppColors.textHint.withValues(alpha: 0.1),
//             blurRadius: 6,
//             offset: const Offset(0, 2),
//           ),
//         ],
//       ),
//       child: TextFormField(
//         controller: _emailController,
//         keyboardType: TextInputType.emailAddress,
//         style: const TextStyle(color: AppColors.textPrimary),
//         decoration: const InputDecoration(
//           border: InputBorder.none,
//           errorBorder: InputBorder.none,
//           focusedErrorBorder: InputBorder.none,
//           prefixIcon: Icon(Icons.email_outlined, color: AppColors.textHint),
//           hintText: "e.g., alex@example.com",
//           hintStyle: TextStyle(color: AppColors.textHint),
//           contentPadding: EdgeInsets.symmetric(vertical: 16),
//         ),
//         validator: (value) {
//           if (value == null || value.isEmpty) {
//             return 'Please enter your email';
//           }
//           final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
//           if (!emailRegex.hasMatch(value)) {
//             return 'Invalid email address';
//           }
//           return null;
//         },
//       ),
//     );
//   }
// }
import 'package:flutter/material.dart';
import 'package:jobgo/core/configs/theme/app_colors.dart';
import 'package:jobgo/main.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'forgotpassword_otp_page.dart';

class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _emailController = TextEditingController();
  bool _isLoading = false;

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  void _onSubmit() async {
    if (_formKey.currentState!.validate()) {
      setState(() => _isLoading = true);

      try {
        isInForgotPasswordFlow = true;
        //  Gửi OTP về email
        await Supabase.instance.client.auth.signInWithOtp(
          email: _emailController.text.trim(),
        );

        if (mounted) {
          // Navigate sang trang nhập OTP
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => ForgotPasswordOtpPage(
                email: _emailController.text.trim(),
              ),
            ),
          );
        }
      } on AuthApiException catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Lỗi: ${e.message}')),
        );
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Có lỗi xảy ra: $e')),
        );
      } finally {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.white,
      appBar: AppBar(
        backgroundColor: AppColors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: AppColors.textPrimary),
          onPressed: () => Navigator.maybePop(context),
        ),
      ),
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            return SingleChildScrollView(
              child: ConstrainedBox(
                constraints: BoxConstraints(minHeight: constraints.maxHeight),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24.0),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            const SizedBox(height: 20),
                            _buildLogoIcon(),
                            const SizedBox(height: 40),
                            const Text(
                              "Forgot Password?",
                              style: TextStyle(
                                fontSize: 28,
                                fontWeight: FontWeight.bold,
                                color: AppColors.textPrimary,
                              ),
                            ),
                            const SizedBox(height: 12),
                            const Text(
                              "Enter the email address associated with your account and we'll send a 6-digit OTP to reset your password.",
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontSize: 14,
                                color: AppColors.textSecondary,
                                height: 1.5,
                              ),
                            ),
                            const SizedBox(height: 40),
                            const Align(
                              alignment: Alignment.centerLeft,
                              child: Text(
                                "Email Address",
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: AppColors.textPrimary,
                                ),
                              ),
                            ),
                            const SizedBox(height: 8),
                            _buildEmailTextField(),
                            const SizedBox(height: 24),
                            SizedBox(
                              width: double.infinity,
                              height: 56,
                              child: ElevatedButton(
                                onPressed: _isLoading ? null : _onSubmit,
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: AppColors.primary,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(16),
                                  ),
                                ),
                                child: _isLoading
                                    ? const CircularProgressIndicator(color: Colors.white)
                                    : const Text(
                                        "Send OTP",
                                        style: TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.bold,
                                          color: AppColors.white,
                                        ),
                                      ),
                              ),
                            ),
                          ],
                        ),
                        Padding(
                          padding: const EdgeInsets.symmetric(vertical: 24.0),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Text(
                                "Remembered your password? ",
                                style: TextStyle(color: AppColors.textSecondary),
                              ),
                              TextButton(
                                onPressed: () => Navigator.maybePop(context),
                                child: const Text(
                                  "Back to Login",
                                  style: TextStyle(
                                    color: AppColors.primary,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildLogoIcon() {
    return Container(
      width: 120,
      height: 120,
      decoration: BoxDecoration(
        color: AppColors.primary.withValues(alpha: 0.1),
        shape: BoxShape.circle,
      ),
      child: Center(
        child: Container(
          width: 60,
          height: 60,
          decoration: BoxDecoration(
            color: AppColors.primary,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: AppColors.primary.withValues(alpha: 0.3),
                blurRadius: 10,
                offset: const Offset(0, 5),
              ),
            ],
          ),
          child: const Icon(Icons.lock_reset_outlined, color: AppColors.white, size: 32),
        ),
      ),
    );
  }

  Widget _buildEmailTextField() {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border),
        boxShadow: [
          BoxShadow(
            color: AppColors.textHint.withValues(alpha: 0.1),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: TextFormField(
        controller: _emailController,
        keyboardType: TextInputType.emailAddress,
        style: const TextStyle(color: AppColors.textPrimary),
        decoration: const InputDecoration(
          border: InputBorder.none,
          prefixIcon: Icon(Icons.email_outlined, color: AppColors.textHint),
          hintText: "e.g., alex@example.com",
          hintStyle: TextStyle(color: AppColors.textHint),
          contentPadding: EdgeInsets.symmetric(vertical: 16),
        ),
        validator: (value) {
          if (value == null || value.isEmpty) return 'Please enter your email';
          final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
          if (!emailRegex.hasMatch(value)) return 'Invalid email address';
          return null;
        },
      ),
    );
  }
}
