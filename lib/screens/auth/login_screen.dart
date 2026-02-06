import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:special_squad/screens/main_dashboard.dart';
import '../../services/login.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  final _formKey = GlobalKey<FormState>();

  bool _isLoading = false;
  String? _errorMessage;

  Future<void> handleLogin() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      // ✅ GET AuthService FROM PROVIDER
      final authService = context.read<AuthService>();

      await authService.login(
        email: emailController.text.trim(),
        password: passwordController.text.trim(),
      );

      if (!mounted) return;

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const MainDashboard()),
      );
    } catch (e) {
      debugPrint('❌ LOGIN ERROR: $e');

      setState(() {
        _errorMessage =
            e.toString().replaceAll('Exception:', '').trim();
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(_errorMessage!)),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }


  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      body: Stack(
        children: [
          Center(
            child: SingleChildScrollView(
              padding: EdgeInsets.all(24),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Logo/Header
                  Container(
                    padding: EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.primaryContainer,
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: Theme.of(
                            context,
                          ).colorScheme.primary.withOpacity(0.2),
                          blurRadius: 10,
                          spreadRadius: 2,
                        ),
                      ],
                    ),
                    child: Icon(
                      Icons.group,
                      size: 60,
                      color: Theme.of(context).colorScheme.primary,
                    ),
                  ),
                  SizedBox(height: 32),

                  // Title
                  Text(
                    'Organization Management',
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: Colors.blue.shade900,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  SizedBox(height: 8),
                  Text(
                    'Secretary Login',
                    style: TextStyle(fontSize: 16, color: Colors.grey.shade600),
                  ),
                  SizedBox(height: 20),

                  // Login Button Card
                  Card(
                    elevation: 4,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Padding(
                      padding: EdgeInsets.all(24),
                      child: Form(
                        key: _formKey,
                        child: Column(
                          children: [
                            Text(
                              'Secretary Login',
                              style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                                color: Colors.blue.shade800,
                              ),
                            ),

                            if (_errorMessage != null) ...[
                              Text(
                                _errorMessage!,
                                style: theme.textTheme.bodySmall?.copyWith(
                                  color: theme.colorScheme.error,
                                ),
                              ),
                              const SizedBox(height: 12),
                            ],
                            SizedBox(height: 16),
                            TextFormField(
                              controller: emailController,
                              decoration: InputDecoration(
                                hintText: 'Enter Email Address',
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(4.0),
                                ),
                              ),
                              keyboardType: TextInputType.emailAddress,
                              validator: (value) {
                                if (value == null || value.trim().isEmpty) {
                                  return 'Email is required';
                                }
                                if (!value.contains('@')) {
                                  return 'Enter a valid email';
                                }
                                return null;
                              },
                            ),
                            SizedBox(height: 24),
                            TextFormField(
                              controller: passwordController,
                              decoration: InputDecoration(
                                hintText: 'Enter Password',
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(4.0),
                                ),
                              ),
                              obscureText: true,
                              validator: (value) {
                                if (value == null || value.trim().isEmpty) {
                                  return 'Password is required';
                                }
                                if (value.length < 6) {
                                  return 'Password must be at least 6 characters';
                                }
                                return null;
                              },
                            ),
                            SizedBox(height: 24),
                            // Login Button
                            SizedBox(
                              width: double.infinity,
                              height: 50,
                              child: ElevatedButton(
                                onPressed: _isLoading ? null : handleLogin,
                                child: const Text('Login'),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  SizedBox(height: 32),

                ],
              ),
            ),
          ),
          if (_isLoading)
            Container(
              color: Colors.black.withOpacity(0.3),
              child: const Center(
                child: CircularProgressIndicator(),
              ),
            ),
        ],
      ),
    );
  }
}

