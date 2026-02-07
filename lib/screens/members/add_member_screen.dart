import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'package:special_squad/screens/members/sections/section_title.dart';
import '../../models/location_location.dart';
import '../../services/location_provider.dart';
import 'guarantor_infoo.dart';

class AddMemberScreen extends StatefulWidget {
  const AddMemberScreen({super.key});

  @override
  State<AddMemberScreen> createState() => _AddMemberScreenState();
}

class _AddMemberScreenState extends State<AddMemberScreen> {
  // Form controllers
  final TextEditingController fullNameController = TextEditingController();
  final TextEditingController idNoController = TextEditingController();
  final TextEditingController rifleNoController = TextEditingController();
  final TextEditingController tribeController = TextEditingController();
  final TextEditingController religionController = TextEditingController();
  final TextEditingController dobController = TextEditingController();
  final TextEditingController phoneController = TextEditingController();
  final TextEditingController locationController = TextEditingController();
  final TextEditingController addressController = TextEditingController();
  final TextEditingController maritalController = TextEditingController();
  final TextEditingController positionController = TextEditingController();
  final TextEditingController ninController = TextEditingController();
  final TextEditingController bvnController = TextEditingController();
  final TextEditingController stateController = TextEditingController();
  final TextEditingController accountController = TextEditingController();
  final TextEditingController unitAreaController = TextEditingController();

  // Selected values
  String? selectedGender;
  String? selectedUnitAreaType;

