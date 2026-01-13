import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:special_squad/screens/dashboard.dart';
import 'package:special_squad/screens/auth/register_screen.dart';
import 'package:special_squad/screens/members/member_list_screen.dart';
import 'package:special_squad/screens/payments/payments_screen.dart';
import 'package:special_squad/services/auth_service.dart';
import 'package:special_squad/services/duty_service.dart';
import 'package:special_squad/services/member_service.dart';
import 'package:special_squad/services/payment_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        Provider<AuthService>(create: (_) => AuthService()),
        Provider<MemberService>(create: (_) => MemberService()),
        Provider<DutyService>(create: (_) => DutyService()),
        Provider<PaymentService>(create: (_) => PaymentService()),
      ],
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'Organization Management',
        theme: ThemeData(
          primarySwatch: Colors.blue,
          visualDensity: VisualDensity.adaptivePlatformDensity,
        ),
        home: AuthWrapper(),
        routes: {
          '/dashboard': (context) => DashboardScreen(),
          '/members': (context) => MemberListScreen(),
          '/payments': (context) => PaymentScreen(),
          '/register': (context) => RegisterScreen(),
        },
      ),
    );
  }
}

class AuthWrapper extends StatelessWidget {
  const AuthWrapper({super.key});

  @override
  Widget build(BuildContext context) {
    // Temporarily bypass authentication - go directly to dashboard
    return DashboardScreen();

    // Original authentication code (commented out for now)
    /*
    return FutureBuilder<User?>(
      future: Provider.of<AuthService>(context, listen: false).getCurrentUser(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Scaffold(
            body: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(),
                  SizedBox(height: 16),
                  Text('Loading...'),
                ],
              ),
            ),
          );
        }
        return snapshot.hasData ? DashboardScreen() : LoginScreen();
      },
    );
    */
  }
}
