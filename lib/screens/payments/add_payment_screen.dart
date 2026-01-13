import 'package:flutter/material.dart';
import '../../models/payment.dart';
import '../../models/member.dart';

class AddPaymentScreen extends StatefulWidget {
  const AddPaymentScreen({super.key});

  @override
  _AddPaymentScreenState createState() => _AddPaymentScreenState();
}

class _AddPaymentScreenState extends State<AddPaymentScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _amountController = TextEditingController();
  final TextEditingController _receiptController = TextEditingController();
  final TextEditingController _notesController = TextEditingController();

  DateTime _selectedDate = DateTime.now();
  String _selectedMethod = 'Cash';
  String _selectedPurpose = 'Membership Fee';
  String? _selectedMemberId;
  List<Member> _members = [];

  final List<String> _paymentMethods = [
    'Cash',
    'Bank Transfer',
    'Mobile Money',
  ];
  final List<String> _paymentPurposes = [
    'Membership Fee',
    'Donation',
    'Event Fee',
    'Other',
  ];

  @override
  void initState() {
    super.initState();
    _loadMembers();
  }

  void _loadMembers() {
    // Load members from service
    // This is placeholder - implement actual data loading
    setState(() {
      _members = [
        Member(
          id: '1',
          fullName: 'John Doe',
          idNumber: 'ID001234567',
          phone: '1234567890',
          dateOfBirth: DateTime(1990, 1, 1),
          address: '123 Main St',
          position: 'Member',
          joinDate: DateTime.now(),
        ),
        Member(
          id: '2',
          fullName: 'Jane Smith',
          idNumber: 'ID009876543',
          phone: '0987654321',
          dateOfBirth: DateTime(1992, 2, 2),
          address: '456 Oak Ave',
          position: 'Manager',
          joinDate: DateTime.now(),
        ),
      ];
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Record Payment')),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _buildMemberSelector(),
              SizedBox(height: 20),
              _buildAmountField(),
              SizedBox(height: 20),
              _buildDatePicker(),
              SizedBox(height: 20),
              _buildMethodSelector(),
              SizedBox(height: 20),
              _buildPurposeSelector(),
              SizedBox(height: 20),
              _buildReceiptField(),
              SizedBox(height: 20),
              _buildNotesField(),
              SizedBox(height: 30),
              ElevatedButton(
                onPressed: _savePayment,
                style: ElevatedButton.styleFrom(
                  padding: EdgeInsets.symmetric(vertical: 16),
                ),
                child: Text('Save Payment'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMemberSelector() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Member *',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
        ),
        SizedBox(height: 8),
        DropdownButtonFormField<String>(
          initialValue: _selectedMemberId,
          decoration: InputDecoration(
            border: OutlineInputBorder(),
            contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 16),
          ),
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'Please select a member';
            }
            return null;
          },
          hint: Text('Select a member'),
          items: _members
              .map(
                (member) => DropdownMenuItem(
                  value: member.id,
                  child: Text(member.fullName),
                ),
              )
              .toList(),
          onChanged: (value) {
            setState(() {
              _selectedMemberId = value;
            });
          },
        ),
      ],
    );
  }

  Widget _buildAmountField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Amount *',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
        ),
        SizedBox(height: 8),
        TextFormField(
          controller: _amountController,
          decoration: InputDecoration(
            border: OutlineInputBorder(),
            prefixText: '₦ ',
            hintText: '0.00',
          ),
          keyboardType: TextInputType.numberWithOptions(decimal: true),
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'Please enter amount';
            }
            if (double.tryParse(value) == null) {
              return 'Please enter a valid number';
            }
            return null;
          },
        ),
      ],
    );
  }

  Widget _buildDatePicker() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Payment Date',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
        ),
        SizedBox(height: 8),
        GestureDetector(
          onTap: _pickDate,
          child: Container(
            padding: EdgeInsets.all(12),
            decoration: BoxDecoration(
              border: Border.all(color: Colors.grey.shade300),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              children: [
                Icon(Icons.calendar_today, color: Colors.blue),
                SizedBox(width: 12),
                Text(
                  '${_selectedDate.day}/${_selectedDate.month}/${_selectedDate.year}',
                  style: TextStyle(fontSize: 16),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildMethodSelector() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Payment Method',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
        ),
        SizedBox(height: 8),
        DropdownButtonFormField<String>(
          initialValue: _selectedMethod,
          decoration: InputDecoration(
            border: OutlineInputBorder(),
            contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 16),
          ),
          items: _paymentMethods
              .map(
                (method) =>
                    DropdownMenuItem(value: method, child: Text(method)),
              )
              .toList(),
          onChanged: (value) {
            setState(() {
              _selectedMethod = value!;
            });
          },
        ),
      ],
    );
  }

  Widget _buildPurposeSelector() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Payment Purpose',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
        ),
        SizedBox(height: 8),
        DropdownButtonFormField<String>(
          initialValue: _selectedPurpose,
          decoration: InputDecoration(
            border: OutlineInputBorder(),
            contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 16),
          ),
          items: _paymentPurposes
              .map(
                (purpose) =>
                    DropdownMenuItem(value: purpose, child: Text(purpose)),
              )
              .toList(),
          onChanged: (value) {
            setState(() {
              _selectedPurpose = value!;
            });
          },
        ),
      ],
    );
  }

  Widget _buildReceiptField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Receipt Number (Optional)',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
        ),
        SizedBox(height: 8),
        TextFormField(
          controller: _receiptController,
          decoration: InputDecoration(
            border: OutlineInputBorder(),
            hintText: 'Enter receipt number',
          ),
        ),
      ],
    );
  }

  Widget _buildNotesField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Notes (Optional)',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
        ),
        SizedBox(height: 8),
        TextFormField(
          controller: _notesController,
          maxLines: 3,
          decoration: InputDecoration(
            border: OutlineInputBorder(),
            hintText: 'Enter any notes...',
          ),
        ),
      ],
    );
  }

  Future<void> _pickDate() async {
    final pickedDate = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2020, 1, 1),
      lastDate: DateTime.now(),
    );
    if (pickedDate != null) {
      setState(() {
        _selectedDate = pickedDate;
      });
    }
  }

  void _savePayment() {
    if (_formKey.currentState!.validate()) {
      final payment = Payment(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        memberId: _selectedMemberId!,
        amount: double.parse(_amountController.text),
        paymentDate: _selectedDate,
        paymentMethod: _selectedMethod,
        purpose: _selectedPurpose,
        receiptNumber: _receiptController.text.isNotEmpty
            ? _receiptController.text
            : null,
        notes: _notesController.text.isNotEmpty ? _notesController.text : null,
        status: 'Completed',
      );

      // Save payment to database (implement this)
      print('Payment saved: $payment');

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Payment recorded successfully'),
          backgroundColor: Colors.green,
        ),
      );

      Navigator.pop(context);
    }
  }
}
