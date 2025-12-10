// ==================== WELCOME PAGE ====================
import 'package:flutter/material.dart';
import '../AddTestPage.dart';
import '../MyColors.dart';
import '../services/authservice.dart';
import 'login_page.dart';
import 'signup_page.dart';


class WelcomePage extends StatelessWidget {
  final VoidCallback toggleTheme;

  const WelcomePage({super.key, required this.toggleTheme});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      body: Stack(
        children: [
          // Background Image - Full Screen
          Positioned.fill(
            child: Container(
              color: isDark ? const Color(0xFF0f1419) : const Color(0xFFf5f7fa),
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
                color: isDark
                    ? const Color(0xFF1a1f2e).withOpacity(0.95)
                    : Colors.white.withOpacity(0.95),
                borderRadius: BorderRadius.circular(24),
                border: Border.all(
                  color: isDark
                      ? const Color(0xFF324159).withOpacity(0.3)
                      : MyColors.cyan.withOpacity(0.1),
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

                  Text(
                    'PractiCo',
                    style: TextStyle(
                      fontSize: 36,
                      fontWeight: FontWeight.bold,
                      color: isDark ? Colors.white : Colors.black87,
                      letterSpacing: 2,
                    ),
                  ),
                  const SizedBox(height: 15),

                  Text(
                    'PractiCo Makes Perfect !',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 16,
                      color: isDark
                          ? Colors.white.withOpacity(0.7)
                          : const Color(0xFF324159),
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
                      color: isDark
                          ? Colors.white.withOpacity(0.6)
                          : const Color(0xFF324159).withOpacity(0.8),
                    ),
                  ),
                  const SizedBox(height: 35),

                  // Login Button
                  SizedBox(
                    width: double.infinity,
                    height: 55,
                    child: ElevatedButton(
                      onPressed: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => LoginPage(toggleTheme: toggleTheme),
                        ),
                      ),
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
                    onPressed: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => SignUpPage(toggleTheme: toggleTheme),
                      ),
                    ),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: isDark ? Colors.white : MyColors.cyan,
                      side: BorderSide(
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

                  // ============================================================
                  // ⚠️ BU BUTON SONRADAN SİLİNECEK - SADECE TEST İÇİN
                  // ============================================================
                  const SizedBox(height: 20),
                  SizedBox(
                    width: double.infinity,
                    height: 55,
                    child: ElevatedButton(
                      onPressed: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => AddTestPage(toggleTheme: toggleTheme),
                        ),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.pink.shade300,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        elevation: 3,
                        shadowColor: Colors.pink.shade200.withOpacity(0.3),
                      ),
                      child: const Text(
                        'Go to AddPracticeTest',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                  // ============================================================
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}