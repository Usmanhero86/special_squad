import 'package:flutter/material.dart';

class UnderlineTextField extends StatelessWidget {
  final String label;
  final TextEditingController controller;
  final bool requiredField;
  final bool enabled;
  final TextInputType keyboardType;
  final int? maxLines;
  final Function(String)? onChanged;
  final String? Function(String?)? validator;
  final bool obscureText;
  final Widget? suffixIcon;
  final double? labelWidth;
  final double? spacing;

  const UnderlineTextField({
    super.key,
    required this.label,
    required this.controller,
    this.requiredField = false,
    this.enabled = true,
    this.keyboardType = TextInputType.text,
    this.maxLines = 1,
    this.onChanged,
    this.validator,
    this.obscureText = false,
    this.suffixIcon,
    this.labelWidth,
    this.spacing,
  });

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isTablet = screenWidth > 600;
    final isDesktop = screenWidth > 1200;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        // Label text
        SizedBox(
          width: labelWidth ?? (isTablet ? 120 : 80),
          child: Text(
            label,
            style: TextStyle(
              fontWeight: FontWeight.w500,
              color: Colors.black,
              fontSize: isDesktop ? 16 : (isTablet ? 15 : 14),
            ),
          ),
        ),
        SizedBox(width: spacing ?? (isTablet ? 10 : 8)),
        // Text field
        Expanded(
          child: TextFormField(
            controller: controller,
            style: TextStyle(
              fontSize: isDesktop ? 19 : (isTablet ? 16 : 15),
            ),
            keyboardType: keyboardType,
            maxLines: maxLines,
            enabled: enabled,
            obscureText: obscureText,
            onChanged: onChanged,
            decoration: InputDecoration(
              isDense: true,
              suffixIcon: suffixIcon,
              contentPadding: EdgeInsets.only(
                left: 8,
                bottom: isTablet ? 12 : 8,
                top: isTablet ? 12 : 8,
              ),
              border: const UnderlineInputBorder(
                borderSide: BorderSide(color: Colors.black, width: 0.5),
              ),
              enabledBorder: const UnderlineInputBorder(
                borderSide: BorderSide(color: Colors.black, width: 0.5),
              ),
              focusedBorder: const UnderlineInputBorder(
                borderSide: BorderSide(color: Colors.blue, width: 0.5),
              ),
              errorBorder: const UnderlineInputBorder(
                borderSide: BorderSide(color: Colors.red, width: 0.5),
              ),
              focusedErrorBorder: const UnderlineInputBorder(
                borderSide: BorderSide(color: Colors.red, width: 0.5),
              ),
            ),
            validator: validator ?? (requiredField
                ? (value) {
              if (value == null || value.trim().isEmpty) {
                return 'This field is required';
              }
              return null;
            }
                : null),
          ),
        ),
      ],
    );
  }
}