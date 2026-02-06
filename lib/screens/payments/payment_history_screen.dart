import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/payment.dart';
import '../../models/member.dart';
import '../../models/paymentListMembers.dart';
import '../../models/payment_detail.dart';
import '../../services/payment.dart';
import '../../widgets/theme_toggle_button.dart';

class PaymentHistoryScreen extends StatefulWidget {
  const PaymentHistoryScreen({super.key});

  @override
  PaymentHistoryScreenState createState() => PaymentHistoryScreenState();
}

class PaymentHistoryScreenState extends State<PaymentHistoryScreen>
    with WidgetsBindingObserver {
  List<PaymentHistoryRecord> _paymentHistory = [];
  List<PaymentHistoryRecord> _filteredHistory = [];
  final TextEditingController _searchController = TextEditingController();
  String? _selectedLocation;
  String _selectedStatus = 'All';
  DateTimeRange? _selectedDateRange;
  bool _isFetchingPayments = true;
  // =======================
// PAGED API STATE (ADD THIS)
// =======================
  int _pageFromApi = 1;
  int _limitFromApi = 10;

  bool _isLoading = true;
  double _totalAmountFromApi = 0;
  int _totalRecordsFromApi = 0;

  String? _selectedMonth;
// Raw payments from API
  List<Payments> _payments = [];
  bool _isFetchingHistory = true;
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
  final List<String> _statusOptions = [
    'All',
    'Paid',
    'Unpaid',
    'Completed',
    'Pending',
  ];

  List<Payments> _filteredPayments = [];
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
    WidgetsBinding.instance.addObserver(this);
    _selectedLocation = _locations.first;

    _loadPaymentRecords();   // ✅ REQUIRED
    _loadPaymentHistory();   // (optional for summary)

    _searchController.addListener(_filterHistory);
  }
  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _searchController.dispose();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      // Refresh data when app comes back to foreground
      _loadPaymentHistory();
    }
  }

  Future<void> _loadPaymentHistory() async {
    setState(() {
      _isFetchingHistory = true;
    });

    try {
      final historyRecords = <PaymentHistoryRecord>[];

      historyRecords.sort(
            (a, b) => b.payment.paymentDate.compareTo(a.payment.paymentDate),
      );

      if (!mounted) return;

      setState(() {
        _paymentHistory = historyRecords;
        _filteredHistory = historyRecords;
        _isFetchingHistory = false;
      });
    } catch (e) {
      if (!mounted) return;

      setState(() {
        _isFetchingHistory = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error loading payment history: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  void _filterHistory() {
    final query = _searchController.text.toLowerCase();
    setState(() {
      _filteredHistory = _paymentHistory.where((record) {
        final matchesSearch =
            record.member.fullName.toLowerCase().contains(query) ||
            record.payment.purpose.toLowerCase().contains(query) ||
            record.payment.paymentMethod.toLowerCase().contains(query);

        final matchesLocation =
            _selectedLocation == 'All Locations' ||
            record.member.location == _selectedLocation;

        final matchesStatus =
            _selectedStatus == 'All' ||
            record.payment.status.toLowerCase() ==
                _selectedStatus.toLowerCase() ||
            (_selectedStatus == 'Paid' &&
                (record.payment.status.toLowerCase() == 'completed' ||
                    record.payment.status.toLowerCase() == 'paid')) ||
            (_selectedStatus == 'Unpaid' &&
                (record.payment.status.toLowerCase() == 'pending' ||
                    record.payment.status.toLowerCase() == 'unpaid'));

        final matchesDateRange =
            _selectedDateRange == null ||
            (record.payment.paymentDate.isAfter(
                  _selectedDateRange!.start.subtract(const Duration(days: 1)),
                ) &&
                record.payment.paymentDate.isBefore(
                  _selectedDateRange!.end.add(const Duration(days: 1)),
                ));

        return matchesSearch &&
            matchesLocation &&
            matchesStatus &&
            matchesDateRange;
      }).toList();
    });
  }

  double get _totalAmount {
    return _filteredHistory
        .where(
          (record) =>
              record.payment.status.toLowerCase() == 'completed' ||
              record.payment.status.toLowerCase() == 'paid',
        )
        .fold(0.0, (sum, record) => sum + record.payment.amount);
  }

  Map<String, List<PaymentHistoryRecord>> get _groupedByLocation {
    final grouped = <String, List<PaymentHistoryRecord>>{};
    for (final record in _filteredHistory) {
      final location = record.member.location ?? 'Unknown';
      grouped.putIfAbsent(location, () => []).add(record);
    }
    return grouped;
  }

  Future<void> _loadPaymentRecords() async {
    final paymentService =
    Provider.of<PaymentServices>(context, listen: false);

    setState(() {
      _isFetchingPayments = true;
    });

    try {
      final response = await paymentService.getPayments(
        page: _pageFromApi,
        limit: _limitFromApi,
      );

      if (!mounted) return;

      setState(() {
        _payments = response.payments;
        _filteredPayments = response.payments;

        _totalAmountFromApi = response.totalAmount;
        _totalRecordsFromApi = response.total;
        _pageFromApi = response.page;
        _limitFromApi = response.limit;

        _isFetchingPayments = false;
      });
    } catch (e) {
      if (!mounted) return;

      setState(() {
        _isFetchingPayments = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.toString())),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      appBar: AppBar(
        title: const Text(
          'Payment History',
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.w600),
        ),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [
          const ThemeToggleButton(),
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadPaymentHistory,
            tooltip: 'Refresh',
          ),
        ],
      ),
      body: Column(
        children: [
          // Filters Section
          _buildFiltersSection(),

          // Summary Card
          _buildSummaryCard(),
          // Payment Records List
          Expanded(
            child: _isFetchingPayments
                ? const Center(
              child: CircularProgressIndicator(),
            )
                : _filteredPayments.isEmpty
                ? _buildEmptyState()
                : ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              itemCount: _filteredPayments.length,
              itemBuilder: (context, index) {
                final record = _filteredPayments[index];
                return _buildPaymentRecordTile(record);
              },
            ),
          ),
        ],
      ),
    );
  }
  Widget _buildPaymentRecordTile(Payments record) {
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
            const SizedBox(width: 12),
          ],
        ),
        title: Text(
          record.memberName,
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
              onSelected: (value) {
                if (value == 'view') {
                  _showPaymentDetailsById(record.id);
                }
              },
            ),
          ],
        ),
        onTap: () => _showPaymentDetailsById(record.id),
      ),
    );
  }

  Widget _buildFiltersSection() {
    return Container(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          // Search Bar
          TextField(
            controller: _searchController,
            decoration: InputDecoration(
              hintText: 'Search payments...',
              prefixIcon: Icon(
                Icons.search,
                color: Theme.of(
                  context,
                ).colorScheme.onSurface.withValues(alpha: 0.6),
              ),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 12,
              ),
            ),
          ),
          const SizedBox(height: 16),

          // Filter Row
          Row(
            children: [
              Expanded(
                child: Container(
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
              ),
            ],
          ),

          // Date Range Display
          if (_selectedDateRange != null)
            Container(
              margin: const EdgeInsets.only(top: 8),
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: Theme.of(
                  context,
                ).colorScheme.primary.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    '${_formatDate(_selectedDateRange!.start)} - ${_formatDate(_selectedDateRange!.end)}',
                    style: TextStyle(
                      fontSize: 12,
                      color: Theme.of(context).colorScheme.primary,
                    ),
                  ),
                  const SizedBox(width: 8),
                  GestureDetector(
                    onTap: () {
                      setState(() {
                        _selectedDateRange = null;
                      });
                      _filterHistory();
                    },
                    child: Icon(
                      Icons.close,
                      size: 16,
                      color: Theme.of(context).colorScheme.primary,
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildSummaryCard() {
    final paidCount = _filteredHistory
        .where(
          (record) =>
              record.payment.status.toLowerCase() == 'completed' ||
              record.payment.status.toLowerCase() == 'paid',
        )
        .length;
    final unpaidCount = _filteredHistory.length - paidCount;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.primaryContainer,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          Text(
            'Payment Summary',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: Theme.of(context).colorScheme.onPrimaryContainer,
            ),
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildSummaryItem(
                'Total Amount',
                '₦${_totalAmountFromApi.toStringAsFixed(0).replaceAllMapped(
                  RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
                      (m) => '${m[1]},',
                )}',
                Colors.green,
              ),

              _buildSummaryItem(
                'Total Records',
                '$_totalRecordsFromApi',
                Colors.blue,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryItem(String label, String value, Color color) {
    return Column(
      children: [
        Text(
          value,
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: Theme.of(
              context,
            ).colorScheme.onPrimaryContainer.withValues(alpha: 0.7),
          ),
        ),
      ],
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.history,
            size: 64,
            color: Theme.of(
              context,
            ).colorScheme.onSurface.withValues(alpha: 0.6),
          ),
          const SizedBox(height: 16),
          Text(
            'No Payment History',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: Theme.of(context).colorScheme.onSurface,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Payment history will appear here once payments are recorded',
            style: TextStyle(
              fontSize: 14,
              color: Theme.of(
                context,
              ).colorScheme.onSurface.withValues(alpha: 0.6),
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildHistoryList() {
    if (_selectedLocation == 'All Locations') {
      // Group by location when showing all locations
      final grouped = _groupedByLocation;
      return ListView.builder(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: grouped.length,
        itemBuilder: (context, index) {
          final location = grouped.keys.elementAt(index);
          final records = grouped[location]!;
          return _buildLocationGroup(location, records);
        },
      );
    } else {
      // Show flat list for specific location
      return ListView.builder(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: _filteredHistory.length,
        itemBuilder: (context, index) {
          final record = _filteredHistory[index];
          return _buildPaymentHistoryTile(record);
        },
      );
    }
  }

  Widget _buildLocationGroup(
    String location,
    List<PaymentHistoryRecord> records,
  ) {
    final locationTotal = records
        .where(
          (record) =>
              record.payment.status.toLowerCase() == 'completed' ||
              record.payment.status.toLowerCase() == 'paid',
        )
        .fold(0.0, (sum, record) => sum + record.payment.amount);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          margin: const EdgeInsets.symmetric(vertical: 8),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.secondaryContainer,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                location,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Theme.of(context).colorScheme.onSecondaryContainer,
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    '₦${locationTotal.toStringAsFixed(0).replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]},')}',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: Colors.green,
                    ),
                  ),
                  Text(
                    '${records.length} payment(s)',
                    style: TextStyle(
                      fontSize: 12,
                      color: Theme.of(
                        context,
                      ).colorScheme.onSecondaryContainer.withValues(alpha: 0.7),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        ...records.map((record) => _buildPaymentHistoryTile(record)),
        const SizedBox(height: 16),
      ],
    );
  }

  Widget _buildPaymentHistoryTile(PaymentHistoryRecord record) {
    final isPaid =
        record.payment.status.toLowerCase() == 'completed' ||
        record.payment.status.toLowerCase() == 'paid';

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        leading: CircleAvatar(
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
        title: Text(
          record.member.fullName,
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '${record.payment.purpose} • ${record.payment.paymentMethod}',
              style: TextStyle(
                fontSize: 14,
                color: Theme.of(
                  context,
                ).colorScheme.onSurface.withValues(alpha: 0.7),
              ),
            ),
            Text(
              _formatDate(record.payment.paymentDate),
              style: TextStyle(
                fontSize: 12,
                color: Theme.of(
                  context,
                ).colorScheme.onSurface.withValues(alpha: 0.6),
              ),
            ),
            if (record.member.location != null)
              Text(
                record.member.location!,
                style: TextStyle(
                  fontSize: 12,
                  color: Theme.of(context).colorScheme.primary,
                  fontWeight: FontWeight.w500,
                ),
              ),
          ],
        ),
        trailing: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(
              '₦${record.payment.amount.toStringAsFixed(0).replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]},')}',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: isPaid ? Colors.green : Colors.red,
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
              decoration: BoxDecoration(
                color: isPaid
                    ? Colors.green.withValues(alpha: 0.1)
                    : Colors.red.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                isPaid ? 'Paid' : 'Unpaid',
                style: TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.w500,
                  color: isPaid ? Colors.green : Colors.red,
                ),
              ),
            ),
          ],
        ),
        onTap: () => _showPaymentDetails(record.payment),
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
      _filterHistory();
    }
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }

  void _showPaymentDetails(Payment payment) {
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
          child: PaymentDetailsSheetFromHistory(payment: payment),
        );
      },
    );
  }

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

}

