import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:provider/provider.dart';

import '../MyColors.dart';
import '../UserProvider.dart';
import '../services/authservice.dart';
import 'OTPVerificaitonPage.dart';
import 'login_page.dart';

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

        // ✅ Trigger Chrome "Save password?" prompt
        TextInput.finishAutofillContext();

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
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: isDark ? Colors.white : Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: isDark
                ? [const Color(0xFF0a1215), const Color(0xFF1a2b2e)]
                : [const Color(0xFFf0f4f8), const Color(0xFFe8eef5)],
          ),
        ),
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 60),
            child: Container(
              constraints: const BoxConstraints(maxWidth: 440),
              padding: const EdgeInsets.all(40),
              decoration: BoxDecoration(
                color: isDark ? const Color(0xFF0a0f14) : Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: isDark ? Colors.white.withOpacity(0.05) : Colors.black.withOpacity(0.05),
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.2),
                    blurRadius: 30,
                    offset: const Offset(0, 10),
                  ),
                ],
              ),
              child: AutofillGroup(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // LOGO
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: MyColors.cyan,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Icon(Icons.bolt, color: Colors.white, size: 24),
                    ),
                    const SizedBox(height: 12),
                    const Text(
                      'PractiCo',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 1,
                      ),
                    ),
                    const SizedBox(height: 32),
                    const Text(
                      'Create Account',
                      style: TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        letterSpacing: -0.5,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Start your professional journey with us today.',
                      style: TextStyle(
                        color: isDark ? Colors.white54 : Colors.black54,
                        fontSize: 14,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 40),

                    // FORM FIELDS
                    _buildLabel('Full Name', isDark),
                    const SizedBox(height: 8),
                    _buildTextField(
                      controller: nameController,
                      hint: 'John Doe',
                      isDark: isDark,
                      prefixIcon: Icons.person_outline,
                      autofillHints: [AutofillHints.name],
                    ),
                    const SizedBox(height: 24),
                    _buildLabel('Email Address', isDark),
                    const SizedBox(height: 8),
                    _buildTextField(
                      controller: emailController,
                      hint: 'john@example.com',
                      isDark: isDark,
                      prefixIcon: Icons.alternate_email,
                      autofillHints: [AutofillHints.email],
                    ),
                    const SizedBox(height: 24),
                    _buildLabel('Password', isDark),
                    const SizedBox(height: 8),
                    _buildTextField(
                      controller: passwordController,
                      hint: '••••••••',
                      isDark: isDark,
                      isPassword: true,
                      prefixIcon: Icons.lock_outline,
                      autofillHints: [AutofillHints.newPassword],
                      suffix: IconButton(
                        icon: Icon(
                          _obscurePassword ? Icons.visibility_off : Icons.visibility,
                          color: isDark ? Colors.white24 : Colors.black26,
                          size: 18,
                        ),
                        onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
                      ),
                    ),
                    const SizedBox(height: 20),
                    
                    // AGREEMENT
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
                        Expanded(
                          child: Text.rich(
                            TextSpan(
                              text: 'I agree to the ',
                              style: TextStyle(color: isDark ? Colors.white54 : Colors.black54, fontSize: 12),
                              children: const [
                                TextSpan(
                                  text: 'Terms of Service',
                                  style: TextStyle(color: Color(0xFF00bcd4), fontWeight: FontWeight.bold),
                                ),
                                TextSpan(text: ' and '),
                                TextSpan(
                                  text: 'Privacy Policy',
                                  style: TextStyle(color: Color(0xFF00bcd4), fontWeight: FontWeight.bold),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 32),

                    // SIGN UP BUTTON
                    SizedBox(
                      width: double.infinity,
                      height: 48,
                      child: ElevatedButton(
                        onPressed: isLoading ? null : handleSignUp,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF00bcd4),
                          foregroundColor: Colors.black,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                          elevation: 8,
                          shadowColor: const Color(0xFF00bcd4).withOpacity(0.3),
                        ),
                        child: isLoading
                            ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.black))
                            : Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: const [
                                  Text(
                                    'Create My Account',
                                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                                  ),
                                  SizedBox(width: 8),
                                  Icon(Icons.arrow_forward, size: 18),
                                ],
                              ),
                      ),
                    ),
                    const SizedBox(height: 32),
                    const _OrDividerSignup(),
                    const SizedBox(height: 24),

                    // SOCIAL BUTTONS
                    Row(
                      children: [
                        Expanded(
                          child: _buildSocialButton(
                            icon: Icons.g_mobiledata,
                            label: 'Google',
                            isDark: isDark,
                            onPressed: () {},
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: _buildSocialButton(
                            icon: Icons.terminal,
                            label: 'GitHub',
                            isDark: isDark,
                            onPressed: () {},
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 32),

                    // LOGIN LINK
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          'Already have an account? ',
                          style: TextStyle(
                            color: isDark ? Colors.white54 : Colors.black54,
                            fontSize: 14,
                          ),
                        ),
                        GestureDetector(
                          onTap: () => Navigator.pushReplacement(
                            context,
                            MaterialPageRoute(builder: (context) => LoginPage(toggleTheme: widget.toggleTheme)),
                          ),
                          child: const Text(
                            'Log in',
                            style: TextStyle(
                              color: Color(0xFF00bcd4),
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
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
      ),
    );
  }

  Widget _buildLabel(String text, bool isDark) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Text(
        text,
        style: TextStyle(
          fontSize: 13,
          fontWeight: FontWeight.w600,
          color: isDark ? Colors.white70 : Colors.black87,
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String hint,
    required bool isDark,
    required IconData prefixIcon,
    bool isPassword = false,
    Widget? suffix,
    List<String>? autofillHints,
  }) {
    return TextField(
      controller: controller,
      obscureText: isPassword && _obscurePassword,
      autofillHints: autofillHints,
      style: const TextStyle(fontSize: 14),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: TextStyle(color: isDark ? Colors.white10 : Colors.black12),
        prefixIcon: Icon(prefixIcon, size: 18, color: isDark ? Colors.white24 : Colors.black26),
        suffixIcon: suffix,
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
        padding: const EdgeInsets.symmetric(vertical: 10),
        side: BorderSide(color: isDark ? Colors.white10 : Colors.black12),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        backgroundColor: isDark ? const Color(0xFF13191f).withOpacity(0.5) : Colors.white,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 18, color: isDark ? Colors.white : Colors.black),
          const SizedBox(width: 8),
          Text(
            label,
            style: TextStyle(
              color: isDark ? Colors.white : Colors.black,
              fontWeight: FontWeight.w600,
              fontSize: 13,
            ),
          ),
        ],
      ),
    );
  }
}

class _OrDividerSignup extends StatelessWidget {
  const _OrDividerSignup();

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Row(
      children: [
        Expanded(child: Divider(color: isDark ? Colors.white10 : Colors.black12)),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Text(
            'OR REGISTER WITH',
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