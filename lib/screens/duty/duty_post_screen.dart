import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/duty_post.dart';
import '../../models/duty_roster.dart';
import '../../models/duty_assignment.dart';
import '../../services/duty_service.dart';
import '../../widgets/duty_post_card.dart';
import 'assign_duty_screen.dart';

class DutyPostScreen extends StatefulWidget {
  const DutyPostScreen({super.key});

  @override
  State<DutyPostScreen> createState() => _DutyPostScreenState();
}

class _DutyPostScreenState extends State<DutyPostScreen> {
  List<DutyPost> _dutyPosts = [];
  bool _isLoading = true;
  DateTime _selectedDate = DateTime.now();
  final Map<DateTime, List<DutyRoster>> _events = {};

  // Pagination
  int _currentPage = 1;
  final int _limit = 10;
  bool _hasMore = true;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  void _onDateChanged(DateTime newDate) {
    if (newDate.year == _selectedDate.year &&
        newDate.month == _selectedDate.month &&
        newDate.day == _selectedDate.day) {
      return; // ✅ same date → do nothing
    }

    setState(() {
      _selectedDate = newDate;
      _currentPage = 1;
      _dutyPosts.clear();
      _hasMore = true;
      _isLoading = true;
    });

    _loadData(); // ✅ fetch ONLY when date actually changes
  }

