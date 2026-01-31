import 'package:flutter/material.dart';
import 'package:special_squad/screens/payments/add_payment_screen.dart';
import 'package:special_squad/screens/payments/payments_screen.dart';
import './members/add_member_screen.dart';
import './members/member_list_screen.dart';
import './duty/duty_post_screen.dart';
import './duty/duty_roster_screen.dart';
import './payments/payment_history_screen.dart';
import '../widgets/dashboard_card.dart';
import '../widgets/theme_toggle_button.dart';
import 'duty/assign_duty_screen.dart';

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Organization Dashboard'),
        centerTitle: true,
        actions: [
          const ThemeToggleButton(),
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: () {},
            tooltip: 'Search',
          ),
        ],
      ),
      body: GridView.count(
        crossAxisCount: 2,
        padding: EdgeInsets.all(16),
        childAspectRatio: 0.9,
        children: [
          DashboardCard(
            icon: Icons.group_add,
            title: 'Register Member',
            color: Colors.blue,
            subtitle: 'Add new members',
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => AddMemberScreen()),
            ),
          ),
          DashboardCard(
            icon: Icons.list_alt,
            title: 'Member List',
            color: Colors.green,
            subtitle: 'View all members',
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => MemberListScreen()),
            ),
          ),
          DashboardCard(
            icon: Icons.work,
            title: 'Duty Posts',
            color: Colors.orange,
            subtitle: 'Manage duty posts',
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => DutyPostScreen()),
            ),
          ),
          DashboardCard(
            icon: Icons.schedule,
            title: 'Duty Roster',
            color: Colors.purple,
            subtitle: 'Schedule duties',
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => DutyRosterScreen()),
            ),
          ),
          DashboardCard(
            icon: Icons.payment,
            title: 'Payments',
            color: Colors.teal,
            subtitle: 'Record payments',
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => PaymentScreen()),
            ),
          ),
          DashboardCard(
            icon: Icons.history,
            title: 'Payment History',
            color: Colors.red,
            subtitle: 'View all payments',
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => PaymentHistoryScreen()),
            ),
          ),
          DashboardCard(
            icon: Icons.bar_chart,
            title: 'Reports',
            color: Colors.indigo,
            subtitle: 'Generate reports',
            onTap: () => showReports(context),
          ),
          DashboardCard(
            icon: Icons.settings,
            title: 'Settings',
            color: Colors.grey,
            subtitle: 'App settings',
            onTap: () => showSettings(context),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => quickAdd(context),
        tooltip: 'Quick Add',
        child: Icon(Icons.add),
      ),
    );
  }

  void quickAdd(BuildContext context) {
    showModalBottomSheet(
      context: context,
      builder: (context) => Container(
        padding: EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Quick Add',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 20),
            ListTile(
              leading: Icon(Icons.person_add, color: Colors.blue),
              title: Text('Add Member'),
              onTap: () {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => AddMemberScreen()),
                );
              },
            ),
            ListTile(
              leading: Icon(Icons.payment, color: Colors.green),
              title: Text('Record Payment'),
              onTap: () {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => AddPaymentScreen()),
                );
              },
            ),
            ListTile(
              leading: Icon(Icons.work, color: Colors.orange),
              title: Text('Assign Duty'),
              onTap: () {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => AssignDutyScreen()),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  void showReports(BuildContext context) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text('Reports feature coming soon!')));
  }

  void showSettings(BuildContext context) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text('Settings feature coming soon!')));
  }
}

