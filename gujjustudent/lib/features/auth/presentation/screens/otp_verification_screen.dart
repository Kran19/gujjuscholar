import 'package:flutter/material.dart';
import 'package:edustream/core/constants/app_colors.dart';
import 'package:edustream/core/constants/app_strings.dart';
import 'package:edustream/routes/app_routes.dart';
import 'package:edustream/core/widgets/custom_button.dart';
import 'package:edustream/core/widgets/custom_textfield.dart';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:edustream/features/auth/presentation/providers/auth_providers.dart';

class OtpVerificationScreen extends ConsumerStatefulWidget {
  final String email;
  final bool isSignup;
  final String purpose;
  const OtpVerificationScreen({
    super.key, 
    required this.email,
    this.isSignup = false,
    this.purpose = 'login',
  });

  @override
  ConsumerState<OtpVerificationScreen> createState() => _OtpVerificationScreenState();
}

class _OtpVerificationScreenState extends ConsumerState<OtpVerificationScreen> {
  final _otpController = TextEditingController();

  @override
  void dispose() {
    _otpController.dispose();
    super.dispose();
  }

  bool _isLoading = false;

  Future<void> _onVerifyPressed() async {
    final otp = _otpController.text.trim();
    if (otp.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Please enter the OTP')));
      return;
    }

    setState(() => _isLoading = true);
    try {
      final repo = ref.read(authRepositoryProvider);
      final response = await repo.verifyOtp(widget.email, otp, widget.purpose);

      if (!mounted) return;
      
      if (response['status'] == 'needs_signup') {
        // Navigate to Profile Setup to collect Name and Course
        Navigator.pushReplacementNamed(
          context,
          AppRoutes.profileSetup,
          arguments: widget.email,
        );
      } else {
        // Navigate to Entry on success
        Navigator.pushNamedAndRemoveUntil(
          context,
          AppRoutes.entry,
          (route) => false,
        );
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Failed to verify OTP: $e')));
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _onResendPressed() async {
    try {
      final repo = ref.read(authRepositoryProvider);
      final response = await repo.sendOtp(widget.email, widget.purpose);
      if (!mounted) return;
      final newOtp = response['otp'];
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('NEW TEST OTP: $newOtp'),
          duration: const Duration(seconds: 10),
          action: SnackBarAction(label: 'OK', onPressed: () {}),
        )
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Failed to resend OTP: $e')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: const IconThemeData(color: AppColors.black),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 24),
              Text(
                AppStrings.verifyOtp,
                style: Theme.of(context).textTheme.displayMedium,
              ),
              const SizedBox(height: 8),
              Text(
                "${AppStrings.otpSentTo} ${widget.email}",
                style: Theme.of(context).textTheme.bodyLarge,
              ),
              
              const SizedBox(height: 48),

              // OTP Field
              CustomTextField(
                controller: _otpController,
                hintText: AppStrings.otpHint,
                prefixIcon: Icons.lock_clock_outlined,
                keyboardType: TextInputType.number,
              ),
              
              const SizedBox(height: 32),

              // Verify Button
              _isLoading 
                ? const Center(child: CircularProgressIndicator())
                : CustomButton(
                    text: AppStrings.verify,
                    onPressed: _onVerifyPressed,
                  ),
              
              const SizedBox(height: 24),

              // Resend OTP Link
              Center(
                child: TextButton(
                  onPressed: _onResendPressed,
                  child: const Text(
                    AppStrings.resendOtp,
                    style: TextStyle(
                      color: AppColors.primary,
                      fontWeight: FontWeight.bold,
                    ),
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
