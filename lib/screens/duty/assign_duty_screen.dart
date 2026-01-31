import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/member.dart';
import '../../models/duty_post.dart';
import '../../models/duty_roster.dart';
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
  List<DutyPost> _posts = [];
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

  Future<void> _loadData() async {
    final memberService = Provider.of<MemberService>(context, listen: false);
    final dutyService = Provider.of<DutyService>(context, listen: false);

    try {
      final results = await Future.wait([
        memberService.getMembersSync(),
        dutyService.getDutyPosts(),
      ]);

      final allMembers = results[0] as List<Member>;
      final posts = results[1] as List<DutyPost>;

      // Filter members to only include those from HQ location
      final hqMembers = allMembers.where((member) {
        final location = member.location?.toLowerCase() ?? '';
        return location == 'hq' ||
            location == 'headquarters' ||
            location.contains('hq');
      }).toList();

      // Debug: Check for duplicate IDs
      final memberIds = hqMembers.map((m) => m.id).toList();
      final uniqueIds = memberIds.toSet();
      if (memberIds.length != uniqueIds.length) {
        print('Warning: Duplicate member IDs found in HQ members');
        // Remove duplicates by converting to Set and back to List
        final uniqueMembers = <Member>[];
        final seenIds = <String>{};
        for (final member in hqMembers) {
          if (!seenIds.contains(member.id)) {
            seenIds.add(member.id);
            uniqueMembers.add(member);
          }
        }
        hqMembers.clear();
        hqMembers.addAll(uniqueMembers);
      }

      if (mounted) {
        setState(() {
          _hqMembers = hqMembers;
          _posts = posts;
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
            content: Text('Error loading data: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Assign Duty')),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _hqMembers.isEmpty
          ? _buildNoHQMembersState()
          : Column(
              children: [
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        _buildInfoCard(),
                        const SizedBox(height: 20),
                        _buildDatePicker(),
                        const SizedBox(height: 20),
                        _buildShiftSelector(),
                        const SizedBox(height: 20),
                        _buildPostSelector(),
                        const SizedBox(height: 20),
                        _buildMemberSelector(),
                        const SizedBox(height: 20),
                        _buildNotesField(),
                        const SizedBox(height: 20),
                      ],
                    ),
                  ),
                ),
                // Fixed button at bottom
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.surface,
                    border: Border(
                      top: BorderSide(
                        color: Theme.of(
                          context,
                        ).colorScheme.outline.withOpacity(0.2),
                      ),
                    ),
                  ),
                  child: SafeArea(
                    child: SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: _canAssignDuty() ? _assignDuty : null,
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          backgroundColor: Theme.of(
                            context,
                          ).colorScheme.primary,
                          foregroundColor: Theme.of(
                            context,
                          ).colorScheme.onPrimary,
                          disabledBackgroundColor: Theme.of(
                            context,
                          ).colorScheme.outline.withOpacity(0.3),
                        ),
                        child: Text(
                          _getButtonText(),
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
    );
  }

  bool _canAssignDuty() {
    return _selectedMemberIds.isNotEmpty && _selectedPostId != null;
  }

  String _getButtonText() {
    if (_selectedMemberIds.isEmpty) {
      return 'Select Members to Assign';
    } else if (_selectedPostId == null) {
      return 'Select Duty Post';
    } else {
      return 'Assign Duty to ${_selectedMemberIds.length} Member(s)';
    }
  }

  Widget _buildNoHQMembersState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.location_off,
              size: 64,
              color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
            ),
            const SizedBox(height: 16),
            Text(
              'No HQ Members Available',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Theme.of(context).colorScheme.onSurface,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Only members from HQ location can be assigned duties. Please ensure members have "HQ" or "Headquarters" as their location.',
              style: TextStyle(
                fontSize: 16,
                color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: () => Navigator.pop(context),
              icon: const Icon(Icons.arrow_back),
              label: const Text('Go Back'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoCard() {
    return Card(
      color: Theme.of(context).colorScheme.primaryContainer.withOpacity(0.3),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.info_outline,
                  color: Theme.of(context).colorScheme.primary,
                ),
                const SizedBox(width: 8),
                Text(
                  'Duty Assignment Rules',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              '• Only members from HQ location can be assigned duties\n'
              '• Multiple members can be assigned to the same duty post\n'
              '• Each member will have their own duty record',
              style: TextStyle(
                fontSize: 14,
                color: Theme.of(context).colorScheme.onSurface.withOpacity(0.8),
              ),
            ),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.secondary.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                '${_hqMembers.length} HQ members available',
                style: TextStyle(
                  fontSize: 12,
                  color: Theme.of(context).colorScheme.secondary,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDatePicker() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Select Date',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
        ),
        const SizedBox(height: 8),
        GestureDetector(
          onTap: _pickDate,
          child: Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              border: Border.all(color: Theme.of(context).colorScheme.outline),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.calendar_today,
                  color: Theme.of(context).colorScheme.primary,
                ),
                const SizedBox(width: 12),
                Text(
                  '${_selectedDate.day}/${_selectedDate.month}/${_selectedDate.year}',
                  style: const TextStyle(fontSize: 16),
                ),
                const Spacer(),
                Icon(
                  Icons.arrow_drop_down,
                  color: Theme.of(
                    context,
                  ).colorScheme.onSurface.withOpacity(0.6),
                ),
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
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
        ),
        const SizedBox(height: 8),
        DropdownButtonFormField<String>(
          initialValue: _selectedShift,
          decoration: const InputDecoration(
            border: OutlineInputBorder(),
            contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 16),
          ),
          items: _shifts
              .map(
                (shift) => DropdownMenuItem(value: shift, child: Text(shift)),
              )
              .toList(),
          onChanged: (value) {
            setState(() {
              _selectedShift = value!;
            });
          },
        ),
      ],
    );
  }

  Widget _buildPostSelector() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Select Duty Post',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
        ),
        const SizedBox(height: 8),
        DropdownButtonFormField<String>(
          initialValue: _selectedPostId,
          decoration: const InputDecoration(
            border: OutlineInputBorder(),
            contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 16),
          ),
          hint: const Text('Select a duty post'),
          items: _posts
              .map(
                (post) => DropdownMenuItem(
                  value: post.id,
                  child: Text(
                    '${post.name} (${post.location ?? 'No location'})',
                  ),
                ),
              )
              .toList(),
          onChanged: (value) {
            setState(() {
              _selectedPostId = value;
            });
          },
        ),
      ],
    );
  }

  Widget _buildMemberSelector() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'Select Members (HQ Only)',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
            ),
            if (_selectedMemberIds.isNotEmpty)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.primary.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  '${_selectedMemberIds.length} selected',
                  style: TextStyle(
                    fontSize: 12,
                    color: Theme.of(context).colorScheme.primary,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
          ],
        ),
        const SizedBox(height: 8),

        // Selected members display
        if (_selectedMemberIds.isNotEmpty) ...[
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              border: Border.all(
                color: Theme.of(context).colorScheme.outline.withOpacity(0.3),
              ),
              borderRadius: BorderRadius.circular(8),
              color: Theme.of(
                context,
              ).colorScheme.surfaceContainerHighest.withOpacity(0.3),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Selected Members:',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: Theme.of(
                      context,
                    ).colorScheme.onSurface.withOpacity(0.8),
                  ),
                ),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: _selectedMemberIds.map((memberId) {
                    final member = _hqMembers.firstWhere(
                      (m) => m.id == memberId,
                    );
                    return Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: Theme.of(
                          context,
                        ).colorScheme.primary.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: Theme.of(
                            context,
                          ).colorScheme.primary.withOpacity(0.3),
                        ),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            member.fullName,
                            style: TextStyle(
                              fontSize: 12,
                              color: Theme.of(context).colorScheme.primary,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          const SizedBox(width: 4),
                          GestureDetector(
                            onTap: () {
                              setState(() {
                                _selectedMemberIds.remove(memberId);
                              });
                            },
                            child: Icon(
                              Icons.close,
                              size: 16,
                              color: Theme.of(context).colorScheme.primary,
                            ),
                          ),
                        ],
                      ),
                    );
                  }).toList(),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
        ],

        // Member selection dropdown
        DropdownButtonFormField<String>(
          key: ValueKey(
            'member_dropdown_${_selectedMemberIds.length}',
          ), // Force rebuild
          initialValue: null, // Always null to reset after selection
          decoration: const InputDecoration(
            border: OutlineInputBorder(),
            contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 16),
            hintText: 'Add a member to assignment',
            prefixIcon: Icon(Icons.person_add),
          ),
          items: _hqMembers
              .where((member) => !_selectedMemberIds.contains(member.id))
              .map(
                (member) => DropdownMenuItem(
                  value: member.id,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        member.fullName,
                        style: const TextStyle(fontWeight: FontWeight.w500),
                      ),
                      Text(
                        'ID: ${member.rifleNumber} • ${member.location ?? 'HQ'}',
                        style: TextStyle(
                          fontSize: 12,
                          color: Theme.of(
                            context,
                          ).colorScheme.onSurface.withOpacity(0.6),
                        ),
                      ),
                    ],
                  ),
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

        if (_hqMembers
                .where((member) => !_selectedMemberIds.contains(member.id))
                .isEmpty &&
            _selectedMemberIds.isNotEmpty)
          Padding(
            padding: const EdgeInsets.only(top: 8),
            child: Text(
              'All HQ members have been selected',
              style: TextStyle(
                fontSize: 12,
                color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
                fontStyle: FontStyle.italic,
              ),
            ),
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
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
        ),
        const SizedBox(height: 8),
        TextField(
          controller: _notesController,
          maxLines: 3,
          decoration: const InputDecoration(
            border: OutlineInputBorder(),
            hintText: 'Enter any special instructions...',
          ),
        ),
      ],
    );
  }

  Future<void> _pickDate() async {
    final pickedDate = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );
    if (pickedDate != null) {
      setState(() {
        _selectedDate = pickedDate;
      });
    }
  }

  Future<void> _assignDuty() async {
    if (_selectedMemberIds.isEmpty || _selectedPostId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please select both members and a duty post'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    final dutyService = Provider.of<DutyService>(context, listen: false);
    final notes = _notesController.text.trim();

    try {
      // Create duty roster entries for each selected member
      final duties = <DutyRoster>[];
      for (final memberId in _selectedMemberIds) {
        final duty = DutyRoster(
          id: '${DateTime.now().millisecondsSinceEpoch}_$memberId',
          memberId: memberId,
          dutyPostId: _selectedPostId!,
          date: _selectedDate,
          shift: _selectedShift,
          status: 'Scheduled',
          notes: notes.isNotEmpty ? notes : null,
        );
        duties.add(duty);
      }

      // Save all duties to database
      for (final duty in duties) {
        await dutyService.addDutyRoster(duty);
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Successfully assigned ${_selectedMemberIds.length} member(s) to duty',
            ),
            backgroundColor: Colors.green,
          ),
        );

        Navigator.pop(context, true); // Return true to indicate success
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error assigning duty: $e'),
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
