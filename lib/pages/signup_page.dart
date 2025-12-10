import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:untitled5/pages/login_page.dart';
import '../MyColors.dart';
import '../UserProvider.dart';
import '../services/authservice.dart';
import 'OTPVerificaitonPage.dart';

class SignUpPage extends StatefulWidget {
  final VoidCallback toggleTheme;

  const SignUpPage({super.key, required this.toggleTheme});

  @override
  State<SignUpPage> createState() => _SignUpPageState();
}

class _SignUpPageState extends State<SignUpPage> {
  final TextEditingController nameController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  bool isLoading = false;
  bool _obscurePassword = true;

  @override
  void dispose() {
    nameController.dispose();
    emailController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  void _showSnackBar(String message, Color color) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message,style: TextStyle(fontWeight:FontWeight.w600,color:MyColors.white)),
        backgroundColor: color,
        duration: Duration(seconds: 2),
      ),
    );
  }

  bool _isValidEmail(String email) {
    return RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(email);
  }

  Future<void> handleSignUp() async {
    final name = nameController.text.trim();
    final email = emailController.text.trim();
    final password = passwordController.text.trim();

    // ✅ VALIDATION CHECKS
    if (name.isEmpty || email.isEmpty || password.isEmpty) {
      _showSnackBar("Please fill all fields", Colors.orange);
      return;
    }

    if (name.length < 2) {
      _showSnackBar("Name must be at least 2 characters", Colors.orange);
      return;
    }

    if (!_isValidEmail(email)) {
      _showSnackBar("Please enter a valid email address", Colors.orange);
      return;
    }

    if (password.length < 6) {
      _showSnackBar("Password must be at least 6 characters", Colors.orange);
      return;
    }

    setState(() {
      isLoading = true;
    });

    try {
      var val = await AuthService().signup(name, password, email);

      if (val != null && val.data["success"] == true) {
        String userId = val.data["userId"];
        String email = val.data["email"];
        String token = val.data["token"];

        if (!mounted) return;

        _showSnackBar("Account created! Please verify your email", MyColors.green_light);

        await Future.delayed(Duration(milliseconds: 500));

        if (!mounted) return;

        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => OTPVerificationPage(
              userId: userId,
              email: email,
              token: token,
              toggleTheme: widget.toggleTheme,
            ),
          ),
        );
      } else {
        if (!mounted) return;
        _showSnackBar(val?.data["msg"] ?? "Sign Up Failed", MyColors.red);
      }
    } catch (e) {
      if (!mounted) return;
      print("❌ Sign Up Error: $e");
      _showSnackBar("An error occurred", MyColors.red);
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

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back,
            color: isDark ? MyColors.black : MyColors.black,
          ),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'PractiCo',
          style: TextStyle(
            fontWeight: FontWeight.w700,
            letterSpacing: 2.0,
            color: isDark ? MyColors.cyan : MyColors.green,
            shadows: isDark ? [
              Shadow(
                color: MyColors.cyan.withOpacity(0.5),
                blurRadius: 10,
              ),
            ] : [],
          ),
        ),
        backgroundColor: isDark ? MyColors.softBeige : MyColors.white,
        elevation: 0,
        actions: [
          Container(
            margin: const EdgeInsets.only(right: 8),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(
                color: isDark ? MyColors.cyan.withOpacity(0.3) : MyColors.green.withOpacity(0.3),
                width: 1.5,
              ),
            ),

            child: IconButton(
              icon: Icon(
                isDark ? Icons.light_mode : Icons.dark_mode,
                color: isDark ? Colors.yellow : MyColors.bocco_blue,
              ),
              onPressed: widget.toggleTheme,
            ),
          ),
        ],
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: isDark
              ? LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              const Color(0xFF0a0e1a),
              const Color(0xFF141b2d),
              MyColors.green.withOpacity(0.1),
            ],
          )
              : LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              const Color(0xFFf0f4f8),
              const Color(0xFFe8eef5),
            ],
          ),
        ),
        child: Center(
          child: Container(
            constraints: const BoxConstraints(maxWidth: 480),
            margin: const EdgeInsets.all(32),
            padding: const EdgeInsets.all(40),
            decoration: BoxDecoration(
              color: isDark
                  ? const Color(0xFF242938)
                  : MyColors.white,
              borderRadius: BorderRadius.circular(24),
              border: Border.all(
                color: isDark
                    ? MyColors.white.withOpacity(0.3)
                    : MyColors.green.withOpacity(0.2),
                width: 2,
              ),
              boxShadow: [
                BoxShadow(
                  color: isDark
                      ? MyColors.white.withOpacity(0.15)
                      : Colors.black.withOpacity(0.12),
                  blurRadius: 40,
                  offset: const Offset(0, 10),
                ),
                if (isDark)
                  BoxShadow(
                    color: MyColors.cyan.withOpacity(0.1),
                    blurRadius: 60,
                    spreadRadius: -5,
                  ),
              ],
            ),
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    'Create Account',
                    style: TextStyle(
                      fontSize: 32,
                      fontWeight: FontWeight.w500,
                      color: isDark ? MyColors.white : MyColors.green,
                      letterSpacing: 1.5,
                      shadows: isDark ? [
                        Shadow(
                          color: MyColors.white.withOpacity(0.3),
                          blurRadius: 8,
                        ),
                      ] : [],
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Fill in the details to get started',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w400,
                      color: isDark ? MyColors.white.withOpacity(0.5) : MyColors.green.withOpacity(0.7),
                      letterSpacing: 0.8,
                    ),
                  ),
                  const SizedBox(height: 40),

                  // NAME FIELD
                  TextField(
                    controller: nameController,
                    style: TextStyle(
                      color: isDark ? Colors.white : MyColors.green,
                      fontSize: 15,
                      fontWeight: FontWeight.w500,
                    ),
                    decoration: InputDecoration(
                      labelText: 'Full name',
                      labelStyle: TextStyle(
                        color: isDark ? MyColors.white.withOpacity(0.6) : MyColors.green.withOpacity(0.8),
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                      ),
                      prefixIcon: Icon(
                        Icons.person_outline,
                        color: isDark ? MyColors.white.withOpacity(0.5) : MyColors.green,
                        size: 20,
                      ),
                      filled: true,
                      fillColor: isDark
                          ? const Color(0xFF0f1419).withOpacity(0.5)
                          : const Color(0xFFf5f7fa),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(14),
                        borderSide: BorderSide.none,
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(14),
                        borderSide: BorderSide(
                          color: isDark ? Colors.white.withOpacity(0.05) : Colors.black.withOpacity(0.05),
                          width: 1,
                        ),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(14),
                        borderSide: BorderSide(
                          color: isDark ? MyColors.white : MyColors.green,
                          width: 2,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),

                  // EMAIL FIELD
                  TextField(
                    controller: emailController,
                    keyboardType: TextInputType.emailAddress,
                    style: TextStyle(
                      color: isDark ? Colors.white : MyColors.green,
                      fontSize: 15,
                      fontWeight: FontWeight.w500,
                    ),
                    decoration: InputDecoration(
                      labelText: 'Email address',
                      labelStyle: TextStyle(
                        color: isDark ? MyColors.white.withOpacity(0.6) : MyColors.green.withOpacity(0.8),
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                      ),
                      prefixIcon: Icon(
                        Icons.email_outlined,
                        color: isDark ? MyColors.white.withOpacity(0.5) : MyColors.green,
                        size: 20,
                      ),
                      filled: true,
                      fillColor: isDark
                          ? const Color(0xFF0f1419).withOpacity(0.5)
                          : const Color(0xFFf5f7fa),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(14),
                        borderSide: BorderSide.none,
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(14),
                        borderSide: BorderSide(
                          color: isDark ? Colors.white.withOpacity(0.05) : Colors.black.withOpacity(0.05),
                          width: 1,
                        ),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(14),
                        borderSide: BorderSide(
                          color: isDark ? MyColors.white : MyColors.green,
                          width: 2,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),

                  // PASSWORD FIELD
                  TextField(
                    controller: passwordController,
                    obscureText: _obscurePassword,
                    style: TextStyle(
                      color: isDark ? Colors.white : MyColors.green,
                      fontSize: 15,
                      fontWeight: FontWeight.w500,
                    ),
                    decoration: InputDecoration(
                      labelText: 'Password',
                      labelStyle: TextStyle(
                        color: isDark ? MyColors.white.withOpacity(0.6) : MyColors.green.withOpacity(0.8),
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                      ),
                      prefixIcon: Icon(
                        Icons.lock_outline,
                        color: isDark ? MyColors.white.withOpacity(0.5) : MyColors.green,
                        size: 20,
                      ),
                      suffixIcon: IconButton(
                        icon: Icon(
                          _obscurePassword ? Icons.visibility_off : Icons.visibility,
                          color: isDark ? MyColors.white.withOpacity(0.5) : MyColors.green.withOpacity(0.7),
                          size: 20,
                        ),
                        onPressed: () {
                          setState(() {
                            _obscurePassword = !_obscurePassword;
                          });
                        },
                      ),
                      filled: true,
                      fillColor: isDark
                          ? const Color(0xFF0f1419).withOpacity(0.5)
                          : const Color(0xFFf5f7fa),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(14),
                        borderSide: BorderSide.none,
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(14),
                        borderSide: BorderSide(
                          color: isDark ? Colors.white.withOpacity(0.05) : Colors.black.withOpacity(0.05),
                          width: 1,
                        ),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(14),
                        borderSide: BorderSide(
                          color: isDark ? MyColors.white : MyColors.green,
                          width: 2,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 30),

                  // SIGN UP BUTTON
                  SizedBox(
                    width: double.infinity,
                    height: 56,
                    child: ElevatedButton(
                      onPressed: isLoading ? null : handleSignUp,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: isDark ? MyColors.cyan : MyColors.green,
                        foregroundColor: MyColors.white,
                        disabledBackgroundColor: isDark
                            ? MyColors.cyan.withOpacity(0.3)
                            : MyColors.green.withOpacity(0.3),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                        elevation: 0,
                        shadowColor: isDark ? MyColors.cyan.withOpacity(0.5) : MyColors.green.withOpacity(0.3),
                      ).copyWith(
                        overlayColor: WidgetStateProperty.all(
                          isDark ? MyColors.green_light.withOpacity(0.2) : MyColors.cyan.withOpacity(0.1),
                        ),
                      ),
                      child: isLoading
                          ? const SizedBox(
                        height: 24,
                        width: 24,
                        child: CircularProgressIndicator(
                          color: Colors.white,
                          strokeWidth: 2.5,
                        ),
                      )
                          : Text(
                        'Sign Up',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          letterSpacing: 1.2,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),

                  // LOGIN LINK
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        'Already have an account? ',
                        style: TextStyle(
                          color: isDark ? MyColors.white.withOpacity(0.6) : MyColors.green.withOpacity(0.7),
                          fontSize: 14,
                        ),
                      ),
                      TextButton(
                        onPressed: () => Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(
                            builder: (context) => LoginPage(
                              toggleTheme: widget.toggleTheme,
                            ),
                          ),
                        ),
                        style: TextButton.styleFrom(
                          padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 4),
                        ),
                        child: Text(
                          'Login',
                          style: TextStyle(
                            color: isDark ? MyColors.cyan : MyColors.green,
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            letterSpacing: 0.3,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}