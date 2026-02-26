import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:special_squad/screens/members/member_list_screen.dart';

class DashboardHomeScreen extends StatefulWidget {
  const DashboardHomeScreen({super.key});

  @override
  State<DashboardHomeScreen> createState() => _DashboardHomeScreenState();
}

class _DashboardHomeScreenState extends State<DashboardHomeScreen> {
  String _userName = '';
  String _userRole = '';

  @override
  void initState() {
    super.initState();
    _loadUserInfo();
  }

  Future<void> _loadUserInfo() async {
    final prefs = await SharedPreferences.getInstance();

    setState(() {
      _userName = prefs.getString('userName') ?? 'Admin';
      _userRole = prefs.getString('userRole') ?? 'User';
    });
  }

  String _getGreeting() {
    final hour = DateTime.now().hour;
    if (hour < 12) {
      return 'Good Morning';
    } else if (hour < 17) {
      return 'Good Afternoon';
    } else {
      return 'Good Evening';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      body: SafeArea(
        child: Column(
          children: [
            // Top App Bar
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
              child: Align(
                alignment: Alignment.center,
                child: Text(
                  'Dashboard',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w600,
                    color: Theme.of(context).colorScheme.onSurface,
                  ),
                ),
              ),
            ),

            // Main Content
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 20),

                    // Greeting
                    Text(
                      'Hi, $_userName!',
                      style: TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        color: Theme.of(context).colorScheme.onSurface,
                      ),
                    ),
                    Text(
                      _getGreeting(),
                      style: TextStyle(
                        fontSize: 16,
                        color: Theme.of(
                          context,
                        ).colorScheme.onSurface.withValues(alpha: 0.6),
                      ),
                    ),
                    const SizedBox(height: 30),

                    // User Profile Card
                    GestureDetector(
                      child: Container(
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          color: const Color(0xFF2C3E50),
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Row(
                          children: [
                            // Profile Image
                            CircleAvatar(
                              radius: 30,
                              backgroundColor: Colors.white.withValues(
                                alpha: 0.2,
                              ),
                              backgroundImage: const AssetImage(
                                'lib/assets/Screenshot 2026-01-30 142441.png',
                              ),
                              onBackgroundImageError: (exception, stackTrace) {
                                // Handle image loading error
                              },
                              child: const Icon(
                                Icons.person,
                                size: 30,
                                color: Colors.white,
                              ),
                            ),
                            const SizedBox(width: 16),

                            // User Info
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    _userName,
                                    style: const TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.white,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    _userRole,
                                    style: TextStyle(
                                      fontSize: 14,
                                      color: Colors.white.withValues(
                                        alpha: 0.8,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),

                            // Arrow Icon
                            Icon(
                              Icons.chevron_right,
                              color: Colors.white.withValues(alpha: 0.8),
                              size: 24,
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 30),

                    // Dashboard Cards Grid
                    GridView.count(
                      crossAxisCount: 2,
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      crossAxisSpacing: 16,
                      mainAxisSpacing: 16,
                      childAspectRatio: 1.3,
                      children: [
                        _buildDashboardCard(
                          context,
                          icon: Icons.person_add,
                          title: 'Register Member',
                          subtitle: 'Add new members',
                          backgroundColor:  Colors.white,
                          iconColor: const Color(0xFF2C3E50),
                          textColor: Color(0xFF2C3E50),
                          onTap: () =>
                              Navigator.pushNamed(context, '/members/add'),
                        ),
                        _buildDashboardCard(
                          context,
                          icon: Icons.person,
                          title: 'Member',
                          subtitle: 'Members List',
                          backgroundColor: Colors.white,
                          iconColor: const Color(0xFF2C3E50),
                          textColor: Color(0xFF2C3E50),
                          onTap: () => Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const MemberListScreen(),
                            ),
                          ),
                        ),
                        _buildDashboardCard(
                          context,
                          icon: Icons.work,
                          title: 'Duty Posts',
                          subtitle: 'View all members',
                          backgroundColor: Colors.white,
                          iconColor: const Color(0xFF2C3E50),
                          textColor: const Color(0xFF2C3E50),
                          onTap: () =>
                              Navigator.pushNamed(context, '/duty/posts'),
                        ),
                        _buildDashboardCard(
                          context,
                          icon: Icons.location_pin,
                          title: 'Location',
                          subtitle: 'Add Location',
                          backgroundColor: Colors.white,
                          iconColor: const Color(0xFF2C3E50),
                          textColor: const Color(0xFF2C3E50),
                          onTap: () =>
                              Navigator.pushNamed(context, '/duty/roster'),
                        ),
                        _buildDashboardCard(
                          context,
                          icon: Icons.payment,
                          title: 'Payments',
                          subtitle: 'Record Payments',
                          backgroundColor: Colors.white,
                          iconColor: const Color(0xFF2C3E50),
                          textColor: const Color(0xFF2C3E50),
                          onTap: () =>
                              Navigator.pushNamed(context, '/payments'),
                        ),
                        _buildDashboardCard(
                          context,
                          icon: Icons.history,
                          title: 'Payment History',
                          subtitle: 'View all payments',
                          backgroundColor: Colors.white,
                          iconColor: const Color(0xFF2C3E50),
                          textColor: const Color(0xFF2C3E50),
                          onTap: () =>
                              Navigator.pushNamed(context, '/payments/history'),
                        ),
                      ],
                    ),
                    const SizedBox(height: 30),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDashboardCard(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String subtitle,
    required Color backgroundColor,
    required Color iconColor,
    Color? textColor,
    required VoidCallback onTap,
  }) {
    final cardTextColor = textColor ?? Colors.white;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: backgroundColor,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.1),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            // Icon
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: backgroundColor == Colors.white
                    ? iconColor
                    : iconColor.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: Colors.white, size: 20),
            ),

            // Text content
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Title
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: cardTextColor,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 2),
                // Subtitle
                Text(
                  subtitle,
                  style: TextStyle(
                    fontSize: 11,
                    color: cardTextColor.withValues(alpha: 0.8),
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
