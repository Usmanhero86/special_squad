import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/member.dart';
import '../../services/member_service.dart';

class MemberDetailScreen extends StatefulWidget {
  final String memberId;

  const MemberDetailScreen({super.key, required this.memberId});

  @override
  _MemberDetailScreenState createState() => _MemberDetailScreenState();
}

class _MemberDetailScreenState extends State<MemberDetailScreen> {
  late Future<Member?> _memberFuture;

  @override
  void initState() {
    super.initState();
    _memberFuture = _loadMember();
  }

  Future<Member?> _loadMember() async {
    final memberService = Provider.of<MemberService>(context, listen: false);
    try {
      return await memberService.getMemberById(widget.memberId);
    } catch (e) {
      return null;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Member Details'),
        actions: [IconButton(icon: Icon(Icons.edit), onPressed: () {})],
      ),
      body: FutureBuilder<Member?>(
        future: _memberFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError || snapshot.data == null) {
            return Center(child: Text('Error loading member details'));
          }

          final member = snapshot.data!;

          return SingleChildScrollView(
            padding: EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: CircleAvatar(
                    radius: 60,
                    backgroundImage: member.profileImage != null
                        ? NetworkImage(member.profileImage!)
                        : null,
                    backgroundColor: Colors.blue.shade100,
                    child: member.profileImage == null
                        ? Icon(
                            Icons.person,
                            size: 60,
                            color: Colors.blue.shade800,
                          )
                        : null,
                  ),
                ),
                SizedBox(height: 24),
                _buildDetailItem('Full Name', member.fullName),
                _buildDetailItem('ID Number', member.idNumber),
                _buildDetailItem('Phone', member.phone),
                _buildDetailItem('Address', member.address),
                _buildDetailItem('Position', member.position),
                _buildDetailItem(
                  'Date of Birth',
                  '${member.dateOfBirth.day}/${member.dateOfBirth.month}/${member.dateOfBirth.year}',
                ),
                _buildDetailItem(
                  'Join Date',
                  '${member.joinDate.day}/${member.joinDate.month}/${member.joinDate.year}',
                ),
                _buildDetailItem(
                  'Status',
                  member.isActive ? 'Active' : 'Inactive',
                ),
                SizedBox(height: 20),
                if (member.additionalInfo != null)
                  ..._buildAdditionalInfo(member.additionalInfo!),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildDetailItem(String label, String value) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey.shade600,
              fontWeight: FontWeight.w500,
            ),
          ),
          SizedBox(height: 4),
          Text(
            value,
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
          ),
        ],
      ),
    );
  }

  List<Widget> _buildAdditionalInfo(Map<String, dynamic> info) {
    return [
      SizedBox(height: 16),
      Text(
        'Additional Information',
        style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
      ),
      ...info.entries.map(
        (entry) => _buildDetailItem(
          entry.key.replaceAll('_', ' ').toTitleCase(),
          entry.value.toString(),
        ),
      ),
    ];
  }
}

extension StringExtension on String {
  String toTitleCase() {
    return split(' ')
        .map((word) => word[0].toUpperCase() + word.substring(1).toLowerCase())
        .join(' ');
  }
}
