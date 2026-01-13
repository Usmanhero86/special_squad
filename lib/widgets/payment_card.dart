import 'package:flutter/material.dart';
import '../models/payment.dart';

class PaymentCard extends StatelessWidget {
  final Payment payment;
  final VoidCallback onTap;

  const PaymentCard({
    super.key,
    required this.payment,
    required this.onTap,
  });

  Color _getStatusColor(String status) {
    switch (status) {
      case 'Completed':
        return Colors.green.shade700;
      case 'Pending':
        return Colors.orange.shade700;
      case 'Failed':
        return Colors.red.shade700;
      default:
        return Colors.grey.shade700;
    }
  }

  IconData _getMethodIcon(String method) {
    switch (method) {
      case 'Bank Transfer':
        return Icons.account_balance;
      case 'Mobile Money':
        return Icons.phone_android;
      case 'Cash':
        return Icons.money;
      default:
        return Icons.payment;
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
            color: _getStatusColor(payment.status).withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(
            _getMethodIcon(payment.paymentMethod),
            color: _getStatusColor(payment.status),
          ),
        ),
        title: Text(
          '₦${payment.amount.toStringAsFixed(2)}',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(height: 2),
            Text('${payment.purpose} • ${payment.paymentMethod}'),
            Text(
              payment.paymentDate.toLocal().toString().split(' ')[0],
              style: TextStyle(fontSize: 12),
            ),
          ],
        ),
        trailing: Container(
          padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(
            color: _getStatusColor(payment.status).withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Text(
            payment.status,
            style: TextStyle(
              color: _getStatusColor(payment.status),
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      ),
    );
  }
}