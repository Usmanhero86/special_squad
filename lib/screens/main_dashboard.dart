import 'package:flutter/material.dart';
import 'package:http/http.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:special_squad/screens/members/member_list_screen.dart';
import '../screens/profile/profile_screen.dart';
import '../services/memberProvider.dart';
import 'search/search_screen.dart';
import 'settings/settings_screen.dart';

class MainDashboard extends StatefulWidget {
  const MainDashboard({super.key});

  @override
  State<MainDashboard> createState() => _MainDashboardState();
}

class _MainDashboardState extends State<MainDashboard> {
  int _currentIndex = 0;

  final List<Widget> _screens = [
    const DashboardHomeScreen(),
    const SearchScreen(),
    const SettingsScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _screens[_currentIndex],
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surface,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.1),
              blurRadius: 10,
              offset: const Offset(0, -2),
            ),
          ],
        ),
        child: BottomNavigationBar(
          currentIndex: _currentIndex,
          onTap: (index) {
            setState(() {
              _currentIndex = index;
            });
          },
          type: BottomNavigationBarType.fixed,
          backgroundColor: Colors.transparent,
          elevation: 0,
          selectedItemColor: const Color(0xFF2C3E50),
          unselectedItemColor: Theme.of(
            context,
          ).colorScheme.onSurface.withValues(alpha: 0.6),
          selectedLabelStyle: const TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: Color(0xFF2C3E50)
          ),
          unselectedLabelStyle: const TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w400,
          ),
          items: const [
            BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
            BottomNavigationBarItem(icon: Icon(Icons.search), label: 'Search'),
            BottomNavigationBarItem(
              icon: Icon(Icons.settings),
              label: 'Settings',
            ),
          ],
        ),
      ),
    );
  }
}

class DashboardHomeScreen extends StatefulWidget {
  const DashboardHomeScreen({super.key});

  @override
  State<DashboardHomeScreen> createState() => _DashboardHomeScreenState();
}

class _DashboardHomeScreenState extends State<DashboardHomeScreen> {
  @override
  void initState() {
    super.initState();
    _loadUserInfo();
  }
  String _userName = '';
  String _userRole = '';
  bool _isUserLoading = true;
  Future<void> _loadUserInfo() async {
    final prefs = await SharedPreferences.getInstance();

    setState(() {
      _userName = prefs.getString('userName') ?? 'Admin';
      _userRole = prefs.getString('userRole') ?? 'User';
      _isUserLoading = false;
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
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // Menu Icon
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Theme.of(
                        context,
                      ).colorScheme.onSurface.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(
                      Icons.menu,
                      color: Theme.of(context).colorScheme.onSurface,
                      size: 24,
                    ),
                  ),

                  // Home Title
                  Text(
                    'Home',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w600,
                      color: Theme.of(context).colorScheme.onSurface,
                    ),
                  ),

                  // Notification Bell
                  Stack(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: Theme.of(
                            context,
                          ).colorScheme.onSurface.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Icon(
                          Icons.notifications_outlined,
                          color: Theme.of(context).colorScheme.onSurface,
                          size: 24,
                        ),
                      ),
                      // Notification Badge
                      Positioned(
                        right: 6,
                        top: 6,
                        child: Container(
                          width: 8,
                          height: 8,
                          decoration: const BoxDecoration(
                            color: Colors.red,
                            shape: BoxShape.circle,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
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
                      'Hi $_userName!',
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
                      // onTap: () {
                      //   Navigator.push(
                      //     context,
                      //     MaterialPageRoute(
                      //       builder: (context) => const ProfileScreen(),
                      //     ),
                      //   );
                      // },
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
                                    style: TextStyle(
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
                      childAspectRatio: 1.3, // Increased to give more height
                      children: [
                        _buildDashboardCard(
                          context,
                          icon: Icons.person_add,
                          title: 'Register Member',
                          subtitle: 'Add new members',
                          backgroundColor: const Color(0xFF2C3E50),
                          iconColor: const Color(0xFFD4AF37),
                          onTap: () =>
                              Navigator.pushNamed(context, '/members/add'),
                        ),
                         _buildDashboardCard(
                          context,
                          icon: Icons.person_add,
                          title: 'Member',
                          subtitle: 'Members List',
                          backgroundColor: const Color(0xFF2C3E50),
                          iconColor: const Color(0xFFD4AF37),
                          onTap: () =>
                              Navigator.push(context, MaterialPageRoute
                              (builder: (context)=> MemberListScreen()),)
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
                          iconColor:  Color(0xFF2C3E50),
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
                        // _buildDashboardCard(
                        //   context,
                        //   icon: Icons.person,
                        //   title: 'Reports',
                        //   subtitle: 'Generate reports',
                        //   backgroundColor: Colors.white,
                        //   iconColor: const Color(0xFF2C3E50),
                        //   textColor: const Color(0xFF2C3E50),
                        //   onTap: () => _showReports(context),
                        // ),
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
        padding: const EdgeInsets.all(16), // Reduced padding from 20 to 16
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
          mainAxisAlignment: MainAxisAlignment.spaceBetween, // Added this
          children: [
            // Icon
            Container(
              padding: const EdgeInsets.all(
                10,
              ), // Reduced padding from 12 to 10
              decoration: BoxDecoration(
                color: backgroundColor == Colors.white
                    ? iconColor // Colored background for white cards
                    : iconColor.withValues(
                        alpha: 0.2,
                      ), // Semi-transparent for colored cards
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                icon,
                color: Colors.white, // White icon on colored background
                size: 20,
              ),
            ),

            // Text content
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Title
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 14, // Reduced from 16 to 14
                    fontWeight: FontWeight.bold,
                    color: cardTextColor,
                  ),
                  maxLines: 2, // Added maxLines
                  overflow: TextOverflow.ellipsis, // Added overflow handling
                ),
                const SizedBox(height: 2), // Reduced spacing
                // Subtitle
                Text(
                  subtitle,
                  style: TextStyle(
                    fontSize: 11, // Reduced from 12 to 11
                    color: cardTextColor.withValues(alpha: 0.8),
                  ),
                  maxLines: 2, // Added maxLines
                  overflow: TextOverflow.ellipsis, // Added overflow handling
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _showReports(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Reports feature coming soon!'),
        backgroundColor: Colors.blue,
      ),
    );
  }
}
