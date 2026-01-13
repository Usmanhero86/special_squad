import 'package:flutter/material.dart';
import '../../models/payment.dart';

class PaymentDetailsSheet extends StatelessWidget {
  final Payment payment;
  final BuildContext parentContext;

  const PaymentDetailsSheet({super.key, required this.payment, required this.parentContext});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(16),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey.shade300,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          SizedBox(height: 20),
          Text(
            'Payment Details',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: 20),
          _buildDetailRow('Amount', '₦${payment.amount.toStringAsFixed(2)}'),
          _buildDetailRow('Payment Method', payment.paymentMethod),
          _buildDetailRow('Purpose', payment.purpose),
          _buildDetailRow('Date', payment.paymentDate.toLocal().toString().split(' ')[0]),
          _buildDetailRow('Status', payment.status, isStatus: true),
          if (payment.receiptNumber != null)
            _buildDetailRow('Receipt Number', payment.receiptNumber!),
          if (payment.bankReference != null)
            _buildDetailRow('Bank Reference', payment.bankReference!),
          if (payment.notes != null)
            _buildDetailRow('Notes', payment.notes!),
          SizedBox(height: 20),
          if (payment.attachmentUrl != null)
            _buildAttachmentSection(),
          SizedBox(height: 20),
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: () => Navigator.pop(context),
                  child: Text('Close'),
                ),
              ),
              SizedBox(width: 12),
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: _printReceipt,
                  icon: Icon(Icons.print),
                  label: Text('Print Receipt'),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildDetailRow(String label, String value, {bool isStatus = false}) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Expanded(
            flex: 2,
            child: Text(
              label,
              style: TextStyle(
                color: Colors.grey.shade600,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          Expanded(
            flex: 3,
            child: isStatus
                ? Container(
              padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: _getStatusColor(payment.status).withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                value,
                style: TextStyle(
                  color: _getStatusColor(payment.status),
                  fontWeight: FontWeight.w500,
                ),
              ),
            )
                : Text(
              value,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAttachmentSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Attachment',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 16,
          ),
        ),
        SizedBox(height: 8),
        Container(
          padding: EdgeInsets.all(12),
          decoration: BoxDecoration(
            border: Border.all(color: Colors.grey.shade300),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Row(
            children: [
              Icon(Icons.picture_as_pdf, color: Colors.red),
              SizedBox(width: 12),
              Expanded(
                child: Text(
                  'Payment Receipt.pdf',
                  style: TextStyle(fontWeight: FontWeight.w500),
                ),
              ),
              IconButton(
                icon: Icon(Icons.download),
                onPressed: _downloadAttachment,
                tooltip: 'Download attachment',
              ),
            ],
          ),
        ),
      ],
    );
  }

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

  void _printReceipt() {
    // Implement print receipt functionality
    ScaffoldMessenger.of(parentContext).showSnackBar(
      SnackBar(content: Text('Printing receipt...')),
    );
  }

  void _downloadAttachment() {
    // Implement download functionality
    ScaffoldMessenger.of(parentContext).showSnackBar(
      SnackBar(content: Text('Downloading attachment...')),
    );
  }
}