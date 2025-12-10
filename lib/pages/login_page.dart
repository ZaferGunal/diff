import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../UserProvider.dart';
import '../services/authservice.dart';
import 'OTPVerificaitonPage.dart';
import 'home_page.dart';
import 'ForgotPasswordPage.dart';
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

        await Future.delayed(const Duration(milliseconds: 500));

        if (!mounted) return;

        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => HomePage(
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
            decoration: BoxDecoration(color: isDark ? MyColors.black: MyColors.white,
              shape: BoxShape.circle,
              border: Border.all(
                color: isDark ? MyColors.softBeige.withOpacity(0.6) : MyColors.green.withOpacity(0.6),
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
                    'Welcome Back',
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
                    'Sign in to continue',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w400,
                      color: isDark ? MyColors.white.withOpacity(0.5) : MyColors.green.withOpacity(0.7),
                      letterSpacing: 0.8,
                    ),
                  ),
                  const SizedBox(height: 40),
                  TextField(
                    controller: emailController,
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
                  TextField(
                    controller: passwordController,
                    obscureText: true,
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

                  const SizedBox(height: 12),
                  Align(
                    alignment: Alignment.centerRight,
                    child: TextButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => ForgotPasswordPage(
                              toggleTheme: widget.toggleTheme,
                            ),
                          ),
                        );
                      },
                      style: TextButton.styleFrom(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      ),
                      child: Text(
                        'Forgot Password?',
                        style: TextStyle(
                          color: isDark ? MyColors.white : MyColors.green,
                          fontSize: 13,
                          fontWeight: FontWeight.w500,
                          letterSpacing: 0.3,
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 24),
                  SizedBox(
                    width: double.infinity,
                    height: 56,
                    child: ElevatedButton(
                      onPressed: isLoading ? null : handleLogin,
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
                        'Login',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          letterSpacing: 1.2,
                        ),
                      ),
                    ),
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