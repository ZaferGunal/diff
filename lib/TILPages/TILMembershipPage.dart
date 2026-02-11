import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../UserProvider.dart';
import '../widgets/theme_toggle.dart';
import 'package:google_fonts/google_fonts.dart';
import 'TILIDashboard.dart'; // For BentoColors
import 'TILPurchasePage.dart';

class TILMembershipPage extends StatelessWidget {
  final VoidCallback toggleTheme;
  const TILMembershipPage({super.key, required this.toggleTheme});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final authProvider = context.watch<AuthProvider>();
    final tier = authProvider.tiliPackageTier?.toLowerCase() ?? 'free';
    
    final bg = isDark ? const Color(0xFF0B1622) : const Color(0xFFF5F7FA);
    final text = isDark ? Colors.white : const Color(0xFF1A1A2E);

    return Scaffold(
      backgroundColor: bg,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildHeader(context, isDark, text),
              const SizedBox(height: 32),
              _buildCurrentStatusCard(isDark, text, tier),
              const SizedBox(height: 40),
              _buildPlanOptions(context, isDark, text, tier),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context, bool isDark, Color text) {
    return Row(
      children: [
        GestureDetector(
          onTap: () => Navigator.pop(context),
          child: Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: isDark ? const Color(0xFF1A2332) : Colors.white,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: isDark ? const Color(0xFF2A3A4A) : Colors.grey.withOpacity(0.2)),
            ),
            child: Icon(Icons.arrow_back_ios_new_rounded, color: text, size: 18),
          ),
        ),
        const SizedBox(width: 16),
        Text(
          "Membership",
          style: GoogleFonts.inter(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: text,
          ),
        ),
        const Spacer(),
        SunMoonToggle(isDark: isDark, onToggle: toggleTheme),
      ],
    );
  }

  Widget _buildCurrentStatusCard(bool isDark, Color text, String tier) {
    String tierName = tier.toUpperCase();
    if (tier == 'free') tierName = 'FREE TRIAL';
    
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: isDark 
            ? [const Color(0xFF1E3A5F), const Color(0xFF15202B)]
            : [Colors.white, const Color(0xFFEDF2F7)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(28),
        border: Border.all(color: const Color(0xFF00C9A7).withOpacity(0.3), width: 2),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF00C9A7).withOpacity(0.1),
            blurRadius: 40,
            offset: const Offset(0, 20),
          )
        ],
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: const Color(0xFF00C9A7).withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.stars_rounded, color: Color(0xFF00C9A7), size: 48),
          ),
          const SizedBox(height: 20),
          Text(
            "Current Plan",
            style: GoogleFonts.inter(fontSize: 14, color: text.withOpacity(0.5), fontWeight: FontWeight.w500),
          ),
          const SizedBox(height: 8),
          Text(
            tierName,
            style: GoogleFonts.inter(fontSize: 32, fontWeight: FontWeight.w900, color: text, letterSpacing: 1),
          ),
          const SizedBox(height: 24),
          if (tier != 'premium')
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              decoration: BoxDecoration(
                color: const Color(0xFF00C9A7).withOpacity(0.1),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Text(
                tier == 'free' ? "Upgrade to unlock full content" : "Unlock more with Premium",
                style: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w600, color: const Color(0xFF00C9A7)),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildPlanOptions(BuildContext context, bool isDark, Color text, String currentTier) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "Available Plans",
          style: GoogleFonts.inter(fontSize: 18, fontWeight: FontWeight.bold, color: text),
        ),
        const SizedBox(height: 20),
        _buildPlanCard(
          context,
          isDark,
          "Basic Tier",
          "55 EUR / 2860 TRY",
          ["500 Practice Questions", "Video Tutorials", "Standard PDF Access", "Email Support"],
          const Color(0xFF4ECDC4),
          currentTier == 'basic' || currentTier == 'premium',
          'basic',
          currentTier,
        ),
        const SizedBox(height: 16),
        _buildPlanCard(
          context,
          isDark,
          "Premium Tier",
          currentTier == 'basic' ? "14 EUR / 720 TRY (Upgrade)" : "69 EUR / 3580 TRY",
          ["1000+ Practice Questions", "All Video Tutorials", "Deep-Dive PDF Library", "AI Study Assistant", "Priority Support"],
          const Color(0xFFFF6B6B),
          currentTier == 'premium',
          'premium',
          currentTier,
        ),
      ],
    );
  }

  Widget _buildPlanCard(
    BuildContext context, 
    bool isDark, 
    String title, 
    String price, 
    List<String> features, 
    Color color,
    bool isCurrent,
    String tierKey,
    String userTier,
  ) {
    final text = isDark ? Colors.white : const Color(0xFF1A1A2E);
    final isUpgrade = userTier == 'basic' && tierKey == 'premium';
    
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1A2332) : Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: (isCurrent && userTier == tierKey) ? color : (isDark ? Colors.white.withOpacity(0.05) : Colors.grey.withOpacity(0.1)),
          width: (isCurrent && userTier == tierKey) ? 2 : 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(title, style: GoogleFonts.inter(fontSize: 20, fontWeight: FontWeight.bold, color: text)),
              if (isCurrent && userTier == tierKey)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(color: color.withOpacity(0.1), borderRadius: BorderRadius.circular(12)),
                  child: Text("Active", style: GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.bold, color: color)),
                ),
              if (isCurrent && userTier == 'premium' && tierKey == 'basic')
                 Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(color: const Color(0xFF00C9A7).withOpacity(0.1), borderRadius: BorderRadius.circular(12)),
                  child: Text("Included", style: GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.bold, color: const Color(0xFF00C9A7))),
                ),
            ],
          ),
          const SizedBox(height: 8),
          Text(price, style: GoogleFonts.inter(fontSize: 16, fontWeight: FontWeight.w600, color: color)),
          const SizedBox(height: 20),
          ...features.map((f) => Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: Row(
              children: [
                Icon(Icons.check_circle_rounded, color: color.withOpacity(0.6), size: 18),
                const SizedBox(width: 12),
                Text(f, style: GoogleFonts.inter(fontSize: 14, color: text.withOpacity(0.7))),
              ],
            ),
          )),
          const SizedBox(height: 24),
          if (!isCurrent && tierKey != 'free')
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                   final authProvider = context.read<AuthProvider>();
                   Navigator.push(context, MaterialPageRoute(builder: (context) => TILIPurchasePage(
                     toggleTheme: toggleTheme,
                     token: authProvider.token ?? '',
                     userId: authProvider.userId ?? '',
                     userEmail: authProvider.email ?? '',
                     userName: authProvider.name ?? '',
                     packageTier: tierKey,
                      packageName: isUpgrade ? "TIL-I Premium Upgrade" : title,
                     priceEur: isUpgrade ? '14' : (tierKey == 'basic' ? '55' : '69'),
                     priceTry: isUpgrade ? '720' : (tierKey == 'basic' ? '2860' : '3580'),
                   )));
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: color,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  elevation: 0,
                ),
                child: Text(isUpgrade ? "Upgrade Now" : "Get Started", style: GoogleFonts.inter(fontSize: 16, fontWeight: FontWeight.bold)),
              ),
            ),
        ],
      ),
    );
  }
}
