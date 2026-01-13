import 'package:flutter/material.dart';
import '../../models/member.dart';
import '../../models/duty_post.dart';
import '../../models/duty_roster.dart';

class AssignDutyScreen extends StatefulWidget {
  final String? dutyPostId;

  const AssignDutyScreen({super.key, this.dutyPostId});

  @override
  _AssignDutyScreenState createState() => _AssignDutyScreenState();
}

class _AssignDutyScreenState extends State<AssignDutyScreen> {
  DateTime _selectedDate = DateTime.now();
  String _selectedShift = 'Morning';
  String? _selectedMemberId;
  String? _selectedPostId;
  List<Member> _members = [];
  List<DutyPost> _posts = [];

  final List<String> _shifts = ['Morning', 'Afternoon', 'Evening'];

  @override
  void initState() {
    super.initState();
    _selectedPostId = widget.dutyPostId;
    // Load members and posts from service
    _loadData();
  }

  void _loadData() {
    // Load members and posts from services
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
      _posts = [
        DutyPost(
          id: '1',
          name: 'Security Guard',
          description: 'Main gate security',
          location: 'Main Gate',
        ),
        DutyPost(
          id: '2',
          name: 'Receptionist',
          description: 'Front desk',
          location: 'Lobby',
        ),
      ];
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Assign Duty')),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _buildDatePicker(),
            SizedBox(height: 20),
            _buildShiftSelector(),
            SizedBox(height: 20),
            _buildPostSelector(),
            SizedBox(height: 20),
            _buildMemberSelector(),
            SizedBox(height: 20),
            _buildNotesField(),
            SizedBox(height: 30),
            ElevatedButton(
              onPressed: _assignDuty,
              style: ElevatedButton.styleFrom(
                padding: EdgeInsets.symmetric(vertical: 16),
              ),
              child: Text('Assign Duty'),
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
        Text(
          'Select Date',
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
                Spacer(),
                Icon(Icons.arrow_drop_down, color: Colors.grey),
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
        Text(
          'Select Shift',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
        ),
        SizedBox(height: 8),
        DropdownButtonFormField<String>(
          initialValue: _selectedShift,
          decoration: InputDecoration(
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
        Text(
          'Select Duty Post',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
        ),
        SizedBox(height: 8),
        DropdownButtonFormField<String>(
          initialValue: _selectedPostId,
          decoration: InputDecoration(
            border: OutlineInputBorder(),
            contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 16),
          ),
          hint: Text('Select a duty post'),
          items: _posts
              .map(
                (post) => DropdownMenuItem(
                  value: post.id,
                  child: Text('${post.name} (${post.location})'),
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
        Text(
          'Select Member',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
        ),
        SizedBox(height: 8),
        DropdownButtonFormField<String>(
          initialValue: _selectedMemberId,
          decoration: InputDecoration(
            border: OutlineInputBorder(),
            contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 16),
          ),
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

  Widget _buildNotesField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Notes (Optional)',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
        ),
        SizedBox(height: 8),
        TextField(
          maxLines: 3,
          decoration: InputDecoration(
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
      lastDate: DateTime.now().add(Duration(days: 365)),
    );
    if (pickedDate != null) {
      setState(() {
        _selectedDate = pickedDate;
      });
    }
  }

  void _assignDuty() {
    if (_selectedMemberId == null || _selectedPostId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Please select both a member and a duty post'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    // Create duty roster entry
    final duty = DutyRoster(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      memberId: _selectedMemberId!,
      dutyPostId: _selectedPostId!,
      date: _selectedDate,
      shift: _selectedShift,
      status: 'Scheduled',
    );

    // Save to database (implement this)
    print('Duty assigned: $duty');

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Duty assigned successfully'),
        backgroundColor: Colors.green,
      ),
    );

    Navigator.pop(context);
  }
}
