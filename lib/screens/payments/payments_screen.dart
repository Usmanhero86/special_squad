import 'package:flutter/material.dart';
import 'package:special_squad/screens/payments/payment_details_sheet.dart';
import '../../models/payment.dart';
import '../../services/payment_service.dart';
import '../../widgets/payment_card.dart';
import 'add_payment_screen.dart';

class PaymentScreen extends StatefulWidget {
  const PaymentScreen({super.key});

  @override
  _PaymentScreenState createState() => _PaymentScreenState();
}

class _PaymentScreenState extends State<PaymentScreen> {
  final PaymentService _paymentService = PaymentService();
  List<Payment> _payments = [];
  double _totalReceived = 0;

  @override
  void initState() {
    super.initState();
    _loadPayments();
  }

  Future<void> _loadPayments() async {
    final payments = await _paymentService.getRecentPayments();
    setState(() {
      _payments = payments;
      _totalReceived = payments
          .where((p) => p.status == 'Completed')
          .fold(0, (sum, payment) => sum + payment.amount);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Payments'),
        actions: [
          IconButton(
            icon: Icon(Icons.add),
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => AddPaymentScreen()),
            ),
          ),
          IconButton(
            icon: Icon(Icons.download),
            onPressed: _exportPayments,
          ),
        ],
      ),
      body: Column(
        children: [
          _buildSummaryCard(),
          Expanded(
            child: ListView.builder(
              itemCount: _payments.length,
              itemBuilder: (context, index) {
                final payment = _payments[index];
                return PaymentCard(
                  payment: payment,
                  onTap: () => _showPaymentDetails(payment),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryCard() {
    return Card(
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          children: [
            Text(
              'Total Received',
              style: TextStyle(fontSize: 16, color: Colors.grey),
            ),
            SizedBox(height: 8),
            Text(
              '₦${_totalReceived.toStringAsFixed(2)}',
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: Colors.green,
              ),
            ),
            SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _buildStatItem('Today', '₦0.00'),
                _buildStatItem('This Week', '₦0.00'),
                _buildStatItem('This Month', '₦0.00'),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatItem(String label, String value) {
    return Column(
      children: [
        Text(label, style: TextStyle(color: Colors.grey)),
        SizedBox(height: 4),
        Text(value, style: TextStyle(fontWeight: FontWeight.bold)),
      ],
    );
  }

  void _showPaymentDetails(Payment payment) {
    showModalBottomSheet(
      context: context,
      builder: (context) => PaymentDetailsSheet(payment: payment, parentContext: context,),
    );
  }

  Future<void> _exportPayments() async {
    // Implement PDF export functionality
  }
}