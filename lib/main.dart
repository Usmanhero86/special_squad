import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:special_squad/screens/auth/login_screen.dart';
import 'package:special_squad/screens/dashboard.dart';
import 'package:special_squad/screens/auth/register_screen.dart';
import 'package:special_squad/screens/members/member_list_screen.dart';
import 'package:special_squad/screens/payments/payments_screen.dart';
import 'package:special_squad/services/auth_service.dart';
import 'package:special_squad/services/duty_service.dart';
import 'package:special_squad/services/member_service.dart';
import 'package:special_squad/services/payment_service.dart';
import 'package:special_squad/services/theme_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize MemberService and database before running the app
  final memberService = MemberService();
  await memberService.initializeDatabase();

  // Initialize ThemeService
  final themeService = ThemeService();

  runApp(MyApp(memberService: memberService, themeService: themeService));
}

class MyApp extends StatelessWidget {
  final MemberService memberService;
  final ThemeService themeService;

  const MyApp({
    super.key,
    required this.memberService,
    required this.themeService,
  });

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        Provider<MemberService>.value(value: memberService),
        ChangeNotifierProvider<ThemeService>.value(value: themeService),
        Provider<AuthService>(create: (_) => AuthService()),
        Provider<DutyService>(create: (_) => DutyService()),
        Provider<PaymentService>(create: (_) => PaymentService()),
      ],
      child: Consumer<ThemeService>(
        builder: (context, themeService, child) {
          return MaterialApp(
            debugShowCheckedModeBanner: false,
            title: 'Organization Management',
            theme: ThemeService.lightTheme,
            darkTheme: ThemeService.darkTheme,
            themeMode: themeService.themeMode,
            home: LoginScreen(),
            routes: {
              '/dashboard': (context) => DashboardScreen(),
              '/members': (context) => MemberListScreen(),
              '/payments': (context) => PaymentScreen(),
              '/register': (context) => RegisterScreen(),
              '/login': (context) => LoginScreen(),
            },
          );
        },
      ),
    );
  }
}
