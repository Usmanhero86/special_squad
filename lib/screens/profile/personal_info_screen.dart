import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/member.dart';
import '../../services/member_service.dart';

class PersonalInfoScreen extends StatefulWidget {
  final Member? member;

  const PersonalInfoScreen({super.key, this.member});

  @override
  State<PersonalInfoScreen> createState() => _PersonalInfoScreenState();
}

class _PersonalInfoScreenState extends State<PersonalInfoScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  late TextEditingController _phoneController;
  late TextEditingController _rifleNumberController;
  late TextEditingController _positionController;
  late TextEditingController _locationController;

  bool _isEditing = false;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(
      text: widget.member?.fullName ?? '',
    );
    _phoneController = TextEditingController(text: widget.member?.phone ?? '');
    _rifleNumberController = TextEditingController(
      text: widget.member?.rifleNumber ?? '',
    );
    _positionController = TextEditingController(
      text: widget.member?.position ?? '',
    );
    _locationController = TextEditingController(
      text: widget.member?.location ?? '',
    );
  }

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _rifleNumberController.dispose();
    _positionController.dispose();
    _locationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      appBar: AppBar(
        title: const Text('Personal Info'),
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [
          TextButton(
            onPressed: _isEditing ? _saveChanges : _toggleEdit,
            child: Text(
              _isEditing ? 'Save' : 'Edit',
              style: TextStyle(
                color: Theme.of(context).colorScheme.primary,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Form(
                key: _formKey,
                child: Column(
                  children: [
                    // Profile Picture Section
                    _buildProfilePictureSection(),
                    const SizedBox(height: 30),

                    // Personal Information Fields
                    _buildInfoField(
                      label: 'Full Name',
                      controller: _nameController,
                      icon: Icons.person_outline,
                    ),
                    const SizedBox(height: 20),

                    _buildInfoField(
                      label: 'Rifle Number',
                      controller: _rifleNumberController,
                      icon: Icons.badge_outlined,
                    ),
                    const SizedBox(height: 20),

                    _buildInfoField(
                      label: 'Phone Number',
                      controller: _phoneController,
                      icon: Icons.phone_outlined,
                      keyboardType: TextInputType.phone,
                    ),
                    const SizedBox(height: 20),

                    _buildInfoField(
                      label: 'Position',
                      controller: _positionController,
                      icon: Icons.work_outline,
                    ),
                    const SizedBox(height: 20),

                    _buildInfoField(
                      label: 'Location',
                      controller: _locationController,
                      icon: Icons.location_on_outlined,
                    ),
                    const SizedBox(height: 20),

                    // Additional Info
                    _buildInfoTile(
                      label: 'Date of Birth',
                      value: widget.member?.dateOfBirth != null
                          ? '${widget.member!.dateOfBirth.day}/${widget.member!.dateOfBirth.month}/${widget.member!.dateOfBirth.year}'
                          : 'Not set',
                      icon: Icons.cake_outlined,
                    ),
                    const SizedBox(height: 20),

                    _buildInfoTile(
                      label: 'Join Date',
                      value: widget.member?.joinDate != null
                          ? '${widget.member!.joinDate.day}/${widget.member!.joinDate.month}/${widget.member!.joinDate.year}'
                          : 'Not set',
                      icon: Icons.calendar_today_outlined,
                    ),
                  ],
                ),
              ),
            ),
    );
  }

  Widget _buildProfilePictureSection() {
    return Column(
      children: [
        Container(
          width: 120,
          height: 120,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: const Color(0xFFFFB4A3),
            border: Border.all(
              color: Theme.of(
                context,
              ).colorScheme.primary.withValues(alpha: 0.2),
              width: 3,
            ),
          ),
          child: widget.member?.profileImage != null
              ? ClipOval(
                  child: Image.network(
                    widget.member!.profileImage!,
                    width: 120,
                    height: 120,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) {
                      return Center(
                        child: Text(
                          widget.member?.fullName
                                  .substring(0, 1)
                                  .toUpperCase() ??
                              'U',
                          style: const TextStyle(
                            fontSize: 48,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      );
                    },
                  ),
                )
              : Center(
                  child: Text(
                    widget.member?.fullName.substring(0, 1).toUpperCase() ??
                        'U',
                    style: const TextStyle(
                      fontSize: 48,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
        ),
        const SizedBox(height: 15),
        if (_isEditing)
          TextButton.icon(
            onPressed: _changeProfilePicture,
            icon: const Icon(Icons.camera_alt_outlined),
            label: const Text('Change Photo'),
          ),
      ],
    );
  }

  Widget _buildInfoField({
    required String label,
    required TextEditingController controller,
    required IconData icon,
    TextInputType? keyboardType,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: TextFormField(
        controller: controller,
        enabled: _isEditing,
        keyboardType: keyboardType,
        decoration: InputDecoration(
          labelText: label,
          prefixIcon: Icon(icon),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(15),
            borderSide: BorderSide.none,
          ),
          filled: true,
          fillColor: Colors.transparent,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 20,
            vertical: 16,
          ),
        ),
        validator: (value) {
          if (value == null || value.isEmpty) {
            return 'Please enter $label';
          }
          return null;
        },
      ),
    );
  }

  Widget _buildInfoTile({
    required String label,
    required String value,
    required IconData icon,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
        leading: Icon(icon),
        title: Text(
          label,
          style: TextStyle(
            fontSize: 14,
            color: Theme.of(
              context,
            ).colorScheme.onSurface.withValues(alpha: 0.6),
          ),
        ),
        subtitle: Text(
          value,
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
        ),
      ),
    );
  }

  void _toggleEdit() {
    setState(() {
      _isEditing = !_isEditing;
    });
  }

  void _saveChanges() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
    });

    try {
      if (widget.member != null) {
        final memberService = Provider.of<MemberService>(
          context,
          listen: false,
        );

        final updatedMember = Member(
          id: widget.member!.id,
          fullName: _nameController.text,
          rifleNumber: _rifleNumberController.text,
          phone: _phoneController.text,
          dateOfBirth: widget.member!.dateOfBirth,
          address: widget.member!.address,
          position: _positionController.text,
          joinDate: widget.member!.joinDate,
          location: _locationController.text,
          profileImage: widget.member!.profileImage,
          isActive: widget.member!.isActive,
          additionalInfo: widget.member!.additionalInfo,
        );

        await memberService.updateMember(updatedMember);

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Profile updated successfully'),
              backgroundColor: Colors.green,
            ),
          );
          setState(() {
            _isEditing = false;
          });
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error updating profile: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  void _changeProfilePicture() {
    // Implement profile picture change functionality
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Profile picture change functionality coming soon'),
      ),
    );
  }
}
