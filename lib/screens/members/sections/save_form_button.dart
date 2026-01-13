import 'package:flutter/material.dart';

class SaveFormButton extends StatefulWidget {
  final VoidCallback onPressed;

  const SaveFormButton({
    super.key,
    required this.onPressed,
  });

  @override
  State<SaveFormButton> createState() => _SaveFormButtonState();
}

class _SaveFormButtonState extends State<SaveFormButton> {
  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isTablet = screenWidth > 600;
    final isDesktop = screenWidth > 1200;

    return SizedBox(
      width: double.infinity,
      height: isTablet ? 60 : 50,
      child: ElevatedButton(
        onPressed: widget.onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.red,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        ),
        child: Text(
          'SAVE MEMBERSHIP FORM',
          style: TextStyle(
            fontSize: isDesktop ? 18 : (isTablet ? 17 : 16),
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }

}
