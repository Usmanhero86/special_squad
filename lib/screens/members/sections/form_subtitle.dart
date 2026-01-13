import 'package:flutter/material.dart';

class FormSubtitle extends StatelessWidget {
  final String text;

  const FormSubtitle({
    super.key,
    required this.text,
  });

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isTablet = screenWidth > 600;
    final isDesktop = screenWidth > 1200;

    return Padding(
      padding: const EdgeInsets.only(top: 5),
      child: Text(
        text,
        style: TextStyle(
          fontSize: isDesktop ? 12 : (isTablet ? 11 : 10),
          color: Colors.grey[600],
          fontStyle: FontStyle.italic,
        ),
      ),
    );
  }
}