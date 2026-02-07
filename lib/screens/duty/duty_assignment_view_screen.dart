import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/duty_roster.dart';
import '../../models/duty_post.dart';
import '../../models/member.dart';
import '../../services/duty_service.dart';
import '../../services/member_service.dart';
import '../../widgets/theme_toggle_button.dart';

class DutyAssignmentViewScreen extends StatefulWidget {
  final DateTime selectedDate;
  final List<DutyRoster> assignments;

  const DutyAssignmentViewScreen({
    super.key,
    required this.selectedDate,
    required this.assignments,
  });

  @override
  State<DutyAssignmentViewScreen> createState() =>
      _DutyAssignmentViewScreenState();
}

class _DutyAssignmentViewScreenState extends State<DutyAssignmentViewScreen> {
  Map<String, DutyPost> _dutyPosts = {};
  Map<String, Member> _members = {};
  Map<String, List<DutyRoster>> _assignmentsByPost = {};
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    final dutyService = Provider.of<DutyService>(context, listen: false);
    final memberService = Provider.of<MemberService>(context, listen: false);

    try {
      // Load duty posts and members
      final posts = await dutyService.getDutyPosts(date: widget.selectedDate);
      final members = await memberService.getMembersSync();

      // Create maps for quick lookup
      final postMap = <String, DutyPost>{};
      for (final post in posts) {
        postMap[post.id] = post;
      }

      final memberMap = <String, Member>{};
      for (final member in members) {
        memberMap[member.id] = member;
      }

      // Group assignments by duty post
      final assignmentsByPost = <String, List<DutyRoster>>{};
      for (final assignment in widget.assignments) {
        if (!assignmentsByPost.containsKey(assignment.dutyPostId)) {
          assignmentsByPost[assignment.dutyPostId] = [];
        }
        assignmentsByPost[assignment.dutyPostId]!.add(assignment);
      }

      if (mounted) {
        setState(() {
          _dutyPosts = postMap;
          _members = memberMap;
          _assignmentsByPost = assignmentsByPost;
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
      appBar: AppBar(
        title: const Text('Duty Assignments'),
        leading: Text(
          '${widget.selectedDate.day}/${widget.selectedDate.month}/${widget.selectedDate.year}',
        ),
        actions: const [ThemeToggleButton()],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : widget.assignments.isEmpty
          ? _buildEmptyState()
          : _buildAssignmentsList(),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.assignment_outlined,
            size: 64,
            color: Theme.of(
              context,
            ).colorScheme.onSurface.withValues(alpha: 0.6),
          ),
          const SizedBox(height: 16),
          Text(
            'No duties assigned for this date',
            style: TextStyle(
              fontSize: 18,
              color: Theme.of(
                context,
              ).colorScheme.onSurface.withValues(alpha: 0.6),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Assignments will appear here once duties are scheduled',
            style: TextStyle(
              fontSize: 14,
              color: Theme.of(
                context,
              ).colorScheme.onSurface.withValues(alpha: 0.4),
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildAssignmentsList() {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _assignmentsByPost.keys.length,
      itemBuilder: (context, index) {
        final postId = _assignmentsByPost.keys.elementAt(index);
        final post = _dutyPosts[postId];
        final assignments = _assignmentsByPost[postId]!;

        if (post == null) return const SizedBox.shrink();

        return Card(
          margin: const EdgeInsets.only(bottom: 16),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Duty Post Header
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Theme.of(context).colorScheme.primaryContainer,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Icon(
                        Icons.work,
                        color: Theme.of(context).colorScheme.primary,
                        size: 20,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            post.name,
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          
                        ],
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: Theme.of(
                          context,
                        ).colorScheme.secondary.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        '${assignments.length} assigned',
                        style: TextStyle(
                          fontSize: 12,
                          color: Theme.of(context).colorScheme.secondary,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ],
                ),

                
                const SizedBox(height: 16),
                const Divider(),
                const SizedBox(height: 8),

                // Assigned Members
                Text(
                  'Assigned Members:',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Theme.of(context).colorScheme.onSurface,
                  ),
                ),
                const SizedBox(height: 12),

                ...assignments.map(
                  (assignment) => _buildMemberAssignment(assignment),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildMemberAssignment(DutyRoster assignment) {
    final member = _members[assignment.memberId];

    if (member == null) {
      return Container(
        margin: const EdgeInsets.only(bottom: 8),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Theme.of(
            context,
          ).colorScheme.errorContainer.withValues(alpha: 0.3),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: Theme.of(context).colorScheme.error.withValues(alpha: 0.3),
          ),
        ),
        child: Row(
          children: [
            Icon(
              Icons.error_outline,
              color: Theme.of(context).colorScheme.error,
              size: 20,
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                'Member not found (ID: ${assignment.memberId})',
                style: TextStyle(
                  color: Theme.of(context).colorScheme.error,
                  fontSize: 14,
                ),
              ),
            ),
            IconButton(
              icon: const Icon(Icons.delete_outline, size: 20),
              color: Theme.of(context).colorScheme.error,
              onPressed: () => _showDeleteConfirmation(assignment, null),
              tooltip: 'Delete Assignment',
            ),
          ],
        ),
      );
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Theme.of(
          context,
        ).colorScheme.surfaceContainerHighest.withValues(alpha: 0.3),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: Theme.of(context).colorScheme.outline.withValues(alpha: 0.2),
        ),
      ),
      child: Row(
        children: [
          // Member Avatar
          CircleAvatar(
            radius: 20,
            backgroundColor: Theme.of(
              context,
            ).colorScheme.primary.withValues(alpha: 0.1),
            child: member.profileImage != null
                ? ClipOval(
                    child: Image.file(
                      member.profileImage as dynamic,
                      width: 40,
                      height: 40,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) {
                        return Icon(
                          Icons.person,
                          color: Theme.of(context).colorScheme.primary,
                          size: 20,
                        );
                      },
                    ),
                  )
                : Icon(
                    Icons.person,
                    color: Theme.of(context).colorScheme.primary,
                    size: 20,
                  ),
          ),
          const SizedBox(width: 12),

          // Member Details
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  member.fullName,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  'ID: ${member.rifleNumber}',
                  style: TextStyle(
                    fontSize: 12,
                    color: Theme.of(
                      context,
                    ).colorScheme.onSurface.withValues(alpha: 0.6),
                  ),
                ),
                if (member.location != null && member.location!.isNotEmpty)
                  Text(
                    'Location: ${member.location}',
                    style: TextStyle(
                      fontSize: 12,
                      color: Theme.of(
                        context,
                      ).colorScheme.onSurface.withValues(alpha: 0.6),
                    ),
                  ),
              ],
            ),
          ),

          // Shift and Status
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: _getShiftColor(
                    assignment.shift,
                  ).withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  assignment.shift,
                  style: TextStyle(
                    fontSize: 12,
                    color: _getShiftColor(assignment.shift),
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
              const SizedBox(height: 4),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: _getStatusColor(
                    assignment.status,
                  ).withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  assignment.status,
                  style: TextStyle(
                    fontSize: 12,
                    color: _getStatusColor(assignment.status),
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),

          // Delete Button
          IconButton(
            icon: const Icon(Icons.delete_outline, size: 20),
            color: Colors.red,
            onPressed: () => _showDeleteConfirmation(assignment, member),
            tooltip: 'Delete Assignment',
          ),
        ],
      ),
    );
  }

