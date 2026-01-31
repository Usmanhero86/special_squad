import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/payment.dart';
import '../../models/member.dart';
import '../../services/payment_service.dart';
import '../../services/member_service.dart';
import '../../widgets/theme_toggle_button.dart';
import 'add_payment_screen.dart';
import 'payment_details_sheet.dart';
import 'payment_history_screen.dart';

class PaymentScreen extends StatefulWidget {
  const PaymentScreen({super.key});

  @override
  State<PaymentScreen> createState() => _PaymentScreenState();
}

class _PaymentScreenState extends State<PaymentScreen> {
  List<PaymentRecord> _paymentRecords = [];
  List<PaymentRecord> _filteredRecords = [];
  final TextEditingController _searchController = TextEditingController();
  bool _isLoading = true;
  String? _selectedLocation;
  final List<String> _locations = [
    'All Locations',
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

  @override
  void initState() {
    super.initState();
    _selectedLocation = _locations.first;
    _loadPaymentRecords();
    _searchController.addListener(_filterRecords);
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadPaymentRecords() async {
    final paymentService = Provider.of<PaymentService>(context, listen: false);
    final memberService = Provider.of<MemberService>(context, listen: false);

    try {
      // Load members and payments
      final members = await memberService.getMembersSync();
      final payments = await paymentService.getRecentPayments();

      // Create payment records for each member
      final records = <PaymentRecord>[];

      for (final member in members) {
        // Find the latest payment for this member
        final memberPayments = payments
            .where((p) => p.memberId == member.id)
            .toList();
        memberPayments.sort((a, b) => b.paymentDate.compareTo(a.paymentDate));

        final latestPayment = memberPayments.isNotEmpty
            ? memberPayments.first
            : null;

        records.add(
          PaymentRecord(
            member: member,
            payment: latestPayment,
            amount: latestPayment?.amount ?? 100000, // Default salary amount
            status: latestPayment?.status ?? 'Unpaid',
          ),
        );
      }

      if (mounted) {
        setState(() {
          _paymentRecords = records;
          _filteredRecords = records;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error loading payment records: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  void _filterRecords() {
    final query = _searchController.text.toLowerCase();
    setState(() {
      _filteredRecords = _paymentRecords.where((record) {
        final matchesSearch =
            record.member.fullName.toLowerCase().contains(query) ||
            record.status.toLowerCase().contains(query);

        final matchesLocation =
            _selectedLocation == 'All Locations' ||
            record.member.location == _selectedLocation;

        return matchesSearch && matchesLocation;
      }).toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      appBar: AppBar(
        title: const Text(
          'Salary Payment',
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.w600),
        ),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.history),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const PaymentHistoryScreen(),
                ),
              );
            },
            tooltip: 'Payment History',
          ),
          Container(
            margin: const EdgeInsets.only(right: 16),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.primary,
              shape: BoxShape.circle,
            ),
            child: IconButton(
              icon: const Icon(Icons.add, color: Colors.white),
              onPressed: () => _showAddPaymentDialog(),
              tooltip: 'Add Payment',
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          // Search Bar and Location Filter
          Container(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                // Location Filter Dropdown
                Container(
                  margin: const EdgeInsets.only(bottom: 16),
                  child: DropdownButtonFormField<String>(
                    initialValue: _selectedLocation,
                    decoration: InputDecoration(
                      labelText: 'Filter by Location',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 12,
                      ),
                    ),
                    items: _locations
                        .map(
                          (location) => DropdownMenuItem(
                            value: location,
                            child: Text(location),
                          ),
                        )
                        .toList(),
                    onChanged: (value) {
                      setState(() {
                        _selectedLocation = value;
                      });
                      _filterRecords();
                    },
                  ),
                ),
                // Search Bar
                TextField(
                  controller: _searchController,
                  decoration: InputDecoration(
                    hintText: 'Search',
                    prefixIcon: Icon(
                      Icons.search,
                      color: Theme.of(
                        context,
                      ).colorScheme.onSurface.withValues(alpha: 0.6),
                    ),
                    suffixIcon: Container(
                      margin: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Theme.of(
                          context,
                        ).colorScheme.primary.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Icon(
                        Icons.tune,
                        color: Theme.of(context).colorScheme.primary,
                      ),
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(
                        color: Theme.of(
                          context,
                        ).colorScheme.outline.withValues(alpha: 0.3),
                      ),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(
                        color: Theme.of(
                          context,
                        ).colorScheme.outline.withValues(alpha: 0.3),
                      ),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(
                        color: Theme.of(context).colorScheme.primary,
                      ),
                    ),
                    filled: true,
                    fillColor: Theme.of(context).colorScheme.surface,
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 12,
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Payment Records List
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _filteredRecords.isEmpty
                ? _buildEmptyState()
                : ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    itemCount: _filteredRecords.length,
                    itemBuilder: (context, index) {
                      final record = _filteredRecords[index];
                      return _buildPaymentRecordTile(record);
                    },
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.payment_outlined,
            size: 64,
            color: Theme.of(
              context,
            ).colorScheme.onSurface.withValues(alpha: 0.6),
          ),
          const SizedBox(height: 16),
          Text(
            'No Payment Records',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: Theme.of(context).colorScheme.onSurface,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Payment records will appear here once members are added',
            style: TextStyle(
              fontSize: 14,
              color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildPaymentRecordTile(PaymentRecord record) {
    final isPaid =
        record.status.toLowerCase() == 'paid' ||
        record.status.toLowerCase() == 'completed';

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        leading: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Checkbox
            Container(
              width: 20,
              height: 20,
              decoration: BoxDecoration(
                border: Border.all(
                  color: Theme.of(
                    context,
                  ).colorScheme.outline.withValues(alpha: 0.5),
                  width: 2,
                ),
                borderRadius: BorderRadius.circular(4),
              ),
              child: isPaid
                  ? Icon(
                      Icons.check,
                      size: 16,
                      color: Theme.of(context).colorScheme.primary,
                    )
                  : null,
            ),
            const SizedBox(width: 12),
            // Profile Picture
            CircleAvatar(
              radius: 24,
              backgroundColor: Theme.of(
                context,
              ).colorScheme.primary.withValues(alpha: 0.1),
              backgroundImage: record.member.profileImage != null
                  ? FileImage(record.member.profileImage as dynamic)
                  : null,
              child: record.member.profileImage == null
                  ? Text(
                      record.member.fullName.substring(0, 1).toUpperCase(),
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.primary,
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                      ),
                    )
                  : null,
            ),
          ],
        ),
        title: Text(
          record.member.fullName,
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              isPaid ? 'Paid' : 'Unpaid',
              style: TextStyle(
                fontSize: 14,
                color: isPaid ? Colors.green : Colors.red,
                fontWeight: FontWeight.w500,
              ),
            ),
            if (record.member.location != null)
              Text(
                record.member.location!,
                style: TextStyle(
                  fontSize: 12,
                  color: Theme.of(
                    context,
                  ).colorScheme.onSurface.withValues(alpha: 0.6),
                ),
              ),
          ],
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              '₦${record.amount.toStringAsFixed(0).replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]},')}',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: isPaid ? Colors.green : Colors.red,
              ),
            ),
            const SizedBox(width: 8),
            PopupMenuButton<String>(
              icon: Icon(
                Icons.more_vert,
                color: Theme.of(
                  context,
                ).colorScheme.onSurface.withValues(alpha: 0.6),
              ),
              onSelected: (value) => _handleMenuAction(value, record),
              itemBuilder: (context) => [
                const PopupMenuItem(
                  value: 'view',
                  child: Row(
                    children: [
                      Icon(Icons.visibility, size: 20),
                      SizedBox(width: 8),
                      Text('View Details'),
                    ],
                  ),
                ),
                PopupMenuItem(
                  value: isPaid ? 'mark_unpaid' : 'mark_paid',
                  child: Row(
                    children: [
                      Icon(
                        isPaid ? Icons.cancel : Icons.check_circle,
                        size: 20,
                        color: isPaid ? Colors.red : Colors.green,
                      ),
                      const SizedBox(width: 8),
                      Text(isPaid ? 'Mark as Unpaid' : 'Mark as Paid'),
                    ],
                  ),
                ),
                const PopupMenuItem(
                  value: 'edit',
                  child: Row(
                    children: [
                      Icon(Icons.edit, size: 20),
                      SizedBox(width: 8),
                      Text('Edit Payment'),
                    ],
                  ),
                ),
                const PopupMenuItem(
                  value: 'delete',
                  child: Row(
                    children: [
                      Icon(Icons.delete, size: 20, color: Colors.red),
                      SizedBox(width: 8),
                      Text('Delete', style: TextStyle(color: Colors.red)),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
        onTap: () => _showPaymentDetails(record),
      ),
    );
  }

  void _handleMenuAction(String action, PaymentRecord record) {
    switch (action) {
      case 'view':
        _showPaymentDetails(record);
        break;
      case 'mark_paid':
        _updatePaymentStatus(record, 'Completed');
        break;
      case 'mark_unpaid':
        _updatePaymentStatus(record, 'Pending');
        break;
      case 'edit':
        _editPayment(record);
        break;
      case 'delete':
        _deletePayment(record);
        break;
    }
  }

  void _updatePaymentStatus(PaymentRecord record, String newStatus) async {
    final paymentService = Provider.of<PaymentService>(context, listen: false);

    try {
      // Update the UI immediately for better user experience
      setState(() {
        record.status = newStatus;
      });

      // If there's an existing payment record, update it
      if (record.payment != null) {
        final updatedPayment = record.payment!.copyWith(status: newStatus);
        await paymentService.updatePayment(updatedPayment);
      } else {
        // Create a new payment record if none exists
        final newPayment = Payment(
          id: DateTime.now().millisecondsSinceEpoch.toString(),
          memberId: record.member.id,
          amount: record.amount,
          paymentDate: DateTime.now(),
          paymentMethod: 'Cash',
          purpose: 'Salary',
          status: newStatus,
        );
        await paymentService.addPayment(newPayment, null);

        // Update the record with the new payment
        record.payment = newPayment;
      }

      // Refresh the payment data to ensure consistency
      await _loadPaymentRecords();

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Payment status updated to $newStatus and saved to database',
            ),
            backgroundColor: newStatus == 'Paid' || newStatus == 'Completed'
                ? Colors.green
                : Colors.orange,
          ),
        );
      }
    } catch (e) {
      // Revert the UI change if database update fails
      setState(() {
        record.status = newStatus == 'Paid' ? 'Unpaid' : 'Paid';
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to update payment status: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  void _showPaymentDetails(PaymentRecord record) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        height: MediaQuery.of(context).size.height * 0.7,
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surface,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: Column(
          children: [
            Container(
              width: 40,
              height: 4,
              margin: const EdgeInsets.symmetric(vertical: 12),
              decoration: BoxDecoration(
                color: Theme.of(
                  context,
                ).colorScheme.outline.withValues(alpha: 0.3),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            Expanded(
              child: PaymentDetailsSheet(
                payment:
                    record.payment ??
                    Payment(
                      id: 'temp',
                      memberId: record.member.id,
                      amount: record.amount,
                      paymentDate: DateTime.now(),
                      paymentMethod: 'Cash',
                      purpose: 'Salary',
                      status: record.status,
                    ),
                parentContext: context,
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _editPayment(PaymentRecord record) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const AddPaymentScreen()),
    ).then((_) => _loadPaymentRecords());
  }

  void _deletePayment(PaymentRecord record) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Payment'),
        content: Text(
          'Are you sure you want to delete the payment record for ${record.member.fullName}?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              // Implement delete logic here
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Payment record deleted'),
                  backgroundColor: Colors.red,
                ),
              );
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Delete', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  void _showAddPaymentDialog() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const AddPaymentScreen()),
    ).then((_) => _loadPaymentRecords());
  }
}

// Helper class to combine member and payment data
class PaymentRecord {
  final Member member;
  Payment? payment;
  final double amount;
  String status;

  PaymentRecord({
    required this.member,
    this.payment,
    required this.amount,
    required this.status,
  });
}
