import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:special_squad/screens/members/sections/contact_info_section.dart';
import 'package:special_squad/screens/members/sections/emergency_section.dart';
import 'package:special_squad/screens/members/sections/form_subtitle.dart';
import 'package:special_squad/screens/members/sections/guarantor_section.dart';
import 'package:special_squad/screens/members/sections/membership_header.dart';
import 'package:special_squad/screens/members/sections/next_of_kin_section.dart';
import 'package:special_squad/screens/members/sections/save_form_button.dart';
import 'package:special_squad/screens/members/sections/section_title.dart';
import 'package:special_squad/screens/members/sections/signature_section.dart';
import '../../models/member.dart';
import '../../services/member_service.dart';

class AddMemberScreen extends StatefulWidget {
  const AddMemberScreen({super.key});

  @override
  State<AddMemberScreen> createState() => _AddMemberScreenState();
}

class _AddMemberScreenState extends State<AddMemberScreen> {
  final _formKey = GlobalKey<FormState>();

  // Contact Information
  final TextEditingController _rifleNoController = TextEditingController();
  final TextEditingController _idNoController = TextEditingController();
  final TextEditingController _fullNameController = TextEditingController();
  final TextEditingController _tribeController = TextEditingController();
  final TextEditingController _religionController = TextEditingController();
  final TextEditingController _permanentAddressController = TextEditingController();
  final TextEditingController _phoneNoController = TextEditingController();
  final TextEditingController _maritalStatusController = TextEditingController();
  final TextEditingController _positionController = TextEditingController();
  final TextEditingController _ninNoController = TextEditingController();
  final TextEditingController _bvnController = TextEditingController();
  final TextEditingController _accountNoController = TextEditingController();
  final TextEditingController _lgaController = TextEditingController();
  final TextEditingController _stateController = TextEditingController();
  final TextEditingController _unitAreaController = TextEditingController();

  // Guarantor's Information
  final TextEditingController _guarantorFullNameController =
      TextEditingController();
  final TextEditingController _guarantorAddressController =
      TextEditingController();
  final TextEditingController _guarantorPhoneController =
      TextEditingController();
  final TextEditingController _guarantorRelationshipController =
      TextEditingController();

  // Emergency Contact Information
  final TextEditingController _emergencyFullNameController =
      TextEditingController();
  final TextEditingController _emergencyAddressController =
      TextEditingController();
  final TextEditingController _emergencyPhoneController =
      TextEditingController();

  // Next of Kin
  final TextEditingController _nextOfKinFullNameController =
      TextEditingController();
  final TextEditingController _nextOfKinAddressController =
      TextEditingController();
  final TextEditingController _nextOfKinPhoneController =
      TextEditingController();

  final DateTime _dateOfBirth = DateTime.now();
  final String _gender = '';
  final String _accountType = 'Salary Acct';

  // Unit Area checkboxes
  final bool _boyesBatchA = false;
  final bool _boyesBatchB = false;
  final bool _neighborhoodWatch = false;
  final bool _hybridForce = false;
  final bool _volunteer = false;


