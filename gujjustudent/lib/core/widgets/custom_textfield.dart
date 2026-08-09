import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../constants/app_colors.dart';

class CustomTextField extends StatelessWidget {
  final String hintText;
  final IconData? prefixIcon;
  final IconData? suffixIcon;
  final bool obscureText;
  final TextEditingController? controller;
  final String? Function(String?)? validator;
  final VoidCallback? onSuffixTap;
  final TextInputType? keyboardType;
  final bool readOnly;

  final List<TextInputFormatter>? inputFormatters;
  final bool? filled;
  final Color? fillColor;

  const CustomTextField({
    super.key,
    required this.hintText,
    this.prefixIcon,
    this.suffixIcon,
    this.obscureText = false,
    this.controller,
    this.validator,
    this.onSuffixTap,
    this.keyboardType,
    this.readOnly = false,
    this.inputFormatters,
    this.filled,
    this.fillColor,
  });

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      obscureText: obscureText,
      validator: validator,
      keyboardType: keyboardType,
      readOnly: readOnly,
      inputFormatters: inputFormatters,
      decoration: InputDecoration(
        hintText: hintText,
        filled: filled,
        fillColor: fillColor,
        prefixIcon: prefixIcon != null ? Icon(prefixIcon, color: AppColors.grey) : null,
        suffixIcon: suffixIcon != null
            ? IconButton(
                icon: Icon(suffixIcon, color: AppColors.grey),
                onPressed: onSuffixTap,
              )
            : null,
      ),
    );
  }
}
