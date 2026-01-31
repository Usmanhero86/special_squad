import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/payment.dart';
import '../../models/member.dart';
import '../../services/member_service.dart';
import '../../services/payment_service.dart';

class AddPaymentScreen extends StatefulWidget {
  const AddPaymentScreen({super.key});

  @override
  AddPaymentScreenState createState() => AddPaymentScreenState();
}

class AddPaymentScreenState extends State<AddPaymentScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _amountController = TextEditingController();
  final TextEditingController _receiptController = TextEditingController();
  final TextEditingController _notesController = TextEditingController();

  DateTime _selectedDate = DateTime.now();
  String _selectedMethod = 'Cash';
  String _selectedPurpose = 'Salary';
  String? _selectedMemberId;
  String? _selectedLocation;
  List<Member> _members = [];
  List<Member> _filteredMembers = [];
  final List<String> _locations = [
    'HQ',
    'Marte',
    'Baga',
    'Sabon gari',
    'Mallum fatori',
    'Dikwa',
    'Ngala',
    'Mafa',
    'Rann',
    'Kala Balge',
    'Gwoza',
    'Askira',
    'Biu',
    'Damboa',
    'Gamboru',
  ];

  final List<String> _paymentMethods = [
    'Cash',
    'Bank Transfer',
    'Mobile Money',
  ];
  final List<String> _paymentPurposes = [
    'Salary',
    'Allowance',
    'Membership Fee',
    'Other',
  ];

  @override
  void initState() {
    super.initState();
    _loadMembers();
  }

  Future<void> _loadMembers() async {
    final memberService = Provider.of<MemberService>(context, listen: false);
    try {
      final members = await memberService.getMembersSync();
      if (mounted) {
        setState(() {
          _members = members;
          _filteredMembers = members;
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error loading members: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  void _filterMembersByLocation(String? location) {
    setState(() {
      _selectedLocation = location;
      _selectedMemberId = null; // Reset selected member when location changes

      if (location == null || location.isEmpty) {
        _filteredMembers = _members;
      } else {
        _filteredMembers = _members
            .where((member) => member.location == location)
            .toList();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Record Payment')),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _buildLocationSelector(),
              SizedBox(height: 20),
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

  Widget _buildLocationSelector() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Location *',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
        ),
        SizedBox(height: 8),
        DropdownButtonFormField<String>(
          initialValue: _selectedLocation,
          decoration: InputDecoration(
            border: OutlineInputBorder(),
            contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 16),
          ),
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'Please select a location';
            }
            return null;
          },
          hint: Text('Select location first'),
          items: _locations
              .map(
                (location) =>
                    DropdownMenuItem(value: location, child: Text(location)),
              )
              .toList(),
          onChanged: (value) {
            _filterMembersByLocation(value);
          },
        ),
      ],
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
          hint: Text(
            _selectedLocation == null
                ? 'Select location first'
                : _filteredMembers.isEmpty
                ? 'No members in $_selectedLocation'
                : 'Select a member from $_selectedLocation',
          ),
          items: _filteredMembers
              .map(
                (member) => DropdownMenuItem(
                  value: member.id,
                  child: Row(
                    children: [
                      CircleAvatar(
                        radius: 16,
                        backgroundColor: Theme.of(
                          context,
                        ).colorScheme.primary.withValues(alpha: 0.1),
                        backgroundImage: member.profileImage != null
                            ? FileImage(member.profileImage as dynamic)
                            : null,
                        child: member.profileImage == null
                            ? Text(
                                member.fullName.substring(0, 1).toUpperCase(),
                                style: TextStyle(
                                  color: Theme.of(context).colorScheme.primary,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 12,
                                ),
                              )
                            : null,
                      ),
                      SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              member.fullName,
                              style: TextStyle(fontWeight: FontWeight.w500),
                            ),
                            Text(
                              member.location ?? 'No location',
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.grey[600],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              )
              .toList(),
          onChanged: _selectedLocation == null
              ? null
              : (value) {
                  setState(() {
                    _selectedMemberId = value;
                  });
                },
        ),
        if (_selectedLocation != null && _filteredMembers.isNotEmpty)
          Padding(
            padding: const EdgeInsets.only(top: 8),
            child: Text(
              '${_filteredMembers.length} member(s) in $_selectedLocation',
              style: TextStyle(fontSize: 12, color: Colors.grey[600]),
            ),
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

  Future<void> _savePayment() async {
    if (_formKey.currentState!.validate()) {
      if (_selectedLocation == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Please select a location first'),
            backgroundColor: Colors.red,
          ),
        );
        return;
      }

      final paymentService = Provider.of<PaymentService>(
        context,
        listen: false,
      );

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

      try {
        await paymentService.addPayment(payment, null);

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                'Payment recorded successfully for $_selectedLocation',
              ),
              backgroundColor: Colors.green,
            ),
          );
          Navigator.pop(context);
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Error saving payment: $e'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    }
  }
}