  Color _getShiftColor(String shift) {
    switch (shift.toLowerCase()) {
      case 'morning':
        return Colors.orange;
      case 'afternoon':
        return Colors.blue;
      case 'evening':
        return Colors.purple;
      case 'night':
        return Colors.indigo;
      default:
        return Theme.of(context).colorScheme.primary;
    }
  }

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'completed':
        return Colors.green;
      case 'absent':
        return Colors.red;
      case 'in progress':
        return Colors.orange;
      case 'scheduled':
        return Colors.blue;
      default:
        return Theme.of(context).colorScheme.primary;
    }
  }

  void _showDeleteConfirmation(DutyRoster assignment, Member? member) {
    final dutyPost = _dutyPosts[assignment.dutyPostId];

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Duty Assignment'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Are you sure you want to delete this duty assignment?'),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.red.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.red.withValues(alpha: 0.3)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (dutyPost != null) ...[
                    Row(
                      children: [
                        const Icon(Icons.work, size: 16),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            dutyPost.name,
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                  ],
                  if (member != null) ...[
                    Row(
                      children: [
                        const Icon(Icons.person, size: 16),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            member.fullName,
                            style: const TextStyle(fontWeight: FontWeight.w600),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'ID: ${member.rifleNumber}',
                      style: const TextStyle(fontSize: 12),
                    ),
                  ],
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: _getShiftColor(
                            assignment.shift,
                          ).withValues(alpha: 0.2),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          assignment.shift,
                          style: TextStyle(
                            fontSize: 11,
                            color: _getShiftColor(assignment.shift),
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: _getStatusColor(
                            assignment.status,
                          ).withValues(alpha: 0.2),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          assignment.status,
                          style: TextStyle(
                            fontSize: 11,
                            color: _getStatusColor(assignment.status),
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),
            const Text(
              'This action cannot be undone.',
              style: TextStyle(color: Colors.red, fontWeight: FontWeight.w500),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              _confirmDeleteAssignment(assignment);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }

  Future<void> _confirmDeleteAssignment(DutyRoster assignment) async {
    try {
      // Show loading indicator
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (BuildContext context) {
          return const AlertDialog(
            content: Row(
              children: [
                CircularProgressIndicator(),
                SizedBox(width: 20),
                Text('Deleting assignment...'),
              ],
            ),
          );
        },
      );

      final dutyService = Provider.of<DutyService>(context, listen: false);
      await dutyService.deleteDutyAssignment(assignment.id);

      if (mounted) {
        Navigator.of(context).pop(); // Close loading dialog

        // Show success message
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Duty assignment has been deleted successfully'),
            backgroundColor: Colors.green,
            duration: Duration(seconds: 3),
          ),
        );

        // Refresh the data
        _loadData();
      }
    } catch (e) {
      if (mounted) {
        Navigator.of(context).pop(); // Close loading dialog

        // Parse error message
        String errorMessage = e.toString();
        if (errorMessage.contains('Exception:')) {
          errorMessage = errorMessage.replaceFirst('Exception:', '').trim();
        }

        // Check if it's an endpoint not found error
        final isEndpointError =
            errorMessage.toLowerCase().contains('endpoint') ||
            errorMessage.toLowerCase().contains('not found') ||
            errorMessage.toLowerCase().contains('not implemented');

        // Show error dialog with more details
        showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              title: Row(
                children: [
                  Icon(
                    isEndpointError ? Icons.warning : Icons.error,
                    color: isEndpointError ? Colors.orange : Colors.red,
                  ),
                  const SizedBox(width: 12),
                  const Expanded(child: Text('Cannot Delete')),
                ],
              ),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(errorMessage),
                  if (isEndpointError) ...[
                    const SizedBox(height: 16),
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.blue.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                          color: Colors.blue.withValues(alpha: 0.3),
                        ),
                      ),
                      child: const Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Note:',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: Colors.blue,
                            ),
                          ),
                          SizedBox(height: 8),
                          Text(
                            'The delete duty assignment API endpoint may not be responding correctly. The endpoint should be:\n\n'
                            'DELETE /api/v1/admin/duty/assign/{assignmentId}\n\n'
                            'Please verify with the backend team.',
                            style: TextStyle(fontSize: 13),
                          ),
                        ],
                      ),
                    ),
                  ],
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('OK'),
                ),
              ],
            );
          },
        );
      }
    }
  }
}
