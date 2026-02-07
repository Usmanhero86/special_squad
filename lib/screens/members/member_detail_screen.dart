import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:special_squad/services/member_service.dart';
import '../../models/membersDetails.dart';

class MemberDetailScreen extends StatefulWidget {
  final String memberId;

  const MemberDetailScreen({super.key, required this.memberId});

  @override
  State<MemberDetailScreen> createState() => _MemberDetailScreenState();
}

class _MemberDetailScreenState extends State<MemberDetailScreen> {
  late Future<MemberDetail> _memberFuture;

  @override
  void initState() {
    super.initState();
    _memberFuture = context.read<MemberService>().getMemberById(
      widget.memberId,
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(title: const Text('Member Details')),
      body: FutureBuilder<MemberDetail>(
        future: _memberFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(child: Text(snapshot.error.toString()));
          }

          final member = snapshot.data!;

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                /// ===============================
                /// PROFILE HEADER
                /// ===============================
                Card(
                  elevation: 2,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      children: [
                        GestureDetector(
                          onTap: member.photo != null
                              ? () {
                                  showDialog(
                                    context: context,
                                    builder: (_) => Dialog(
                                      backgroundColor: Colors.transparent,
                                      child: InteractiveViewer(
                                        child: ClipRRect(
                                          borderRadius: BorderRadius.circular(
                                            12,
                                          ),
                                          child: Image.network(
                                            member.photo!,
                                            fit: BoxFit.contain,
                                          ),
                                        ),
                                      ),
                                    ),
                                  );
                                }
                              : null,
                          child: Container(
                            width: 280,
                            height: 190,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(12),
                              color: theme.colorScheme.primaryContainer,
                              image: member.photo != null
                                  ? DecorationImage(
                                      image: NetworkImage(member.photo!),
                                      fit: BoxFit.cover,
                                    )
                                  : null,
                            ),
                            child: member.photo == null
                                ? Icon(
                                    Icons.person,
                                    size: 64,
                                    color: theme.colorScheme.primary,
                                  )
                                : null,
                          ),
                        ),
                        const SizedBox(height: 16),

                        Text(
                          member.fullName,
                          style: theme.textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),

                        const SizedBox(height: 8),

                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 6,
                          ),
                          decoration: BoxDecoration(
                            color: member.isActive
                                ? Colors.green.withOpacity(0.1)
                                : Colors.red.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(
                            member.isActive ? 'ACTIVE' : 'INACTIVE',
                            style: TextStyle(
                              color: member.isActive
                                  ? Colors.green
                                  : Colors.red,
                              fontWeight: FontWeight.w600,
                              fontSize: 12,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 24),

                /// ===============================
                /// PERSONAL INFORMATION
                /// ===============================
                _buildSection(
                  title: 'Personal Information',
                  children: [
                    _buildInfoRow('ID Number', member.idNo),
                    _buildInfoRow(
                      'Date of Birth',
                      '${member.dateOfBirth.toLocal().day.toString().padLeft(2, '0')}/${member.dateOfBirth.toLocal().month.toString().padLeft(2, '0')}/${member.dateOfBirth.toLocal().year}',
                    ),
                    _buildInfoRow('Position', member.position),
                  ],
                ),

                const SizedBox(height: 16),

                /// ===============================
                /// CONTACT & LOCATION
                /// ===============================
                _buildSection(
                  title: 'Contact & Location',
                  children: [
                    _buildInfoRow('Phone Number', member.phoneNumber),
                    _buildInfoRow('Address / Location', member.location),
                  ],
                ),

                const SizedBox(height: 16),

                /// ===============================
                /// SYSTEM INFORMATION
                /// ===============================
                _buildSection(
                  title: 'System Information',
                  children: [
                    _buildInfoRow('Join Date', member.createdAt.toString()),
                  ],
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  /// ===============================
  /// SECTION WRAPPER
  /// ===============================
  Widget _buildSection({
    required String title,
    required List<Widget> children,
  }) {
    return Card(
      elevation: 1,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: Theme.of(
                context,
              ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            ...children,
          ],
        ),
      ),
    );
  }

  /// ===============================
  /// INFO ROW
  /// ===============================
  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            flex: 3,
            child: Text(
              label,
              style: TextStyle(fontSize: 13, color: Colors.grey.shade600),
            ),
          ),
          Expanded(
            flex: 5,
            child: Text(
              value,
              style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w500),
            ),
          ),
        ],
      ),
    );
  }
}
