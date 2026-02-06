import 'dart:io';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:special_squad/screens/members/sections/section_title.dart';
import '../../models/member.dart';
import '../../services/member_service.dart';
import '../../services/members.dart';
import 'member_list_screen.dart';

class GuarantorInfoScreen extends StatefulWidget {
  final Map<String, dynamic> memberData;
  final File? photoFile; // ✅ ADD THIS

  const GuarantorInfoScreen({super.key, required this.memberData, this.photoFile});

  @override
  State<GuarantorInfoScreen> createState() => _GuarantorInfoScreenState();
}

class _GuarantorInfoScreenState extends State<GuarantorInfoScreen> {
  // Guarantor controllers
  final TextEditingController guarantorNameController = TextEditingController();
  final TextEditingController guarantorRelationshipController =
      TextEditingController();
  final TextEditingController guarantorTribeController =
      TextEditingController();
  final TextEditingController guarantorPhoneController =
      TextEditingController();

  // Emergency Contact controllers
  final TextEditingController emergencyNameController = TextEditingController();
  final TextEditingController emergencyAddressController =
      TextEditingController();
  final TextEditingController emergencyPhoneController =
      TextEditingController();

  // Next of Kin controllers
  final TextEditingController nextOfKinNameController = TextEditingController();
  final TextEditingController nextOfKinAddressController =
      TextEditingController();
  final TextEditingController nextOfKinPhoneController =
      TextEditingController();

  // Selected values
  String? selectedGCOSpecialSquad;
  final List<String> gcoSpecialSquadOptions = [
    'General Commanding Officer',
    'Special Squad',
  ];

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
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Note Enter the Contact information of your Guarantor below'),

            // Guarantor Details Text Area
            SectionTitle(title: 'Guarantor Details'),

            // Guarantor Form Grid
            _buildGuarantorGrid(),

            const SizedBox(height: 24),

            // Emergency Contact Information
SectionTitle(title:'Emergency Contact'),
            const SizedBox(height: 8),

            _buildEmergencyContactForm(),

            const SizedBox(height: 24),

            // Next of Kin
SectionTitle(title: 'Next of Kin',),
            const SizedBox(height: 8),

            _buildNextOfKinForm(),

            const SizedBox(height: 24),

            // GCO/Special Squad Selection
            _buildSectionHeader(
              'General Commanding Officer / Special Squad',
              null,
            ),

