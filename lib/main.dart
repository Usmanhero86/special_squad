import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:special_squad/screens/auth/login_screen.dart';
import 'package:special_squad/screens/main_dashboard.dart';
import 'package:special_squad/screens/members/member_list_screen.dart';
import 'package:special_squad/screens/members/add_member_screen.dart';
import 'package:special_squad/screens/payments/payment_history_screen.dart';
import 'package:special_squad/screens/duty/duty_post_screen.dart';
import 'package:special_squad/screens/location/location.dart';
import 'package:special_squad/screens/payments/payments_screen.dart';
import 'package:special_squad/screens/splash/splash_screen.dart';

import 'package:special_squad/services/duty_service.dart';
import 'package:special_squad/services/location_provider.dart';
import 'package:special_squad/services/location_service.dart';
import 'package:special_squad/services/login.dart';
import 'package:special_squad/services/memberProvider.dart';
import 'package:special_squad/services/member_service.dart';
import 'package:special_squad/services/payment_service.dart';
import 'package:special_squad/services/theme_service.dart';

import 'core/api_client.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final themeService = ThemeService();

  runApp(MyApp(themeService: themeService));
}

class MyApp extends StatelessWidget {
  final ThemeService themeService;

  const MyApp({super.key, required this.themeService});

  @override
  Widget build(BuildContext context) {
    final apiClient = ApiClient(baseUrl: 'https://api.cjtf.buzz');

    return MultiProvider(
      providers: [
        Provider<ApiClient>.value(value: apiClient),

        /// ================= API SERVICES =================
        Provider<AuthService>(
          create: (context) => AuthService(api: context.read<ApiClient>()),
        ),

        Provider<DutyService>(
          create: (context) => DutyService(api: context.read<ApiClient>()),
        ),

        Provider<LocationService>(
          create: (context) => LocationService(api: context.read<ApiClient>()),
        ),

        Provider<MemberService>(
          create: (context) => MemberService(api: context.read<ApiClient>()),
        ),

        Provider<PaymentService>(create: (_) => PaymentService(api: apiClient)),

        /// ================= STATE (ChangeNotifier) =================
        ChangeNotifierProvider<ThemeService>.value(value: themeService),

        ChangeNotifierProvider<LocationProvider>(
          create: (context) =>
              LocationProvider(service: context.read<LocationService>()),
        ),

        ChangeNotifierProvider<MembersProvider>(
          create: (context) => MembersProvider(context.read<MemberService>()),
        ),
      ],
      child: Consumer<ThemeService>(
        builder: (context, themeService, child) {
          return MaterialApp(
            debugShowCheckedModeBanner: false,
            title: 'Organization Management',
            theme: ThemeService.lightTheme,
            darkTheme: ThemeService.darkTheme,
            themeMode: themeService.themeMode,
            home: const SplashScreen(),
            routes: {
              '/dashboard': (context) => const MainDashboard(),
              '/members': (context) => MemberListScreen(),
              '/members/add': (context) => AddMemberScreen(),
              '/payments': (context) => PaymentScreen(),
              '/payments/history': (context) => const PaymentHistoryScreen(),
              '/duty/posts': (context) => DutyPostScreen(),
              '/duty/roster': (context) => AddLocationScreen(),
              '/login': (context) => LoginScreen(),
            },
          );
        },
      ),
    );
  }
}
