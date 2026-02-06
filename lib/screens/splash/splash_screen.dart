import 'package:flutter/material.dart';
import '../auth/login_screen.dart';
import '../onboarding/onboarding_screen.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 2000),
      vsync: this,
    );

    _scaleAnimation = Tween<double>(begin: 0.5, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.elasticOut),
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );

    _animationController.forward();

    // Navigate to onboarding after 3 seconds
    Future.delayed(const Duration(seconds: 3), () {
      if (mounted) {
        Navigator.of(context).pushReplacement(
          PageRouteBuilder(
            pageBuilder: (context, animation, secondaryAnimation) =>
                const LoginScreen(),
            transitionsBuilder:
                (context, animation, secondaryAnimation, child) {
                  return FadeTransition(opacity: animation, child: child);
                },
            transitionDuration: const Duration(milliseconds: 800),
          ),
        );
      }
    });
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFF1A2332), Color(0xFF2C3E50)],
          ),
        ),
        child: Center(
          child: AnimatedBuilder(
            animation: _animationController,
            builder: (context, child) {
              return FadeTransition(
                opacity: _fadeAnimation,
                child: ScaleTransition(
                  scale: _scaleAnimation,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      // App Logo from assets
                      Container(
                        width: 150,
                        height: 150,
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.1),
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: const Color(0xFFD4AF37),
                            width: 3,
                          ),
                        ),
                        child: ClipOval(
                          child: Image.asset(
                            'assets/logo.png',
                            fit: BoxFit.fill,
                            errorBuilder: (context, error, stackTrace) {
                              // Fallback to icon if image fails to load
                              return const Icon(
                                Icons.security,
                                size: 80,
                                color: Color(0xFFD4AF37),
                              );
                            },
                          ),
                        ),
                      ),
                      const SizedBox(height: 30),

                      // App Name
                      const Text(
                        'SPECIAL SQUAD',
                        style: TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                          letterSpacing: 3,
                        ),
                      ),
                      const SizedBox(height: 10),

                      // Subtitle
                      const Text(
                        'Management System',
                        style: TextStyle(
                          fontSize: 16,
                          color: Color(0xFFD4AF37),
                          letterSpacing: 1,
                        ),
                      ),
                      const SizedBox(height: 50),

                      // Loading indicator
                      const SizedBox(
                        width: 30,
                        height: 30,
                        child: CircularProgressIndicator(
                          valueColor: AlwaysStoppedAnimation<Color>(
                            Color(0xFFD4AF37),
                          ),
                          strokeWidth: 3,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}
