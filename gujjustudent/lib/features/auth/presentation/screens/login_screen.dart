import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:edustream/core/constants/app_colors.dart';
import 'package:edustream/core/constants/app_strings.dart';
import 'package:edustream/routes/app_routes.dart';
import 'package:edustream/core/widgets/custom_button.dart';
import 'package:edustream/core/widgets/custom_textfield.dart';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:edustream/features/auth/presentation/providers/auth_providers.dart';

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  final _emailController = TextEditingController();

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  bool _isLoading = false;

  Future<void> _onLoginPressed() async {
    final email = _emailController.text.trim();
    if (email.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Please enter email')));
      return;
    }
    
    // Simple email validation
    if (!email.contains('@') || !email.contains('.')) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Please enter a valid email')));
      return;
    }

    setState(() => _isLoading = true);
    try {
      final repo = ref.read(authRepositoryProvider);
      final response = await repo.sendOtp(email, 'login');
      
      if (!mounted) return;
      
      // Since DLT isn't approved, show the OTP from API response in a Snackbar for now
      final otp = response['otp'];
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('TEST OTP: $otp'),
          duration: const Duration(seconds: 10),
          action: SnackBarAction(label: 'OK', onPressed: () {}),
        )
      );

      Navigator.pushNamed(
        context, 
        AppRoutes.otpVerification,
        arguments: {
          'email': email,
          'isSignup': false,
          'purpose': 'login',
        },
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Failed to send OTP: $e')));
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _onSignUpPressed() {
    Navigator.pushNamed(context, AppRoutes.signup);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 48),
              
              // Header
              const Icon(Icons.school_outlined, size: 48, color: AppColors.primary),
              const SizedBox(height: 24),
              Text(
                "Welcome Back!",
                style: Theme.of(context).textTheme.displayMedium,
              ),
              const SizedBox(height: 8),
              Text(
                "Login to continue your learning journey.",
                style: Theme.of(context).textTheme.bodyLarge,
              ),
              
              const SizedBox(height: 48),

              // Form
              CustomTextField(
                controller: _emailController,
                hintText: AppStrings.emailHint,
                prefixIcon: Icons.email_outlined,
                keyboardType: TextInputType.emailAddress,
              ),
              
              const SizedBox(height: 32),

              // Login Button
              _isLoading 
                ? const Center(child: CircularProgressIndicator())
                : CustomButton(
                    text: AppStrings.login,
                    onPressed: _onLoginPressed,
                  ),
              
              const SizedBox(height: 24),

              // Sign Up Link
              Center(
                child: RichText(
                  text: TextSpan(
                    text: "Don't have an account? ",
                    style: Theme.of(context).textTheme.bodyMedium,
                    children: [
                      TextSpan(
                        text: AppStrings.signup,
                        style: const TextStyle(
                          color: AppColors.primary,
                          fontWeight: FontWeight.bold,
                        ),
                        recognizer: TapGestureRecognizer()..onTap = _onSignUpPressed,
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
