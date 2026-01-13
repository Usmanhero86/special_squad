import 'package:flutter/material.dart';

import '../widgets/underline_text_field.dart';

class GuarantorInformation extends StatelessWidget {
  final TextEditingController guarantorFullNameController;
  final TextEditingController guarantorAddressController;
  final TextEditingController guarantorPhoneController;
  final TextEditingController guarantorRelationshipController;

  const GuarantorInformation({
    super.key,
    required this.guarantorFullNameController,
    required this.guarantorAddressController,
    required this.guarantorPhoneController,
    required this.guarantorRelationshipController,
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
          controller: guarantorFullNameController,
          requiredField: true,
        ),
        SizedBox(height: spacing),

        UnderlineTextField(
          label: 'Tribe:',
          controller: guarantorAddressController,
          requiredField: true,
        ),
        SizedBox(height: spacing),

        isTablet
            ? Row(
          children: [
            Expanded(
              child: UnderlineTextField(
                label: 'Phone No:',
                controller: guarantorPhoneController,
                requiredField: true,
              ),
            ),
            const SizedBox(width: 40),
            Expanded(
              child: UnderlineTextField(
                label: 'RelationShip:',
                controller: guarantorRelationshipController,
                requiredField: true,
              ),
            ),
          ],
        )
            : Column(
          children: [
            UnderlineTextField(
              label: 'Phone No:',
              controller: guarantorPhoneController,
              requiredField: true,
            ),
            const SizedBox(height: 15),
            UnderlineTextField(
              label: 'Relationship:',
              controller: guarantorRelationshipController,
              requiredField: true,
            ),
          ],
        ),
      ],
    );
  }
}