            const SizedBox(height: 8),

            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey),
                borderRadius: BorderRadius.circular(4.0),
              ),
              child: DropdownButtonHideUnderline(
                child: DropdownButton<String>(
                  value: selectedGCOSpecialSquad,
                  isExpanded: true,
                  hint: const Text('Select option'),
                  items: gcoSpecialSquadOptions.map((String option) {
                    return DropdownMenuItem<String>(
                      value: option,
                      child: Text(option),
                    );
                  }).toList(),
                  onChanged: (String? newValue) {
                    setState(() {
                      selectedGCOSpecialSquad = newValue;
                    });
                  },
                ),
              ),
            ),

            // Save Button
            const SizedBox(height: 32),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  // Handle save button press
                  _saveMembershipForm();
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Theme.of(context).colorScheme.primary,
                  foregroundColor: Theme.of(context).colorScheme.onPrimary,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8.0),
                  ),
                ),
                child: const Text(
                  'Save Membership form',
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

  Widget _buildSectionHeader(String title, String? subtitle) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Colors.black87,
          ),
        ),
        if (subtitle != null) ...[
          const SizedBox(height: 4),
          Text(
            subtitle,
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[600],
              fontStyle: FontStyle.italic,
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildGuarantorGrid() {
    return Column(
      children: [
        // First row: Full Name and Relationship
        Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildFieldLabel('Full Name'),
                  const SizedBox(height: 4),
                  TextFormField(
                    controller: guarantorNameController,
                    decoration: _buildInputDecoration('Enter full name'),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildFieldLabel('Relationship'),
                  const SizedBox(height: 4),
                  TextFormField(
                    controller: guarantorRelationshipController,
                    decoration: _buildInputDecoration('Enter relationship'),
                  ),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        // Second row: Tribe and Phone Number
        Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildFieldLabel('Tribe'),
                  const SizedBox(height: 4),
                  TextFormField(
                    controller: guarantorTribeController,
                    decoration: _buildInputDecoration('Enter tribe'),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildFieldLabel('Phone Number'),
                  const SizedBox(height: 4),
                  TextFormField(
                    controller: guarantorPhoneController,
                    decoration: _buildInputDecoration('Enter phone number'),
                    keyboardType: TextInputType.phone,
                  ),
                ],
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildEmergencyContactForm() {
    return Column(
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildFieldLabel('Full Name'),
            const SizedBox(height: 4),
            TextFormField(
              controller: emergencyNameController,
              decoration: _buildInputDecoration('Enter full name'),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildFieldLabel('Address'),
            const SizedBox(height: 4),
            TextFormField(
              controller: emergencyAddressController,
              maxLines: 2,
              decoration: _buildInputDecoration('Enter address'),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildFieldLabel('Phone Number'),
            const SizedBox(height: 4),
            TextFormField(
              controller: emergencyPhoneController,
              decoration: _buildInputDecoration('Enter phone number'),
              keyboardType: TextInputType.phone,
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildNextOfKinForm() {
    return Column(
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildFieldLabel('Full Name'),
            const SizedBox(height: 4),
            TextFormField(
              controller: nextOfKinNameController,
              decoration: _buildInputDecoration('Enter full name'),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildFieldLabel('Address'),
            const SizedBox(height: 4),
            TextFormField(
              controller: nextOfKinAddressController,
              maxLines: 2,
              decoration: _buildInputDecoration('Enter address'),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildFieldLabel('Phone Number'),
            const SizedBox(height: 4),
            TextFormField(
              controller: nextOfKinPhoneController,
              decoration: _buildInputDecoration('Enter phone number'),
              keyboardType: TextInputType.phone,
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildFieldLabel(String text) {
    return Text(
      text,
      style: const TextStyle(
        fontSize: 14,
        fontWeight: FontWeight.w500,
        color: Colors.black87,
      ),
    );
  }

  InputDecoration _buildInputDecoration(String hintText) {
    return InputDecoration(
      hintText: hintText,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(4.0),
        borderSide: const BorderSide(color: Colors.grey),
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 16),
    );
  }

  void _saveMembershipForm() async {
    // Basic validation
    if (guarantorNameController.text.trim().isEmpty ||
        guarantorPhoneController.text.trim().isEmpty ||
        emergencyNameController.text.trim().isEmpty ||
        nextOfKinNameController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please complete all required fields'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    // ✅ MERGE DATA EXACTLY AS BACKEND EXPECTS
    final payload = {
      ...widget.memberData,

      // GUARANTOR
      "guarantorFullName": guarantorNameController.text.trim(),
      "guarantorRelationship":
      guarantorRelationshipController.text.trim(),
      "guarantorTribe": guarantorTribeController.text.trim(),
      "guarantorPhoneNumber":
      guarantorPhoneController.text.trim(),

      // EMERGENCY CONTACT
      "emergencyFullName": emergencyNameController.text.trim(),
      "emergencyAddress": emergencyAddressController.text.trim(),
      "emergencyPhoneNumber":
      emergencyPhoneController.text.trim(),

      // NEXT OF KIN
      "nextOfKinFullName": nextOfKinNameController.text.trim(),
      "nextOfKinAddress": nextOfKinAddressController.text.trim(),
      "nextOfKinPhoneNumber":
      nextOfKinPhoneController.text.trim(),
    };
    print('✅✅✅✅✅✅✅✅✅✅✅✅✅✅✅✅✅✅✅$payload');
    try {
      final memberService = context.read<MemberServices>();

      await memberService.addMember(
        payload: payload,
        photoFile: widget.photoFile,
      );

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Member registered successfully'),
          backgroundColor: Colors.green,
        ),
      );

      Navigator.popUntil(context, (route) => route.isFirst);
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            e.toString().replaceAll('Exception:', '').trim(),
          ),
          backgroundColor: Colors.red,
        ),
      );
    }
  }
}
