import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:special_squad/screens/auth/login_screen.dart';
import 'package:special_squad/screens/main_dashboard.dart';
import 'package:special_squad/screens/auth/register_screen.dart';
import 'package:special_squad/screens/members/member_list_screen.dart';
import 'package:special_squad/screens/members/add_member_screen.dart';
import 'package:special_squad/screens/payments/payment_history_screen.dart';
import 'package:special_squad/screens/duty/duty_post_screen.dart';
import 'package:special_squad/screens/duty/duty_roster_screen.dart';
import 'package:special_squad/screens/payments/payments_screen.dart';
import 'package:special_squad/screens/splash/splash_screen.dart';
import 'package:special_squad/services/auth_service.dart';
import 'package:special_squad/services/duty_service.dart';
import 'package:special_squad/services/member_service.dart';
import 'package:special_squad/services/payment_service.dart';
import 'package:special_squad/services/theme_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize services and database before running the app
  final memberService = MemberService();
  await memberService.initializeDatabase();

  final paymentService = PaymentService();
  // Ensure payments table exists
  await paymentService.getRecentPayments();

  // Initialize ThemeService
  final themeService = ThemeService();

  runApp(
    MyApp(
      memberService: memberService,
      paymentService: paymentService,
      themeService: themeService,
    ),
  );
}

class MyApp extends StatelessWidget {
  final MemberService memberService;
  final PaymentService paymentService;
  final ThemeService themeService;

  const MyApp({
    super.key,
    required this.memberService,
    required this.paymentService,
    required this.themeService,
  });

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        Provider<MemberService>.value(value: memberService),
        Provider<PaymentService>.value(value: paymentService),
        ChangeNotifierProvider<ThemeService>.value(value: themeService),
        Provider<AuthService>(create: (_) => AuthService()),
        Provider<DutyService>(create: (_) => DutyService()),
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
              '/duty/roster': (context) => DutyRosterScreen(),
              '/register': (context) => RegisterScreen(),
              '/login': (context) => LoginScreen(),
            },
          );
        },
      ),
    );
  }
}
