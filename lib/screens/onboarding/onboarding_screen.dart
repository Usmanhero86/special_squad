import 'package:flutter/material.dart';
import '../auth/login_screen.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );

    _slideAnimation =
        Tween<Offset>(begin: const Offset(0, 0.3), end: Offset.zero).animate(
          CurvedAnimation(
            parent: _animationController,
            curve: Curves.easeOutCubic,
          ),
        );

    _animationController.forward();
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
            colors: [
              Color(0xFF1A2332), // Dark blue-gray
              Color(0xFF2C3E50), // Slightly lighter blue-gray
            ],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              // Top section with logo and organization info
              Expanded(
                flex: 3,
                child: AnimatedBuilder(
                  animation: _animationController,
                  builder: (context, child) {
                    return FadeTransition(
                      opacity: _fadeAnimation,
                      child: SlideTransition(
                        position: _slideAnimation,
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            // Logo Image from assets
                            Container(
                              width: 120,
                              height: 140,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(10),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withValues(alpha: 0.3),
                                    blurRadius: 10,
                                    offset: const Offset(0, 5),
                                  ),
                                ],
                              ),
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(10),
                                child: Image.asset(
                                  'assets/Screenshot 2026-01-30 142441.png',
                                  width: 120,
                                  height: 140,
                                  fit: BoxFit.contain,
                                  errorBuilder: (context, error, stackTrace) {
                                    // Fallback to custom painted shield if image fails to load
                                    return _buildShieldLogo();
                                  },
                                ),
                              ),
                            ),
                            const SizedBox(height: 10),

                            // Organization Title
                            const Text(
                              'C.JTF',
                              style: TextStyle(
                                fontSize: 48,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                                letterSpacing: 8,
                              ),
                            ),
                            const SizedBox(height: 8),

                            const Text(
                              'SPECIAL FORCE',
                              style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.w600,
                                color: Color(0xFFD4AF37), // Gold color
                                letterSpacing: 4,
                              ),
                            ),
                            const SizedBox(height: 10),

                            // Decorative wheat/laurel design
                            _buildDecorativeElement(),
                            const SizedBox(height: 10),

                            const Text(
                              'MAIDUGURI BORNO STATE',
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w500,
                                color: Color(0xFFD4AF37),
                                letterSpacing: 2,
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),

              // Bottom section with page indicators and content
              Expanded(
                flex: 3,
                child: Container(
                  margin: const EdgeInsets.all(20),
                  padding: const EdgeInsets.all(30),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.2),
                        blurRadius: 20,
                        offset: const Offset(0, 10),
                      ),
                    ],
                  ),
                  child: AnimatedBuilder(
                    animation: _animationController,
                    builder: (context, child) {
                      return FadeTransition(
                        opacity: _fadeAnimation,
                        child: SingleChildScrollView(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // Page indicators
                              Row(
                                children: [
                                  _buildPageIndicator(true),
                                  const SizedBox(width: 8),
                                  _buildPageIndicator(false),
                                  const SizedBox(width: 8),
                                  _buildPageIndicator(false),
                                ],
                              ),
                              const SizedBox(height: 16),

                              // Title
                              const Text(
                                'SPECIAL SQUAD',
                                style: TextStyle(
                                  fontSize: 28,
                                  fontWeight: FontWeight.bold,
                                  color: Color(0xFF2C3E50),
                                ),
                              ),
                              const SizedBox(height: 8),

                              // Subtitle
                              const Text(
                                'Special Force Joint Task Force',
                                style: TextStyle(
                                  fontSize: 16,
                                  color: Color(0xFF7F8C8D),
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                              const SizedBox(height: 12),

                              // Badge
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 12,
                                  vertical: 6,
                                ),
                                decoration: BoxDecoration(
                                  color: const Color(0xFF2C3E50),
                                  borderRadius: BorderRadius.circular(15),
                                ),
                                child: const Text(
                                  'BORNO STATE YOUTH VANGUARD',
                                  style: TextStyle(
                                    fontSize: 10,
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                    letterSpacing: 1,
                                  ),
                                ),
                              ),
                              const SizedBox(height: 12),

                              // Description
                              const Text(
                                'SECTOR 11 HEADQUARTERS MAIDUGURI\nBORNO STATE',
                                style: TextStyle(
                                  fontSize: 14,
                                  color: Color(0xFF7F8C8D),
                                  height: 1.5,
                                ),
                              ),
                              const SizedBox(height: 20),

                              // Next Button
                              SizedBox(
                                width: double.infinity,
                                height: 55,
                                child: ElevatedButton(
                                  onPressed: _navigateToLogin,
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: const Color(0xFFD4AF37),
                                    foregroundColor: Colors.white,
                                    elevation: 3,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(15),
                                    ),
                                  ),
                                  child: const Text(
                                    'Next',
                                    style: TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
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
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildShieldLogo() {
    return SizedBox(
      width: 120,
      height: 140,
      child: CustomPaint(painter: ShieldLogoPainter()),
    );
  }

  Widget _buildDecorativeElement() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        _buildWheatBranch(true),
        const SizedBox(width: 20),
        _buildWheatBranch(false),
      ],
    );
  }

  Widget _buildWheatBranch(bool leftSide) {
    return Transform.scale(
      scaleX: leftSide ? -1 : 1,
      child: SizedBox(
        width: 40,
        height: 20,
        child: CustomPaint(painter: WheatBranchPainter()),
      ),
    );
  }

  Widget _buildPageIndicator(bool isActive) {
    return Container(
      width: isActive ? 20 : 8,
      height: 8,
      decoration: BoxDecoration(
        color: isActive ? const Color(0xFF2C3E50) : const Color(0xFFBDC3C7),
        borderRadius: BorderRadius.circular(4),
      ),
    );
  }

  void _navigateToLogin() {
    Navigator.of(context).pushReplacement(
      PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) =>
            const LoginScreen(),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          const begin = Offset(1.0, 0.0);
          const end = Offset.zero;
          const curve = Curves.easeInOut;

          var tween = Tween(
            begin: begin,
            end: end,
          ).chain(CurveTween(curve: curve));

          return SlideTransition(
            position: animation.drive(tween),
            child: child,
          );
        },
        transitionDuration: const Duration(milliseconds: 500),
      ),
    );
  }
}