// dart
// import 'package:flutter/material.dart';
//
// class DashboardScreen extends StatelessWidget {
//   const DashboardScreen({super.key});
//
//   int _columnsForWidth(double width) {
//     if (width >= 1200) return 4;
//     if (width >= 900) return 3;
//     if (width >= 600) return 2;
//     return 1;
//   }
//
//   List<Widget> _buildCards(BuildContext context) {
//     return [
//       DashboardCard(
//         title: 'Members',
//         value: '128',
//         icon: Icons.people,
//         color: Colors.blue,
//         onTap: () {
//           Navigator.pushNamed(context, '/members');
//         },
//       ),
//       DashboardCard(
//         title: 'Duties',
//         value: '8',
//         icon: Icons.event_note,
//         color: Colors.teal,
//         onTap: () {
//           // navigate or show details
//         },
//       ),
//       DashboardCard(
//         title: 'Payments',
//         value: '\$5,420',
//         icon: Icons.payment,
//         color: Colors.indigo,
//         onTap: () {
//           Navigator.pushNamed(context, '/payments');
//         },
//       ),
//       DashboardCard(
//         title: 'Pending',
//         value: '3',
//         icon: Icons.pending_actions,
//         color: Colors.orange,
//         onTap: () {
//           // example action
//         },
//       ),
//     ];
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: const Text('Organization Dashboard'),
//         centerTitle: true,
//         actions: [
//           IconButton(
//             icon: const Icon(Icons.search),
//             onPressed: () {},
//             tooltip: 'Search',
//           ),
//           IconButton(
//             icon: const Icon(Icons.notifications_none),
//             onPressed: () {},
//             tooltip: 'Notifications',
//           ),
//         ],
//       ),
//       drawer: Drawer(
//         child: ListView(
//           padding: EdgeInsets.zero,
//           children: [
//             const DrawerHeader(
//               decoration: BoxDecoration(color: Colors.blue),
//               child: Text('Menu', style: TextStyle(color: Colors.white)),
//             ),
//             ListTile(
//               leading: const Icon(Icons.dashboard),
//               title: const Text('Dashboard'),
//               onTap: () => Navigator.pop(context),
//             ),
//             ListTile(
//               leading: const Icon(Icons.people),
//               title: const Text('Members'),
//               onTap: () {
//                 Navigator.pop(context);
//                 Navigator.pushNamed(context, '/members');
//               },
//             ),
//             ListTile(
//               leading: const Icon(Icons.payment),
//               title: const Text('Payments'),
//               onTap: () {
//                 Navigator.pop(context);
//                 Navigator.pushNamed(context, '/payments');
//               },
//             ),
//           ],
//         ),
//       ),
//       body: LayoutBuilder(
//         builder: (context, constraints) {
//           final columns = _columnsForWidth(constraints.maxWidth);
//           final cards = _buildCards(context);
//
//           return SingleChildScrollView(
//             padding: const EdgeInsets.all(16.0),
//             child: Column(
//               children: [
//                 // Top stats grid
//                 GridView.count(
//                   crossAxisCount: columns,
//                   crossAxisSpacing: 16,
//                   mainAxisSpacing: 16,
//                   shrinkWrap: true,
//                   physics: const NeverScrollableScrollPhysics(),
//                   childAspectRatio: 3 / 1.2,
//                   children: cards,
//                 ),
//                 const SizedBox(height: 24),
//                 // Example larger content area
//                 Row(
//                   crossAxisAlignment: CrossAxisAlignment.start,
//                   children: [
//                     Expanded(
//                       flex: 2,
//                       child: Card(
//                         child: SizedBox(
//                           height: 240,
//                           child: Padding(
//                             padding: const EdgeInsets.all(16.0),
//                             child: Column(
//                               crossAxisAlignment: CrossAxisAlignment.start,
//                               children: const [
//                                 Text('Overview', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600)),
//                                 SizedBox(height: 12),
//                                 Expanded(child: Center(child: Text('Charts / lists go here'))),
//                               ],
//                             ),
//                           ),
//                         ),
//                       ),
//                     ),
//                     const SizedBox(width: 16),
//                     if (constraints.maxWidth >= 900)
//                       Expanded(
//                         flex: 1,
//                         child: Card(
//                           child: SizedBox(
//                             height: 240,
//                             child: Padding(
//                               padding: const EdgeInsets.all(16.0),
//                               child: Column(
//                                 crossAxisAlignment: CrossAxisAlignment.start,
//                                 children: const [
//                                   Text('Recent Activity', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600)),
//                                   SizedBox(height: 12),
//                                   Expanded(child: Center(child: Text('Recent events list'))),
//                                 ],
//                               ),
//                             ),
//                           ),
//                         ),
//                       ),
//                   ],
//                 ),
//               ],
//             ),
//           );
//         },
//       ),
//     );
//   }
// }
//
// class DashboardCard extends StatelessWidget {
//   final String title;
//   final String value;
//   final IconData icon;
//   final Color color;
//   final VoidCallback? onTap;
//
//   const DashboardCard({
//     super.key,
//     required this.title,
//     required this.value,
//     required this.icon,
//     this.color = Colors.blue,
//     this.onTap,
//   });
//
//   @override
//   Widget build(BuildContext context) {
//     final cardContent = Row(
//       children: [
//         CircleAvatar(
//           radius: 28,
//           backgroundColor: color.withOpacity(0.15),
//           child: Icon(icon, color: color, size: 28),
//         ),
//         const SizedBox(width: 12),
//         Expanded(
//           child: Column(
//             crossAxisAlignment: CrossAxisAlignment.start,
//             mainAxisAlignment: MainAxisAlignment.center,
//             children: [
//               Text(title, style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: Colors.grey[700])),
//               const SizedBox(height: 6),
//               Text(value, style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold)),
//             ],
//           ),
//         ),
//         Icon(Icons.chevron_right, color: Colors.grey[400]),
//       ],
//     );
//
//     return InkWell(
//       onTap: onTap,
//       borderRadius: BorderRadius.circular(12),
//       child: Card(
//         shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
//         elevation: 2,
//         child: Padding(
//           padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
//           child: cardContent,
//         ),
//       ),
//     );
//   }
// }
