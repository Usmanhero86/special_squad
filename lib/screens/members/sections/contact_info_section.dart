import 'package:flutter/material.dart';
import '../widgets/checkbox_row.dart';
import '../widgets/underline_text_field.dart';

class ContactInformationForm extends StatefulWidget {
  const ContactInformationForm({super.key});

  @override
  State<ContactInformationForm> createState() =>
      _ContactInformationFormState();
}

class _ContactInformationFormState extends State<ContactInformationForm> {
  // Controllers
  final TextEditingController rifleNoController = TextEditingController();
  final TextEditingController idNoController = TextEditingController();
  final TextEditingController fullNameController = TextEditingController();
  final TextEditingController tribeController = TextEditingController();
  final TextEditingController religionController = TextEditingController();
  final TextEditingController permanentAddressController =
  TextEditingController();
  final TextEditingController phoneNoController = TextEditingController();
  final TextEditingController maritalStatusController =
  TextEditingController();
  final TextEditingController positionController = TextEditingController();
  final TextEditingController ninNoController = TextEditingController();
  final TextEditingController bvnController = TextEditingController();
  final TextEditingController accountNoController = TextEditingController();
  final TextEditingController lgaController = TextEditingController();
  final TextEditingController stateController = TextEditingController();
  final TextEditingController unitAreaController = TextEditingController();

  // State variables
  DateTime dateOfBirth = DateTime.now();
  String accountType = 'Salary Acct';

  bool boyesBatchA = false;
  bool boyesBatchB = false;
  bool neighborhoodWatch = false;
  bool hybridForce = false;
  bool volunteer = false;

  @override
  void dispose() {
    rifleNoController.dispose();
    idNoController.dispose();
    fullNameController.dispose();
    tribeController.dispose();
    religionController.dispose();
    permanentAddressController.dispose();
    phoneNoController.dispose();
    maritalStatusController.dispose();
    positionController.dispose();
    ninNoController.dispose();
    bvnController.dispose();
    accountNoController.dispose();
    lgaController.dispose();
    stateController.dispose();
    unitAreaController.dispose();
    super.dispose();
  }

  Future<void> _selectDateOfBirth() async {
    final pickedDate = await showDatePicker(
      context: context,
      initialDate: dateOfBirth,
      firstDate: DateTime(1950),
      lastDate: DateTime.now(),
    );

    if (pickedDate != null) {
      setState(() => dateOfBirth = pickedDate);
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isTablet = screenWidth > 600;
    final spacing = isTablet ? 20.0 : 15.0;

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Rifle No & ID No
        isTablet
            ? Row(
          children: [
            const Spacer(flex: 2),
            Expanded(
              flex: 3,
              child: Column(
                children: [
                  UnderlineTextField(
                    label: 'Rifle No:',
                    controller: rifleNoController,
                    requiredField: true,
                  ),
                  const SizedBox(height: 10),
                  UnderlineTextField(
                    label: 'Id No:',
                    controller: idNoController,
                    requiredField: true,
                  ),
                ],
              ),
            ),
          ],
        )
            : Column(
          children: [
            UnderlineTextField(
              label: 'Rifle No:',
              controller: rifleNoController,
              requiredField: true,
            ),
            const SizedBox(height: 10),
            UnderlineTextField(
              label: 'Id No:',
              controller: idNoController,
              requiredField: true,
            ),
          ],
        ),

        SizedBox(height: spacing),

        UnderlineTextField(
          label: 'Full Name:',
          controller: fullNameController,
          requiredField: true,
        ),

        SizedBox(height: spacing),

        // Tribe & Religion
        isTablet
            ? Row(
          children: [
            Expanded(
              child: UnderlineTextField(
                label: 'Tribe:',
                controller: tribeController,
                requiredField: true,
              ),
            ),
            const SizedBox(width: 20),
            Expanded(
              child:  UnderlineTextField(
                label: 'Religion:',
                controller: religionController,
                requiredField: true,
              ),
            ),
          ],
        )
            : Column(
          children: [
            UnderlineTextField(
              label: 'Tribe:',
              controller: tribeController,
              requiredField: true,
            ),
            const SizedBox(height: 15),
            UnderlineTextField(
              label: 'Religion:',
              controller: religionController,
              requiredField: true,
            ),
          ],
        ),

        SizedBox(height: spacing),

        // Date of Birth
        GestureDetector(
          onTap: _selectDateOfBirth,
          child: Container(
            padding: const EdgeInsets.only(bottom: 8),
            decoration: const BoxDecoration(
              border: Border(
                bottom: BorderSide(color: Colors.black),
              ),
            ),
            child: Row(
              children: [
                const Text(
                  'Date of Birth: ',
                  style: TextStyle(fontWeight: FontWeight.w500),
                ),
                Text(
                  '${dateOfBirth.day}/${dateOfBirth.month}/${dateOfBirth.year}',
                ),
              ],
            ),
          ),
        ),

        SizedBox(height: spacing),

        // Account Type
        Wrap(
          children: [
            Checkbox(
              value: accountType == 'Salary Acct',
              onChanged: (_) =>
                  setState(() => accountType = 'Salary Acct'),
            ),
            const Text('Salary Acct'),
            Checkbox(
              value: accountType == 'Personal Acct',
              onChanged: (_) =>
                  setState(() => accountType = 'Personal Acct'),
            ),
            const Text('Personal Acct'),
          ],
        ),

        SizedBox(height: spacing),

        // Unit Area Checkboxes
        Wrap(
          spacing: isTablet ? 15 : 7,
          children: [
            buildCheckboxRow(
              'Boyes Batch A',
              boyesBatchA,
                  (v) => setState(() => boyesBatchA = v!),
              context,
            ),
            buildCheckboxRow(
              'Boyes Batch B',
              boyesBatchB,
                  (v) => setState(() => boyesBatchB = v!),
              context,
            ),
            buildCheckboxRow(
              'Neighborhood Watch',
              neighborhoodWatch,
                  (v) => setState(() => neighborhoodWatch = v!),
              context,
            ),
            buildCheckboxRow(
              'Hybrid Force',
              hybridForce,
                  (v) => setState(() => hybridForce = v!),
              context,
            ),
            buildCheckboxRow(
              'Volunteer',
              volunteer,
                  (v) => setState(() => volunteer = v!),
              context,
            ),
          ],
        ),
      ],
    );
  }
}

