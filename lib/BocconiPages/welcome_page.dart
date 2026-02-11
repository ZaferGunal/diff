// ==================== WELCOME PAGE ====================
import 'package:flutter/material.dart';
import '../MyColors.dart';
import 'login_page.dart';

class WelcomePage extends StatelessWidget {
  final VoidCallback toggleTheme;

  const WelcomePage({super.key, required this.toggleTheme});

  @override
  Widget build(BuildContext context) {
    // Light mod tamamen devre dışı - sadece dark mode
    final isDark = true;

    return Scaffold(
      body: Stack(
        children: [
          // Background Image - Full Screen
          Positioned.fill(
            child: Container(
              color: const Color(0xFF0f1419),
              child: Image.asset(
                'assets/welcome_bg.png',
                fit: BoxFit.cover,
              ),
            ),
          ),
          // Right Side Container with Logo and Buttons
          Align(
            alignment: Alignment.centerRight,
            child: Container(
              width: MediaQuery.of(context).size.width * 0.4,
              constraints: const BoxConstraints(
                maxWidth: 500,
                minWidth: 350,
              ),
              margin: const EdgeInsets.fromLTRB(40, 40, 120, 40),
              padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 60),
              decoration: BoxDecoration(
                color: const Color(0xFF1a1f2e).withOpacity(0.95),
                borderRadius: BorderRadius.circular(24),
                border: Border.all(
                  color: const Color(0xFF324159).withOpacity(0.3),
                  width: 2,
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.3),
                    blurRadius: 60,
                    offset: const Offset(0, 20),
                  ),
                ],
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Logo/Icon Section
                  Image.asset(
                    "assets/soleLogo.png",
                    width: 111,
                    height: 111,
                    fit: BoxFit.contain,
                  ),
                  const SizedBox(height: 27),
                  const Text(
                    'PractiCo',
                    style: TextStyle(
                      fontSize: 36,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                      letterSpacing: 2,
                    ),
                  ),
                  const SizedBox(height: 15),
                  Text(
                    'PractiCo Makes Perfect !',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.white.withOpacity(0.7),
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 25),
                  Text(
                    'Welcome! Please sign in or create a new account.',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontWeight: FontWeight.w500,
                      fontSize: 16,
                      color: Colors.white.withOpacity(0.6),
                    ),
                  ),
                  const SizedBox(height: 35),
                  // Login Button
                  SizedBox(
                    width: double.infinity,
                    height: 55,
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => LoginPage(toggleTheme: toggleTheme),
                          ),
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: MyColors.cyan,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        elevation: 3,
                        shadowColor: MyColors.cyan.withOpacity(0.3),
                      ),
                      child: const Text(
                        'Login',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 15),
                  // Sign Up Button
                  OutlinedButton(
                    onPressed: () => Navigator.pushNamed(context, '/signup'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: Colors.white,
                      side: const BorderSide(
                        color: MyColors.earth,
                        width: 2,
                      ),
                      padding: const EdgeInsets.symmetric(vertical: 18),
                      minimumSize: const Size(double.infinity, 55),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: const Text(
                      'Sign Up',
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}