  Location? _selectedLocation;
  // Profile image
  File? _profileImage;
  final ImagePicker _picker = ImagePicker();
  @override
  void initState() {
    super.initState();

    Future.microtask(() {
      context.read<LocationProvider>().loadLocations();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Register Member',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Profile Picture Section
            _buildProfilePictureSection(),
            const SizedBox(height: 24),

            Align(
              alignment: Alignment.center,
              child: SectionTitle(title: 'Membership Data Form'),
            ),
            const SizedBox(height: 24),
            SectionTitle(title: 'Contact Info'),

            // Form Fields
            _buildFormSection(),

            // Next Button
            const SizedBox(height: 32),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _navigateToGuarantorInfo,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Theme.of(context).colorScheme.primary,
                  foregroundColor: Theme.of(context).colorScheme.onPrimary,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8.0),
                  ),
                ),
                child: const Text(
                  'Next',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildFormSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Personal Information Grid
        _buildPersonalInfoGrid(),

        const SizedBox(height: 16),

        // Phone Number Section
        _buildLabel('Phone Number'),
        const SizedBox(height: 4),
        TextFormField(
          controller: phoneController,
          decoration: InputDecoration(
            hintText: 'Enter phone number',
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(4.0),
            ),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 12,
              vertical: 16,
            ),
          ),
          keyboardType: TextInputType.phone,
        ),

        const SizedBox(height: 16),

        // Location Section
        _buildLabel('Location'),
        const SizedBox(height: 4),

        Consumer<LocationProvider>(
          builder: (context, provider, _) {
            if (provider.isFetching) {
              return const LinearProgressIndicator();
            }

            if (provider.error != null) {
              return Text(
                'Failed to load locations',
                style: TextStyle(color: Colors.red),
              );
            }

            return DropdownButtonFormField<Location>(
              initialValue: _selectedLocation,
              hint: const Text('Select location'),
              items: provider.locations.map((location) {
                return DropdownMenuItem<Location>(
                  value: location,
                  child: Text(location.name),
                );
              }).toList(),
              onChanged: (value) {
                setState(() {
                  _selectedLocation = value;
                });
              },
              decoration: InputDecoration(
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(4),
                ),
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 16,
                ),
              ),
            );
          },
        ),

        const SizedBox(height: 16),

        // Gender Section
        _buildLabel('Gender'),
        const SizedBox(height: 8),
        Row(
          children: [
            _buildRadioButton('Male', 'male'),
            const SizedBox(width: 24),
            _buildRadioButton('Female', 'female'),
          ],
        ),

        const SizedBox(height: 16),

        // Permanent Address
        _buildLabel('Permanent Address'),
        const SizedBox(height: 4),
        TextFormField(
          controller: addressController,
          maxLines: 3,
          decoration: InputDecoration(
            hintText: 'Enter permanent address',
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(4.0),
            ),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 12,
              vertical: 12,
            ),
          ),
        ),

        const SizedBox(height: 16),

        // Other Information Grid
        _buildOtherInfoGrid(),

        const SizedBox(height: 16),

        // Unit Area Type Section
        _buildLabel('Unit Area Type'),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            _buildCheckboxOption('Boyce Batch A'),
            _buildCheckboxOption('Boyce Batch B'),
            _buildCheckboxOption('Neighbourhood Watch'),
            _buildCheckboxOption('Hybrid Force'),
            _buildCheckboxOption('Volunteer'),
            _buildCheckboxOption('Hunter'),
            _buildCheckboxOption('SF'),
          ],
        ),
      ],
    );
  }

  Widget _buildPersonalInfoGrid() {
    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildLabel('Full Name'),
                  const SizedBox(height: 4),
                  TextFormField(
                    controller: fullNameController,
                    decoration: _inputDecoration('Enter full name'),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildLabel('ID No'),
                  const SizedBox(height: 4),
                  TextFormField(
                    controller: idNoController,
                    decoration: _inputDecoration('Enter ID number'),
                  ),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildLabel('Rifle No'),
                  const SizedBox(height: 4),
                  TextFormField(
                    controller: rifleNoController,
                    decoration: _inputDecoration('Enter rifle number'),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildLabel('Tribe'),
                  const SizedBox(height: 4),
                  TextFormField(
                    controller: tribeController,
                    decoration: _inputDecoration('Enter tribe'),
                  ),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildLabel('Religion'),
                  const SizedBox(height: 4),
                  TextFormField(
                    controller: religionController,
                    decoration: _inputDecoration('Enter religion'),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildLabel('Date of Birth'),
                  const SizedBox(height: 4),
                  TextFormField(
                    controller: dobController,
                    decoration: _inputDecoration('DD/MM/YYYY'),
                    readOnly: true,
                    onTap: () {
                      _selectDate(context);
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildOtherInfoGrid() {
    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildLabel('Marital Status'),
                  const SizedBox(height: 4),
                  TextFormField(
                    controller: maritalController,
                    decoration: _inputDecoration('Enter marital status'),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildLabel('Position'),
                  const SizedBox(height: 4),
                  TextFormField(
                    controller: positionController,
                    decoration: _inputDecoration('Enter position'),
                  ),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildLabel('NIN No'),
                  const SizedBox(height: 4),
                  TextFormField(
                    controller: ninController,
                    decoration: _inputDecoration('Enter NIN number'),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildLabel('BVN'),
                  const SizedBox(height: 4),
                  TextFormField(
                    controller: bvnController,
                    decoration: _inputDecoration('Enter BVN number'),
                    keyboardType: TextInputType.number,
                  ),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildLabel('State'),
                  const SizedBox(height: 4),
                  TextFormField(
                    controller: stateController,
                    decoration: _inputDecoration('Enter state'),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildLabel('Account No'),
                  const SizedBox(height: 4),
                  TextFormField(
                    controller: accountController,
                    decoration: _inputDecoration('Enter account number'),
                    keyboardType: TextInputType.number,
                  ),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildLabel('Unit Area'),
                  const SizedBox(height: 4),
                  TextFormField(
                    controller: unitAreaController,
                    decoration: _inputDecoration('Enter unit area'),
                  ),
                ],
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildLabel(String text) {
    return Text(
      text,
      style: const TextStyle(
        fontSize: 14,
        fontWeight: FontWeight.w500,
        color: Colors.black87,
      ),
    );
  }

  InputDecoration _inputDecoration(String hintText) {
    return InputDecoration(
      hintText: hintText,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(4.0),
        borderSide: const BorderSide(color: Colors.grey),
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 16),
    );
  }

  Widget _buildRadioButton(String label, String value) {
    return Row(
      children: [
        Radio<String>(
          value: value,
          groupValue: selectedGender,
          onChanged: (String? value) {
            setState(() {
              selectedGender = value;
            });
          },
        ),
        Text(label, style: const TextStyle(fontSize: 14)),
      ],
    );
  }

  Widget _buildCheckboxOption(String label) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey),
        borderRadius: BorderRadius.circular(4.0),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Checkbox(
            value: selectedUnitAreaType == label.toLowerCase(),
            onChanged: (bool? value) {
              setState(() {
                if (value == true) {
                  selectedUnitAreaType = label.toLowerCase();
                } else {
                  selectedUnitAreaType = null;
                }
              });
            },
          ),
          Text(label, style: const TextStyle(fontSize: 14)),
        ],
      ),
    );
  }

  DateTime? selectedDob;

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
    );

    if (picked != null) {
      setState(() {
        selectedDob = picked;
        dobController.text = "${picked.day}/${picked.month}/${picked.year}";
      });
    }
  }

  // Profile Picture Section
  Widget _buildProfilePictureSection() {
    return Center(
      child: Column(
        children: [
          GestureDetector(
            onTap: _pickProfileImage,
            child: Container(
              width: 120,
              height: 120,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: Theme.of(context).colorScheme.primary,
                  width: 3,
                ),
                color: Theme.of(context).colorScheme.surface,
              ),
              child: _profileImage != null
                  ? ClipOval(
                      child: Image.file(
                        _profileImage!,
                        width: 120,
                        height: 120,
                        fit: BoxFit.cover,
                      ),
                    )
                  : Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.camera_alt,
                          size: 40,
                          color: Theme.of(
                            context,
                          ).colorScheme.onSurface.withValues(alpha: 0.6),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Add Photo',
                          style: TextStyle(
                            color: Theme.of(
                              context,
                            ).colorScheme.onSurface.withValues(alpha: 0.6),
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
            ),
          ),
          const SizedBox(height: 12),
          Text(
            'Tap to add profile picture',
            style: TextStyle(
              color: Theme.of(
                context,
              ).colorScheme.onSurface.withValues(alpha: 0.6),
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }

  // Pick profile image
  Future<void> _pickProfileImage() async {
    try {
      final XFile? image = await _picker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 500,
        maxHeight: 500,
        imageQuality: 80,
      );

      if (image != null) {
        setState(() {
          _profileImage = File(image.path);
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error picking image: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  // Navigate to Guarantor Info with member data
  void _navigateToGuarantorInfo() {
    if (fullNameController.text.trim().isEmpty ||
        phoneController.text.trim().isEmpty ||
        selectedDob == null ||
        selectedGender == null ||
        selectedUnitAreaType == null ||
        _selectedLocation == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please complete all required fields'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    final memberData = {
      "fullName": fullNameController.text.trim(),
      "idNo": idNoController.text.trim(),
      "rifleNo": rifleNoController.text.trim(),
      "tribe": tribeController.text.trim(),
      "religion": religionController.text.trim(),
      "dateOfBirth": DateTime(
        selectedDob!.year,
        selectedDob!.month,
        selectedDob!.day,
      ).toUtc().toIso8601String(),
      "phoneNumber": phoneController.text.trim(),

      // ✅ LOCATION FROM DROPDOWN
      // ✅ WHAT BACKEND EXPECTS
      "location": _selectedLocation!.id,
      "gender": selectedGender,
      "permanentAddress": addressController.text.trim(),
      "maritalStatus": maritalController.text.trim(),
      "position": positionController.text.trim(),
      "ninNo": ninController.text.trim(),
      "bvn": bvnController.text.trim(),
      "state": stateController.text.trim(),
      "accountNo": accountController.text.trim(),
      "unitArea": unitAreaController.text.trim(),
      "unitAreaType": selectedUnitAreaType,
    };
    debugPrint('Member data: $memberData');
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => GuarantorInfoScreen(
          memberData: memberData,
          photoFile: _profileImage, // ✅ PASS FILE HERE
        ),
      ),
    );
  }
}
