import 'package:flutter/material.dart';
import '../models/member.dart';

class MemberCard extends StatelessWidget {
  final Member member;
  final VoidCallback onTap;
  final VoidCallback? onEdit;
  final VoidCallback? onDelete;

  const MemberCard({
    super.key,
    required this.member,
    required this.onTap,
    this.onEdit,
    this.onDelete,
  });

  String _getLocation() {
    if (member.additionalInfo != null) {
      // Try to get location from additionalInfo
      final location = member.additionalInfo!['location'];
      if (location != null && location.toString().isNotEmpty) {
        return location.toString();
      }

      // If no specific location, use LGA and State
      final lga = member.additionalInfo!['lga'];
      final state = member.additionalInfo!['state'];

      if (lga != null &&
          state != null &&
          lga.toString().isNotEmpty &&
          state.toString().isNotEmpty) {
        return '$lga, $state';
      } else if (lga != null && lga.toString().isNotEmpty) {
        return lga.toString();
      } else if (state != null && state.toString().isNotEmpty) {
        return state.toString();
      }
    }

    // Fallback to address
    return member.address.isNotEmpty ? member.address : 'No Location';
  }

  @override
  Widget build(BuildContext context) {
    final location = _getLocation();

    return Card(
      margin: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      elevation: 2,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(8),
        child: Padding(
          padding: EdgeInsets.all(12),
          child: Row(
            children: [
              // Profile Image
              Container(
                width: 50,
                height: 50,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.blue.shade100,
                  image:
                      member.profileImage != null &&
                          member.profileImage!.isNotEmpty
                      ? DecorationImage(
                          image: NetworkImage(member.profileImage!),
                          fit: BoxFit.cover,
                        )
                      : null,
                ),
                child:
                    member.profileImage == null || member.profileImage!.isEmpty
                    ? Center(
                        child: Text(
                          member.fullName.isNotEmpty
                              ? member.fullName[0].toUpperCase()
                              : 'M',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: Colors.blue.shade800,
                          ),
                        ),
                      )
                    : null,
              ),
              SizedBox(width: 12),

              // Member Information
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      member.fullName.isNotEmpty
                          ? member.fullName
                          : 'Unknown Member',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: Colors.grey.shade800,
                      ),
                      overflow: TextOverflow.ellipsis,
                      maxLines: 1,
                    ),
                    SizedBox(height: 4),

                    // Position and Location
                    Row(
                      children: [
                        Icon(Icons.work, size: 12, color: Colors.grey.shade500),
                        SizedBox(width: 4),
                        Expanded(
                          child: Text(
                            member.position.isNotEmpty
                                ? member.position
                                : 'Member',
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey.shade600,
                            ),
                            overflow: TextOverflow.ellipsis,
                            maxLines: 1,
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 2),

                    // Location
                    Row(
                      children: [
                        Icon(
                          Icons.location_on,
                          size: 12,
                          color: Colors.grey.shade500,
                        ),
                        SizedBox(width: 4),
                        Expanded(
                          child: Text(
                            location,
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey.shade600,
                            ),
                            overflow: TextOverflow.ellipsis,
                            maxLines: 1,
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 2),

                    // Rifle Number
                    Row(
                      children: [
                        Icon(
                          Icons.confirmation_number,
                          size: 12,
                          color: Colors.grey.shade500,
                        ),
                        SizedBox(width: 4),
                        Text(
                          member.rifleNumber.isNotEmpty
                              ? member.rifleNumber
                              : 'No Rifle No.',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey.shade600,
                          ),
                          overflow: TextOverflow.ellipsis,
                          maxLines: 1,
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              // Status and Actions
              Column(
                children: [
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: member.isActive
                          ? Colors.green.shade100
                          : Colors.red.shade100,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      member.isActive ? 'Active' : 'Inactive',
                      style: TextStyle(
                        fontSize: 10,
                        color: member.isActive
                            ? Colors.green.shade800
                            : Colors.red.shade800,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                  SizedBox(height: 8),
                  Row(
                    children: [
                      if (onEdit != null)
                        IconButton(
                          icon: Icon(Icons.edit, size: 18),
                          onPressed: onEdit,
                          tooltip: 'Edit Member',
                          color: Colors.blue.shade600,
                          padding: EdgeInsets.zero,
                          constraints: BoxConstraints(),
                        ),
                      if (onDelete != null)
                        IconButton(
                          icon: Icon(Icons.delete, size: 18),
                          onPressed: onDelete,
                          tooltip: 'Delete Member',
                          color: Colors.red.shade600,
                          padding: EdgeInsets.zero,
                          constraints: BoxConstraints(),
                        ),
                    ],
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
