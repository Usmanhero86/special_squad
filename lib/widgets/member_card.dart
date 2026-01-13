import 'dart:io';
import 'package:flutter/material.dart';
import '../models/member.dart';

class MemberCard extends StatelessWidget {
  final Member member;
  final VoidCallback onTap;
  final VoidCallback? onEdit;

  const MemberCard({
    super.key,
    required this.member,
    required this.onTap,
    this.onEdit,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      child: ListTile(
        onTap: onTap,
        leading: CircleAvatar(
          radius: 24,
          backgroundImage:
              member.profileImage != null && member.profileImage!.isNotEmpty
              ? FileImage(File(member.profileImage!))
              : null,
          backgroundColor: Colors.blue.shade100,
          child: member.profileImage == null || member.profileImage!.isEmpty
              ? Text(
                  member.fullName.isNotEmpty
                      ? member.fullName[0].toUpperCase()
                      : 'M',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.blue.shade800,
                  ),
                )
              : null,
        ),
        title: Text(
          member.fullName.isNotEmpty ? member.fullName : 'Unknown Member',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(height: 2),
            Text(member.position.isNotEmpty ? member.position : 'Member'),
            Text(
              member.idNumber.isNotEmpty ? member.idNumber : 'No ID',
              style: TextStyle(fontSize: 12),
            ),
          ],
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (onEdit != null)
              IconButton(
                icon: Icon(Icons.edit, size: 20),
                onPressed: onEdit,
                tooltip: 'Edit Member',
              ),
            Icon(
              member.isActive ? Icons.check_circle : Icons.remove_circle,
              color: member.isActive ? Colors.green : Colors.grey,
              size: 20,
            ),
          ],
        ),
      ),
    );
  }
}
