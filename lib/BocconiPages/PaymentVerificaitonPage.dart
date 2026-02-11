import 'dart:async';
import 'dart:html' as html;
import 'package:flutter/material.dart';
import 'package:flutter/gestures.dart';
import '../MyColors.dart';
import '../services/authservice.dart';
import 'login_page.dart';

class PaymentVerificationPage extends StatefulWidget {
  final String userId;
  final String email;
  final VoidCallback toggleTheme;

  const PaymentVerificationPage({
    super.key,
    required this.userId,
    required this.email,
    required this.toggleTheme,
  });

  @override
  State<PaymentVerificationPage> createState() =>
      _PaymentVerificationPageState();
}

class _PaymentVerificationPageState extends State<PaymentVerificationPage> {
  bool isLoading = false;
  String? errorMessage;
  Timer? pollingTimer;
  String? paymentPageUrl;
  bool acceptedTerms = false;

  @override
  void dispose() {
    pollingTimer?.cancel();
    super.dispose();
  }

  Future<void> initializePayment() async {
    if (!acceptedTerms) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text(
            'Please accept the Terms of Service, Privacy Policy, and Distance Sales Agreement to continue.',
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
          ),
          backgroundColor: Colors.red,
          duration: const Duration(seconds: 3),
        ),
      );
      return;
    }

    setState(() {
      isLoading = true;
      errorMessage = null;
    });

    try {
      final response = await AuthService().initializePayment(
        userId: widget.userId,
        email: widget.email,
        name: "User",
        acceptedTerms: true,
        acceptedPreliminaryInformation: true,
      );

      if (response != null && response.data["success"] == true) {
        setState(() {
          paymentPageUrl = response.data["paymentPageUrl"];
          isLoading = false;
        });

        print('✅ [PAYMENT] Payment URL received: $paymentPageUrl');

        if (paymentPageUrl != null) {
          _openPaymentInNewTab();
          _startPaymentPolling();
        }
      } else {
        setState(() {
          errorMessage = response?.data["msg"] ?? "Payment initialization failed";
          isLoading = false;
        });

        print('❌ [PAYMENT] Initialization failed: $errorMessage');
      }
    } catch (e) {
      setState(() {
        errorMessage = "An error occurred. Please try again.";
        isLoading = false;
      });

      print('❌ [PAYMENT] Error: $e');
    }
  }

  void _openPaymentInNewTab() {
    if (paymentPageUrl == null) return;

    print('🌐 [PAYMENT] Opening payment page in new tab...');
    html.window.open(paymentPageUrl!, '_blank');

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text(
            'Payment page opened in new tab. Complete your payment there.',
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
          ),
          backgroundColor: MyColors.green_light,
          duration: const Duration(seconds: 5),
        ),
      );
    }
  }

  void _startPaymentPolling() {
    print('💓 [POLLING] Starting payment status polling...');

    pollingTimer = Timer.periodic(const Duration(seconds: 3), (timer) async {
      try {
        final response = await AuthService().checkPaymentStatus(widget.userId);

        if (response != null && response.data["success"] == true) {
          final isPaid = response.data["isPaid"] ?? false;

          if (isPaid) {
            print('✅ [POLLING] Payment completed!');
            timer.cancel();
            _handlePaymentSuccess();
          }
        }
      } catch (e) {
        print('⚠️ [POLLING] Error: $e');
      }
    });

    Future.delayed(const Duration(minutes: 10), () {
      if (pollingTimer?.isActive ?? false) {
        pollingTimer?.cancel();
        print('⏰ [POLLING] Timeout - stopping payment check');

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text(
                'Payment check timed out. Please refresh the page.',
                style: TextStyle(color: Colors.white),
              ),
              backgroundColor: Colors.orange,
            ),
          );
        }
      }
    });
  }

  void _handlePaymentSuccess() {
    if (!mounted) return;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        title: Row(
          children: const [
            Icon(Icons.check_circle, color: Colors.green, size: 32),
            SizedBox(width: 12),
            Flexible(child: Text('Payment Successful!')),
          ],
        ),
        content: const Text(
          'Your payment has been processed successfully. You can now access all premium features.',
          style: TextStyle(fontSize: 16),
        ),
        actions: [
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop();
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(
                  builder: (context) => LoginPage(
                    toggleTheme: widget.toggleTheme,
                  ),
                ),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: MyColors.green,
              padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: const Text(
              'Login Now',
              style: TextStyle(fontSize: 16, color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }

  void _openLegalDocument(String path) {
    final baseUrl = html.window.location.origin;
    html.window.open('$baseUrl/#$path', '_blank');
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Complete Payment'),
        backgroundColor: isDark ? const Color(0xFF0f172a) : Colors.white,
        actions: [
          IconButton(
            icon: Icon(
              isDark ? Icons.light_mode : Icons.dark_mode,
              color: isDark ? Colors.yellow : MyColors.bocco_blue,
            ),
            onPressed: widget.toggleTheme,
          ),
        ],
      ),
      body: Container(
        color: isDark ? const Color(0xFF0a0e27) : const Color(0xFFe8edf2),
        child: SingleChildScrollView(
          child: Center(
            child: Container(
              constraints: const BoxConstraints(maxWidth: 600),
              margin: EdgeInsets.all(MediaQuery.of(context).size.width < 600 ? 16 : 40),
              padding: EdgeInsets.all(MediaQuery.of(context).size.width < 600 ? 20 : 40),
              decoration: BoxDecoration(
                color: isDark
                    ? const Color(0xFF0f172a).withOpacity(0.7)
                    : Colors.white,
                borderRadius: BorderRadius.circular(24),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 20,
                    offset: const Offset(0, 10),
                  ),
                ],
              ),
              child: isLoading
                  ? Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  CircularProgressIndicator(
                    color: isDark ? MyColors.cyan : MyColors.green,
                    strokeWidth: 3,
                  ),
                  const SizedBox(height: 30),
                  Text(
                    'Preparing payment...',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w500,
                      color: isDark ? Colors.white70 : Colors.black54,
                    ),
                  ),
                ],
              )
                  : errorMessage != null
                  ? Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(
                    Icons.error_outline,
                    size: 80,
                    color: Colors.red,
                  ),
                  const SizedBox(height: 20),
                  Text(
                    'Error',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: isDark ? Colors.white : Colors.black,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    errorMessage!,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 16,
                      color: isDark ? Colors.white70 : Colors.black54,
                    ),
                  ),
                  const SizedBox(height: 30),
                  ElevatedButton(
                    onPressed: initializePayment,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: MyColors.cyan,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 40,
                        vertical: 15,
                      ),
                    ),
                    child: const Text(
                      'Try Again',
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ],
              )
                  : paymentPageUrl != null
                  ? Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.payment,
                    size: 80,
                    color: isDark ? MyColors.cyan : MyColors.green,
                  ),
                  const SizedBox(height: 20),
                  Text(
                    'Payment Page Opened',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: isDark ? Colors.white : Colors.black,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    'Complete your payment in the opened tab.',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 16,
                      color: isDark ? Colors.white70 : Colors.black54,
                    ),
                  ),
                  const SizedBox(height: 30),
                  ElevatedButton.icon(
                    onPressed: _openPaymentInNewTab,
                    icon: const Icon(Icons.open_in_new),
                    label: const Text('Open Payment Page Again'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor:
                      isDark ? MyColors.cyan : MyColors.green,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 30,
                        vertical: 15,
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color:
                          isDark ? MyColors.cyan : MyColors.green,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Text(
                        'Waiting for payment...',
                        style: TextStyle(
                          fontSize: 14,
                          color: isDark
                              ? Colors.white60
                              : Colors.black45,
                        ),
                      ),
                    ],
                  ),
                ],
              )
                  : Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Header
                  Center(
                    child: Icon(
                      Icons.payment,
                      size: 80,
                      color: isDark ? MyColors.cyan : MyColors.green,
                    ),
                  ),
                  const SizedBox(height: 20),
                  Center(
                    child: Text(
                      'Complete Your Payment',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: isDark ? Colors.white : Colors.black,
                      ),
                    ),
                  ),
                  const SizedBox(height: 30),

                  // 💶 PRICE BOX
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: isDark
                            ? [
                          const Color(0xFF1a3a52),
                          const Color(0xFF0f2537),
                        ]
                            : [
                          const Color(0xFFe8f5e9),
                          const Color(0xFFc8e6c9),
                        ],
                      ),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: isDark ? MyColors.cyan.withOpacity(0.3) : MyColors.green.withOpacity(0.3),
                        width: 2,
                      ),
                    ),
                    child: Column(
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.workspace_premium,
                              color: isDark ? MyColors.cyan : MyColors.green,
                              size: 22,
                            ),
                            const SizedBox(width: 8),
                            Flexible(
                              child: Text(
                                'Premium Subscription',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                  color: isDark ? Colors.white : Colors.black87,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              '€',
                              style: TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                                color: isDark ? MyColors.cyan : MyColors.green,
                                height: 1.2,
                              ),
                            ),
                            const SizedBox(width: 2),
                            Text(
                              '79',
                              style: TextStyle(
                                fontSize: 42,
                                fontWeight: FontWeight.bold,
                                color: isDark ? Colors.white : Colors.black87,
                                height: 1,
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.only(top: 6),
                              child: Text(
                                '.99',
                                style: TextStyle(
                                  fontSize: 22,
                                  fontWeight: FontWeight.bold,
                                  color: isDark ? Colors.white70 : Colors.black54,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 6),
                        Text(
                          'One-time payment',
                          style: TextStyle(
                            fontSize: 13,
                            color: isDark ? Colors.white60 : Colors.black54,
                            fontStyle: FontStyle.italic,
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 24),

                  // TERMS CHECKBOX
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: isDark
                          ? const Color(0xFF1a1f2e)
                          : const Color(0xFFf5f7fa),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: acceptedTerms
                            ? (isDark ? MyColors.cyan : MyColors.green)
                            : (isDark
                            ? Colors.white24
                            : Colors.black12),
                        width: acceptedTerms ? 2 : 1,
                      ),
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Checkbox(
                          value: acceptedTerms,
                          onChanged: (value) {
                            setState(() {
                              acceptedTerms = value ?? false;
                            });
                          },
                          activeColor: isDark
                              ? MyColors.cyan
                              : MyColors.green,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(4),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Padding(
                            padding: const EdgeInsets.only(top: 12),
                            child: RichText(
                              text: TextSpan(
                                style: TextStyle(
                                  fontSize: 14,
                                  color: isDark
                                      ? Colors.white70
                                      : Colors.black87,
                                  height: 1.5,
                                ),
                                children: [
                                  const TextSpan(
                                    text: 'I have read and accept the ',
                                  ),
                                  TextSpan(
                                    text: 'Terms of Service',
                                    style: TextStyle(
                                      color: isDark
                                          ? MyColors.white
                                          : MyColors.green,
                                      fontWeight: FontWeight.w600,
                                      decoration:
                                      TextDecoration.underline,
                                    ),
                                    recognizer: TapGestureRecognizer()
                                      ..onTap = () =>
                                          _openLegalDocument('/terms'),
                                  ),
                                  const TextSpan(text: ', '),
                                  TextSpan(
                                    text: 'Privacy Policy',
                                    style: TextStyle(
                                      color: isDark
                                          ? MyColors.white
                                          : MyColors.green,
                                      fontWeight: FontWeight.w600,
                                      decoration:
                                      TextDecoration.underline,
                                    ),
                                    recognizer: TapGestureRecognizer()
                                      ..onTap = () => _openLegalDocument(
                                          '/privacy'),
                                  ),
                                  const TextSpan(text: ', and '),
                                  TextSpan(
                                    text: 'Distance Sales Agreement',
                                    style: TextStyle(
                                      color: isDark
                                          ? MyColors.white
                                          : MyColors.green,
                                      fontWeight: FontWeight.w600,
                                      decoration:
                                      TextDecoration.underline,
                                    ),
                                    recognizer: TapGestureRecognizer()
                                      ..onTap = () => _openLegalDocument(
                                          '/distance_sales_agreement'),
                                  ),
                                  const TextSpan(text: '.'),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 24),

                  // Proceed Button
                  Center(
                    child: ElevatedButton.icon(
                      onPressed: acceptedTerms ? initializePayment : null,
                      icon: acceptedTerms ? const Icon(Icons.lock_open) : const Icon(Icons.lock),
                      label: const Text(
                        'Proceed to Payment',
                        style: TextStyle(fontWeight: FontWeight.w500),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: acceptedTerms
                            ? (isDark ? MyColors.green_light : MyColors.green_light)
                            : Colors.grey,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 40,
                          vertical: 15,
                        ),
                        disabledBackgroundColor: Colors.grey,
                        disabledForegroundColor: Colors.white70,
                      ),
                    ),
                  ),

                  if (!acceptedTerms) ...[
                    const SizedBox(height: 12),
                    Center(
                      child: Text(
                        'Please accept the terms to continue',
                        style: TextStyle(
                          fontSize: 12,
                          color: isDark
                              ? Colors.white54
                              : Colors.black54,
                          fontStyle: FontStyle.italic,
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}