  Future<void> _pickDate() async {
    final pickedDate = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2020, 1, 1),
      lastDate: DateTime(2030, 12, 31),
    );

    if (pickedDate != null) {
      _onDateChanged(pickedDate);
    }
  }

  Future<void> _loadData() async {
    final dutyService = Provider.of<DutyService>(context, listen: false);

    setState(() => _isLoading = true);

    try {
      final posts = await dutyService.getDutyPosts(
        page: _currentPage,
        limit: _limit,
        date: _selectedDate, // ✅ DATE PASSED
      );

      setState(() {
        _dutyPosts = posts;
        _hasMore = posts.length >= _limit;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.toString()), backgroundColor: Colors.red),
      );
    }
  }

  Future<void> _loadMorePosts() async {
    if (_isLoading || !_hasMore) return;

    final dutyService = Provider.of<DutyService>(context, listen: false);
    _currentPage++;

    try {
      final morePosts = await dutyService.getDutyPosts(
        page: _currentPage,
        limit: _limit,
        date: _selectedDate, // ✅ DATE PASSED
      );

      setState(() {
        _dutyPosts.addAll(morePosts);
        _hasMore = morePosts.length >= _limit;
      });
    } catch (_) {}
  }

  void _showAddDutyPostDialog() {
    final nameController = TextEditingController();
    final descriptionController = TextEditingController();

    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Add Duty Post'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nameController,
                decoration: const InputDecoration(
                  labelText: 'Post Name *',
                  hintText: 'Enter post name',
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: descriptionController,
                decoration: const InputDecoration(
                  labelText: 'Description (optional)',
                  hintText: 'Enter description',
                ),
                maxLines: 3,
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              final name = nameController.text.trim();
              if (name.isEmpty) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Post name is required'),
                    backgroundColor: Colors.red,
                  ),
                );
                return;
              }

              final dutyService = Provider.of<DutyService>(
                context,
                listen: false,
              );

              try {
                debugPrint('🟡 ADD DUTY POST STARTED');
                debugPrint('📤 POST NAME: $name');

                final post = await dutyService.addDutyPost(name);

                debugPrint('✅ DUTY POST CREATED: ${post.id}');

                if (!mounted) return;

                setState(() {
                  _dutyPosts.insert(0, post); // Add to beginning of list
                });

                Navigator.pop(dialogContext);

                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Duty post "$name" created successfully!'),
                    backgroundColor: Colors.green,
                  ),
                );
              } catch (e, s) {
                debugPrint('❌ ADD DUTY POST ERROR: $e');
                debugPrint(s.toString());

                if (!mounted) return;

                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Failed to create duty post: $e'),
                    backgroundColor: Colors.red,
                  ),
                );
              }
            },
            child: const Text('Add'),
          ),
        ],
      ),
    );
  }

  String _getWeekdayName(int weekday) {
    const days = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
    return days[weekday - 1];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Duty Posts'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              setState(() {
                _currentPage = 1;
              });
              _loadData();
            },
            tooltip: 'Refresh',
          ),
          IconButton(
            icon: const Icon(Icons.add_location_alt),
            onPressed: _showAddDutyPostDialog,
            tooltip: 'Add Duty Post',
          ),
        ],
      ),
      body: Column(
        children: [
          // Date header
          Column(
            children: [
              Container(
                padding: const EdgeInsets.all(16),
                color: Theme.of(
                  context,
                ).colorScheme.primaryContainer.withValues(alpha: 0.3),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.chevron_left),
                      onPressed: () {
                        _onDateChanged(
                          _selectedDate.subtract(const Duration(days: 1)),
                        );
                      },
                    ),
                    GestureDetector(
                      onTap: _pickDate,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 8,
                        ),
                        decoration: BoxDecoration(
                          color: Theme.of(context).colorScheme.primary,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          '${_selectedDate.day}/${_selectedDate.month}/${_selectedDate.year}',
                          style: TextStyle(
                            color: Theme.of(context).colorScheme.onPrimary,
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.chevron_right),
                      onPressed: () {
                        _onDateChanged(
                          _selectedDate.add(const Duration(days: 1)),
                        );
                      },
                    ),
                  ],
                ),
              ),
              // Week view
              SizedBox(
                height: 80,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: 7,
                  itemBuilder: (context, index) {
                    final date = _selectedDate.subtract(
                      Duration(days: _selectedDate.weekday - 1 - index),
                    );
                    final isSelected =
                        date.day == _selectedDate.day &&
                        date.month == _selectedDate.month &&
                        date.year == _selectedDate.year;
                    final dateKey = DateTime(date.year, date.month, date.day);
                    final hasEvents =
                        _events.containsKey(dateKey) &&
                        _events[dateKey]!.isNotEmpty;

                    return GestureDetector(
                      onTap: () {
                        setState(() {
                          _selectedDate = date;
                        });
                      },
                      child: Container(
                        width: 60,
                        margin: const EdgeInsets.all(4),
                        decoration: BoxDecoration(
                          color: isSelected
                              ? Theme.of(context).colorScheme.primary
                              : hasEvents
                              ? Theme.of(
                                  context,
                                ).colorScheme.secondary.withValues(alpha: 0.3)
                              : Theme.of(
                                  context,
                                ).colorScheme.surfaceContainerHighest,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              _getWeekdayName(date.weekday),
                              style: TextStyle(
                                color: isSelected
                                    ? Theme.of(context).colorScheme.onPrimary
                                    : Theme.of(context).colorScheme.onSurface,
                                fontSize: 12,
                              ),
                            ),
                            Text(
                              '${date.day}',
                              style: TextStyle(
                                color: isSelected
                                    ? Theme.of(context).colorScheme.onPrimary
                                    : Theme.of(context).colorScheme.onSurface,
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            if (hasEvents)
                              Container(
                                width: 6,
                                height: 6,
                                decoration: BoxDecoration(
                                  color: isSelected
                                      ? Theme.of(context).colorScheme.onPrimary
                                      : Theme.of(context).colorScheme.secondary,
                                  shape: BoxShape.circle,
                                ),
                              ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
          // Duty posts list
          Expanded(
            child: _isLoading && _dutyPosts.isEmpty
                ? const Center(child: CircularProgressIndicator())
                : dutyPostsTab(),
          ),
        ],
      ),
    );
  }

  Widget dutyPostsTab() {
    if (_dutyPosts.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.work_off, size: 64, color: Colors.grey),
            const SizedBox(height: 16),
            const Text(
              'No duty posts available',
              style: TextStyle(fontSize: 18, color: Colors.grey),
            ),
            const SizedBox(height: 8),
            ElevatedButton(
              onPressed: _showAddDutyPostDialog,
              child: const Text('Add First Duty Post'),
            ),
          ],
        ),
      );
    }

    return NotificationListener<ScrollNotification>(
      onNotification: (ScrollNotification scrollInfo) {
        if (!_isLoading &&
            _hasMore &&
            scrollInfo.metrics.pixels == scrollInfo.metrics.maxScrollExtent) {
          _loadMorePosts();
        }
        return false;
      },
      child: ListView.builder(
        itemCount: _dutyPosts.length + (_hasMore ? 1 : 0),
        itemBuilder: (context, index) {
          if (index == _dutyPosts.length) {
            return const Center(
              child: Padding(
                padding: EdgeInsets.all(16.0),
                child: CircularProgressIndicator(),
              ),
            );
          }

          final post = _dutyPosts[index];
          return DutyPostCard(
            post: post,
            onTap: () => showDutyPostDetails(post),
            onEdit: () => editDutyPost(post),
            onDelete: () => deleteDutyPost(post),
          );
        },
      ),
    );
  }

  void editDutyPost(DutyPost post) {
    final nameController = TextEditingController(text: post.name);
    final descriptionController = TextEditingController(
      text: post.description ?? '',
    );

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Edit Duty Post'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nameController,
                decoration: const InputDecoration(
                  labelText: 'Post Name *',
                  hintText: 'Enter post name',
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: descriptionController,
                decoration: const InputDecoration(
                  labelText: 'Description (optional)',
                  hintText: 'Enter description',
                ),
                maxLines: 3,
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              final name = nameController.text.trim();
              if (name.isEmpty) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Post name is required'),
                    backgroundColor: Colors.red,
                  ),
                );
                return;
              }

              Navigator.pop(context);
              _updateDutyPost(post, name, descriptionController.text.trim());
            },
            child: const Text('Update'),
          ),
        ],
      ),
    );
  }

  Future<void> _updateDutyPost(
    DutyPost post,
    String name,
    String description,
  ) async {
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
                Text('Updating duty post...'),
              ],
            ),
          );
        },
      );

      final dutyService = Provider.of<DutyService>(context, listen: false);
      final updatedPost = await dutyService.updateDutyPost(
        dutyPostId: post.id,
        postName: name,
        description: description.isEmpty ? null : description,
      );

      if (mounted) {
        Navigator.of(context).pop(); // Close loading dialog

        // Update the post in the list
        setState(() {
          final index = _dutyPosts.indexWhere((p) => p.id == post.id);
          if (index != -1) {
            _dutyPosts[index] = updatedPost;
          }
        });

        // Show success message
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Duty post "$name" has been updated successfully'),
            backgroundColor: Colors.green,
            duration: const Duration(seconds: 3),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        Navigator.of(context).pop(); // Close loading dialog

        // Show error message
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error updating duty post: $e'),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 4),
          ),
        );
      }
    }
  }

  void deleteDutyPost(DutyPost post) {
    // Check if there are assignments
    final hasAssignments =
        post.dutyAssignments != null && post.dutyAssignments!.isNotEmpty;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Duty Post'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (hasAssignments) ...[
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.orange.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: Colors.orange.withValues(alpha: 0.3),
                  ),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.warning, color: Colors.orange, size: 24),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        'This duty post has ${post.dutyAssignments!.length} active assignment(s)',
                        style: const TextStyle(
                          color: Colors.orange,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 12),
            ],
            const Text('Are you sure you want to delete this duty post?'),
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
                  Text(
                    post.name,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                  if (post.description != null &&
                      post.description!.isNotEmpty) ...[
                    const SizedBox(height: 4),
                    Text('Description: ${post.description}'),
                  ],
                ],
              ),
            ),
            const SizedBox(height: 12),
            if (hasAssignments)
              const Text(
                'Note: You may need to remove all duty assignments first before deleting this post.',
                style: TextStyle(
                  fontSize: 12,
                  fontStyle: FontStyle.italic,
                  color: Colors.grey,
                ),
              )
            else
              const Text(
                'This action cannot be undone.',
                style: TextStyle(
                  color: Colors.red,
                  fontWeight: FontWeight.w500,
                ),
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
              _confirmDeleteDutyPost(post);
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

  Future<void> _confirmDeleteDutyPost(DutyPost post) async {
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
                Text('Deleting duty post...'),
              ],
            ),
          );
        },
      );

      final dutyService = Provider.of<DutyService>(context, listen: false);
      await dutyService.deleteDutyPost(post.id);

      if (mounted) {
        Navigator.of(context).pop(); // Close loading dialog

        // Show success message
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Duty post "${post.name}" has been deleted successfully',
            ),
            backgroundColor: Colors.green,
            duration: const Duration(seconds: 3),
          ),
        );

        // Refresh the list
        setState(() {
          _dutyPosts.removeWhere((p) => p.id == post.id);
        });
      }
    } catch (e) {
      if (mounted) {
        Navigator.of(context).pop(); // Close loading dialog

        // Parse error message
        String errorMessage = e.toString();
        if (errorMessage.contains('Exception:')) {
          errorMessage = errorMessage.replaceFirst('Exception:', '').trim();
        }

        // Check if it's an assignment-related error
        final isAssignmentError = errorMessage.toLowerCase().contains(
          'assignment',
        );

        // Show error dialog with more details
        showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              title: Row(
                children: [
                  Icon(
                    isAssignmentError ? Icons.warning : Icons.error,
                    color: isAssignmentError ? Colors.orange : Colors.red,
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
                  if (isAssignmentError) ...[
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
                            'What to do:',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: Colors.blue,
                            ),
                          ),
                          SizedBox(height: 8),
                          Text(
                            '1. Remove all duty assignments from this post first\n'
                            '2. Then try deleting the duty post again',
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

  void showDutyPostDetails(DutyPost post) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => DutyPostDetailsSheet(post: post)),
    );
  }
}

// Separate widget for duty post details with assigned members
class DutyPostDetailsSheet extends StatefulWidget {
  final DutyPost post;

  const DutyPostDetailsSheet({super.key, required this.post});

  @override
  State<DutyPostDetailsSheet> createState() => _DutyPostDetailsSheetState();
}

class _DutyPostDetailsSheetState extends State<DutyPostDetailsSheet> {
  List<DutyAssignment> _assignedMembers = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadAssignedMembers();
  }

  Future<void> _loadAssignedMembers() async {
    final dutyService = Provider.of<DutyService>(context, listen: false);

    try {
      final assignments = await dutyService.getAssignedMembers(widget.post.id);

      if (mounted) {
        setState(() {
          _assignedMembers = assignments;
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
            content: Text('Failed to load assigned members: $e'),
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
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text('Duty Post Details'),
      ),
      body: Container(
        height: MediaQuery.of(context).size.height * 1,
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surface,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: Column(
          children: [
            // Content
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Title
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: Theme.of(
                              context,
                            ).colorScheme.primaryContainer,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Icon(
                            Icons.work,
                            color: Theme.of(context).colorScheme.primary,
                            size: 28,
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                widget.post.name,
                                style: Theme.of(context).textTheme.headlineSmall
                                    ?.copyWith(fontWeight: FontWeight.bold),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                'Duty Post',
                                style: TextStyle(
                                  color: Theme.of(context).colorScheme.onSurface
                                      .withValues(alpha: 0.6),
                                  fontSize: 14,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),

                    // Description
                    if (widget.post.description != null &&
                        widget.post.description!.isNotEmpty) ...[
                      Text(
                        'Description',
                        style: Theme.of(context).textTheme.titleMedium
                            ?.copyWith(fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 8),
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Theme.of(
                            context,
                          ).colorScheme.surfaceContainerHighest,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          widget.post.description!,
                          style: const TextStyle(fontSize: 14),
                        ),
                      ),
                      const SizedBox(height: 24),
                    ],
                    //
                    // Assigned Members Section
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Assigned Members',
                          style: Theme.of(context).textTheme.titleMedium
                              ?.copyWith(fontWeight: FontWeight.bold),
                        ),
                        if (!_isLoading)
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 6,
                            ),
                            decoration: BoxDecoration(
                              color: Theme.of(
                                context,
                              ).colorScheme.primaryContainer,
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Text(
                              '${_assignedMembers.length}',
                              style: TextStyle(
                                color: Theme.of(context).colorScheme.primary,
                                fontWeight: FontWeight.bold,
                                fontSize: 14,
                              ),
                            ),
                          ),
                      ],
                    ),
                    const SizedBox(height: 12),

                    // Assigned Members List
                    if (_isLoading)
                      const Center(
                        child: Padding(
                          padding: EdgeInsets.all(32.0),
                          child: CircularProgressIndicator(),
                        ),
                      )
                    else if (_assignedMembers.isEmpty)
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(32),
                        decoration: BoxDecoration(
                          color: Theme.of(
                            context,
                          ).colorScheme.surfaceContainerHighest,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Column(
                          children: [
                            Icon(
                              Icons.people_outline,
                              size: 48,
                              color: Theme.of(
                                context,
                              ).colorScheme.onSurface.withValues(alpha: 0.4),
                            ),
                            const SizedBox(height: 12),
                            Text(
                              'No members assigned yet',
                              style: TextStyle(
                                color: Theme.of(
                                  context,
                                ).colorScheme.onSurface.withValues(alpha: 0.6),
                                fontSize: 14,
                              ),
                            ),
                          ],
                        ),
                      )
                    else
                      ..._assignedMembers.map(
                        (assignment) => _buildMemberCard(context, assignment),
                      ),

                    const SizedBox(height: 12),

                    // Action Button
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        onPressed: () {
                          Navigator.pop(context);
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) =>
                                  AssignDutyScreen(dutyPostId: widget.post.id),
                            ),
                          );
                        },
                        icon: const Icon(Icons.assignment_ind),
                        label: const Text('Assign Duty'),
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMemberCard(BuildContext context, DutyAssignment assignment) {
    final member = assignment.member;
    final assignmentDate = DateTime.tryParse(assignment.day);
    final formattedDate = assignmentDate != null
        ? '${assignmentDate.day}/${assignmentDate.month}/${assignmentDate.year}'
        : assignment.day;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: Theme.of(context).colorScheme.outline.withValues(alpha: 0.2),
        ),
      ),
      child: Row(
        children: [
          // Profile Picture
          CircleAvatar(
            radius: 28,
            backgroundColor: Theme.of(context).colorScheme.primaryContainer,
            backgroundImage: member.hasPhoto
                ? NetworkImage(member.displayPhoto)
                : null,
            child: !member.hasPhoto
                ? Text(
                    member.fullName.substring(0, 1).toUpperCase(),
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.primary,
                      fontWeight: FontWeight.bold,
                      fontSize: 20,
                    ),
                  )
                : null,
          ),
          const SizedBox(width: 16),
          // Member Info
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
                const SizedBox(height: 4),
                if (member.rifleNo != null)
                  Text(
                    'Rifle No: ${member.rifleNo}',
                    style: TextStyle(
                      fontSize: 13,
                      color: Theme.of(
                        context,
                      ).colorScheme.onSurface.withValues(alpha: 0.7),
                    ),
                  ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Icon(
                      Icons.calendar_today,
                      size: 14,
                      color: Theme.of(context).colorScheme.primary,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      formattedDate,
                      style: TextStyle(
                        fontSize: 12,
                        color: Theme.of(context).colorScheme.primary,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          // Status Badge and Delete Button
          Column(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: member.status == 'ACTIVE'
                      ? Colors.green.withValues(alpha: 0.1)
                      : Colors.grey.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: member.status == 'ACTIVE'
                        ? Colors.green
                        : Colors.grey,
                    width: 1,
                  ),
                ),
                child: Text(
                  member.status,
                  style: TextStyle(
                    color: member.status == 'ACTIVE'
                        ? Colors.green
                        : Colors.grey,
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              const SizedBox(height: 8),
              IconButton(
                icon: const Icon(Icons.delete_outline, size: 20),
                color: Colors.red,
                onPressed: () => _showDeleteAssignmentConfirmation(assignment),
                tooltip: 'Delete Assignment',
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow(
    BuildContext context,
    String label,
    String value,
    IconData icon,
  ) {
    return Row(
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
                  color: Theme.of(
                    context,
                  ).colorScheme.onSurface.withValues(alpha: 0.6),
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
    );
  }

  void _showDeleteAssignmentConfirmation(DutyAssignment assignment) {
    final member = assignment.member;
    final assignmentDate = DateTime.tryParse(assignment.day);
    final formattedDate = assignmentDate != null
        ? '${assignmentDate.day}/${assignmentDate.month}/${assignmentDate.year}'
        : assignment.day;

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
                  Row(
                    children: [
                      const Icon(Icons.work, size: 16),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          widget.post.name,
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
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
                  if (member.rifleNo != null) ...[
                    const SizedBox(height: 4),
                    Text(
                      'Rifle No: ${member.rifleNo}',
                      style: const TextStyle(fontSize: 12),
                    ),
                  ],
                  const SizedBox(height: 4),
                  Text(
                    'Date: $formattedDate',
                    style: const TextStyle(fontSize: 12),
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

  Future<void> _confirmDeleteAssignment(DutyAssignment assignment) async {
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

        // Refresh the assigned members list
        _loadAssignedMembers();
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
