import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import '../MyColors.dart';
import '../services/authservice.dart';
import '../UserProvider.dart';
import '../MainPages/Dashboard.dart';

class TILIPurchasePage extends StatefulWidget {
  final VoidCallback toggleTheme;
  final String token;
  final String userId;
  final String userEmail;
  final String userName;
  final String packageTier;
  final String packageName;
  final String priceEur;
  final String priceTry;

  const TILIPurchasePage({
    super.key,
    required this.toggleTheme,
    required this.token,
    required this.userId,
    required this.userEmail,
    required this.userName,
    required this.packageTier,
    required this.packageName,
    required this.priceEur,
    required this.priceTry,
  });

  @override
  State<TILIPurchasePage> createState() => _TILIPurchasePageState();
}

class _TILIPurchasePageState extends State<TILIPurchasePage> {
  bool _acceptedTerms = false;
  bool _acceptedPreliminaryInfo = false;
  bool _isProcessing = false;
  Timer? _pollTimer;
  bool _isPolling = false;

  @override
  void dispose() {
    _pollTimer?.cancel();
    super.dispose();
  }

  Future<void> _handlePurchase() async {
    if (!_acceptedTerms || !_acceptedPreliminaryInfo) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Please accept all terms to continue',
            style: TextStyle(fontWeight: FontWeight.w600, color: Colors.white),
          ),
          backgroundColor: MyColors.orange,
        ),
      );
      return;
    }

    setState(() {
      _isProcessing = true;
    });

    try {
      final authProvider = context.read<AuthProvider>();
      final userId = authProvider.userId;
      final userEmail = authProvider.email ?? '';
      final userName = authProvider.name ?? '';

      if (userId == null || userId.isEmpty) {
        throw 'User ID not found. Please login again.';
      }

      print('🔍 [TILI PURCHASE] Initializing payment for user: $userId');
      print('📦 [TILI PURCHASE] Package tier: ${widget.packageTier}');

      final response = await AuthService().initializeTiliPayment(
        userId: userId,
        email: userEmail,
        name: userName,
        acceptedTerms: _acceptedTerms,
        acceptedPreliminaryInformation: _acceptedPreliminaryInfo,
        packageTier: widget.packageTier,
      );

      if (response != null && response.data['success'] == true) {
        final paymentUrl = response.data['paymentPageUrl'];

        if (paymentUrl != null) {
          print('✅ [TILI] Opening payment URL');

          final uri = Uri.parse(paymentUrl);
          await launchUrl(uri, mode: LaunchMode.externalApplication);

          _startPaymentPolling(userId);

          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(
                  'Complete payment in the new window. We\'ll redirect you automatically.',
                  style: TextStyle(color: Colors.white),
                ),
                backgroundColor: MyColors.green,
                duration: Duration(seconds: 5),
              ),
            );
          }
        } else {
          throw 'Payment URL not found';
        }
      } else {
        final errorMsg = response?.data['msg'] ?? 'Payment failed';
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(errorMsg), backgroundColor: MyColors.red),
          );
        }
      }
    } catch (e) {
      print('❌ [TILI] Error: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Payment failed: ${e.toString()}'),
            backgroundColor: MyColors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isProcessing = false;
        });
      }
    }
  }

  void _startPaymentPolling(String userId) {
    if (_isPolling) return;

    setState(() {
      _isPolling = true;
    });

    print('🔄 [POLLING] Starting...');

    _pollTimer = Timer.periodic(Duration(seconds: 3), (timer) async {
      try {
        print('🔍 [POLLING] Checking...');

        final response = await AuthService().checkUserPaymentStatus(userId);

        if (response != null && response.data['success'] == true) {
          final hasTili = response.data['hasTiliPackage'] ?? false;

          if (hasTili) {
            print('✅ [POLLING] Payment successful!');

            timer.cancel();
            _pollTimer = null;

            await context.read<AuthProvider>().refresh();

            if (mounted) {
              Navigator.pushAndRemoveUntil(
                context,
                MaterialPageRoute(
                  builder: (context) => DashboardPage(
                    toggleTheme: widget.toggleTheme,
                    token: widget.token,
                  ),
                ),
                    (route) => false,
              );

              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('🎉 Payment successful! Welcome to TIL-I ${widget.packageName}!'),
                  backgroundColor: MyColors.green,
                ),
              );
            }
          }
        }
      } catch (e) {
        print('⚠️ [POLLING] Error: $e');
      }
    });

    Future.delayed(Duration(minutes: 5), () {
      if (_pollTimer != null && _pollTimer!.isActive) {
        print('⏰ [POLLING] Timeout');
        _pollTimer?.cancel();
        _pollTimer = null;
        if (mounted) setState(() => _isPolling = false);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    if (_isPolling) {
      return Scaffold(
        body: Container(
          decoration: BoxDecoration(
            gradient: isDark
                ? LinearGradient(
              colors: [Color(0xFF0a0e1a), Color(0xFF141b2d)],
            )
                : LinearGradient(
              colors: [Color(0xFFf0f4f8), Color(0xFFe8eef5)],
            ),
          ),
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                CircularProgressIndicator(
                  color: isDark ? MyColors.orange : MyColors.bocco_blue,
                ),
                SizedBox(height: 20),
                Text(
                  'Waiting for payment...',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
                ),
                SizedBox(height: 10),
                Text(
                  'Complete the payment in the new window',
                  style: TextStyle(fontSize: 14, color: Colors.grey),
                ),
              ],
            ),
          ),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back,
            color: isDark ? MyColors.orange : MyColors.bocco_blue,
          ),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Complete Purchase',
          style: TextStyle(
            fontWeight: FontWeight.w700,
            letterSpacing: 1.5,
            color: isDark ? MyColors.orange : MyColors.bocco_blue,
          ),
        ),
        backgroundColor: isDark ? const Color(0xFF0f172a) : Colors.white,
        elevation: 0,
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
              MyColors.orange.withOpacity(0.1),
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
            constraints: const BoxConstraints(maxWidth: 600),
            margin: EdgeInsets.all(MediaQuery.of(context).size.width < 768 ? 16 : 32),
            padding: EdgeInsets.all(MediaQuery.of(context).size.width < 768 ? 20 : 40),
            decoration: BoxDecoration(
              color: isDark ? const Color(0xFF1a1f2e) : Colors.white,
              borderRadius: BorderRadius.circular(32),
              border: Border.all(
                color: isDark
                    ? MyColors.orange.withOpacity(0.3)
                    : MyColors.bocco_blue.withOpacity(0.3),
                width: 2,
              ),
              boxShadow: [
                BoxShadow(
                  color: isDark
                      ? Colors.black.withOpacity(0.5)
                      : Colors.black.withOpacity(0.1),
                  blurRadius: 40,
                  offset: const Offset(0, 10),
                ),
              ],
            ),
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Center(
                    child: Column(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(20),
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [
                                MyColors.orange.withOpacity(0.3),
                                MyColors.bocco_blue.withOpacity(0.2),
                              ],
                            ),
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            Icons.lightbulb_rounded,
                            size: 48,
                            color: isDark ? MyColors.orange : MyColors.bocco_blue,
                          ),
                        ),
                        const SizedBox(height: 20),
                        Text(
                          widget.packageName.contains('Upgrade') 
                            ? widget.packageName 
                            : 'TIL-I ${widget.packageName} Package',
                          style: TextStyle(
                            fontSize: MediaQuery.of(context).size.width < 768 ? 22 : 28,
                            fontWeight: FontWeight.w800,
                            color: isDark ? Colors.white : Colors.black87,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 30),
                      ],
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      color: isDark
                          ? const Color(0xFF0f1419).withOpacity(0.5)
                          : const Color(0xFFf5f7fa),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: isDark
                            ? Colors.white.withOpacity(0.1)
                            : Colors.black.withOpacity(0.05),
                        width: 1,
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Order Summary',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w700,
                            color: isDark ? Colors.white : Colors.black87,
                          ),
                        ),
                        const SizedBox(height: 20),
                        _buildSummaryRow('Package', widget.packageName.contains('Upgrade') ? widget.packageName : 'TIL-I ${widget.packageName}', isDark),
                        _buildSummaryRow(widget.packageName.contains('Upgrade') ? 'Old Plan' : 'Access', widget.packageName.contains('Upgrade') ? 'Basic Tier' : 'Lifetime', isDark),
                        const Divider(height: 32),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'Total',
                              style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.w800,
                                color: isDark ? Colors.white : Colors.black87,
                              ),
                            ),
                            Text(
                              '€${widget.priceEur}',
                              style: TextStyle(
                                fontSize: 28,
                                fontWeight: FontWeight.w900,
                                color: isDark ? MyColors.orange : MyColors.bocco_blue,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 32),
                  Text(
                    'Terms & Conditions',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                      color: isDark ? Colors.white : Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 16),
                  _buildCheckbox(
                    value: _acceptedTerms,
                    onChanged: (value) => setState(() => _acceptedTerms = value ?? false),
                    text: 'I accept the Terms of Service and Privacy Policy',
                    isDark: isDark,
                  ),
                  const SizedBox(height: 12),
                  _buildCheckbox(
                    value: _acceptedPreliminaryInfo,
                    onChanged: (value) => setState(() => _acceptedPreliminaryInfo = value ?? false),
                    text: 'I accept the Distance Sales Agreement',
                    isDark: isDark,
                  ),
                  const SizedBox(height: 32),
                  SizedBox(
                    width: double.infinity,
                    height: 60,
                    child: ElevatedButton(
                      onPressed: _isProcessing ? null : _handlePurchase,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: isDark ? MyColors.orange : MyColors.bocco_blue,
                        foregroundColor: Colors.white,
                        disabledBackgroundColor: Colors.grey,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                        elevation: 0,
                      ),
                      child: _isProcessing
                          ? const SizedBox(
                        height: 24,
                        width: 24,
                        child: CircularProgressIndicator(
                          color: Colors.white,
                          strokeWidth: 2.5,
                        ),
                      )
                          : Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.lock_outline, size: 20),
                          const SizedBox(width: 12),
                          Text(
                            'Proceed to Secure Payment',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w700,
                              letterSpacing: 1,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.verified_user,
                        size: 16,
                        color: isDark ? Colors.white.withOpacity(0.5) : Colors.black45,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'Secure payment powered by İyzico',
                        style: TextStyle(
                          fontSize: 13,
                          color: isDark ? Colors.white.withOpacity(0.5) : Colors.black45,
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

  Widget _buildSummaryRow(String label, String value, bool isDark) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 15,
              color: isDark ? Colors.white.withOpacity(0.6) : Colors.black54,
            ),
          ),
          Text(
            value,
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w600,
              color: isDark ? Colors.white : Colors.black87,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCheckbox({
    required bool value,
    required Function(bool?) onChanged,
    required String text,
    required bool isDark,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Checkbox(
          value: value,
          onChanged: onChanged,
          activeColor: isDark ? MyColors.orange : MyColors.bocco_blue,
          side: BorderSide(
            color: isDark ? Colors.white.withOpacity(0.3) : Colors.black26,
            width: 1.5,
          ),
        ),
        Expanded(
          child: Padding(
            padding: const EdgeInsets.only(top: 12, left: 8),
            child: Text(
              text,
              style: TextStyle(
                fontSize: 14,
                color: isDark ? Colors.white.withOpacity(0.8) : Colors.black87,
                height: 1.5,
              ),
            ),
          ),
        ),
      ],
    );
  }
}