import 'dart:async';
import 'package:flutter/material.dart';
import '../MyColors.dart';
import '../services/authservice.dart';
import 'login_page.dart';

class OTPVerificationPage extends StatefulWidget {
  final String userId;
  final String email;
  final String token;
  final VoidCallback toggleTheme;

  const OTPVerificationPage({
    super.key,
    required this.userId,
    required this.email,
    required this.token,
    required this.toggleTheme,
  });

  @override
  State<OTPVerificationPage> createState() => _OTPVerificationPageState();
}

class _OTPVerificationPageState extends State<OTPVerificationPage> {
  final TextEditingController otpController = TextEditingController();
  bool isLoading = false;
  bool canResend = false;
  int resendTimer = 60;
  Timer? timer;

  @override
  void initState() {
    super.initState();
    startResendTimer();
  }

  @override
  void dispose() {
    otpController.dispose();
    timer?.cancel();
    super.dispose();
  }

  void startResendTimer() {
    setState(() {
      canResend = false;
      resendTimer = 60;
    });

    timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (resendTimer > 0) {
        setState(() {
          resendTimer--;
        });
      } else {
        setState(() {
          canResend = true;
        });
        timer.cancel();
      }
    });
  }

  void _showSnackBar(String message, Color color) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          message,
          style: const TextStyle(fontWeight: FontWeight.w600, color: MyColors.white),
        ),
        backgroundColor: color,
        duration: const Duration(seconds: 2),
      ),
    );
  }

  Future<void> handleVerifyOTP() async {
    final otp = otpController.text.trim();

    if (otp.isEmpty) {
      _showSnackBar("Please enter the verification code", Colors.orange);
      return;
    }

    if (otp.length != 6) {
      _showSnackBar("Verification code must be 6 digits", Colors.orange);
      return;
    }

    setState(() {
      isLoading = true;
    });

    try {
      var val = await AuthService().verifyOTP(widget.userId, otp);

      if (val != null && val.data["success"] == true) {
        if (!mounted) return;

        _showSnackBar("Email verified successfully!", MyColors.green_light);

        await Future.delayed(const Duration(milliseconds: 500));

        if (!mounted) return;

        // ✅ DEĞİŞİKLİK: PaymentVerificationPage yerine LoginPage'e yönlendir
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(
            builder: (context) => LoginPage(
              toggleTheme: widget.toggleTheme,
            ),
          ),
              (route) => false, // Tüm önceki sayfaları kaldır (back tuşu çalışmasın)
        );

        // ✅ Başarı mesajı göster
        Future.delayed(const Duration(milliseconds: 300), () {
          if (mounted) {
            _showSnackBar(
              "Account created! You can now login",
              MyColors.green_light,
            );
          }
        });
      } else {
        if (!mounted) return;
        _showSnackBar(
          val?.data["msg"] ?? "Verification failed",
          MyColors.red,
        );
      }
    } catch (e) {
      if (!mounted) return;
      print("❌ OTP Verification Error: $e");
      _showSnackBar("An error occurred", MyColors.red);
    } finally {
      if (mounted) {
        setState(() {
          isLoading = false;
        });
      }
    }
  }

  Future<void> handleResendOTP() async {
    setState(() {
      isLoading = true;
    });

    try {
      var val = await AuthService().resendOTP(widget.userId, widget.email);

      if (val != null && val.data["success"] == true) {
        if (!mounted) return;
        _showSnackBar("Verification code sent!", MyColors.green_light);
        startResendTimer();
      } else {
        if (!mounted) return;
        _showSnackBar(
          val?.data["msg"] ?? "Failed to resend code",
          MyColors.red,
        );
      }
    } catch (e) {
      if (!mounted) return;
      print("❌ Resend OTP Error: $e");
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
            shadows: isDark
                ? [
              Shadow(
                color: MyColors.cyan.withOpacity(0.5),
                blurRadius: 10,
              ),
            ]
                : [],
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
                color: isDark
                    ? MyColors.cyan.withOpacity(0.3)
                    : MyColors.green.withOpacity(0.3),
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
              color: isDark ? const Color(0xFF242938) : MyColors.white,
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
                  Icon(
                    Icons.mark_email_read_outlined,
                    size: 80,
                    color: isDark ? MyColors.cyan : MyColors.green,
                  ),
                  const SizedBox(height: 24),
                  Text(
                    'Verify Your Email',
                    style: TextStyle(
                      fontSize: 32,
                      fontWeight: FontWeight.w500,
                      color: isDark ? MyColors.white : MyColors.green,
                      letterSpacing: 1.5,
                      shadows: isDark
                          ? [
                        Shadow(
                          color: MyColors.white.withOpacity(0.3),
                          blurRadius: 8,
                        ),
                      ]
                          : [],
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'Enter the 6-digit code sent to',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w400,
                      color: isDark
                          ? MyColors.white.withOpacity(0.5)
                          : MyColors.green.withOpacity(0.7),
                      letterSpacing: 0.8,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    widget.email,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: isDark ? MyColors.cyan : MyColors.green,
                      letterSpacing: 0.5,
                    ),
                  ),
                  const SizedBox(height: 40),

                  // OTP INPUT
                  TextField(
                    controller: otpController,
                    keyboardType: TextInputType.number,
                    maxLength: 6,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: isDark ? Colors.white : MyColors.green,
                      fontSize: 24,
                      fontWeight: FontWeight.w600,
                      letterSpacing: 8,
                    ),
                    decoration: InputDecoration(
                      counterText: "",
                      hintText: '000000',
                      hintStyle: TextStyle(
                        color: isDark
                            ? MyColors.white.withOpacity(0.2)
                            : MyColors.green.withOpacity(0.2),
                        letterSpacing: 8,
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
                          color: isDark
                              ? Colors.white.withOpacity(0.05)
                              : Colors.black.withOpacity(0.05),
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

                  // VERIFY BUTTON
                  SizedBox(
                    width: double.infinity,
                    height: 56,
                    child: ElevatedButton(
                      onPressed: isLoading ? null : handleVerifyOTP,
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
                          : const Text(
                        'Verify Email',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          letterSpacing: 1.2,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),

                  // RESEND CODE
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        "Didn't receive the code? ",
                        style: TextStyle(
                          color: isDark
                              ? MyColors.white.withOpacity(0.6)
                              : MyColors.green.withOpacity(0.7),
                          fontSize: 14,
                        ),
                      ),
                      if (canResend)
                        TextButton(
                          onPressed: isLoading ? null : handleResendOTP,
                          style: TextButton.styleFrom(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 4, vertical: 4),
                          ),
                          child: Text(
                            'Resend',
                            style: TextStyle(
                              color: isDark ? MyColors.cyan : MyColors.green,
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              letterSpacing: 0.3,
                            ),
                          ),
                        )
                      else
                        Text(
                          'Resend in ${resendTimer}s',
                          style: TextStyle(
                            color: isDark
                                ? MyColors.white.withOpacity(0.4)
                                : MyColors.green.withOpacity(0.5),
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
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