  Future<void> _saveMember() async {
    if (_formKey.currentState!.validate()) {
      final memberService = Provider.of<MemberService>(context, listen: false);

      // Create comprehensive member data
      final additionalInfo = {
        'rifleNo': _rifleNoController.text.trim(),
        'gender': _gender,
        'tribe': _tribeController.text.trim(),
        'religion': _religionController.text.trim(),
        'maritalStatus': _maritalStatusController.text.trim(),
        'ninNo': _ninNoController.text.trim(),
        'bvn': _bvnController.text.trim(),
        'accountNo': _accountNoController.text.trim(),
        'accountType': _accountType,
        'lga': _lgaController.text.trim(),
        'state': _stateController.text.trim(),
        'unitArea': _unitAreaController.text.trim(),
        'boyesBatchA': _boyesBatchA,
        'boyesBatchB': _boyesBatchB,
        'neighborhoodWatch': _neighborhoodWatch,
        'hybridForce': _hybridForce,
        'volunteer': _volunteer,
        'guarantor': {
          'fullName': _guarantorFullNameController.text.trim(),
          'address': _guarantorAddressController.text.trim(),
          'phone': _guarantorPhoneController.text.trim(),
          'relationship': _guarantorRelationshipController.text.trim(),
        },
        'emergencyContact': {
          'fullName': _emergencyFullNameController.text.trim(),
          'address': _emergencyAddressController.text.trim(),
          'phone': _emergencyPhoneController.text.trim(),
        },
        'nextOfKin': {
          'fullName': _nextOfKinFullNameController.text.trim(),
          'address': _nextOfKinAddressController.text.trim(),
          'phone': _nextOfKinPhoneController.text.trim(),
        },
      };

      final member = Member(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        fullName: _fullNameController.text.trim(),
        idNumber: _idNoController.text.trim().isEmpty
            ? DateTime.now().millisecondsSinceEpoch.toString()
            : _idNoController.text.trim(),
        phone: _phoneNoController.text.trim(),
        dateOfBirth: _dateOfBirth,
        address: _permanentAddressController.text.trim(),
        position: _positionController.text.trim().isEmpty
            ? 'Member'
            : _positionController.text.trim(),
        joinDate: DateTime.now(),
        additionalInfo: additionalInfo,
      );

      try {
        await memberService.addMember(member, null);
        if (mounted) {
          Navigator.pop(context);
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                'Member "${member.fullName}" registered successfully!',
              ),
              backgroundColor: Colors.green,
              duration: Duration(seconds: 3),
            ),
          );
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Error registering member: $e'),
              backgroundColor: Colors.red,
              duration: Duration(seconds: 3),
            ),
          );
        }
      }
    }
  }

  @override
  void dispose() {
    // Dispose all controllers
    _rifleNoController.dispose();
    _idNoController.dispose();
    _fullNameController.dispose();
    _tribeController.dispose();
    _religionController.dispose();
    _permanentAddressController.dispose();
    _phoneNoController.dispose();
    _maritalStatusController.dispose();
    _positionController.dispose();
    _ninNoController.dispose();
    _bvnController.dispose();
    _accountNoController.dispose();
    _lgaController.dispose();
    _stateController.dispose();
    _unitAreaController.dispose();
    _guarantorFullNameController.dispose();
    _guarantorAddressController.dispose();
    _guarantorPhoneController.dispose();
    _guarantorRelationshipController.dispose();
    _emergencyFullNameController.dispose();
    _emergencyAddressController.dispose();
    _emergencyPhoneController.dispose();
    _nextOfKinFullNameController.dispose();
    _nextOfKinAddressController.dispose();
    _nextOfKinPhoneController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isTablet = screenWidth > 600;
    final isDesktop = screenWidth > 1200;

    // Responsive margins and padding
    final containerPadding = isDesktop ? 40.0 : (isTablet ? 30.0 : 20.0);

    return Scaffold(
      backgroundColor: Colors.white,
      // appBar: AppBar(
      //   backgroundColor: Colors.white,
      //   elevation: 0,
      //   leading: IconButton(
      //     icon: Icon(Icons.arrow_back, color: Colors.black),
      //     onPressed: () => Navigator.pop(context),
      //   ),
      //   title: Text(
      //     'Membership Data Form',
      //     style: TextStyle(
      //       color: Colors.black,
      //       fontWeight: FontWeight.bold,
      //       fontSize: isTablet ? 20 : 18,
      //     ),
      //   ),
      // ),
      body: SingleChildScrollView(
        child: Center(
          child: SafeArea(
            child: Container(
              // constraints: BoxConstraints(
              //   maxWidth: isDesktop ? 800 : double.infinity,
              // ),
              // margin: EdgeInsets.symmetric(
              //   horizontal: horizontalMargin,
              //   vertical: 16,
              // ),
              padding: EdgeInsets.all(containerPadding),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  // mainAxisSize: MainAxisSize.min,
                  children: [
                    // Header
                    MembershipHeader(),
                    SizedBox(height: isTablet ? 30 : 20),
            
                    // Contact Information Section
                    SectionTitle(title: 'Contact Information'),                  SizedBox(height: 15),
                    ContactInformationForm(),
                    SizedBox(height: isTablet ? 30 : 20),
            
                    // Guarantor's Information Section
                    SectionTitle(title: "Guarantor's Information" ),
                    FormSubtitle(
                      text: 'Note: Enter the Contact Information of your Guarantor below.',
                    ),
                    SizedBox(height: 10),
                    GuarantorInformation(guarantorFullNameController: _guarantorFullNameController, guarantorAddressController: _guarantorAddressController, guarantorPhoneController: _guarantorPhoneController, guarantorRelationshipController: _guarantorRelationshipController),
                    SizedBox(height: isTablet ? 30 : 20),
            
                    // Emergency Contact Information Section
                    SectionTitle(title: 'Emergency Contact Information'),
                    SizedBox(height: 10),
                    EmergencyContactInformation(
                      emergencyFullnameController: _emergencyFullNameController,
                      emergencyAddressController: _emergencyAddressController,
                      emergencyPhoneController: _emergencyPhoneController,
                    ),
                    SizedBox(height: isTablet ? 30 : 20),
            
                    // Next of Kin Section
                    SectionTitle(title: 'Next of Kin'),
                    SizedBox(height: 10),
                    NextOfKinInformation(
                      nextOfKinFullnameController: _nextOfKinFullNameController,
                      nextOfKinAddressController: _nextOfKinAddressController,
                      nextOfKinPhoneController: _nextOfKinPhoneController,
                    ),
                    SizedBox(height: isTablet ? 40 : 30),
            
                    // Signature Section
                    SignatureSection(),
                    SizedBox(height: isTablet ? 40 : 30),
            
                    // Save Button
                    SaveFormButton(onPressed: _saveMember),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

}
