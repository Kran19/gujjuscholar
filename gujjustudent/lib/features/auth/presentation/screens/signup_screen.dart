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

class SignupScreen extends ConsumerStatefulWidget {
  final String email;
  const SignupScreen({super.key, required this.email});

  @override
  ConsumerState<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends ConsumerState<SignupScreen> {
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();

  int? _selectedCourseId;
  List<dynamic> _courses = [];
  bool _isLoadingCourses = true;
  bool _isSubmitting = false;

  @override
  void initState() {
    super.initState();
    _emailController.text = widget.email;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _fetchCourses();
    });
  }

  Future<void> _fetchCourses() async {
    try {
      final repo = ref.read(authRepositoryProvider);
      final fetched = await repo.getPublicCourses();
      if (mounted) {
        setState(() {
          _courses = fetched;
          _isLoadingCourses = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoadingCourses = false);
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Failed to load courses: $e')));
      }
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    super.dispose();
  }

  Future<void> _onSignupPressed() async {
    final name = _nameController.text.trim();
    if (name.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Please enter your name')));
      return;
    }
    
    if (_selectedCourseId == null) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Please select a course')));
      return;
    }

    setState(() => _isSubmitting = true);
    try {
      final repo = ref.read(authRepositoryProvider);
      await repo.register({
        'name': name,
        'email': widget.email,
        'course_id': _selectedCourseId,
      });

      if (!mounted) return;
      Navigator.pushNamedAndRemoveUntil(context, AppRoutes.entry, (route) => false);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Profile setup failed: $e')));
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
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
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Text(
                "Complete Profile",
                style: Theme.of(context).textTheme.displayMedium,
              ),
              const SizedBox(height: 8),
              Text(
                "Enter your name and select your course to join us!",
                style: Theme.of(context).textTheme.bodyLarge,
              ),
              
              const SizedBox(height: 32),

              // Form
              CustomTextField(
                controller: _nameController,
                hintText: "Full Name",
                prefixIcon: Icons.person_outline,
              ),
              const SizedBox(height: 16),
              CustomTextField(
                controller: _emailController,
                hintText: AppStrings.emailHint,
                prefixIcon: Icons.email_outlined,
                readOnly: true,
                filled: true,
                fillColor: Colors.grey[200],
              ),
              const SizedBox(height: 16),

              // Course Selection Dropdown (Acting as Standard)
              _isLoadingCourses 
                ? const Center(child: CircularProgressIndicator())
                : DropdownButtonFormField<int>(
                    initialValue: _selectedCourseId,
                    hint: const Text('Select your Course'),
                    decoration: InputDecoration(
                      prefixIcon: const Icon(Icons.school_outlined, color: AppColors.primary),
                      filled: true,
                      fillColor: Colors.grey[100],
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(16),
                        borderSide: BorderSide.none,
                      ),
                    ),
                    items: _courses.map<DropdownMenuItem<int>>((course) {
                      return DropdownMenuItem<int>(
                        value: course['id'] as int,
                        child: Text(course['name'] as String),
                      );
                    }).toList(),
                    onChanged: (value) {
                      setState(() {
                        _selectedCourseId = value;
                      });
                    },
                  ),
              
              const SizedBox(height: 32),

              // Signup Button
              _isSubmitting
                ? const Center(child: CircularProgressIndicator())
                : CustomButton(
                    text: AppStrings.signup,
                    onPressed: _onSignupPressed,
                  ),
              
              const SizedBox(height: 24),

              // Login Link
              Center(
                child: RichText(
                  text: TextSpan(
                    text: "Logged in with a different number? ",
                    style: Theme.of(context).textTheme.bodyMedium,
                    children: [
                      TextSpan(
                        text: AppStrings.login,
                        style: const TextStyle(
                          color: AppColors.primary,
                          fontWeight: FontWeight.bold,
                        ),
                        recognizer: TapGestureRecognizer()..onTap = () {
                          Navigator.pushNamedAndRemoveUntil(context, AppRoutes.login, (r) => false);
                        },
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
