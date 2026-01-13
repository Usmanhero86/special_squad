import 'package:flutter/material.dart';

class SignatureSection extends StatelessWidget {
  const SignatureSection({super.key});

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isTablet = screenWidth > 600;
    final isDesktop = screenWidth > 1200;

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: double.infinity,
          height: isTablet ? 80 : 60,
          decoration: BoxDecoration(
            border: Border(bottom: BorderSide(color: Colors.black, width: 1)),
          ),
          child: Align(
            alignment: Alignment.bottomCenter,
            child: Padding(
              padding: const EdgeInsets.only(bottom: 5),
              child: Text(
                'Signature of the Applicant',
                style: TextStyle(
                  fontSize: isDesktop ? 14 : (isTablet ? 13 : 12),
                  color: Colors.grey[600],
                ),
              ),
            ),
          ),
        ),
        SizedBox(height: isTablet ? 50 : 40),
        Align(
          alignment: Alignment.centerRight,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: isTablet ? 250 : 200,
                height: 1,
                color: Colors.black,
              ),
              const SizedBox(height: 5),
              Text(
                'General Commanding Officer',
                style: TextStyle(
                  fontSize: isDesktop ? 12 : (isTablet ? 11 : 10),
                  color: Colors.grey[600],
                ),
              ),
              Text(
                'Special Squad',
                style: TextStyle(
                  fontSize: isDesktop ? 12 : (isTablet ? 11 : 10),
                  color: Colors.grey[600],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}