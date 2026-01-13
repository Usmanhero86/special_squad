import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:permission_handler/permission_handler.dart';

class MembershipHeader extends StatefulWidget {
  const MembershipHeader({super.key});

  @override
  State<MembershipHeader> createState() => _MembershipHeaderState();
}

class _MembershipHeaderState extends State<MembershipHeader> {
  File? _selectedImage;
  final ImagePicker _picker = ImagePicker();

  Future<bool> _checkAndRequestPermission() async {
    var status = await Permission.photos.status;
    if (status.isDenied) {
      status = await Permission.photos.request();
    }
    return status.isGranted;
  }

  Future<void> _pickImage() async {
    // Check permission first
    final hasPermission = await _checkAndRequestPermission();
    if (!hasPermission) {
      // Show message that permission is needed
      return;
    }

    try {
      final XFile? pickedFile = await _picker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 800,
        maxHeight: 800,
        imageQuality: 85,
      );

      if (pickedFile != null) {
        setState(() {
          _selectedImage = File(pickedFile.path);
        });
      }
    } catch (e) {
      print('Error picking image: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isTablet = screenWidth > 600;
    final isDesktop = screenWidth > 1200;

    return Column(
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Logo placeholder
            Container(
              width: isDesktop ? 100 : (isTablet ? 70 : 60),
              height: isDesktop ? 100 : (isTablet ? 70 : 60),
              decoration: BoxDecoration(
                color: Colors.red.shade100,
                shape: BoxShape.circle,
                border: Border.all(color: Colors.red, width: 2),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.security,
                    color: Colors.red,
                    size: isDesktop ? 40 : (isTablet ? 30 : 20),
                  ),
                  Text(
                    'CJTF',
                    style: TextStyle(
                      fontSize: isDesktop ? 12 : (isTablet ? 11 : 9),
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(width: isTablet ? 20 : 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'SPECIAL SQUAD',
                    style: TextStyle(
                      fontSize: isDesktop ? 30 : (isTablet ? 22 : 18),
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    'Special Force Joint Task Force',
                    style: TextStyle(
                      fontSize: isDesktop ? 14 : (isTablet ? 13 : 10),
                      fontWeight: FontWeight.bold,
                      color: Colors.red[600],
                    ),
                  ),
                  Container(
                    margin: EdgeInsets.symmetric(vertical: 4),
                    padding: EdgeInsets.symmetric(
                      horizontal: isTablet ? 10 : 6,
                      vertical: 2,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.blue,
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(
                      'BORNO STATE YOUTH VANGUARD',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: isDesktop ? 12 : (isTablet ? 11 : 9),
                      ),
                    ),
                  ),
                  Text(
                    'SECTOR 11 HEADQUARTERS MAIDUGURI BORNO STATE',
                    style: TextStyle(
                        fontSize: isDesktop ? 14 : (isTablet ? 10 : 8),
                        color: Colors.black,
                        fontWeight: FontWeight.bold
                    ),
                  ),
                  Text(
                    'Email: civilianjtfsector7@gmail.com',
                    style: TextStyle(
                        fontSize: isDesktop ? 14 : (isTablet ? 10 : 8),
                        color: Colors.blue,
                        fontWeight: FontWeight.bold
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(width: isTablet ? 20 : 10),
            // Applicant Photo with upload capability
            GestureDetector(
              onTap: _pickImage, // This should open gallery
              // Optional: Use this for camera/gallery choice:
              // onTap: () => _showImageSourceDialog(context),
              child: Container(
                width: isDesktop ? 120 : (isTablet ? 110 : 90),
                height: isDesktop ? 140 : (isTablet ? 130 : 110),
                decoration: BoxDecoration(
                  color: Colors.grey[100],
                  border: Border.all(
                    color: Colors.blueGrey,
                    width: 1,
                  ),
                  borderRadius: BorderRadius.circular(4),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.withOpacity(0.3),
                      blurRadius: 2,
                      offset: Offset(0, 1),
                    ),
                  ],
                ),
                child: _selectedImage != null
                    ? Stack(
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(4),
                      child: Image.file(
                        _selectedImage!,
                        fit: BoxFit.cover,
                        width: double.infinity,
                        height: double.infinity,
                      ),
                    ),
                    Positioned(
                      top: 5,
                      right: 5,
                      child: GestureDetector(
                        onTap: () {
                          setState(() {
                            _selectedImage = null;
                          });
                        },
                        child: Container(
                          padding: EdgeInsets.all(4),
                          decoration: BoxDecoration(
                            color: Colors.black54,
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            Icons.close,
                            color: Colors.white,
                            size: 16,
                          ),
                        ),
                      ),
                    ),
                  ],
                )
                    : Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      width: isDesktop ? 50 : (isTablet ? 45 : 35),
                      height: isDesktop ? 50 : (isTablet ? 45 : 35),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.blueGrey),
                      ),
                      child: Icon(
                        Icons.add_a_photo,
                        color: Colors.blueGrey,
                        size: isDesktop ? 25 : (isTablet ? 22 : 18),
                      ),
                    ),
                    SizedBox(height: 8),
                    Text(
                      'Passport Photo',
                      style: TextStyle(
                        fontSize: isDesktop ? 11 : (isTablet ? 10 : 8),
                        color: Colors.blueGrey[800],
                        fontWeight: FontWeight.bold,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    SizedBox(height: 2),
                    Text(
                      'Tap to upload\n3.5cm x 4.5cm',
                      style: TextStyle(
                        fontSize: isDesktop ? 9 : (isTablet ? 8 : 7),
                        color: Colors.grey[600],
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
        SizedBox(height: isTablet ? 25 : 15),
        Text(
          'Membership Data Form',
          style: TextStyle(
            fontSize: isDesktop ? 20 : (isTablet ? 23 : 20),
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }
}