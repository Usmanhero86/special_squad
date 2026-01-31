import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/member.dart';
import '../../services/member_service.dart';
import '../../widgets/member_card.dart';
import 'add_member_screen.dart';
import 'edit_member_screen.dart';
import 'member_detail_screen.dart';

class MemberListScreen extends StatefulWidget {
  const MemberListScreen({super.key});

  @override
  State<MemberListScreen> createState() => _MemberListScreenState();
}

class _MemberListScreenState extends State<MemberListScreen> {
  final TextEditingController _searchController = TextEditingController();
  List<Member> _filteredMembers = [];

  @override
  void initState() {
    super.initState();
    _searchController.addListener(_onSearchChanged);
  }

  void _onSearchChanged() {
    final query = _searchController.text.toLowerCase();
    if (query.isEmpty) {
      setState(() => _filteredMembers = []);
      return;
    }
    setState(() {});
  }

  List<Member> _applySearch(List<Member> members) {
    final query = _searchController.text.toLowerCase();
    if (query.isEmpty) return members;
    return members.where((m) {
      final name = m.fullName.toLowerCase();
      final position = m.position.toLowerCase();
      final rifleNo = m.rifleNumber.toLowerCase(); // Updated to rifleNumber
      return name.contains(query) || position.contains(query) || rifleNo.contains(query);
    }).toList();
  }

  Future<void> _deleteMember(BuildContext context, Member member) async {
    final memberService = Provider.of<MemberService>(context, listen: false);

    bool? confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Delete Member'),
        content: Text(
          'Are you sure you want to delete ${member.fullName} (Rifle No: ${member.rifleNumber})? This action cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
            ),
            child: Text('Delete'),
          ),
        ],
      ),
    );

    if (confirm == true) {
      try {
        await memberService.deleteMember(member.id);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Member deleted successfully'),
            backgroundColor: Colors.green,
          ),
        );
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error deleting member: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final memberService = Provider.of<MemberService>(context);

    return Scaffold(
      appBar: AppBar(
        title: Text('Members'),
        actions: [
          IconButton(
            icon: Icon(Icons.add),
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => AddMemberScreen()),
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          // Search Bar
          Padding(
            padding: EdgeInsets.all(12),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Search by name, position, or rifle number...',
                prefixIcon: Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                filled: true,
                fillColor: Colors.grey.shade50,
              ),
            ),
          ),

          // Statistics Bar
          Container(
            padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            color: Colors.blue.shade50,
            child: StreamBuilder<List<Member>>(
              stream: memberService.getMembers(),
              builder: (context, snapshot) {
                final total = snapshot.data?.length ?? 0;
                final active = snapshot.data?.where((m) => m.isActive).length ?? 0;

                return Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    _buildStatItem('Total', total.toString(), Icons.group),
                    _buildStatItem('Active', active.toString(), Icons.check_circle),
                    _buildStatItem('Inactive', (total - active).toString(), Icons.remove_circle),
                  ],
                );
              },
            ),
          ),

          // Members List
          Expanded(
            child: StreamBuilder<List<Member>>(
              stream: memberService.getMembers(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Center(child: CircularProgressIndicator());
                }

                if (snapshot.hasError) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.error, size: 64, color: Colors.red),
                        SizedBox(height: 16),
                        Text('Error loading members', style: TextStyle(fontSize: 18, color: Colors.red)),
                        SizedBox(height: 8),
                        Text('${snapshot.error}', style: TextStyle(color: Colors.grey), textAlign: TextAlign.center),
                        SizedBox(height: 16),
                        ElevatedButton(
                          onPressed: () => setState(() {}),
                          child: Text('Retry'),
                        ),
                      ],
                    ),
                  );
                }

                final members = snapshot.data ?? [];
                final displayMembers = _applySearch(members);

                if (displayMembers.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.group, size: 64, color: Colors.grey),
                        SizedBox(height: 16),
                        Text(
                          _searchController.text.isNotEmpty ? 'No members found' : 'No members yet',
                          style: TextStyle(fontSize: 18, color: Colors.grey),
                        ),
                        SizedBox(height: 8),
                        if (_searchController.text.isEmpty)
                          ElevatedButton.icon(
                            onPressed: () => Navigator.push(
                              context,
                              MaterialPageRoute(builder: (context) => AddMemberScreen()),
                            ),
                            icon: Icon(Icons.add),
                            label: Text('Add First Member'),
                          ),
                      ],
                    ),
                  );
                }

                return RefreshIndicator(
                  onRefresh: () async {
                    setState(() {});
                  },
                  child: ListView.builder(
                    itemCount: displayMembers.length,
                    itemBuilder: (context, index) {
                      final member = displayMembers[index];
                      return MemberCard(
                        member: member,
                        onTap: () => Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => MemberDetailScreen(memberId: member.id),
                          ),
                        ),
                        onEdit: () => _editMember(context, member),
                        onDelete: () => _deleteMember(context, member),
                      );
                    },
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatItem(String label, String value, IconData icon) {
    return Column(
      children: [
        Icon(icon, color: Colors.blue.shade700, size: 24),
        SizedBox(height: 4),
        Text(
          value,
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Colors.blue.shade900,
          ),
        ),
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: Colors.grey.shade600,
          ),
        ),
      ],
    );
  }

  void _editMember(BuildContext context, Member member) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => EditMemberScreen(member: member),
      ),
    );
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }
}