import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/payment.dart';
import '../../models/member.dart';
import '../../services/payment_service.dart';
import '../../services/member_service.dart';
import '../../widgets/theme_toggle_button.dart';
import 'payment_details_sheet.dart';

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
  bool _isLoading = true;
  String? _selectedLocation;
  String _selectedStatus = 'All';
  DateTimeRange? _selectedDateRange;
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

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _selectedLocation = _locations.first;
    _loadPaymentHistory();
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
    final paymentService = Provider.of<PaymentService>(context, listen: false);
    final memberService = Provider.of<MemberService>(context, listen: false);

    try {
      setState(() {
        _isLoading = true;
      });

      // Load all payments and members
      final payments = await paymentService.getPaymentsSync();
      final members = await memberService.getMembersSync();

      // Create a map for quick member lookup
      final memberMap = {for (var member in members) member.id: member};

      // Create payment history records
      final historyRecords = <PaymentHistoryRecord>[];

      for (final payment in payments) {
        final member = memberMap[payment.memberId];
        if (member != null) {
          historyRecords.add(
            PaymentHistoryRecord(payment: payment, member: member),
          );
        }
      }

      // Sort by payment date (most recent first)
      historyRecords.sort(
        (a, b) => b.payment.paymentDate.compareTo(a.payment.paymentDate),
      );

      if (mounted) {
        setState(() {
          _paymentHistory = historyRecords;
          _filteredHistory = historyRecords;
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
            content: Text('Error loading payment history: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
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

          // Payment History List
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _filteredHistory.isEmpty
                ? _buildEmptyState()
                : _buildHistoryList(),
          ),
        ],
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
              // Location Filter
              Expanded(
                flex: 2,
                child: DropdownButtonFormField<String>(
                  initialValue: _selectedLocation,
                  decoration: InputDecoration(
                    labelText: 'Location',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 8,
                    ),
                  ),
                  isExpanded: true,
                  items: _locations
                      .map(
                        (location) => DropdownMenuItem(
                          value: location,
                          child: Text(
                            location,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(fontSize: 12),
                          ),
                        ),
                      )
                      .toList(),
                  onChanged: (value) {
                    setState(() {
                      _selectedLocation = value;
                    });
                    _filterHistory();
                  },
                ),
              ),
              const SizedBox(width: 8),

              // Status Filter
              Expanded(
                flex: 1,
                child: DropdownButtonFormField<String>(
                  initialValue: _selectedStatus,
                  decoration: InputDecoration(
                    labelText: 'Status',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 8,
                    ),
                  ),
                  isExpanded: true,
                  items: _statusOptions
                      .map(
                        (status) => DropdownMenuItem(
                          value: status,
                          child: Text(
                            status,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(fontSize: 12),
                          ),
                        ),
                      )
                      .toList(),
                  onChanged: (value) {
                    setState(() {
                      _selectedStatus = value!;
                    });
                    _filterHistory();
                  },
                ),
              ),
              const SizedBox(width: 8),

              // Date Range Filter
              Container(
                decoration: BoxDecoration(
                  border: Border.all(
                    color: Theme.of(
                      context,
                    ).colorScheme.outline.withValues(alpha: 0.5),
                  ),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: IconButton(
                  icon: Icon(
                    Icons.date_range,
                    size: 20,
                    color: _selectedDateRange != null
                        ? Theme.of(context).colorScheme.primary
                        : Theme.of(
                            context,
                          ).colorScheme.onSurface.withValues(alpha: 0.6),
                  ),
                  onPressed: _pickDateRange,
                  tooltip: 'Date Range',
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
                '₦${_totalAmount.toStringAsFixed(0).replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]},')}',
                Colors.green,
              ),
              _buildSummaryItem('Paid', '$paidCount', Colors.green),
              _buildSummaryItem('Unpaid', '$unpaidCount', Colors.red),
              _buildSummaryItem(
                'Total Records',
                '${_filteredHistory.length}',
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
        onTap: () => _showPaymentDetails(record),
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

  void _showPaymentDetails(PaymentHistoryRecord record) {
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
                payment: record.payment,
                parentContext: context,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// Helper class to combine payment and member data for history
class PaymentHistoryRecord {
  final Payment payment;
  final Member member;

  PaymentHistoryRecord({required this.payment, required this.member});
}
