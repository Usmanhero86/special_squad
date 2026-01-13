import 'package:flutter/material.dart';

import '../widgets/underline_text_field.dart';

class NextOfKinInformation extends StatelessWidget {
  final TextEditingController nextOfKinFullnameController;
  final TextEditingController nextOfKinAddressController;
  final TextEditingController nextOfKinPhoneController;

  const NextOfKinInformation({
    super.key,
    required this.nextOfKinFullnameController,
    required this.nextOfKinAddressController,
    required this.nextOfKinPhoneController,
  });

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isTablet = screenWidth > 600;
    final spacing = isTablet ? 20.0 : 15.0;

    return Column(
      children: [
        UnderlineTextField(
          label: 'full Name:',
          controller: nextOfKinFullnameController,
          requiredField: true,
        ),
        SizedBox(height: spacing),

        UnderlineTextField(
          label: 'Address:',
          controller: nextOfKinAddressController,
          requiredField: true,
        ),
        SizedBox(height: spacing),

        UnderlineTextField(
          label: 'Phone:',
          controller: nextOfKinPhoneController,
          requiredField: true,
        ),
      ],
    );
  }
}
