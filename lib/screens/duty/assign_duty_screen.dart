import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../models/member.dart';
import '../../models/duty_post.dart';
import '../../services/duty_service.dart';
import '../../services/member_service.dart';

class AssignDutyScreen extends StatefulWidget {
  final String? dutyPostId;
  final String? preSelectedMemberId;

  const AssignDutyScreen({
    super.key,
    this.dutyPostId,
    this.preSelectedMemberId,
  });

  @override
  State<AssignDutyScreen> createState() => _AssignDutyScreenState();
}

class _AssignDutyScreenState extends State<AssignDutyScreen> {
  DateTime _selectedDate = DateTime.now();
  String _selectedShift = 'Morning';
  List<String> _selectedMemberIds = [];
  String? _selectedPostId;

  List<Member> _hqMembers = [];

  final TextEditingController _notesController = TextEditingController();
  bool _isLoading = true;

  final List<String> _shifts = ['Morning', 'Afternoon', 'Evening', 'Night'];

  @override
  void initState() {
    super.initState();

    _selectedPostId = widget.dutyPostId;

    if (widget.preSelectedMemberId != null) {
      _selectedMemberIds = [widget.preSelectedMemberId!];
    }

    _loadData();
  }

  // ===============================
  // LOAD MEMBERS AND POSTS (MAIN FIX)
  // ===============================
  Future<void> _loadData() async {
    final memberService = Provider.of<MemberService>(context, listen: false);
    final dutyService = Provider.of<DutyService>(context, listen: false);

    try {
      debugPrint('🟡 LOAD DUTY ASSIGNMENT DATA');

      // 1️⃣ FETCH DUTY MEMBERS
      final dutyMembers = await memberService.getDutyMembers();
      debugPrint('✅ DUTY MEMBERS FETCHED: ${dutyMembers.length}');

      // 2️⃣ FETCH DUTY POSTS — DATE IS REQUIRED ✅
      final List<DutyPost> posts = await dutyService.getDutyPosts(
        page: 1,
        limit: 100,
        date: _selectedDate, // ✅ REQUIRED FIX
      );

      debugPrint('✅ DUTY POSTS FETCHED: ${posts.length}');

      // 3️⃣ FILTER HQ MEMBERS
      final hqMembers = dutyMembers.where((m) {
        final location = m.location?.toLowerCase() ?? '';
        return location.contains('hq');
      }).toList();

      if (!mounted) return;

      setState(() {
        _hqMembers = hqMembers
            .map(
              (m) => Member(
                id: m.id,
                fullName: m.fullName,
                rifleNumber: m.rifleNo,
                phone: '',
                dateOfBirth: DateTime.now(),
                address: '',
                position: m.position,
                joinDate: DateTime.now(),
                isActive: m.isActive,
                location: m.location,
              ),
            )
            .toList();

        _isLoading = false;
      });
    } catch (e, s) {
      debugPrint('❌ LOAD DUTY DATA ERROR: $e');
      debugPrint(s.toString());

      if (mounted) {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to load duty data: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  // ===============================
  // UI
  // ===============================
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      appBar: AppBar(
        title: const Text('Assign Duty'),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _hqMembers.isEmpty
          ? _buildNoHQMembersState()
          : _buildContent(),
    );
  }

  Widget _buildContent() {
    return Column(
      children: [
        Expanded(
          child: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              // _buildDutyPostSelector(),
              // const SizedBox(height: 16),
              _buildDateSelector(),
              const SizedBox(height: 16),
              _buildShiftSelector(),
              const SizedBox(height: 16),
              _buildMemberSelector(),
              const SizedBox(height: 16),
              _buildSelectedMembers(),
              const SizedBox(height: 16),
              _buildNotesField(),
            ],
          ),
        ),
        _buildAssignButton(),
      ],
    );
  }

  Widget _buildNoHQMembersState() {
    return Center(
      child: Text(
        'No HQ Members Available',
        style: Theme.of(context).textTheme.titleLarge,
      ),
    );
  }

  Widget _buildMemberSelector() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Select Members (HQ Only)',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 12),
        DropdownButtonFormField<String>(
          isExpanded: true,
          hint: const Text('Select member'),
          items: _hqMembers
              .map(
                (member) => DropdownMenuItem(
                  value: member.id,
                  child: Text(member.fullName),
                ),
              )
              .toList(),
          onChanged: (value) {
            if (value != null && !_selectedMemberIds.contains(value)) {
              setState(() {
                _selectedMemberIds.add(value);
              });
            }
          },
        ),
      ],
    );
  }

  Widget _buildDateSelector() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Select Date',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 12),
        InkWell(
          onTap: () async {
            final date = await showDatePicker(
              context: context,
              initialDate: _selectedDate,
              firstDate: DateTime.now(),
              lastDate: DateTime.now().add(const Duration(days: 365)),
            );
            if (date != null) {
              setState(() {
                _selectedDate = date;
              });
            }
          },
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              border: Border.all(color: Colors.grey),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  '${_selectedDate.day}/${_selectedDate.month}/${_selectedDate.year}',
                ),
                const Icon(Icons.calendar_today),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildShiftSelector() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Select Shift',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 12),
        DropdownButtonFormField<String>(
          initialValue: _selectedShift,
          isExpanded: true,
          items: _shifts
              .map(
                (shift) => DropdownMenuItem(value: shift, child: Text(shift)),
              )
              .toList(),
          onChanged: (value) {
            if (value != null) {
              setState(() {
                _selectedShift = value;
              });
            }
          },
        ),
      ],
    );
  }

  Widget _buildSelectedMembers() {
    if (_selectedMemberIds.isEmpty) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Selected Members',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 12),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: _selectedMemberIds.map((id) {
            final member = _hqMembers.firstWhere((m) => m.id == id);
            return Chip(
              label: Text(member.fullName),
              onDeleted: () {
                setState(() {
                  _selectedMemberIds.remove(id);
                });
              },
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildNotesField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Notes (Optional)',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 12),
        TextField(
          controller: _notesController,
          maxLines: 3,
          decoration: const InputDecoration(
            hintText: 'Enter any additional notes...',
            border: OutlineInputBorder(),
          ),
        ),
      ],
    );
  }

  Widget _buildAssignButton() {
    return Container(
      padding: const EdgeInsets.all(16),
      child: SizedBox(
        width: double.infinity,
        child: ElevatedButton(
          onPressed: _canAssignDuty() ? _assignDuty : null,
          style: ElevatedButton.styleFrom(
            padding: const EdgeInsets.symmetric(vertical: 16),
          ),
          child: const Text('Assign Duty'),
        ),
      ),
    );
  }

  bool _canAssignDuty() {
    return _selectedMemberIds.isNotEmpty && _selectedPostId != null;
  }

  Future<void> _assignDuty() async {
    if (!_canAssignDuty()) return;

    debugPrint('🟡 ASSIGN DUTY CLICKED');

    try {
      final dutyService = Provider.of<DutyService>(context, listen: false);

      final success = await dutyService.assignDuty(
        postId: _selectedPostId!,
        memberIds: _selectedMemberIds,
        date: _selectedDate,
        shift: _selectedShift,
        notes: _notesController.text.trim().isEmpty
            ? null
            : _notesController.text.trim(),
      );

      if (success && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Duty assigned successfully!'),
            backgroundColor: Colors.green,
          ),
        );
        Navigator.pop(context, true);
      }
    } catch (e) {
      debugPrint('❌ ASSIGN DUTY ERROR: $e');

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to assign duty: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  void dispose() {
    _notesController.dispose();
    super.dispose();
  }
}
