import 'package:flutter/material.dart';
import 'package:special_squad/screens/payments/add_payment_screen.dart';
import 'package:special_squad/screens/payments/payments_screen.dart';
import './members/add_member_screen.dart';
import './members/member_list_screen.dart';
import './duty/duty_post_screen.dart';
import './duty/duty_roster_screen.dart';
import './payments/payment_history_screen.dart';
import '../widgets/custom_appbar.dart';
import '../widgets/dashboard_card.dart';
import 'duty/assign_duty_screen.dart';

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(
        title: 'Organization Dashboard',
        showBackButton: false,
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
            onTap: () => _showReports(context),
          ),
          DashboardCard(
            icon: Icons.settings,
            title: 'Settings',
            color: Colors.grey,
            subtitle: 'App settings',
            onTap: () => _showSettings(context),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _quickAdd(context),
        tooltip: 'Quick Add',
        child: Icon(Icons.add),
      ),
    );
  }

  void _quickAdd(BuildContext context) {
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

  void _showReports(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Reports feature coming soon!')),
    );
  }

  void _showSettings(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Settings feature coming soon!')),
    );
  }
}