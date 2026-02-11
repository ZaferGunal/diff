import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:provider/provider.dart';
import '../MainPages/Dashboard.dart';
import '../UserProvider.dart';
import '../services/authservice.dart';
import 'OTPVerificaitonPage.dart';
import 'PaymentVerificaitonPage.dart';


import 'ForgotPasswordPage.dart';
import 'signup_page.dart';
import '../MyColors.dart';

class LoginPage extends StatefulWidget {
  final VoidCallback toggleTheme;

  const LoginPage({super.key, required this.toggleTheme});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  bool isLoading = false;

  @override
  void dispose() {
    emailController.dispose();
    passwordController.dispose();
    super.dispose();
  }



  Future<void> handleLogin() async {
    setState(() {
      isLoading = true;
    });

    try {
      var val = await AuthService().login(
          emailController.text.trim(),
          passwordController.text.trim()
      );

      if (val != null && val.data["success"] == true) {
        String token = val.data["token"];

        await context.read<AuthProvider>().setToken(token);

        print("🔑 TOKEN: $token");

        if (!mounted) return;

        if (val.data["previousSessionClosed"] == true) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: const Text("Previous session was closed. You are now logged in.",style:TextStyle(color:MyColors.white,fontWeight:FontWeight.w600)),
              backgroundColor: MyColors.green_light,
              duration: const Duration(seconds: 2),
            ),
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: const Text("Login Successful!",style: TextStyle(fontWeight:FontWeight.w600,color:MyColors.white)),
              backgroundColor: MyColors.green_light,
              duration: const Duration(seconds: 1),
            ),
          );
        }

        // ✅ Trigger Chrome "Save password?" prompt
        TextInput.finishAutofillContext();

        await Future.delayed(const Duration(milliseconds: 500));

        if (!mounted) return;

        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => DashboardPage(
              toggleTheme: widget.toggleTheme,
              token: token,
            ),
          ),
        );
      }
      else if (val != null && val.data["needsVerification"] == true) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text("Please verify your email first", style: TextStyle(fontWeight: FontWeight.w600,color: MyColors.white,)),
            backgroundColor: MyColors.orange,
          ),
        );

        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => OTPVerificationPage(
              userId: val.data["userId"],
              email: val.data["email"],
              token: "",
              toggleTheme: widget.toggleTheme,
            ),
          ),
        );
      }
      // ✅ needsPayment kontrolü KALDIRILDI
      else {
        // ✅ Server'dan gelen hata mesajı varsa göster
        if (val?.data["msg"] != null) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(val!.data["msg"],style: TextStyle(fontWeight:FontWeight.w600,color:MyColors.white)),
              backgroundColor: MyColors.red,
            ),
          );
        }
      }
    } catch (e) {
      // ✅ Network hatalarını kullanıcıya göster
      print("⚠️ Login error: $e");

      String errorMessage = "An error occurred. Please try again.";

      // ✅ Internet bağlantısı kontrolü
      if (e.toString().contains('SocketException') ||
          e.toString().contains('Failed host lookup') ||
          e.toString().contains('Connection') ||
          e.toString().contains('Network')) {
        errorMessage = "No internet connection. Please check your network.";
      }

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(errorMessage,style: TextStyle(fontWeight:FontWeight.w600,color:MyColors.white),),
          backgroundColor: MyColors.red,
          duration: const Duration(seconds: 3),
        ),
      );
    } finally {
      if (mounted) {
        setState(() {
          isLoading = false;
        });
      }

    }
  }


  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final size = MediaQuery.of(context).size;
    final bool isDesktop = size.width > 900;

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: isDesktop ? null : IconButton(
          icon: Icon(Icons.arrow_back, color: isDark ? Colors.white : Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        title: isDesktop ? null : Text(
          'PractiCo',
          style: TextStyle(
            fontWeight: FontWeight.w700,
            color: isDark ? MyColors.cyan : MyColors.green,
          ),
        ),
      ),
      body: Row(
        children: [
          // LEFT PANEL: HERO SECTION (Only on Desktop)
          if (isDesktop)
            Expanded(
              flex: 5,
              child: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      const Color(0xFF0a1215),
                      const Color(0xFF1a2b2e),
                      const Color(0xFF0a1215),
                    ],
                  ),
                ),
                child: Stack(
                  children: [
                    // Wavy Background Effect (Simulated with Gradients)
                    Positioned.fill(
                      child: Opacity(
                        opacity: 0.2,
                        child: CustomPaint(
                          painter: WavyBackgroundPainter(),
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(60.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // LOGO
                          Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.all(8),
                                decoration: BoxDecoration(
                                  color: MyColors.cyan,
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: const Icon(Icons.bolt, color: Colors.white, size: 24),
                              ),
                              const SizedBox(width: 12),
                              const Text(
                                'PractiCo',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 22,
                                  fontWeight: FontWeight.bold,
                                  letterSpacing: 1,
                                ),
                              ),
                            ],
                          ),
                          const Spacer(),
                          // HERO TEXT
                          const Text(
                            'Elevate your\nworkflow\nproductivity.',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 56,
                              fontWeight: FontWeight.bold,
                              height: 1.1,
                            ),
                          ),
                          const SizedBox(height: 24),
                          Text(
                            'Join thousands of professionals who streamline their\ndaily tasks with our intelligent management\necosystem.',
                            style: TextStyle(
                              color: Colors.white.withOpacity(0.6),
                              fontSize: 18,
                              height: 1.5,
                            ),
                          ),
                          const Spacer(),
                          // FOOTER
                          Text(
                            '© 2024 PractiCo Inc.  •  All rights reserved.',
                            style: TextStyle(
                              color: Colors.white.withOpacity(0.3),
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),

          // RIGHT PANEL: LOGIN FORM
          Expanded(
            flex: 4,
            child: Container(
              color: isDark ? const Color(0xFF0a0f14) : Colors.white,
              child: Center(
                child: SingleChildScrollView(
                  padding: EdgeInsets.symmetric(
                    horizontal: isDesktop ? 80 : 32,
                    vertical: 40,
                  ),
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 400),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        if (!isDesktop) ...[
                           Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: MyColors.cyan,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: const Icon(Icons.bolt, color: Colors.white, size: 24),
                          ),
                          const SizedBox(height: 16),
                        ],
                        const Text(
                          'Welcome back',
                          style: TextStyle(
                            fontSize: 28,
                            fontWeight: FontWeight.bold,
                            letterSpacing: -0.5,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            Text(
                              'New here? ',
                              style: TextStyle(
                                color: isDark ? Colors.white54 : Colors.black54,
                                fontSize: 14,
                              ),
                            ),
                            GestureDetector(
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(builder: (context) => SignUpPage(toggleTheme: widget.toggleTheme)),
                                );
                              },
                              child: const Text(
                                'Create an account',
                                style: TextStyle(
                                  color: Color(0xFF00bcd4),
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 32),
                        
                        // SOCIAL BUTTONS
                        Row(
                          children: [
                            Expanded(
                              child: _buildSocialButton(
                                icon: Icons.g_mobiledata, // Placeholder for Google Icon
                                label: 'Google',
                                isDark: isDark,
                                onPressed: () {},
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: _buildSocialButton(
                                icon: Icons.terminal, // Placeholder for GitHub Icon
                                label: 'GitHub',
                                isDark: isDark,
                                onPressed: () {},
                              ),
                            ),
                          ],
                        ),
                        
                        const SizedBox(height: 32),
                        const _OrDivider(),
                        const SizedBox(height: 32),

                        // FORM FIELDS
                        _buildLabel('Email Address', isDark),
                        const SizedBox(height: 8),
                        _buildTextField(
                          controller: emailController,
                          hint: 'name@example.com',
                          isDark: isDark,
                          autofillHints: [AutofillHints.email],
                        ),
                        const SizedBox(height: 24),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            _buildLabel('Password', isDark),
                            GestureDetector(
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(builder: (context) => ForgotPasswordPage(toggleTheme: widget.toggleTheme)),
                                );
                              },
                              child: const Text(
                                'Forgot password?',
                                style: TextStyle(
                                  color: Color(0xFF00bcd4),
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        _buildTextField(
                          controller: passwordController,
                          hint: '••••••••',
                          isDark: isDark,
                          isPassword: true,
                          autofillHints: [AutofillHints.password],
                        ),
                        const SizedBox(height: 16),
                        Row(
                          children: [
                            SizedBox(
                              height: 18,
                              width: 18,
                              child: Checkbox(
                                value: true,
                                onChanged: (v) {},
                                activeColor: const Color(0xFF00bcd4),
                                side: BorderSide(color: isDark ? Colors.white24 : Colors.black26),
                              ),
                            ),
                            const SizedBox(width: 8),
                            Text(
                              'Keep me logged in for 30 days',
                              style: TextStyle(
                                color: isDark ? Colors.white54 : Colors.black54,
                                fontSize: 13,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 32),

                        // LOGIN BUTTON
                        SizedBox(
                          width: double.infinity,
                          height: 48,
                          child: ElevatedButton(
                            onPressed: isLoading ? null : handleLogin,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF00bcd4),
                              foregroundColor: Colors.black,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                              elevation: 0,
                            ),
                            child: isLoading
                                ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.black))
                                : Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: const [
                                      Text(
                                        'Login to PractiCo',
                                        style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                                      ),
                                      SizedBox(width: 8),
                                      Icon(Icons.arrow_forward, size: 18),
                                    ],
                                  ),
                          ),
                        ),
                        
                        const SizedBox(height: 40),
                        // FOOTER LINKS (Small)
                        Center(
                          child: Wrap(
                            spacing: 16,
                            children: [
                              _buildFooterLink('Privacy Policy', isDark),
                              _buildFooterLink('Terms of Service', isDark),
                              _buildFooterLink('Help Center', isDark),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLabel(String text, bool isDark) {
    return Text(
      text,
      style: TextStyle(
        fontSize: 14,
        fontWeight: FontWeight.w600,
        color: isDark ? Colors.white70 : Colors.black87,
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String hint,
    required bool isDark,
    bool isPassword = false,
    List<String>? autofillHints,
  }) {
    return TextField(
      controller: controller,
      obscureText: isPassword,
      autofillHints: autofillHints,
      style: const TextStyle(fontSize: 15),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: TextStyle(color: isDark ? Colors.white24 : Colors.black26),
        filled: true,
        fillColor: isDark ? const Color(0xFF13191f) : const Color(0xFFf5f7fa),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: isDark ? Colors.white10 : Colors.black12),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: isDark ? Colors.white10 : Colors.black12),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: Color(0xFF00bcd4), width: 2),
        ),
      ),
    );
  }

  Widget _buildSocialButton({
    required IconData icon,
    required String label,
    required bool isDark,
    required VoidCallback onPressed,
  }) {
    return OutlinedButton(
      onPressed: onPressed,
      style: OutlinedButton.styleFrom(
        padding: const EdgeInsets.symmetric(vertical: 12),
        side: BorderSide(color: isDark ? Colors.white10 : Colors.black12),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 20, color: isDark ? Colors.white : Colors.black),
          const SizedBox(width: 8),
          Text(
            label,
            style: TextStyle(
              color: isDark ? Colors.white : Colors.black,
              fontWeight: FontWeight.bold,
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFooterLink(String text, bool isDark) {
    return Text(
      text,
      style: TextStyle(
        color: isDark ? Colors.white24 : Colors.black26,
        fontSize: 12,
      ),
    );
  }
}

class _OrDivider extends StatelessWidget {
  const _OrDivider();

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Row(
      children: [
        Expanded(child: Divider(color: isDark ? Colors.white10 : Colors.black12)),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Text(
            'OR CONTINUE WITH',
            style: TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.bold,
              color: isDark ? Colors.white24 : Colors.black26,
              letterSpacing: 1.2,
            ),
          ),
        ),
        Expanded(child: Divider(color: isDark ? Colors.white10 : Colors.black12)),
      ],
    );
  }
}

class WavyBackgroundPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = const Color(0xFF00bcd4).withOpacity(0.5)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.0;

    final path = Path();
    for (var i = 0; i < 10; i++) {
      path.moveTo(0, size.height * (0.1 * i));
      path.quadraticBezierTo(
        size.width * 0.5,
        size.height * (0.1 * i + 0.1),
        size.width,
        size.height * (0.1 * i),
      );
    }
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}