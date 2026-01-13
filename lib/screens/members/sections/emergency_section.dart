import 'package:flutter/material.dart';

import '../widgets/underline_text_field.dart';

class EmergencyContactInformation extends StatelessWidget {
  final TextEditingController emergencyFullnameController;
  final TextEditingController emergencyAddressController;
  final TextEditingController emergencyPhoneController;

  const EmergencyContactInformation({
    super.key,
    required this.emergencyFullnameController,
    required this.emergencyAddressController,
    required this.emergencyPhoneController,
  });

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isTablet = screenWidth > 600;
    final spacing = isTablet ? 20.0 : 15.0;

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        UnderlineTextField(
          label: 'full Name:',
          controller: emergencyFullnameController,
          requiredField: true,
        ),
        SizedBox(height: spacing),

        UnderlineTextField(
          label: 'Address:',
          controller: emergencyAddressController,
          requiredField: true,
        ),
        SizedBox(height: spacing),

        UnderlineTextField(
          label: 'Phone:',
          controller: emergencyPhoneController,
          requiredField: true,
        ),
      ],
    );
  }
}
