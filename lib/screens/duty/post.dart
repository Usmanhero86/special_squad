// import 'package:flutter/material.dart';
// import 'package:provider/provider.dart';
// import '../../models/duty_post.dart';
// import '../../models/member.dart';
// import '../../services/duty_service.dart';
// import '../../services/member_service.dart';
// import '../../widgets/duty_post_card.dart';
// import '../../widgets/member_location_card.dart';
// import 'assign_duty_screen.dart';
//
// class DutyPostScreen extends StatefulWidget {
//   const DutyPostScreen({super.key});
//
//   @override
//   State<DutyPostScreen> createState() => _DutyPostScreenState();
// }
//
// class _DutyPostScreenState extends State<DutyPostScreen> {
//   List<DutyPost> _dutyPosts = [];
//   bool _isLoading = true;
//   List<Member> _membersByLocation = [];
//   List<String> _locations = [];
//   String? _selectedLocation;
//   int _selectedTab = 0;
//
//   @override
//   void initState() {
//     super.initState();
//     _loadData();
//   }
//
//   Future<void> _loadData() async {
//     final dutyService = Provider.of<DutyService>(context, listen: false);
//     final memberService = Provider.of<MemberService>(context, listen: false);
//
//     try {
//       final List<DutyPost> posts = await dutyService.getDutyPosts();
//       final List<String> locations = await memberService.getMemberLocations();
//
//       if (mounted) {
//         setState(() {
//           _dutyPosts = posts;
//           _locations = locations;
//           _isLoading = false;
//         });
//       }
//     } catch (e) {
//       if (mounted) {
//         setState(() {
//           _isLoading = false;
//         });
//         ScaffoldMessenger.of(
//           context,
//         ).showSnackBar(SnackBar(content: Text('Failed to load data: $e')));
//       }
//     }
//   }
//
//   Future<void> loadMembersByLocation(String location) async {
//     final memberService = Provider.of<MemberService>(context, listen: false);
//     try {
//       final members = await memberService.getMembersByLocation(location);
//       if (mounted) {
//         setState(() {
//           _membersByLocation = members;
//           _selectedLocation = location;
//         });
//       }
//     } catch (e) {
//       ScaffoldMessenger.of(
//         context,
//       ).showSnackBar(SnackBar(content: Text('Failed to load members: $e')));
//     }
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return DefaultTabController(
//       length: 2,
//       child: Scaffold(
//         appBar: AppBar(
//           title: Text('Duty Posts'),
//           bottom: TabBar(
//             onTap: (index) {
//               setState(() {
//                 _selectedTab = index;
//               });
//             },
//             tabs: [
//               Tab(text: 'Duty Posts'),
//               Tab(text: 'Members by Location'),
//             ],
//           ),
//         ),
//         body: _isLoading
//             ? Center(child: CircularProgressIndicator())
//             : TabBarView(
//           children: [
//             // Tab 1: Duty Posts
//             dutyPostsTab(),
//
//             // Tab 2: Members by Location
//             membersByLocationTab(),
//           ],
//         ),
//       ),
//     );
//   }
//
//   // Keep as method - depends on state
//   Widget dutyPostsTab() {
//     return _dutyPosts.isEmpty
//         ? Center(
//       child: Column(
//         mainAxisAlignment: MainAxisAlignment.center,
//         children: [
//           Icon(Icons.work_off, size: 64, color: Colors.grey),
//           SizedBox(height: 16),
//           Text(
//             'No duty posts available',
//             style: TextStyle(fontSize: 18, color: Colors.grey),
//           ),
//           SizedBox(height: 8),
//           ElevatedButton(
//             onPressed: addDutyPost,
//             child: Text('Add First Duty Post'),
//           ),
//         ],
//       ),
//     )
//         : ListView.builder(
//       itemCount: _dutyPosts.length,
//       itemBuilder: (context, index) {
//         final post = _dutyPosts[index];
//         return DutyPostCard(
//           post: post,
//           onTap: () => showDutyPostDetails(post),
//           onEdit: () => editDutyPost(post),
//           onDelete: () => deleteDutyPost(post),
//         );
//       },
//     );
//   }
//
//   // Keep as method - depends on state
//   Widget membersByLocationTab() {
//     return Column(
//       children: [
//         // Location Filter
//         Padding(
//           padding: EdgeInsets.all(16),
//           child: DropdownButtonFormField<String>(
//             initialValue: _selectedLocation,
//             decoration: InputDecoration(
//               labelText: 'Select Location',
//               border: OutlineInputBorder(),
//               prefixIcon: Icon(Icons.location_on),
//             ),
//             items: [
//               DropdownMenuItem(value: null, child: Text('All Locations')),
//               ..._locations.map((location) {
//                 return DropdownMenuItem(value: location, child: Text(location));
//               }),
//             ],
//             onChanged: (value) {
//               if (value != null) {
//                 loadMembersByLocation(value);
//               } else {
//                 setState(() {
//                   _selectedLocation = null;
//                   _membersByLocation = [];
//                 });
//               }
//             },
//           ),
//         ),
//
//         // Members List
//         Expanded(
//           child: _selectedLocation == null
//               ? Center(
//             child: Column(
//               mainAxisAlignment: MainAxisAlignment.center,
//               children: [
//                 Icon(Icons.location_on, size: 64, color: Colors.grey),
//                 SizedBox(height: 16),
//                 Text(
//                   'Select a location to view members',
//                   style: TextStyle(fontSize: 16, color: Colors.grey),
//                 ),
//               ],
//             ),
//           )
//               : _membersByLocation.isEmpty
//               ? Center(
//             child: Column(
//               mainAxisAlignment: MainAxisAlignment.center,
//               children: [
//                 Icon(Icons.people, size: 64, color: Colors.grey),
//                 SizedBox(height: 16),
//                 Text(
//                   'No members found for $_selectedLocation',
//                   style: TextStyle(fontSize: 16, color: Colors.grey),
//                 ),
//               ],
//             ),
//           )
//               : ListView.builder(
//             itemCount: _membersByLocation.length,
//             itemBuilder: (context, index) {
//               final member = _membersByLocation[index];
//               return MemberLocationCard(
//                 member: member,
//                 onAssignDuty: () {
//                   Navigator.push(
//                     context,
//                     MaterialPageRoute(
//                       builder: (context) => AssignDutyScreen(
//                         dutyPostId: null,
//                         preSelectedMemberId: member.id,
//                       ),
//                     ),
//                   );
//                 },
//               );
//             },
//           ),
//         ),
//       ],
//     );
//   }
//
//   void addDutyPost() {
//     final nameController = TextEditingController();
//     final locationController = TextEditingController();
//     final descriptionController = TextEditingController();
//
//     showDialog(
//       context: context,
//       builder: (context) => AlertDialog(
//         title: Text('Add New Duty Post'),
//         content: SingleChildScrollView(
//           child: Column(
//             mainAxisSize: MainAxisSize.min,
//             children: [
//               TextField(
//                 controller: nameController,
//                 decoration: InputDecoration(labelText: 'Post Name *'),
//               ),
//               SizedBox(height: 8),
//               TextField(
//                 controller: locationController,
//                 decoration: InputDecoration(labelText: 'Location'),
//               ),
//               SizedBox(height: 8),
//               TextField(
//                 controller: descriptionController,
//                 decoration: InputDecoration(labelText: 'Description'),
//                 maxLines: 3,
//               ),
//             ],
//           ),
//         ),
//         actions: [
//           TextButton(
//             onPressed: () => Navigator.pop(context),
//             child: Text('Cancel'),
//           ),
//           ElevatedButton(
//             onPressed: () => _saveDutyPost(
//               nameController.text,
//               locationController.text,
//               descriptionController.text,
//             ),
//             child: Text('Save'),
//           ),
//         ],
//       ),
//     );
//   }
//
//   Future<void> _saveDutyPost(
//       String name,
//       String location,
//       String description,
//       ) async {
//     if (name.trim().isEmpty) {
//       ScaffoldMessenger.of(
//         context,
//       ).showSnackBar(SnackBar(content: Text('Post name is required')));
//       return;
//     }
//
//     final dutyService = Provider.of<DutyService>(context, listen: false);
//     final newPost = DutyPost(
//       id: DateTime.now().millisecondsSinceEpoch.toString(),
//       name: name.trim(),
//       location: location.trim().isEmpty ? null : location.trim(),
//       description: description.trim().isEmpty ? null : description.trim(),
//     );
//
//     try {
//       await dutyService.addDutyPost(newPost);
//       Navigator.pop(context);
//       _loadData(); // Refresh the list
//       ScaffoldMessenger.of(
//         context,
//       ).showSnackBar(SnackBar(content: Text('Duty post added successfully')));
//     } catch (e) {
//       ScaffoldMessenger.of(
//         context,
//       ).showSnackBar(SnackBar(content: Text('Failed to add duty post: $e')));
//     }
//   }
//
//   void editDutyPost(DutyPost post) {
//     final nameController = TextEditingController(text: post.name);
//     final locationController = TextEditingController(text: post.location ?? '');
//     final descriptionController = TextEditingController(
//       text: post.description ?? '',
//     );
//
//     showDialog(
//       context: context,
//       builder: (context) => AlertDialog(
//         title: Text('Edit Duty Post'),
//         content: SingleChildScrollView(
//           child: Column(
//             mainAxisSize: MainAxisSize.min,
//             children: [
//               TextField(
//                 controller: nameController,
//                 decoration: InputDecoration(labelText: 'Post Name *'),
//               ),
//               SizedBox(height: 8),
//               TextField(
//                 controller: locationController,
//                 decoration: InputDecoration(labelText: 'Location'),
//               ),
//               SizedBox(height: 8),
//               TextField(
//                 controller: descriptionController,
//                 decoration: InputDecoration(labelText: 'Description'),
//                 maxLines: 3,
//               ),
//             ],
//           ),
//         ),
//         actions: [
//           TextButton(
//             onPressed: () => Navigator.pop(context),
//             child: Text('Cancel'),
//           ),
//           ElevatedButton(
//             onPressed: () => updateDutyPost(
//               post,
//               nameController.text,
//               locationController.text,
//               descriptionController.text,
//             ),
//             child: Text('Update'),
//           ),
//         ],
//       ),
//     );
//   }
//
//   Future<void> updateDutyPost(
//       DutyPost post,
//       String name,
//       String location,
//       String description,
//       ) async {
//     if (name.trim().isEmpty) {
//       ScaffoldMessenger.of(
//         context,
//       ).showSnackBar(SnackBar(content: Text('Post name is required')));
//       return;
//     }
//
//     final dutyService = Provider.of<DutyService>(context, listen: false);
//     final updatedPost = post.copyWith(
//       name: name.trim(),
//       location: location.trim().isEmpty ? null : location.trim(),
//       description: description.trim().isEmpty ? null : description.trim(),
//     );
//
//     try {
//       await dutyService.updateDutyPost(updatedPost);
//       Navigator.pop(context);
//       _loadData(); // Refresh the list
//       ScaffoldMessenger.of(
//         context,
//       ).showSnackBar(SnackBar(content: Text('Duty post updated successfully')));
//     } catch (e) {
//       ScaffoldMessenger.of(
//         context,
//       ).showSnackBar(SnackBar(content: Text('Failed to update duty post: $e')));
//     }
//   }
//
//   void deleteDutyPost(DutyPost post) {
//     showDialog(
//       context: context,
//       builder: (context) => AlertDialog(
//         title: Text('Delete Duty Post'),
//         content: Text('Are you sure you want to delete "${post.name}"?'),
//         actions: [
//           TextButton(
//             onPressed: () => Navigator.pop(context),
//             child: Text('Cancel'),
//           ),
//           ElevatedButton(
//             onPressed: () => confirmDeleteDutyPost(post),
//             style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
//             child: Text('Delete'),
//           ),
//         ],
//       ),
//     );
//   }
//
//   Future<void> confirmDeleteDutyPost(DutyPost post) async {
//     final dutyService = Provider.of<DutyService>(context, listen: false);
//
//     try {
//       await dutyService.deleteDutyPost(post.id);
//       Navigator.pop(context);
//       _loadData(); // Refresh the list
//       ScaffoldMessenger.of(
//         context,
//       ).showSnackBar(SnackBar(content: Text('Duty post deleted successfully')));
//     } catch (e) {
//       ScaffoldMessenger.of(
//         context,
//       ).showSnackBar(SnackBar(content: Text('Failed to delete duty post: $e')));
//     }
//   }
//
//   void showDutyPostDetails(DutyPost post) {
//     showModalBottomSheet(
//       context: context,
//       builder: (context) => Container(
//         padding: EdgeInsets.all(16),
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           mainAxisSize: MainAxisSize.min,
//           children: [
//             Text(
//               post.name,
//               style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
//             ),
//             SizedBox(height: 8),
//             if (post.location != null && post.location!.isNotEmpty) ...[
//               Text(
//                 'Location: ${post.location!}',
//                 style: TextStyle(fontSize: 16),
//               ),
//               SizedBox(height: 8),
//             ],
//             if (post.description != null && post.description!.isNotEmpty) ...[
//               Text(
//                 'Description:',
//                 style: TextStyle(fontWeight: FontWeight.bold),
//               ),
//               Text(post.description!),
//               SizedBox(height: 8),
//             ],
//             SizedBox(height: 20),
//             Row(
//               mainAxisAlignment: MainAxisAlignment.end,
//               children: [
//                 TextButton(
//                   onPressed: () => Navigator.pop(context),
//                   child: Text('Close'),
//                 ),
//                 ElevatedButton(
//                   onPressed: () {
//                     Navigator.pop(context);
//                     Navigator.push(
//                       context,
//                       MaterialPageRoute(
//                         builder: (context) =>
//                             AssignDutyScreen(dutyPostId: post.id),
//                       ),
//                     );
//                   },
//                   child: Text('Assign Duty'),
//                 ),
//               ],
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }