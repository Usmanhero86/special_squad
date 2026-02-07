import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:special_squad/services/member_service.dart';
import 'package:special_squad/services/payment_service.dart';
import '../../models/membersDetails.dart';
import '../../models/member.dart';
import '../../services/memberProvider.dart';

class AddPaymentScreen extends StatefulWidget {
  final Member? preSelectedMember;
  final double? defaultAmount;

  const AddPaymentScreen({
    super.key,
    this.preSelectedMember,
    this.defaultAmount,
  });

  @override
  AddPaymentScreenState createState() => AddPaymentScreenState();
}

class AddPaymentScreenState extends State<AddPaymentScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _amountController = TextEditingController();
  final TextEditingController _notesController = TextEditingController();
  // List<Members> _members = [];
  // List<Members> _filteredMembers = [];
  String? _selectedMemberId;
  DateTime _selectedDate = DateTime.now();
  String _selectedMethod = 'Cash';
  String _selectedPurpose = 'Salary';
  static const double MAX_PAYMENT_AMOUNT = 99999999.99;

  MemberDetail? _selectedMemberDetail;
  bool _loadingMember = false;
  final List<String> _paymentMethods = [
    'Cash',
    'Bank Transfer',
    'Mobile Money',
  ];
  final List<String> _paymentPurposes = ['Salary', 'Allowance', 'Other'];
  @override
  void initState() {
    super.initState();

    // Set pre-selected member if provided
    if (widget.preSelectedMember != null) {
      _selectedMemberId = widget.preSelectedMember!.id;
    }

    // Set default amount if provided
    if (widget.defaultAmount != null) {
      _amountController.text = widget.defaultAmount!.toStringAsFixed(0);
    }

    Future.microtask(() {
      final provider = context.read<MembersProvider>();
      provider.load();
    });
  }

  // Future<void> _loadMembers() async {
  //   final memberService =
  //   Provider.of<MemberServices>(context, listen: false);
  //
  //   final members = await memberService.getMembers(limit: 500);
  //
  //   setState(() {
  //     _members = members.where((m) => m.isActive).toList();
  //     _filteredMembers = _members;
  //   });
  // }

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
              // _buildReceiptField(),
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
    final membersProvider = context.watch<MembersProvider>();

    final activeMembers = membersProvider.members
        .where((m) => m.isActive)
        .toList();
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
          hint: const Text('Select a member'),
          items: activeMembers
              .map(
                (member) => DropdownMenuItem(
                  value: member.id,
                  child: Row(
                    children: [
                      CircleAvatar(
                        radius: 10,
                        backgroundColor: Theme.of(
                          context,
                        ).colorScheme.primary.withValues(alpha: 0.1),
                        backgroundImage:
                            member.photo != null && member.photo!.isNotEmpty
                            ? NetworkImage(member.photo!)
                            : null,
                        child: (member.photo == null || member.photo!.isEmpty)
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
                      const SizedBox(width: 12),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            member.fullName,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(fontWeight: FontWeight.w500),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              )
              .toList(),
          onChanged: (value) async {
            if (value == null) return;

            setState(() {
              _selectedMemberId = value;
              _loadingMember = true;
            });

            try {
              final memberService = context.read<MemberService>();

              final detail = await memberService.getMemberById(value);

              if (!mounted) return;

              setState(() {
                _selectedMemberDetail = detail;
              });
            } catch (e) {
              if (!mounted) return;

              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Failed to load member details'),
                  backgroundColor: Colors.red,
                ),
              );
            } finally {
              if (mounted) {
                setState(() => _loadingMember = false);
              }
            }
          },
        ),
        if (_loadingMember)
          const Padding(
            padding: EdgeInsets.only(top: 8),
            child: LinearProgressIndicator(),
          ),

        if (_selectedMemberDetail != null)
          Padding(
            padding: const EdgeInsets.only(top: 12),
            child: Card(
              child: ListTile(
                leading: CircleAvatar(
                  backgroundImage:
                      _selectedMemberDetail!.photo != null &&
                          _selectedMemberDetail!.photo!.isNotEmpty
                      ? NetworkImage(_selectedMemberDetail!.photo!)
                      : null,
                  child: _selectedMemberDetail!.photo == null
                      ? Text(_selectedMemberDetail!.fullName[0])
                      : null,
                ),
              ),
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

  // ===============================
  // SAVE PAYMENT (FULLY SAFE)
  // ===============================
  Future<void> _savePayment() async {
    if (!_formKey.currentState!.validate()) return;

    if (_selectedMemberId == null) {
      _showError('Please select a member');
      return;
    }

    final amount = double.tryParse(_amountController.text);

    if (amount == null) {
      _showError('Invalid amount entered');
      return;
    }

    // 🚫 FRONTEND HARD LIMIT
    if (amount > MAX_PAYMENT_AMOUNT) {
      _showError(
        'Amount exceeds allowed limit (₦99,999,999.99).\nPlease enter a smaller amount.',
      );
      return;
    }

    final paymentService = Provider.of<PaymentService>(context, listen: false);

    try {
      String apiPaymentMethod;
      switch (_selectedMethod) {
        case 'Bank Transfer':
          apiPaymentMethod = 'BANK_TRANSFER';
          break;
        case 'Mobile Money':
          apiPaymentMethod = 'MOBILE_MONEY';
          break;
        default:
          apiPaymentMethod = 'CASH';
      }

      const months = [
        'January',
        'February',
        'March',
        'April',
        'May',
        'June',
        'July',
        'August',
        'September',
        'October',
        'November',
        'December',
      ];

      final forMonth =
          '${months[_selectedDate.month - 1]},${_selectedDate.year}';

      await paymentService.makePayment(
        memberId: _selectedMemberId!,
        amount: amount,
        purpose: _selectedPurpose,
        paymentMethod: apiPaymentMethod,
        note: _notesController.text.isNotEmpty ? _notesController.text : null,
        forMonth: forMonth,
      );

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Payment recorded successfully'),
          backgroundColor: Colors.green,
        ),
      );

      Navigator.pop(context);
    } catch (e) {
      if (!mounted) return;
      _showError(e.toString().replaceAll('Exception:', '').trim());
    }
  }

  // ===============================
  // HELPERS
  // ===============================
  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
        duration: const Duration(seconds: 4),
      ),
    );
  }
}
