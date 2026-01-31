import 'package:flutter/material.dart';

class UnderlineTextField extends StatelessWidget {
  final String label;
  final TextEditingController controller;
  final bool requiredField;
  final bool enabled;
  final TextInputType keyboardType;
  final int? maxLines;
  final Function(String)? onChanged;
  final bool obscureText;
  final Widget? suffixIcon;
  final double? labelWidth;
  final double? spacing;
  // final FocusNode? focusNode;

  const UnderlineTextField({
    super.key,
    required this.label,
    required this.controller,
    this.requiredField = false,
    this.enabled = true,
    this.keyboardType = TextInputType.text,
    this.maxLines = 1,
    this.onChanged,
    this.obscureText = false,
    this.suffixIcon,
    this.labelWidth,
    this.spacing,
    // this.focusNode,
  });

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isTablet = screenWidth > 600;
    final isDesktop = screenWidth > 1200;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(
              label,
              style: TextStyle(
                fontWeight: FontWeight.w500,
                color: Colors.black,
                fontSize: isDesktop ? 16 : (isTablet ? 15 : 14),
              ),
            ),
            if (requiredField)
              const Text(
                ' *',
                style: TextStyle(
                  color: Colors.red,
                  fontWeight: FontWeight.bold,
                ),
              ),
          ],
        ),
        SizedBox(height: 4),
        TextField(
          controller: controller,
          // focusNode: focusNode,
          style: TextStyle(
    color: Colors.black,
            fontSize: isDesktop ? 19 : (isTablet ? 16 : 15),
          ),
          keyboardType: keyboardType,
          maxLines: maxLines,
          enabled: enabled,
          obscureText: obscureText,
          onChanged: onChanged,
          decoration: InputDecoration(
            fillColor: Colors.black,
            focusColor: Colors.black,
            hoverColor: Colors.black,
            isDense: true,
            suffixIcon: suffixIcon,
            contentPadding: EdgeInsets.only(
              left: 8,
              bottom: isTablet ? 12 : 8,
              top: isTablet ? 12 : 8,
            ),
            border: const OutlineInputBorder(
              borderSide: BorderSide(color: Colors.black, width: 0.5),
            ),
            enabledBorder: const OutlineInputBorder(
              borderSide: BorderSide(color: Colors.black, width: 0.5),
            ),
            focusedBorder: const OutlineInputBorder(
              borderSide: BorderSide(color: Colors.blue, width: 0.5),
            ),
          ),
        ),
      ],
    );
  }
}