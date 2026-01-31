import 'package:flutter/material.dart';
import '../widgets/checkbox_row.dart';
import '../widgets/underline_text_field.dart';

class ContactInformationForm extends StatefulWidget {
  const ContactInformationForm({super.key});

  @override
  ContactInformationFormState createState() => ContactInformationFormState();
}

class ContactInformationFormState extends State<ContactInformationForm> {
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
  final TextEditingController locationController = TextEditingController();

  // State variables
  DateTime dateOfBirth = DateTime.now();
  String accountType = 'Salary Acct';
  String gender = '';

  bool boyesBatchA = false;
  bool boyesBatchB = false;
  bool neighborhoodWatch = false;
  bool hybridForce = false;
  bool volunteer = false;

  // Focus node to manage keyboard
  final FocusNode _focusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    // Delay focus to prevent immediate keyboard opening
    Future.delayed(Duration.zero, () {
      if (mounted) {
        _focusNode.unfocus();
      }
    });
  }

  @override
  void dispose() {
    _closeControllers();
    _focusNode.dispose();
    super.dispose();
  }

  void _closeControllers() {
    // Unfocus before disposing to prevent keyboard issues
    _focusNode.unfocus();

    // Dispose all controllers
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
    locationController.dispose();
  }

  Future<void> _selectDateOfBirth() async {
    // Unfocus any text field before showing date picker
    _focusNode.unfocus();

    final pickedDate = await showDatePicker(
      context: context,
      initialDate: dateOfBirth,
      firstDate: DateTime(1950),
      lastDate: DateTime.now(),
    );

    if (pickedDate != null && mounted) {
      setState(() => dateOfBirth = pickedDate);
    }
  }

  // Method to get all form data
  Map<String, dynamic> getFormData() {
    return {
      'rifleNo': rifleNoController.text.trim(),
      'idNo': idNoController.text.trim(),
      'fullName': fullNameController.text.trim(),
      'tribe': tribeController.text.trim(),
      'religion': religionController.text.trim(),
      'permanentAddress': permanentAddressController.text.trim(),
      'phoneNo': phoneNoController.text.trim(),
      'maritalStatus': maritalStatusController.text.trim(),
      'position': positionController.text.trim(),
      'ninNo': ninNoController.text.trim(),
      'bvn': bvnController.text.trim(),
      'accountNo': accountNoController.text.trim(),
      'lga': lgaController.text.trim(),
      'state': stateController.text.trim(),
      'unitArea': unitAreaController.text.trim(),
      'location': locationController.text.trim(),
      'dateOfBirth': dateOfBirth,
      'accountType': accountType,
      'gender': gender,
      'boyesBatchA': boyesBatchA,
      'boyesBatchB': boyesBatchB,
      'neighborhoodWatch': neighborhoodWatch,
      'hybridForce': hybridForce,
      'volunteer': volunteer,
    };
  }

  // Method to validate form
  Map<String, dynamic> validateForm() {
    if (fullNameController.text.trim().isEmpty) {
      return {
        'isValid': false,
        'message': 'Please enter full name',
      };
    }

    if (rifleNoController.text.trim().isEmpty) {
      return {
        'isValid': false,
        'message': 'Please enter rifle number',
      };
    }

    if (phoneNoController.text.trim().isEmpty) {
      return {
        'isValid': false,
        'message': 'Please enter phone number',
      };
    }

    if (tribeController.text.trim().isEmpty) {
      return {
        'isValid': false,
        'message': 'Please enter tribe',
      };
    }

    if (religionController.text.trim().isEmpty) {
      return {
        'isValid': false,
        'message': 'Please enter religion',
      };
    }

    return {
      'isValid': true,
      'message': 'Form is valid',
    };
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isTablet = screenWidth > 600;
    final isDesktop = screenWidth > 1200;
    final spacing = isTablet ? 20.0 : 15.0;

    return FocusScope(
      node: FocusScopeNode(),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Full Name - COMES FIRST
          UnderlineTextField(
            label: 'Full Name:',
            controller: fullNameController,
            requiredField: true,
            // focusNode: _focusNode,
          ),

          SizedBox(height: spacing),

          // ID No & Rifle No - REORDERED: ID No first, then Rifle No
          if (isTablet)
            Row(
              children: [
                const Spacer(flex: 2),
                Expanded(
                  flex: 3,
                  child: Column(
                    children: [
                      UnderlineTextField(
                        label: 'Id No:',
                        controller: idNoController,
                        // focusNode: _focusNode,
                      ),
                      const SizedBox(height: 10),
                      UnderlineTextField(
                        label: 'Rifle No:',
                        controller: rifleNoController,
                        requiredField: true,
                        // focusNode: _focusNode,
                      ),
                    ],
                  ),
                ),
              ],
            )
          else
            Column(
              children: [
                UnderlineTextField(
                  label: 'Id No:',
                  controller: idNoController,
                  // focusNode: _focusNode,
                ),
                const SizedBox(height: 10),
                UnderlineTextField(
                  label: 'Rifle No:',
                  controller: rifleNoController,
                  requiredField: true,
                  // focusNode: _focusNode,
                ),
              ],
            ),

          SizedBox(height: spacing),

          // Tribe & Religion
          if (isTablet)
            Row(
              children: [
                Expanded(
                  child: UnderlineTextField(
                    label: 'Tribe:',
                    controller: tribeController,
                    requiredField: true,
                    // focusNode: _focusNode,
                  ),
                ),
                const SizedBox(width: 20),
                Expanded(
                  child: UnderlineTextField(
                    label: 'Religion:',
                    controller: religionController,
                    requiredField: true,
                    // focusNode: _focusNode,
                  ),
                ),
              ],
            )
          else
            Column(
              children: [
                UnderlineTextField(
                  label: 'Tribe:',
                  controller: tribeController,
                  requiredField: true,
                  // focusNode: _focusNode,
                ),
                const SizedBox(height: 15),
                UnderlineTextField(
                  label: 'Religion:',
                  controller: religionController,
                  requiredField: true,
                  // focusNode: _focusNode,
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

          // Gender Selection - Responsive
          if (isTablet)
            Row(
              children: [
                const Text(
                  'Gender: ',
                  style: TextStyle(fontWeight: FontWeight.w500),
                ),
                const SizedBox(width: 20),
                Expanded(
                  child: Wrap(
                    spacing: 20,
                    children: [
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Radio<String>(
                            value: 'Male',
                            groupValue: gender,
                            onChanged: (value) {
                              if (mounted) {
                                setState(() {
                                  gender = value!;
                                });
                              }
                            },
                          ),
                          const Text('Male'),
                        ],
                      ),
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Radio<String>(
                            value: 'Female',
                            groupValue: gender,
                            onChanged: (value) {
                              if (mounted) {
                                setState(() {
                                  gender = value!;
                                });
                              }
                            },
                          ),
                          const Text('Female'),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            )
          else
            Row(
              children: [
                const Text(
                  'Gender:',
                  style: TextStyle(fontWeight: FontWeight.w500),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Radio<String>(
                      value: 'Male',
                      groupValue: gender,
                      onChanged: (value) {
                        if (mounted) {
                          setState(() {
                            gender = value!;
                          });
                        }
                      },
                    ),
                    const Text('Male'),
                    const SizedBox(width: 20),
                    Radio<String>(
                      value: 'Female',
                      groupValue: gender,
                      onChanged: (value) {
                        if (mounted) {
                          setState(() {
                            gender = value!;
                          });
                        }
                      },
                    ),
                    const Text('Female'),
                  ],
                ),
              ],
            ),

          SizedBox(height: spacing),

          // Permanent Address
          UnderlineTextField(
            label: 'Permanent Address:',
            controller: permanentAddressController,
            maxLines: 2,
            // focusNode: _focusNode,
          ),

          SizedBox(height: spacing),

          // Phone Number
          UnderlineTextField(
            label: 'Phone No:',
            controller: phoneNoController,
            requiredField: true,
            keyboardType: TextInputType.phone,
            // focusNode: _focusNode,
          ),

          SizedBox(height: spacing),

          // Location Field
          UnderlineTextField(
            label: 'Location:',
            controller: locationController,
            // focusNode: _focusNode,
          ),

          SizedBox(height: spacing),

          // Marital Status
          UnderlineTextField(
            label: 'Marital Status:',
            controller: maritalStatusController,
            // focusNode: _focusNode,
          ),

          SizedBox(height: spacing),

          // Position
          UnderlineTextField(
            label: 'Position:',
            controller: positionController,
            // focusNode: _focusNode,
          ),

          SizedBox(height: spacing),

          // NIN Number
          UnderlineTextField(
            label: 'NIN No:',
            controller: ninNoController,
            // focusNode: _focusNode,
          ),

          SizedBox(height: spacing),

          // BVN
          UnderlineTextField(
            label: 'BVN:',
            controller: bvnController,
            // focusNode: _focusNode,
          ),

          SizedBox(height: spacing),

          // Account Number
          UnderlineTextField(
            label: 'Account No:',
            controller: accountNoController,
            // focusNode: _focusNode,
          ),

          SizedBox(height: spacing),

          // Account Type - Responsive
          if (isTablet)
            Row(
              children: [
                const Text(
                  'Account Type: ',
                  style: TextStyle(fontWeight: FontWeight.w500),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Wrap(
                    spacing: 20,
                    children: [
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Radio<String>(
                            value: 'Salary Acct',
                            groupValue: accountType,
                            onChanged: (value) {
                              if (mounted) {
                                setState(() {
                                  accountType = value!;
                                });
                              }
                            },
                          ),
                          const Text('Salary Acct'),
                        ],
                      ),
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Radio<String>(
                            value: 'Personal Acct',
                            groupValue: accountType,
                            onChanged: (value) {
                              if (mounted) {
                                setState(() {
                                  accountType = value!;
                                });
                              }
                            },
                          ),
                          const Text('Personal Acct'),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            )
          else
            Column(
              children: [
                const Text(
                  'Account Type:',
                  style: TextStyle(fontWeight: FontWeight.w500),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Radio<String>(
                      value: 'Salary Acct',
                      groupValue: accountType,
                      onChanged: (value) {
                        if (mounted) {
                          setState(() {
                            accountType = value!;
                          });
                        }
                      },
                    ),
                    const Text('Salary Acct'),
                    const SizedBox(width: 20),
                    Radio<String>(
                      value: 'Personal Acct',
                      groupValue: accountType,
                      onChanged: (value) {
                        if (mounted) {
                          setState(() {
                            accountType = value!;
                          });
                        }
                      },
                    ),
                    const Text('Personal Acct'),
                  ],
                ),
              ],
            ),

          SizedBox(height: spacing),

          // LGA & State
          if (isTablet)
            Row(
              children: [
                Expanded(
                  child: UnderlineTextField(
                    label: 'LGA:',
                    controller: lgaController,
                    // focusNode: _focusNode,
                  ),
                ),
                const SizedBox(width: 20),
                Expanded(
                  child: UnderlineTextField(
                    label: 'State:',
                    controller: stateController,
                    // focusNode: _focusNode,
                  ),
                ),
              ],
            )
          else
            Column(
              children: [
                UnderlineTextField(
                  label: 'LGA:',
                  controller: lgaController,
                  // focusNode: _focusNode,
                ),
                const SizedBox(height: 15),
                UnderlineTextField(
                  label: 'State:',
                  controller: stateController,
                  // focusNode: _focusNode,
                ),
              ],
            ),

          SizedBox(height: spacing),

          // Unit Area Field
          UnderlineTextField(
            label: 'Unit Area:',
            controller: unitAreaController,
            // focusNode: _focusNode,
          ),

          SizedBox(height: spacing),

          // Unit Area Checkboxes
          const Text(
            'Unit Area Type:',
            style: TextStyle(fontWeight: FontWeight.w500),
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: isTablet ? 15 : 7,
            runSpacing: 8,
            children: [
              buildCheckboxRow(
                'Boyes Batch A',
                boyesBatchA,
                    (v) {
                  if (mounted) {
                    setState(() => boyesBatchA = v!);
                  }
                },
                context,
              ),
              buildCheckboxRow(
                'Boyes Batch B',
                boyesBatchB,
                    (v) {
                  if (mounted) {
                    setState(() => boyesBatchB = v!);
                  }
                },
                context,
              ),
              buildCheckboxRow(
                'Neighborhood Watch',
                neighborhoodWatch,
                    (v) {
                  if (mounted) {
                    setState(() => neighborhoodWatch = v!);
                  }
                },
                context,
              ),
              buildCheckboxRow(
                'Hybrid Force',
                hybridForce,
                    (v) {
                  if (mounted) {
                    setState(() => hybridForce = v!);
                  }
                },
                context,
              ),
              buildCheckboxRow(
                'Volunteer',
                volunteer,
                    (v) {
                  if (mounted) {
                    setState(() => volunteer = v!);
                  }
                },
                context,
              ),
            ],
          ),
        ],
      ),
    );
  }
}