// Helper class to combine payment and member data for history
class PaymentHistoryRecord {
  final Payment payment;
  final Member member;

  PaymentHistoryRecord({required this.payment, required this.member});
}
class PaymentDetailsSheetHistory extends StatelessWidget {
  final Payments payment;

  const PaymentDetailsSheetHistory({
    super.key,
    required this.payment,
  });

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _header(context),
          const SizedBox(height: 16),
          _detailRow('Amount', '₦${payment.amount}'),
          _detailRow('Status', payment.status),
          _detailRow('Method', payment.method),
          _detailRow('Reference', payment.memberName),
          const SizedBox(height: 24),
          _actions(context),
        ],
      ),
    );
  }

  Widget _header(BuildContext context) {
    return Text(
      'Payment Details',
      style: Theme.of(context)
          .textTheme
          .titleLarge
          ?.copyWith(fontWeight: FontWeight.bold),
    );
  }

  Widget _detailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(fontWeight: FontWeight.w500)),
          Text(value),
        ],
      ),
    );
  }

  Widget _actions(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: () => Navigator.pop(context),
        child: const Text('Close'),
      ),
    );
  }
}
class PaymentDetailsSheetFromHistory extends StatelessWidget {
  final Payment payment;

  const PaymentDetailsSheetFromHistory({
    super.key,
    required this.payment,
  });

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Payment Details',
            style: Theme.of(context)
                .textTheme
                .titleLarge
                ?.copyWith(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),
          _row('Amount', '₦${payment.amount}'),
          _row('Status', payment.status),
          _row('Purpose', payment.purpose),
          _row('Method', payment.paymentMethod),
          _row('Date', payment.paymentDate.toString()),
          const SizedBox(height: 24),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Close'),
            ),
          ),
        ],
      ),
    );
  }

  Widget _row(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(fontWeight: FontWeight.w500)),
          Text(value),
        ],
      ),
    );
  }
}

// New widget for detailed payment information from API
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