import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class FormTextField extends StatelessWidget {
  final String label;
  final String? hintText;
  final TextEditingController? controller;
  final TextInputType keyboardType;
  final int maxLines;
  final int minLines;
  final String? Function(String?)? validator;
  final void Function(String)? onChanged;
  final Widget? suffixIcon;
  final String? suffixText;
  final int? maxLength;
  final bool obscureText;

  const FormTextField({
    super.key,
    required this.label,
    this.hintText,
    this.controller,
    this.keyboardType = TextInputType.text,
    this.maxLines = 1,
    this.minLines = 1,
    this.validator,
    this.onChanged,
    this.suffixIcon,
    this.suffixText,
    this.maxLength,
    this.obscureText = false,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: GoogleFonts.poppins(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: Colors.black87,
          ),
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: controller,
          keyboardType: keyboardType,
          maxLines: maxLines,
          minLines: minLines,
          maxLength: maxLength,
          obscureText: obscureText,
          onChanged: onChanged,
          validator: validator,
          decoration: InputDecoration(
            hintText: hintText,
            suffixIcon: suffixIcon,
            suffixText: suffixText,
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 12,
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: const BorderSide(color: Colors.grey),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: const BorderSide(color: Colors.blue, width: 2),
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: const BorderSide(color: Colors.red),
            ),
            filled: true,
            fillColor: Colors.grey.shade50,
          ),
          style: GoogleFonts.poppins(fontSize: 14),
        ),
      ],
    );
  }
}
