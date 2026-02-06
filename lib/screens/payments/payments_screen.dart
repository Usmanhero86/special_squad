import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/payment.dart';
import '../../models/member.dart';
import '../../models/payment_detail.dart';
import '../../models/payment_member.dart';
import '../../services/payment_service.dart';
import '../../services/payment.dart';
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
  String? _selectedMonth;
  int _currentPage = 1;
  final int _pageSize = 20;
  bool _isLoadingMore = false;
  bool _hasMore = true;
  final ScrollController _scrollController = ScrollController();


  Future<void> _showPaymentDetailsById(String paymentId) async {
    // Show loading indicator
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(
        child: CircularProgressIndicator(),
      ),
    );

    try {
      final paymentService = Provider.of<PaymentServices>(context, listen: false);
      final paymentDetail = await paymentService.getPaymentById(paymentId);

      if (!mounted) return;

      // Close loading indicator
      Navigator.of(context).pop();

      // Show payment details
      showModalBottomSheet(
        context: context,
        isScrollControlled: true,
        backgroundColor: Colors.transparent,
        builder: (context) {
          return Container(
            height: MediaQuery.of(context).size.height * 0.7,
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.surface,
              borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
            ),
            child: PaymentDetailSheet(paymentDetail: paymentDetail),
          );
        },
      );
    } catch (e) {
      if (!mounted) return;

      // Close loading indicator
      Navigator.of(context).pop();

      // Show error message
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error loading payment details: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  // Generate list of months (current month and previous 11 months)
  List<Map<String, String>> _generateMonths() {
    final now = DateTime.now();
    final months = <Map<String, String>>[];

    for (int i = 0; i < 12; i++) {
      final date = DateTime(now.year, now.month - i, 1);
      final monthNames = [
        'January', 'February', 'March', 'April', 'May', 'June',
        'July', 'August', 'September', 'October', 'November', 'December'
      ];

      months.add({
        'label': '${monthNames[date.month - 1]} ${date.year}',
        'value': '${monthNames[date.month - 1]},${date.year}',
      });
    }

    return months;
  }

  @override
  void initState() {
    super.initState();

    final now = DateTime.now();
    const monthNames = [
      'January', 'February', 'March', 'April', 'May', 'June',
      'July', 'August', 'September', 'October', 'November', 'December'
    ];

    _selectedMonth = '${monthNames[now.month - 1]},${now.year}'; // ✅ FIXED

    _scrollController.addListener(_onScroll);
    _loadPaymentRecords();
    _searchController.addListener(_filterRecords);
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }
  // ---------------- SCROLL ----------------
  void _onScroll() {
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 200) {
      _loadPaymentRecords(loadMore: true);
    }
  }

  // ---------------- LOAD DATA ----------------
  Future<void> _loadPaymentRecords({bool loadMore = false}) async {
    if (_isLoadingMore || (!_hasMore && loadMore)) return;

    final paymentService =
    Provider.of<PaymentService>(context, listen: false);

    if (loadMore) {
      _isLoadingMore = true;
    } else {
      _currentPage = 1;
      _hasMore = true;
      _paymentRecords.clear();
      _filteredRecords.clear();
      _isLoading = true;
    }

    setState(() {});

    try {
      final paymentMembers = await paymentService.getPaymentMembers(
        month: _selectedMonth,
        page: _currentPage,
        limit: _pageSize,
      );

      if (paymentMembers.length < _pageSize) {
        _hasMore = false;
      }

      final records = _mapPaymentMembers(paymentMembers);

      setState(() {
        _paymentRecords.addAll(records);
        _filteredRecords = List.from(_paymentRecords);
        _currentPage++;
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error loading payments: $e'),
          backgroundColor: Colors.red,
        ),
      );

      debugPrint('📥 BODY: $e');
    } finally {
      _isLoading = false;
      _isLoadingMore = false;
      setState(() {});
    }
  }

  // ---------------- FIX: MAPPING METHOD ----------------
  List<PaymentRecord> _mapPaymentMembers(List<PaymentMember> members) {
    return members.map((m) {
      final member = Member(
        id: m.id,
        fullName: m.fullName,
        rifleNumber: m.rifleNo,
        phone: m.phoneNumber ?? '',
        dateOfBirth: DateTime.now(),
        address: '',
        position: m.position ?? '',
        joinDate: DateTime.now(),
        isActive: m.status == 'ACTIVE',
        location: m.location ?? 'HQ', // ✅ NOW SAFE
      );

      Payment? payment;

      if (m.isPaid && m.amount > 0) {
        payment = Payment(
          id: 'api-${m.id}',
          memberId: m.id,
          amount: m.amount,
          paymentDate: DateTime.now(),
          paymentMethod: 'CASH',
          purpose: 'Salary',
          status: m.paymentStatus,
          memberName: m.fullName,
        );
      }

      return PaymentRecord(
        member: member,
        payment: payment,
        amount: m.amount,
        status: m.isPaid ? 'Paid' : 'Unpaid',
      );
    }).toList();
  }  // ---------------- SEARCH ----------------
  void _filterRecords() {
    final query = _searchController.text.toLowerCase();
    setState(() {
      _filteredRecords = _paymentRecords.where((record) {
        return record.member.fullName.toLowerCase().contains(query) ||
            record.status.toLowerCase().contains(query);
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
          // Container(
          //   margin: const EdgeInsets.only(right: 16),
          //   decoration: BoxDecoration(
          //     color: Theme.of(context).colorScheme.primary,
          //     shape: BoxShape.circle,
          //   ),
          //   child: IconButton(
          //     icon: const Icon(Icons.add, color: Colors.white),
          //     onPressed: () => _showAddPaymentDialog(),
          //     tooltip: 'Add Payment',
          //   ),
          // ),
        ],
      ),
      body: Column(
        children: [
          // Search Bar and Location Filter
          Container(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                // Month Filter Dropdown
                Container(
                  margin: const EdgeInsets.only(bottom: 16),
                  child: DropdownButtonFormField<String>(
                    initialValue: _selectedMonth,
                    decoration: InputDecoration(
                      labelText: 'Select Month',
                      prefixIcon: const Icon(Icons.calendar_month),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 12,
                      ),
                    ),
                    items: _generateMonths()
                        .map(
                          (month) => DropdownMenuItem(
                            value: month['value'],
                            child: Text(month['label']!),
                          ),
                        )
                        .toList(),
                    onChanged: (value) {
                      if (value != null) {
                        setState(() {
                          _selectedMonth = value;
                          _isLoading = true;
                        });
                        _loadPaymentRecords();
                      }
                    },
                  ),
                ),
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
              controller: _scrollController,
              itemCount: _filteredRecords.length + (_hasMore ? 1 : 0),
              itemBuilder: (context, index) {
                if (index == _filteredRecords.length) {
                  return const Padding(
                    padding: EdgeInsets.all(16),
                    child: Center(child: CircularProgressIndicator()),
                  );
                }
                return _buildPaymentRecordTile(_filteredRecords[index]);
              },
            )
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
              color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.6),
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
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 0),
        leading: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Clickable Checkbox - Navigate to payment form
            GestureDetector(
              onTap: () {
                // Navigate to payment form to record payment
                if (!isPaid) {
                  _navigateToPaymentForm(record);
                } else {
                  _confirmMarkAsUnpaid(record);
                }
              },
              child: Container(
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
                  color: isPaid
                      ? Theme.of(context).colorScheme.primary
                      : Colors.transparent,
                ),
                child: isPaid
                    ? Icon(
                        Icons.check,
                        size: 16,
                        color: Colors.white,
                      )
                    : null,
              ),
            ),
            const SizedBox(width: 12),
            // Profile Picture
            CircleAvatar(
              radius: 18,
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
          style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
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
                fontSize: 12,
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
      ),
    );
  }

  void _handleMenuAction(String action, PaymentRecord record) {
    switch (action) {
      case 'view':
        _showPaymentDetails(record);
        break;
      case 'mark_paid':
        _navigateToPaymentForm(record);
        break;
      case 'mark_unpaid':
        _confirmMarkAsUnpaid(record);
        break;
      case 'edit':
        _editPayment(record);
        break;
      case 'delete':
        _deletePayment(record);
        break;
    }
  }

  // Navigate to payment form to make payment
  void _navigateToPaymentForm(PaymentRecord record) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => AddPaymentScreen(
          preSelectedMember: record.member,
          defaultAmount: record.amount,
        ),
      ),
    ).then((_) => _loadPaymentRecords());
  }

  // Confirm marking as unpaid
  void _confirmMarkAsUnpaid(PaymentRecord record) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Mark as Unpaid'),
        content: Text(
          'Are you sure you want to mark ${record.member.fullName}\'s payment as unpaid?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              _updatePaymentStatus(record, 'Pending');
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.orange),
            child: const Text('Mark as Unpaid'),
          ),
        ],
      ),
    );
  }

  void _updatePaymentStatus(PaymentRecord record, String newStatus) async {
    final paymentService = Provider.of<PaymentService>(context, listen: false);

    // Store old status for rollback
    final oldStatus = record.status;

    try {
      // Map UI status to API status
      String apiStatus = 'PENDING';
      if (newStatus == 'Completed' || newStatus == 'Paid') {
        apiStatus = 'COMPLETED';
      } else if (newStatus == 'Pending') {
        apiStatus = 'PENDING';
      }

      // Update the UI immediately for better user experience
      setState(() {
        record.status = newStatus;
      });

      // If there's an existing payment record, update it
      if (record.payment != null) {
        final updatedPayment = record.payment!.copyWith(status: apiStatus);
        await paymentService.updatePayment(updatedPayment);
      } else {
        // Create a new payment record if none exists
        final newPayment = Payment(
          id: DateTime.now().millisecondsSinceEpoch.toString(),
          memberId: record.member.id,
          amount: record.amount,
          paymentDate: DateTime.now(),
          paymentMethod: 'CASH',
          purpose: 'Salary',
          status: apiStatus,
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
              'Payment status updated to $newStatus',
            ),
            backgroundColor: newStatus == 'Paid' || newStatus == 'Completed'
                ? Colors.green
                : Colors.orange,
          ),
        );
      }
    } catch (e) {
      debugPrint('❌ UPDATE PAYMENT STATUS ERROR: $e');

      // Revert the UI change if API update fails
      setState(() {
        record.status = oldStatus;
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
    // If payment exists and has an ID, fetch detailed information
    if (record.payment != null && record.payment!.id.isNotEmpty && record.payment!.id != 'temp') {
      _showPaymentDetailsById(record.payment!.id);
    } else {
      // Show basic payment details for unpaid records
      _showBasicPaymentDetails(record);
    }
  }

  // Future<void> _showPaymentDetailsById(String paymentId) async {
  //   // Show loading indicator
  //   showDialog(
  //     context: context,
  //     barrierDismissible: false,
  //     builder: (context) => const Center(
  //       child: CircularProgressIndicator(),
  //     ),
  //   );
  //
  //   try {
  //     final paymentService = Provider.of<PaymentServices>(context, listen: false);
  //     final paymentDetail = await paymentService.getPaymentById(paymentId);
  //
  //     if (!mounted) return;
  //
  //     // Close loading indicator
  //     Navigator.of(context).pop();
  //
  //     // Show detailed payment information
  //     showModalBottomSheet(
  //       context: context,
  //       isScrollControlled: true,
  //       backgroundColor: Colors.transparent,
  //       builder: (context) {
  //         return Container(
  //           height: MediaQuery.of(context).size.height * 0.8,
  //           decoration: BoxDecoration(
  //             color: Theme.of(context).colorScheme.surface,
  //             borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
  //           ),
  //           child: Column(
  //             children: [
  //               Container(
  //                 width: 40,
  //                 height: 4,
  //                 margin: const EdgeInsets.symmetric(vertical: 12),
  //                 decoration: BoxDecoration(
  //                   color: Theme.of(context).colorScheme.outline.withValues(alpha: 0.3),
  //                   borderRadius: BorderRadius.circular(2),
  //                 ),
  //               ),
  //               Expanded(
  //                 child: PaymentDetailSheet(paymentDetail: paymentDetail),
  //               ),
  //             ],
  //           ),
  //         );
  //       },
  //     );
  //   } catch (e) {
  //     if (!mounted) return;
  //
  //     // Close loading indicator
  //     Navigator.of(context).pop();
  //
  //     // Show error message
  //     ScaffoldMessenger.of(context).showSnackBar(
  //       SnackBar(
  //         content: Text('Error loading payment details: $e'),
  //         backgroundColor: Colors.red,
  //       ),
  //     );
  //   }
  // }

  void _showBasicPaymentDetails(PaymentRecord record) {
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

// Widget for displaying detailed payment information from API
class PaymentDetailSheet extends StatelessWidget {
  final PaymentDetail paymentDetail;

  const PaymentDetailSheet({
    super.key,
    required this.paymentDetail,
  });

  @override
  Widget build(BuildContext context) {
    final isPaid = paymentDetail.isCompleted;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Payment Details',
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
              ),
              IconButton(
                icon: const Icon(Icons.close),
                onPressed: () => Navigator.pop(context),
              ),
            ],
          ),
          const SizedBox(height: 24),

          // Status Badge
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: isPaid
                  ? Colors.green.withValues(alpha: 0.1)
                  : Colors.orange.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: isPaid ? Colors.green : Colors.orange,
                width: 1,
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  isPaid ? Icons.check_circle : Icons.pending,
                  color: isPaid ? Colors.green : Colors.orange,
                  size: 20,
                ),
                const SizedBox(width: 8),
                Text(
                  paymentDetail.paymentStatus,
                  style: TextStyle(
                    color: isPaid ? Colors.green : Colors.orange,
                    fontWeight: FontWeight.w600,
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),

          // Amount Card
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Theme.of(context).colorScheme.primary,
                  Theme.of(context).colorScheme.primary.withValues(alpha: 0.7),
                ],
              ),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Amount Paid',
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.9),
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  '₦${paymentDetail.amountAsDouble.toStringAsFixed(0).replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]},')}',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),

          // Payment Information
          _buildSectionTitle(context, 'Payment Information'),
          const SizedBox(height: 12),
          _buildDetailRow(
            context,
            'Reference Number',
            paymentDetail.referenceNumber,
            Icons.receipt_long,
          ),
          _buildDetailRow(
            context,
            'Payment Method',
            paymentDetail.paymentMethod,
            Icons.payment,
          ),
          _buildDetailRow(
            context,
            'Payment Date',
            _formatDateTime(paymentDetail.paymentDate),
            Icons.calendar_today,
          ),
          const SizedBox(height: 24),

          // Description
          if (paymentDetail.description.isNotEmpty) ...[
            _buildSectionTitle(context, 'Description'),
            const SizedBox(height: 12),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.surfaceContainerHighest,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                paymentDetail.description,
                style: TextStyle(
                  fontSize: 14,
                  color: Theme.of(context).colorScheme.onSurface,
                ),
              ),
            ),
            const SizedBox(height: 24),
          ],

          // Additional Information
          _buildSectionTitle(context, 'Additional Information'),
          const SizedBox(height: 12),
          _buildDetailRow(
            context,
            'Member ID',
            paymentDetail.memberId,
            Icons.person,
          ),
          _buildDetailRow(
            context,
            'Recorded By',
            paymentDetail.recordedById,
            Icons.person_outline,
          ),
          _buildDetailRow(
            context,
            'Created At',
            _formatDateTime(paymentDetail.createdAt),
            Icons.access_time,
          ),
          _buildDetailRow(
            context,
            'Updated At',
            _formatDateTime(paymentDetail.updatedAt),
            Icons.update,
          ),
          const SizedBox(height: 32),

          // Close Button
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () => Navigator.pop(context),
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: const Text(
                'Close',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(BuildContext context, String title) {
    return Text(
      title,
      style: Theme.of(context).textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold,
          ),
    );
  }

  Widget _buildDetailRow(
    BuildContext context,
    String label,
    String value,
    IconData icon,
  ) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.primaryContainer,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              icon,
              size: 20,
              color: Theme.of(context).colorScheme.primary,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 12,
                    color: Theme.of(context)
                        .colorScheme
                        .onSurface
                        .withValues(alpha: 0.6),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  value,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _formatDateTime(DateTime dateTime) {
    return '${dateTime.day}/${dateTime.month}/${dateTime.year} ${dateTime.hour.toString().padLeft(2, '0')}:${dateTime.minute.toString().padLeft(2, '0')}';
  }
}
