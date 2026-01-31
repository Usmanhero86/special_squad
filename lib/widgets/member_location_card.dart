import 'package:flutter/material.dart';
import '../models/member.dart';

class MemberLocationCard extends StatelessWidget {
  final Member member;
  final VoidCallback onAssignDuty;

  const MemberLocationCard({
    super.key,
    required this.member,
    required this.onAssignDuty,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: Colors.blue,
          child: Text(
            member.fullName[0].toUpperCase(),
            style: TextStyle(color: Colors.white),
          ),
        ),
        title: Text(
          member.fullName,
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(height: 2),
            Text('Rifle: ${member.idNumber}'),
            Text('Phone: ${member.phone}'),
            if (member.position.isNotEmpty)
              Text('Position: ${member.position}'),
          ],
        ),
        trailing: IconButton(
          icon: Icon(Icons.assignment, color: Colors.blue),
          onPressed: onAssignDuty,
        ),
      ),
    );
  }
}