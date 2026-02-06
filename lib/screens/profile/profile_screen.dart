// import 'package:flutter/material.dart';
// import 'package:provider/provider.dart';
// import '../../models/member.dart';
// import '../../services/auth_service.dart';
// import '../../services/member_service.dart';
// import '../../widgets/theme_toggle_button.dart';
// import '../auth/login_screen.dart';
// import 'personal_info_screen.dart';
// import 'addresses_screen.dart';
// import 'notifications_screen.dart';
// import 'payment_method_screen.dart';
//
// class ProfileScreen extends StatefulWidget {
//   const ProfileScreen({super.key});
//
//   @override
//   State<ProfileScreen> createState() => _ProfileScreenState();
// }
//
// class _ProfileScreenState extends State<ProfileScreen> {
//   Member? _currentUser;
//   bool _isLoading = true;
//
//   @override
//   void initState() {
//     super.initState();
//     _loadCurrentUser();
//   }
//
//   Future<void> _loadCurrentUser() async {
//     final authService = Provider.of<AuthService>(context, listen: false);
//     final memberService = Provider.of<MemberService>(context, listen: false);
//
//     try {
//       final currentUser = authService.currentUser;
//       if (currentUser != null) {
//         final members = await memberService.getMembersSync();
//         final user = members.firstWhere(
//           (member) =>
//               member.fullName.toLowerCase() ==
//               currentUser.fullName.toLowerCase(),
//           orElse: () => members.isNotEmpty ? members.first : _createDemoUser(),
//         );
//
//         if (mounted) {
//           setState(() {
//             _currentUser = user;
//             _isLoading = false;
//           });
//         }
//       } else {
//         // If no authenticated user, use first member or create demo user
//         final members = await memberService.getMembersSync();
//         if (mounted) {
//           setState(() {
//             _currentUser = members.isNotEmpty
//                 ? members.first
//                 : _createDemoUser();
//             _isLoading = false;
//           });
//         }
//       }
//     } catch (e) {
//       if (mounted) {
//         setState(() {
//           _currentUser = _createDemoUser();
//           _isLoading = false;
//         });
//       }
//     }
//   }
//
//   Member _createDemoUser() {
//     return Member(
//       id: 'demo_user',
//       fullName: 'Muhammad Sani',
//       rifleNumber: 'CMD001',
//       phone: '+234 123 456 7890',
//       dateOfBirth: DateTime(1990, 1, 1),
//       address: '123 Command Street, Abuja',
//       position: 'Commander',
//       joinDate: DateTime.now(),
//       location: 'HQ',
//     );
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: Theme.of(context).colorScheme.surface,
//       appBar: AppBar(
//         title: const Text(
//           'Profile',
//           style: TextStyle(fontSize: 20, fontWeight: FontWeight.w600),
//         ),
//         centerTitle: true,
//         backgroundColor: Colors.transparent,
//         elevation: 0,
//         leading: IconButton(
//           icon: const Icon(Icons.arrow_back_ios),
//           onPressed: () => Navigator.pop(context),
//         ),
//         actions: [
//           IconButton(
//             icon: const Icon(Icons.more_horiz),
//             onPressed: () => _showMoreOptions(),
//           ),
//         ],
//       ),
//       body: _isLoading
//           ? const Center(child: CircularProgressIndicator())
//           : SingleChildScrollView(
//               padding: const EdgeInsets.all(20),
//               child: Column(
//                 children: [
//                   // Profile Header
//                   _buildProfileHeader(),
//                   const SizedBox(height: 40),
//
//                   // Menu Items
//                   _buildMenuItem(
//                     icon: Icons.person_outline,
//                     title: 'Personal Info',
//                     color: Colors.orange,
//                     onTap: () => _navigateToPersonalInfo(),
//                   ),
//                   const SizedBox(height: 20),
//
//                   _buildMenuItem(
//                     icon: Icons.location_on_outlined,
//                     title: 'Addresses',
//                     color: Colors.blue,
//                     onTap: () => _navigateToAddresses(),
//                   ),
//                   const SizedBox(height: 20),
//
//                   _buildMenuItem(
//                     icon: Icons.notifications_outlined,
//                     title: 'Notifications',
//                     color: Colors.amber,
//                     onTap: () => _navigateToNotifications(),
//                   ),
//                   const SizedBox(height: 20),
//
//                   _buildMenuItem(
//                     icon: Icons.credit_card_outlined,
//                     title: 'Payment Method',
//                     color: Colors.blue,
//                     onTap: () => _navigateToPaymentMethod(),
//                   ),
//                   const SizedBox(height: 40),
//
//                   _buildMenuItem(
//                     icon: Icons.logout,
//                     title: 'Log Out',
//                     color: Colors.red,
//                     onTap: () => _showLogoutDialog(),
//                   ),
//                 ],
//               ),
//             ),
//     );
//   }
//
//   Widget _buildProfileHeader() {
//     return Column(
//       children: [
//         // Profile Picture
//         Container(
//           width: 100,
//           height: 100,
//           decoration: BoxDecoration(
//             shape: BoxShape.circle,
//             color: const Color(0xFFFFB4A3), // Peach color from the image
//           ),
//           child: _currentUser?.profileImage != null
//               ? ClipOval(
//                   child: Image.network(
//                     _currentUser!.profileImage!,
//                     width: 100,
//                     height: 100,
//                     fit: BoxFit.cover,
//                     errorBuilder: (context, error, stackTrace) {
//                       return Center(
//                         child: Text(
//                           _currentUser?.fullName
//                                   .substring(0, 1)
//                                   .toUpperCase() ??
//                               'U',
//                           style: const TextStyle(
//                             fontSize: 40,
//                             fontWeight: FontWeight.bold,
//                             color: Colors.white,
//                           ),
//                         ),
//                       );
//                     },
//                   ),
//                 )
//               : Center(
//                   child: Text(
//                     _currentUser?.fullName.substring(0, 1).toUpperCase() ?? 'U',
//                     style: const TextStyle(
//                       fontSize: 40,
//                       fontWeight: FontWeight.bold,
//                       color: Colors.white,
//                     ),
//                   ),
//                 ),
//         ),
//         const SizedBox(height: 20),
//
//         // Name and Position
//         Text(
//           _currentUser?.fullName ?? 'User Name',
//           style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
//         ),
//         const SizedBox(height: 5),
//         Text(
//           _currentUser?.position ?? 'Member',
//           style: TextStyle(
//             fontSize: 16,
//             color: Theme.of(
//               context,
//             ).colorScheme.onSurface.withValues(alpha: 0.6),
//           ),
//         ),
//       ],
//     );
//   }
//
//   Widget _buildMenuItem({required IconData icon,required String title,required Color color,required VoidCallback onTap}) {
//     return Container(
//       decoration: BoxDecoration(
//         color: Theme.of(context).colorScheme.surface,
//         borderRadius: BorderRadius.circular(15),
//         boxShadow: [
//           BoxShadow(
//             color: Colors.black.withValues(alpha: 0.05),
//             blurRadius: 10,
//             offset: const Offset(0, 2),
//           ),
//         ],
//       ),
//       child: ListTile(
//         contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
//         leading: Container(
//           width: 40,
//           height: 40,
//           decoration: BoxDecoration(
//             color: color.withValues(alpha: 0.1),
//             borderRadius: BorderRadius.circular(10),
//           ),
//           child: Icon(icon, color: color, size: 22),
//         ),
//         title: Text(
//           title,
//           style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
//         ),
//         trailing: Icon(
//           Icons.arrow_forward_ios,
//           size: 16,
//           color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.4),
//         ),
//         onTap: onTap,
//       ),
//     );
//   }
//
//   void _navigateToPersonalInfo() {
//     Navigator.push(
//       context,
//       MaterialPageRoute(
//         builder: (context) => PersonalInfoScreen(member: _currentUser),
//       ),
//     );
//   }
//
//   void _navigateToAddresses() {
//     Navigator.push(
//       context,
//       MaterialPageRoute(
//         builder: (context) => AddressesScreen(member: _currentUser),
//       ),
//     );
//   }
//
//   void _navigateToNotifications() {
//     Navigator.push(
//       context,
//       MaterialPageRoute(builder: (context) => const NotificationsScreen()),
//     );
//   }
//
//   void _navigateToPaymentMethod() {
//     Navigator.push(
//       context,
//       MaterialPageRoute(
//         builder: (context) => PaymentMethodScreen(member: _currentUser),
//       ),
//     );
//   }
//
//   void _showMoreOptions() {
//     showModalBottomSheet(
//       context: context,
//       backgroundColor: Colors.transparent,
//       builder: (context) => Container(
//         decoration: BoxDecoration(
//           color: Theme.of(context).colorScheme.surface,
//           borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
//         ),
//         child: Column(
//           mainAxisSize: MainAxisSize.min,
//           children: [
//             Container(
//               width: 40,
//               height: 4,
//               margin: const EdgeInsets.symmetric(vertical: 12),
//               decoration: BoxDecoration(
//                 color: Theme.of(
//                   context,
//                 ).colorScheme.outline.withValues(alpha: 0.3),
//                 borderRadius: BorderRadius.circular(2),
//               ),
//             ),
//             ListTile(
//               leading: const Icon(Icons.edit),
//               title: const Text('Edit Profile'),
//               onTap: () {
//                 Navigator.pop(context);
//                 _navigateToPersonalInfo();
//               },
//             ),
//             ListTile(
//               leading: const Icon(Icons.settings),
//               title: const Text('Settings'),
//               onTap: () {
//                 Navigator.pop(context);
//                 // Navigate to settings
//               },
//             ),
//             const ThemeToggleButton(),
//             const SizedBox(height: 20),
//           ],
//         ),
//       ),
//     );
//   }
//
//   void _showLogoutDialog() {
//     showDialog(
//       context: context,
//       builder: (context) => AlertDialog(
//         title: const Text('Log Out'),
//         content: const Text('Are you sure you want to log out?'),
//         actions: [
//           TextButton(
//             onPressed: () => Navigator.pop(context),
//             child: const Text('Cancel'),
//           ),
//           ElevatedButton(
//             onPressed: () => _logout(),
//             style: ElevatedButton.styleFrom(
//               backgroundColor: Colors.red,
//               foregroundColor: Colors.white,
//             ),
//             child: const Text('Log Out'),
//           ),
//         ],
//       ),
//     );
//   }
//
//   void _logout() async {
//     final authService = Provider.of<AuthService>(context, listen: false);
//
//     try {
//       await authService.signOut();
//
//       if (mounted) {
//         Navigator.of(context).pushAndRemoveUntil(
//           MaterialPageRoute(builder: (context) => const LoginScreen()),
//           (route) => false,
//         );
//       }
//     } catch (e) {
//       if (mounted) {
//         ScaffoldMessenger.of(context).showSnackBar(
//           SnackBar(
//             content: Text('Error logging out: $e'),
//             backgroundColor: Colors.red,
//           ),
//         );
//       }
//     }
//   }
// }
