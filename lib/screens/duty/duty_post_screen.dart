import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/duty_post.dart';
import '../../services/duty_service.dart';
import 'assign_duty_screen.dart';

class DutyPostScreen extends StatefulWidget {
  const DutyPostScreen({super.key});

  @override
  State<DutyPostScreen> createState() => _DutyPostScreenState();
}

class _DutyPostScreenState extends State<DutyPostScreen> {
  List<DutyPost> _dutyPosts = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadDutyPosts();
  }

  Future<void> _loadDutyPosts() async {
    final dutyService = Provider.of<DutyService>(context, listen: false);
    try {
      final posts = await dutyService.getDutyPosts();
      if (mounted) {
        setState(() {
          _dutyPosts = posts;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to load duty posts: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Duty Posts'),
        actions: [IconButton(icon: Icon(Icons.add), onPressed: _addDutyPost)],
      ),
      body: _isLoading
          ? Center(child: CircularProgressIndicator())
          : _dutyPosts.isEmpty
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.work_off, size: 64, color: Colors.grey),
                  SizedBox(height: 16),
                  Text(
                    'No duty posts available',
                    style: TextStyle(fontSize: 18, color: Colors.grey),
                  ),
                  SizedBox(height: 8),
                  ElevatedButton(
                    onPressed: _addDutyPost,
                    child: Text('Add First Duty Post'),
                  ),
                ],
              ),
            )
          : ListView.builder(
              itemCount: _dutyPosts.length,
              itemBuilder: (context, index) {
                final post = _dutyPosts[index];
                return Card(
                  margin: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  child: ListTile(
                    onTap: () => _showDutyPostDetails(post),
                    leading: Container(
                      padding: EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.blue.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Icon(Icons.place, color: Colors.blue),
                    ),
                    title: Text(
                      post.name,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        SizedBox(height: 2),
                        if (post.location != null && post.location!.isNotEmpty)
                          Text(post.location!),
                        if (post.description != null &&
                            post.description!.isNotEmpty)
                          Text(
                            post.description!,
                            style: TextStyle(fontSize: 12),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                      ],
                    ),
                    trailing: PopupMenuButton(
                      onSelected: (value) {
                        if (value == 'edit') {
                          _editDutyPost(post);
                        } else if (value == 'delete') {
                          _deleteDutyPost(post);
                        }
                      },
                      itemBuilder: (context) => [
                        PopupMenuItem(
                          value: 'edit',
                          child: Row(
                            children: [
                              Icon(Icons.edit, size: 20),
                              SizedBox(width: 8),
                              Text('Edit'),
                            ],
                          ),
                        ),
                        PopupMenuItem(
                          value: 'delete',
                          child: Row(
                            children: [
                              Icon(Icons.delete, size: 20, color: Colors.red),
                              SizedBox(width: 8),
                              Text(
                                'Delete',
                                style: TextStyle(color: Colors.red),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
    );
  }

  void _addDutyPost() {
    final nameController = TextEditingController();
    final locationController = TextEditingController();
    final descriptionController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Add New Duty Post'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nameController,
                decoration: InputDecoration(labelText: 'Post Name *'),
              ),
              SizedBox(height: 8),
              TextField(
                controller: locationController,
                decoration: InputDecoration(labelText: 'Location'),
              ),
              SizedBox(height: 8),
              TextField(
                controller: descriptionController,
                decoration: InputDecoration(labelText: 'Description'),
                maxLines: 3,
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => _saveDutyPost(
              nameController.text,
              locationController.text,
              descriptionController.text,
            ),
            child: Text('Save'),
          ),
        ],
      ),
    );
  }

  Future<void> _saveDutyPost(
    String name,
    String location,
    String description,
  ) async {
    if (name.trim().isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Post name is required')));
      return;
    }

    final dutyService = Provider.of<DutyService>(context, listen: false);
    final newPost = DutyPost(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      name: name.trim(),
      location: location.trim().isEmpty ? null : location.trim(),
      description: description.trim().isEmpty ? null : description.trim(),
    );

    try {
      await dutyService.addDutyPost(newPost);
      Navigator.pop(context);
      _loadDutyPosts(); // Refresh the list
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Duty post added successfully')));
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Failed to add duty post: $e')));
    }
  }

  void _editDutyPost(DutyPost post) {
    final nameController = TextEditingController(text: post.name);
    final locationController = TextEditingController(text: post.location ?? '');
    final descriptionController = TextEditingController(
      text: post.description ?? '',
    );

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Edit Duty Post'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nameController,
                decoration: InputDecoration(labelText: 'Post Name *'),
              ),
              SizedBox(height: 8),
              TextField(
                controller: locationController,
                decoration: InputDecoration(labelText: 'Location'),
              ),
              SizedBox(height: 8),
              TextField(
                controller: descriptionController,
                decoration: InputDecoration(labelText: 'Description'),
                maxLines: 3,
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => _updateDutyPost(
              post,
              nameController.text,
              locationController.text,
              descriptionController.text,
            ),
            child: Text('Update'),
          ),
        ],
      ),
    );
  }

  Future<void> _updateDutyPost(
    DutyPost post,
    String name,
    String location,
    String description,
  ) async {
    if (name.trim().isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Post name is required')));
      return;
    }

    final dutyService = Provider.of<DutyService>(context, listen: false);
    final updatedPost = post.copyWith(
      name: name.trim(),
      location: location.trim().isEmpty ? null : location.trim(),
      description: description.trim().isEmpty ? null : description.trim(),
    );

    try {
      await dutyService.updateDutyPost(updatedPost);
      Navigator.pop(context);
      _loadDutyPosts(); // Refresh the list
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Duty post updated successfully')));
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Failed to update duty post: $e')));
    }
  }

  void _deleteDutyPost(DutyPost post) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Delete Duty Post'),
        content: Text('Are you sure you want to delete "${post.name}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => _confirmDeleteDutyPost(post),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: Text('Delete'),
          ),
        ],
      ),
    );
  }

  Future<void> _confirmDeleteDutyPost(DutyPost post) async {
    final dutyService = Provider.of<DutyService>(context, listen: false);

    try {
      await dutyService.deleteDutyPost(post.id);
      Navigator.pop(context);
      _loadDutyPosts(); // Refresh the list
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Duty post deleted successfully')));
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Failed to delete duty post: $e')));
    }
  }

  void _showDutyPostDetails(DutyPost post) {
    showModalBottomSheet(
      context: context,
      builder: (context) => Container(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              post.name,
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 8),
            if (post.location != null && post.location!.isNotEmpty) ...[
              Text(
                'Location: ${post.location!}',
                style: TextStyle(fontSize: 16),
              ),
              SizedBox(height: 8),
            ],
            if (post.description != null && post.description!.isNotEmpty) ...[
              Text(
                'Description:',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              Text(post.description!),
              SizedBox(height: 8),
            ],
            SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: Text('Close'),
                ),
                ElevatedButton(
                  onPressed: () {
                    // Navigate to assign duty screen
                    Navigator.pop(context);
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) =>
                            AssignDutyScreen(dutyPostId: post.id),
                      ),
                    );
                  },
                  child: Text('Assign Duty'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
