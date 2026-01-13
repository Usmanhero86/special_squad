import 'package:flutter/material.dart';
import '../models/duty_roster.dart';

class DutyCard extends StatelessWidget {
  final DutyRoster duty;
  final VoidCallback onTap;
  final VoidCallback? onCheckIn;

  const DutyCard({
    super.key,
    required this.duty,
    required this.onTap,
    this.onCheckIn,
  });

  Color _getShiftColor(String shift) {
    switch (shift) {
      case 'Morning':
        return Colors.orange.shade700;
      case 'Afternoon':
        return Colors.blue.shade700;
      case 'Evening':
        return Colors.purple.shade700;
      default:
        return Colors.grey.shade700;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      child: ListTile(
        onTap: onTap,
        leading: Container(
          padding: EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: _getShiftColor(duty.shift).withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(
            Icons.work,
            color: _getShiftColor(duty.shift),
          ),
        ),
        title: Text(
          duty.shift,
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(height: 2),
            Text('Date: ${duty.date.toLocal().toString().split(' ')[0]}'),
            Text(
              'Status: ${duty.status}',
              style: TextStyle(
                color: duty.status == 'Completed'
                    ? Colors.green
                    : duty.status == 'Absent'
                    ? Colors.red
                    : Colors.orange,
              ),
            ),
          ],
        ),
        trailing: duty.status == 'Scheduled'
            ? ElevatedButton(
          onPressed: onCheckIn,
          style: ElevatedButton.styleFrom(
            padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          ),
          child: Text('Check In'),
        )
            : Container(
          padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(
            color: duty.status == 'Completed'
                ? Colors.green.withOpacity(0.1)
                : Colors.red.withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Text(
            duty.status,
            style: TextStyle(
              color: duty.status == 'Completed'
                  ? Colors.green
                  : Colors.red,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      ),
    );
  }
}