import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../MyColors.dart';
import '../UserProvider.dart';
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
  bool isResending = false;
  int remainingTime = 300;
  Timer? timer;

  @override
  void initState() {
    super.initState();
    startTimer();
  }

  void startTimer() {
    timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (remainingTime > 0) {
        setState(() {
          remainingTime--;
        });
      } else {
        timer.cancel();
      }
    });
  }

  @override
  void dispose() {
    timer?.cancel();
    otpController.dispose();
    super.dispose();
  }

  String get timerText {
    int minutes = remainingTime ~/ 60;
    int seconds = remainingTime % 60;
    return '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
  }

  Future<void> handleVerify() async {
    if (otpController.text.length != 6) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Please enter 6-digit code",style: TextStyle(fontWeight:FontWeight.w600,color:MyColors.white)),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    setState(() {
      isLoading = true;
    });

    try {
      var val = await AuthService().verifyOTP(widget.userId, otpController.text.trim());

      if (val != null && val.data["success"] == true) {
        // ✅ ÖNCE token'ı kaydet
        await context.read<AuthProvider>().setToken(widget.token);

        // ✅ setToken içinde zaten fetchUserInfo çağrılıyor, ama emin olmak için:
        // Biraz bekle ki state güncellensin
        await Future.delayed(Duration(milliseconds: 300));

        // ✅ Kontrol et: token ve userData var mı?
        final authProvider = context.read<AuthProvider>();
        print("🔍 Token: ${authProvider.token}");
        print("🔍 UserData: ${authProvider.name}");
        print("🔍 isAuthenticated: ${authProvider.isAuthenticated}");

        if (!mounted) return;

        // ✅ Başarılı mesajı göster
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Email verified successfully!",style: TextStyle(fontWeight:FontWeight.w600,color:MyColors.white)),
            backgroundColor: Colors.green,
            duration: Duration(seconds: 1),
          ),
        );

        // ✅ Kısa delay
        await Future.delayed(Duration(milliseconds: 500));

        if (!mounted) return;

        // ✅ LoginPage'e git - kullanıcı oradan login olsun
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(
            builder: (context) => LoginPage(
              toggleTheme: widget.toggleTheme,
            ),
          ),
              (route) => false, // Tüm önceki route'ları temizle
        );
      } else {
        if (!mounted) return;

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(style: TextStyle(fontWeight:FontWeight.w600,color:MyColors.white),val?.data["msg"] ?? "Verification failed"),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Error: $e"),
          backgroundColor: Colors.red,
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

  Future<void> handleResend() async {
    setState(() {
      isResending = true;
    });

    try {
      var val = await AuthService().resendOTP(widget.userId, widget.email);

      if (val != null && val.data["success"] == true) {
        if (!mounted) return;

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("New code sent to your email",style: TextStyle(fontWeight:FontWeight.w600,color:MyColors.white)),
            backgroundColor: Colors.green,
          ),
        );

        setState(() {
          remainingTime = 300;
        });
        timer?.cancel();
        startTimer();
      }
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Error: $e",style: TextStyle(fontWeight:FontWeight.w600,color:MyColors.white)),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      if (mounted) {
        setState(() {
          isResending = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Verify Email'),
        backgroundColor: isDark ? const Color(0xFF0f172a) : Colors.white,
        actions: [
          IconButton(
            icon: Icon(color: isDark? Colors.yellow : MyColors.bocco_blue,isDark ? Icons.light_mode : Icons.dark_mode),
            onPressed: widget.toggleTheme,
          ),
        ],
      ),
      body: Container(
        color: isDark ? const Color(0xFF0a0e27) : const Color(0xFFe8edf2),
        child: Center(
          child: Container(
            constraints: const BoxConstraints(maxWidth: 500),
            margin: const EdgeInsets.all(40),
            padding: const EdgeInsets.all(40),
            decoration: BoxDecoration(
              color: isDark ? const Color(0xFF0f172a).withOpacity(0.7) : Colors.white,
              borderRadius: BorderRadius.circular(24),
              border: Border.all(
                color: isDark ? Colors.white.withOpacity(0.1) : Colors.grey[300]!,
              ),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.email_outlined,
                  size: 80,
                  color: isDark ? Colors.white70 : Colors.grey[700],
                ),
                const SizedBox(height: 24),
                Text(
                  'Verify Your Email',
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.w300,
                    color: isDark ? Colors.white : Colors.black87,
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  'We sent a code to\n${widget.email}',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 16,
                    color: isDark ? Colors.white70 : Colors.grey[600],
                  ),
                ),
                const SizedBox(height: 40),
                TextField(
                  controller: otpController,
                  keyboardType: TextInputType.number,
                  maxLength: 6,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 32,
                    letterSpacing: 8,
                    fontWeight: FontWeight.bold,
                  ),
                  decoration: InputDecoration(
                    hintText: '000000',
                    counterText: '',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: const BorderSide(color: MyColors.cyan, width: 2),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  'Time remaining: $timerText',
                  style: TextStyle(
                    fontSize: 14,
                    color: remainingTime < 60 ? Colors.red : (isDark ? Colors.white70 : Colors.grey[600]),
                  ),
                ),
                const SizedBox(height: 30),
                SizedBox(
                  width: double.infinity,
                  height: 55,
                  child: ElevatedButton(
                    onPressed: isLoading ? null : handleVerify,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: MyColors.cyan,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: isLoading
                        ? const CircularProgressIndicator(color: Colors.white)
                        : const Text(
                      'Verify',
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600, color: Colors.white),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                TextButton(
                  onPressed: isResending ? null : handleResend,
                  child: isResending
                      ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                      : const Text(
                    'Resend Code',
                    style: TextStyle(color: MyColors.earth,fontSize: 16),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}