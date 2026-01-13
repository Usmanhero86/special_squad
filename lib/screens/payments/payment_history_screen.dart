import 'package:flutter/material.dart';
import 'package:special_squad/screens/payments/payment_details_sheet.dart';
import '../../models/payment.dart';
import '../../widgets/payment_card.dart';

class PaymentHistoryScreen extends StatefulWidget {
  const PaymentHistoryScreen({super.key});

  @override
  _PaymentHistoryScreenState createState() => _PaymentHistoryScreenState();
}

class _PaymentHistoryScreenState extends State<PaymentHistoryScreen> {
  List<Payment> _payments = [];
  DateTimeRange? _selectedDateRange;
  String _selectedFilter = 'All';

  @override
  void initState() {
    super.initState();
    _loadPayments();
  }

  void _loadPayments() {
    // Load payments from service
    // This is placeholder - implement actual data loading
    setState(() {
      _payments = [
        Payment(
          id: '1',
          memberId: '1',
          amount: 5000.00,
          paymentDate: DateTime.now().subtract(Duration(days: 1)),
          paymentMethod: 'Cash',
          purpose: 'Membership Fee',
          receiptNumber: 'RCT001',
          status: 'Completed',
        ),
        Payment(
          id: '2',
          memberId: '2',
          amount: 10000.00,
          paymentDate: DateTime.now().subtract(Duration(days: 3)),
          paymentMethod: 'Bank Transfer',
          purpose: 'Donation',
          receiptNumber: 'RCT002',
          status: 'Completed',
        ),
        Payment(
          id: '3',
          memberId: '1',
          amount: 2500.00,
          paymentDate: DateTime.now().subtract(Duration(days: 7)),
          paymentMethod: 'Mobile Money',
          purpose: 'Event Fee',
          status: 'Pending',
        ),
      ];
    });
  }

  List<Payment> get _filteredPayments {
    List<Payment> filtered = _payments;

    // Filter by status
    if (_selectedFilter != 'All') {
      filtered = filtered.where((p) => p.status == _selectedFilter).toList();
    }

    // Filter by date range
    if (_selectedDateRange != null) {
      filtered = filtered
          .where((p) =>
      p.paymentDate.isAfter(_selectedDateRange!.start) &&
          p.paymentDate.isBefore(_selectedDateRange!.end))
          .toList();
    }

    return filtered;
  }

  @override
  Widget build(BuildContext context) {
    final filteredPayments = _filteredPayments;
    final totalAmount = filteredPayments
        .where((p) => p.status == 'Completed')
        .fold(0.0, (sum, p) => sum + p.amount);

    return Scaffold(
      appBar: AppBar(
        title: Text('Payment History'),
      ),
      body: Column(
        children: [
          _buildFilterBar(),
          _buildSummaryCard(totalAmount),
          Expanded(
            child: filteredPayments.isEmpty
                ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.history, size: 64, color: Colors.grey),
                  SizedBox(height: 16),
                  Text(
                    'No payments found',
                    style: TextStyle(
                      fontSize: 18,
                      color: Colors.grey,
                    ),
                  ),
                ],
              ),
            )
                : ListView.builder(
              itemCount: filteredPayments.length,
              itemBuilder: (context, index) {
                final payment = filteredPayments[index];
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

  Widget _buildFilterBar() {
    return Container(
      padding: EdgeInsets.all(12),
      color: Colors.grey.shade100,
      child: Row(
        children: [
          Expanded(
            child: DropdownButton<String>(
              value: _selectedFilter,
              isExpanded: true,
              items: [
                'All',
                'Completed',
                'Pending',
                'Failed',
              ].map((status) {
                return DropdownMenuItem(
                  value: status,
                  child: Text(status),
                );
              }).toList(),
              onChanged: (value) {
                setState(() {
                  _selectedFilter = value!;
                });
              },
            ),
          ),
          SizedBox(width: 12),
          IconButton(
            icon: Icon(Icons.calendar_today),
            onPressed: _pickDateRange,
            tooltip: 'Filter by date range',
          ),
          if (_selectedDateRange != null)
            IconButton(
              icon: Icon(Icons.clear),
              onPressed: () {
                setState(() {
                  _selectedDateRange = null;
                });
              },
              tooltip: 'Clear date filter',
            ),
        ],
      ),
    );
  }

  Widget _buildSummaryCard(double totalAmount) {
    return Card(
      margin: EdgeInsets.all(12),
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          children: [
            Text(
              'Total in Selected Period',
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey.shade600,
              ),
            ),
            SizedBox(height: 8),
            Text(
              '₦${totalAmount.toStringAsFixed(2)}',
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: Colors.green.shade700,
              ),
            ),
            SizedBox(height: 8),
            if (_selectedDateRange != null)
              Text(
                '${_selectedDateRange!.start.toString().split(' ')[0]} - ${_selectedDateRange!.end.toString().split(' ')[0]}',
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey.shade600,
                ),
              ),
          ],
        ),
      ),
    );
  }

  Future<void> _pickDateRange() async {
    final pickedRange = await showDateRangePicker(
      context: context,
      firstDate: DateTime(2020, 1, 1),
      lastDate: DateTime.now(),
      initialDateRange: _selectedDateRange,
    );
    if (pickedRange != null) {
      setState(() {
        _selectedDateRange = pickedRange;
      });
    }
  }

  void _showPaymentDetails(Payment payment) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) => PaymentDetailsSheet(payment: payment, parentContext: context,),
    );
  }
}