// Custom painter for the shield logo
class ShieldLogoPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..style = PaintingStyle.fill;

    // Draw shield outline (gold)
    paint.color = const Color(0xFFD4AF37);
    final shieldPath = Path();
    shieldPath.moveTo(size.width * 0.5, 0);
    shieldPath.lineTo(size.width * 0.9, size.height * 0.2);
    shieldPath.lineTo(size.width * 0.9, size.height * 0.7);
    shieldPath.lineTo(size.width * 0.5, size.height);
    shieldPath.lineTo(size.width * 0.1, size.height * 0.7);
    shieldPath.lineTo(size.width * 0.1, size.height * 0.2);
    shieldPath.close();
    canvas.drawPath(shieldPath, paint);

    // Draw inner shield (red top, dark bottom)
    final innerShieldPath = Path();
    innerShieldPath.moveTo(size.width * 0.5, size.height * 0.05);
    innerShieldPath.lineTo(size.width * 0.85, size.height * 0.22);
    innerShieldPath.lineTo(size.width * 0.85, size.height * 0.68);
    innerShieldPath.lineTo(size.width * 0.5, size.height * 0.95);
    innerShieldPath.lineTo(size.width * 0.15, size.height * 0.68);
    innerShieldPath.lineTo(size.width * 0.15, size.height * 0.22);
    innerShieldPath.close();

    // Red top section
    paint.color = const Color(0xFFDC143C);
    final redSection = Path();
    redSection.moveTo(size.width * 0.5, size.height * 0.05);
    redSection.lineTo(size.width * 0.85, size.height * 0.22);
    redSection.lineTo(size.width * 0.85, size.height * 0.45);
    redSection.lineTo(size.width * 0.15, size.height * 0.45);
    redSection.lineTo(size.width * 0.15, size.height * 0.22);
    redSection.close();
    canvas.drawPath(redSection, paint);

    // Dark bottom section
    paint.color = const Color(0xFF2C3E50);
    final darkSection = Path();
    darkSection.moveTo(size.width * 0.15, size.height * 0.45);
    darkSection.lineTo(size.width * 0.85, size.height * 0.45);
    darkSection.lineTo(size.width * 0.85, size.height * 0.68);
    darkSection.lineTo(size.width * 0.5, size.height * 0.95);
    darkSection.lineTo(size.width * 0.15, size.height * 0.68);
    darkSection.close();
    canvas.drawPath(darkSection, paint);

    // Draw star
    paint.color = Colors.white;
    _drawStar(
      canvas,
      size.width * 0.5,
      size.height * 0.3,
      size.width * 0.08,
      paint,
    );

    // Draw crossed rifles
    paint.color = Colors.white;
    paint.strokeWidth = 3;
    paint.style = PaintingStyle.stroke;
    paint.strokeCap = StrokeCap.round;

    // First rifle
    canvas.drawLine(
      Offset(size.width * 0.3, size.height * 0.55),
      Offset(size.width * 0.7, size.height * 0.75),
      paint,
    );

    // Second rifle
    canvas.drawLine(
      Offset(size.width * 0.7, size.height * 0.55),
      Offset(size.width * 0.3, size.height * 0.75),
      paint,
    );
  }

  void _drawStar(
    Canvas canvas,
    double centerX,
    double centerY,
    double radius,
    Paint paint,
  ) {
    final path = Path();
    const numPoints = 5;

    for (int i = 0; i < numPoints; i++) {
      final x =
          centerX +
          radius *
              0.8 *
              (i % 2 == 0 ? 1 : 0.4) *
              (i == 0
                  ? 0
                  : (i == 1
                        ? 0.95
                        : (i == 2 ? 0.59 : (i == 3 ? -0.59 : -0.95))));
      final y =
          centerY +
          radius *
              0.8 *
              (i % 2 == 0 ? 1 : 0.4) *
              (i == 0
                  ? -1
                  : (i == 1
                        ? -0.31
                        : (i == 2 ? 0.81 : (i == 3 ? 0.81 : -0.31))));

      if (i == 0) {
        path.moveTo(x, y);
      } else {
        path.lineTo(x, y);
      }
    }
    path.close();
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

// Custom painter for wheat branches
class WheatBranchPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = const Color(0xFFD4AF37)
      ..strokeWidth = 2
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    // Draw main branch
    canvas.drawLine(Offset(0, size.height), Offset(size.width, 0), paint);

    // Draw wheat grains
    for (int i = 0; i < 5; i++) {
      final progress = i / 4.0;
      final x = size.width * progress * 0.8;
      final y = size.height * (1 - progress * 0.8);

      canvas.drawLine(Offset(x, y), Offset(x + 4, y - 2), paint);
      canvas.drawLine(Offset(x, y), Offset(x + 4, y + 2), paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
