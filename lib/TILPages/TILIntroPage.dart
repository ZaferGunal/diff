import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../UserProvider.dart';
import '../MyColors.dart';
import 'TILMembershipPage.dart';
import 'TILPurchasePage.dart';
import '../TILFreePages/TILFreeDashboard.dart';
import 'TILIDashboard.dart';

class TILIIntroPage extends StatefulWidget {
  final VoidCallback toggleTheme;
  final String token;

  const TILIIntroPage({
    super.key,
    required this.toggleTheme,
    required this.token,
  });

  @override
  State<TILIIntroPage> createState() => _TILIIntroPageState();
}

class _TILIIntroPageState extends State<TILIIntroPage> with TickerProviderStateMixin {
  int _hoveredFeatureIndex = -1;
  int _selectedPackageIndex = 1;
  late AnimationController _pulseController;
  late AnimationController _slideController;

  final List<Map<String, dynamic>> packages = [
    {
      'tier': 'free',
      'name': 'Free Trial',
      'price_eur': '0',
      'price_try': '0',
      'isFree': true,
      'features': [
        {'icon': Icons.quiz_outlined, 'text': 'Limited Practice Questions'},
        {'icon': Icons.video_library_outlined, 'text': 'Sample Tutorials'},
        {'icon': Icons.school_outlined, 'text': 'Formula Library Access'},
        {'icon': Icons.timer_outlined, 'text': '7 Days Trial'},
      ],
      'color': Color(0xFF95E1D3),
      'gradient': [Color(0xFF95E1D3), Color(0xFF38EF7D)],
    },
    {
      'tier': 'basic',
      'name': 'Basic',
      'price_eur': '55',
      'price_try': '2860',
      'features': [
        {'icon': Icons.quiz_outlined, 'text': '500 Practice Questions'},
        {'icon': Icons.video_library_outlined, 'text': 'Video Tutorials'},
        {'icon': Icons.trending_up_rounded, 'text': 'Detailed Progress Tracking'},
        {'icon': Icons.help_outline, 'text': 'Email Support'},
      ],
      'color': Color(0xFF4ECDC4),
      'gradient': [Color(0xFF4ECDC4), Color(0xFF44A08D)],
    },
    {
      'tier': 'premium',
      'name': 'Premium',
      'price_eur': '69',
      'price_try': '3580',
      'popular': true,
      'features': [
        {'icon': Icons.quiz_outlined, 'text': '1000+ Practice Questions'},
        {'icon': Icons.video_library_outlined, 'text': 'All Video Tutorials'},
        {'icon': Icons.trending_up, 'text': 'Advanced Performance Tracking'},
        {'icon': Icons.psychology_outlined, 'text': 'AI Study Assistant'},
        {'icon': Icons.school_outlined, 'text': 'Personalized Learning Path'},
        {'icon': Icons.support_agent, 'text': 'Priority Support'},
      ],
      'color': Color(0xFFFF6B6B),
      'gradient': [Color(0xFFFF6B6B), Color(0xFFFF8E53)],
    },
  ];

  final List<Map<String, dynamic>> features = [
    {
      'icon': Icons.lightbulb_outlined,
      'title': 'Interactive Learning',
      'description': 'Engage with dynamic content and real-time feedback',
      'color': Color(0xFFFF6B6B),
    },
    {
      'icon': Icons.school_outlined,
      'title': 'Comprehensive Curriculum',
      'description': 'Complete TIL-I exam preparation materials',
      'color': Color(0xFF4ECDC4),
    },
    {
      'icon': Icons.trending_up,
      'title': 'Progress Tracking',
      'description': 'Monitor your improvement with detailed reports',
      'color': Color(0xFFFFE66D),
    },
    {
      'icon': Icons.psychology_outlined,
      'title': 'Smart Practice',
      'description': 'AI-powered personalized learning paths',
      'color': Color(0xFF95E1D3),
    },
  ];

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    )..repeat(reverse: true);

    _slideController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    )..forward();
  }

  @override
  void dispose() {
    _pulseController.dispose();
    _slideController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final screenWidth = MediaQuery.of(context).size.width;
    final isSmallScreen = screenWidth < 900;

    return Scaffold(
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
        child: CustomScrollView(
          slivers: [
            // AppBar
            SliverAppBar(
              expandedHeight: 80,
              floating: false,
              pinned: true,
              backgroundColor: isDark ? const Color(0xFF0f172a) : Colors.white,
              elevation: 2,
              leading: IconButton(
                icon: Icon(
                  Icons.arrow_back,
                  color: isDark ? MyColors.orange : MyColors.bocco_blue,
                ),
                onPressed: () => Navigator.pop(context),
              ),
              flexibleSpace: FlexibleSpaceBar(
                title: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.lightbulb_rounded,
                      color: isDark ? MyColors.orange : MyColors.bocco_blue,
                      size: 24,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'TIL-I Study Packages',
                      style: TextStyle(
                        color: isDark ? MyColors.orange : MyColors.bocco_blue,
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
                centerTitle: true,
              ),
            ),

            // Hero Section
            SliverToBoxAdapter(
              child: SlideTransition(
                position: Tween<Offset>(
                  begin: const Offset(0, 0.3),
                  end: Offset.zero,
                ).animate(CurvedAnimation(
                  parent: _slideController,
                  curve: Curves.easeOutCubic,
                )),
                child: FadeTransition(
                  opacity: _slideController,
                  child: Container(
                    padding: EdgeInsets.all(isSmallScreen ? 24 : 80),
                    child: Column(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [
                                MyColors.orange.withOpacity(0.2),
                                MyColors.bocco_blue.withOpacity(0.2),
                              ],
                            ),
                            borderRadius: BorderRadius.circular(50),
                            border: Border.all(
                              color: isDark
                                  ? MyColors.orange.withOpacity(0.3)
                                  : MyColors.bocco_blue.withOpacity(0.3),
                              width: 2,
                            ),
                          ),
                          child: Text(
                            '💡 TIL-I EXAM PREPARATION',
                            style: TextStyle(
                              fontSize: isSmallScreen ? 14 : 16,
                              fontWeight: FontWeight.w700,
                              color: isDark ? MyColors.orange : MyColors.bocco_blue,
                              letterSpacing: 2,
                            ),
                          ),
                        ),
                        const SizedBox(height: 30),
                        Text(
                          'Master Your TIL-I\nEntrance Exam',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: isSmallScreen ? 36 : 52,
                            fontWeight: FontWeight.w800,
                            color: isDark ? Colors.white : Colors.black87,
                            height: 1.2,
                            shadows: isDark
                                ? [
                              Shadow(
                                color: MyColors.orange.withOpacity(0.3),
                                blurRadius: 20,
                              )
                            ]
                                : [],
                          ),
                        ),
                        const SizedBox(height: 20),
                        Text(
                          'Choose the perfect plan for your learning journey',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: isSmallScreen ? 16 : 18,
                            fontWeight: FontWeight.w400,
                            color: isDark ? Colors.white.withOpacity(0.7) : Colors.black54,
                            height: 1.6,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),

            // Pricing Cards
            SliverToBoxAdapter(
              child: Container(
                padding: EdgeInsets.symmetric(
                  horizontal: isSmallScreen ? 16 : 80,
                  vertical: 40,
                ),
                child: isSmallScreen
                    ? Column(
                  children: packages
                      .asMap()
                      .entries
                      .map((entry) => Padding(
                    padding: const EdgeInsets.only(bottom: 20),
                    child: _buildPricingCard(
                      entry.value,
                      entry.key,
                      isDark,
                      isSmallScreen,
                    ),
                  ))
                      .toList(),
                )
                    : Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: packages
                      .asMap()
                      .entries
                      .map((entry) => Flexible(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 15),
                      child: _buildPricingCard(
                        entry.value,
                        entry.key,
                        isDark,
                        isSmallScreen,
                      ),
                    ),
                  ))
                      .toList(),
                ),
              ),
            ),

            // Features Section
            SliverToBoxAdapter(
              child: Container(
                padding: EdgeInsets.all(isSmallScreen ? 24 : 80),
                child: Column(
                  children: [
                    Text(
                      'What\'s Included',
                      style: TextStyle(
                        fontSize: isSmallScreen ? 32 : 42,
                        fontWeight: FontWeight.w800,
                        color: isDark ? Colors.white : Colors.black87,
                      ),
                    ),
                    const SizedBox(height: 50),
                    Wrap(
                      spacing: 30,
                      runSpacing: 30,
                      alignment: WrapAlignment.center,
                      children: List.generate(
                        features.length,
                            (index) => _buildFeatureCard(
                          isDark: isDark,
                          isSmallScreen: isSmallScreen,
                          index: index,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            SliverToBoxAdapter(child: SizedBox(height: 80)),
          ],
        ),
      ),
    );
  }

  Widget _buildPricingCard(
      Map<String, dynamic> package,
      int index,
      bool isDark,
      bool isSmallScreen,
      ) {
    final isSelected = _selectedPackageIndex == index;
    final isPopular = package['popular'] == true;
    final isFree = package['isFree'] == true;

    return MouseRegion(
      onEnter: (_) => setState(() => _selectedPackageIndex = index),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        constraints: BoxConstraints(
          maxWidth: isSmallScreen ? double.infinity : 380,
        ),
        transform: Matrix4.identity()
          ..translate(0.0, isSelected ? -10.0 : 0.0, 0.0)
          ..scale(isSelected ? 1.05 : 1.0),
        child: Stack(
          clipBehavior: Clip.none,
          children: [
            Container(
              padding: EdgeInsets.all(isSmallScreen ? 24 : 40),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: isSelected
                      ? package['gradient']
                      : [
                    isDark ? const Color(0xFF1a1f2e) : Colors.white,
                    isDark ? const Color(0xFF1a1f2e) : Colors.white,
                  ],
                ),
                borderRadius: BorderRadius.circular(32),
                border: Border.all(
                  color: isSelected
                      ? package['color']
                      : (isDark ? Colors.white.withOpacity(0.1) : Colors.black.withOpacity(0.05)),
                  width: isSelected ? 3 : 2,
                ),
                boxShadow: [
                  BoxShadow(
                    color: isSelected
                        ? package['color'].withOpacity(0.4)
                        : (isDark ? Colors.black.withOpacity(0.3) : Colors.black.withOpacity(0.1)),
                    blurRadius: isSelected ? 40 : 20,
                    offset: Offset(0, isSelected ? 15 : 8),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        package['name'],
                        style: TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.w800,
                          color: isSelected ? Colors.white : (isDark ? Colors.white : Colors.black87),
                        ),
                      ),
                      if (isPopular)
                        AnimatedBuilder(
                          animation: _pulseController,
                          builder: (context, child) {
                            return Container(
                              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                              decoration: BoxDecoration(
                                color: Colors.white.withOpacity(0.2 + (_pulseController.value * 0.1)),
                                borderRadius: BorderRadius.circular(20),
                                border: Border.all(color: Colors.white, width: 1.5),
                              ),
                              child: Text(
                                'POPULAR',
                                style: TextStyle(
                                  fontSize: 10,
                                  fontWeight: FontWeight.w700,
                                  color: Colors.white,
                                  letterSpacing: 1.5,
                                ),
                              ),
                            );
                          },
                        ),
                      if (isFree)
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.2),
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(color: Colors.white, width: 1.5),
                          ),
                          child: Text(
                            'TRY NOW',
                            style: TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.w700,
                              color: Colors.white,
                              letterSpacing: 1.5,
                            ),
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 30),
                  if (isFree)
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'FREE',
                          style: TextStyle(
                            fontSize: 64,
                            fontWeight: FontWeight.w900,
                            color: isSelected ? Colors.white : package['color'],
                            height: 1,
                          ),
                        ),
                      ],
                    )
                  else
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '€',
                          style: TextStyle(
                            fontSize: 32,
                            fontWeight: FontWeight.w700,
                            color: isSelected ? Colors.white : package['color'],
                          ),
                        ),
                        Text(
                          package['price_eur'],
                          style: TextStyle(
                            fontSize: 64,
                            fontWeight: FontWeight.w900,
                            color: isSelected ? Colors.white : package['color'],
                            height: 1,
                          ),
                        ),
                      ],
                    ),
                  const SizedBox(height: 10),
                  Text(
                    isFree ? '7 Days Free Trial' : 'One-time payment • Lifetime access',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: isSelected
                          ? Colors.white.withOpacity(0.9)
                          : (isDark ? Colors.white.withOpacity(0.6) : Colors.black54),
                    ),
                  ),
                  if (!isFree) ...[
                    const SizedBox(height: 10),
                    Text(
                      '₺${package['price_try']} (Turkey)',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                        color: isSelected
                            ? Colors.white.withOpacity(0.8)
                            : (isDark ? Colors.white.withOpacity(0.5) : Colors.black45),
                      ),
                    ),
                  ],
                  const SizedBox(height: 40),
                  ...List.generate(
                    package['features'].length,
                        (i) => Padding(
                      padding: const EdgeInsets.only(bottom: 16),
                      child: Row(
                        children: [
                          Icon(
                            package['features'][i]['icon'],
                            size: 20,
                            color: isSelected ? Colors.white : package['color'],
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              package['features'][i]['text'],
                              style: TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.w500,
                                color: isSelected
                                    ? Colors.white
                                    : (isDark ? Colors.white.withOpacity(0.9) : Colors.black87),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 30),
                  SizedBox(
                    width: double.infinity,
                    height: 60,
                    child: ElevatedButton(
                      onPressed: () {
                        if (isFree) {
                          // Navigate to TILFreeDashboard for free trial
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => TILFreeDashboard(toggleTheme: widget.toggleTheme),
                            ),
                          );
                        } else {
                          // Navigate to purchase page for paid plans
                          final authProvider = context.read<AuthProvider>();
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => TILIPurchasePage(
                                toggleTheme: widget.toggleTheme,
                                token: widget.token,
                                userId: authProvider.userId ?? '',
                                userEmail: authProvider.email ?? '',
                                userName: authProvider.name ?? '',
                                packageTier: package['tier'],
                                packageName: package['name'],
                                priceEur: package['price_eur'],
                                priceTry: package['price_try'],
                              ),
                            ),
                          );
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: isSelected
                            ? Colors.white
                            : (isDark ? MyColors.orange : MyColors.bocco_blue),
                        foregroundColor: isSelected ? package['color'] : Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                        elevation: isSelected ? 8 : 0,
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(isFree ? Icons.play_arrow : Icons.shopping_cart_outlined, size: 24),
                          const SizedBox(width: 12),
                          Text(
                            isFree ? 'Start Free Trial' : 'Get Started',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w700,
                              letterSpacing: 1,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFeatureCard({
    required bool isDark,
    required bool isSmallScreen,
    required int index,
  }) {
    final feature = features[index];
    final isHovered = _hoveredFeatureIndex == index;

    return MouseRegion(
      onEnter: (_) => setState(() => _hoveredFeatureIndex = index),
      onExit: (_) => setState(() => _hoveredFeatureIndex = -1),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        transform: Matrix4.identity()..translate(0.0, isHovered ? -8.0 : 0.0, 0.0),
        width: isSmallScreen ? double.infinity : 280,
        padding: EdgeInsets.all(isSmallScreen ? 24 : 32),
        decoration: BoxDecoration(
          color: isDark ? const Color(0xFF1a1f2e) : Colors.white,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(
            color: isHovered
                ? feature['color'].withOpacity(0.5)
                : (isDark ? Colors.white.withOpacity(0.1) : Colors.black.withOpacity(0.05)),
            width: 2,
          ),
          boxShadow: [
            BoxShadow(
              color: isHovered
                  ? feature['color'].withOpacity(0.3)
                  : (isDark ? Colors.black.withOpacity(0.3) : Colors.black.withOpacity(0.1)),
              blurRadius: isHovered ? 30 : 20,
              offset: Offset(0, isHovered ? 12 : 8),
            ),
          ],
        ),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    feature['color'].withOpacity(0.3),
                    feature['color'].withOpacity(0.1),
                  ],
                ),
                shape: BoxShape.circle,
              ),
              child: Icon(
                feature['icon'],
                size: 48,
                color: feature['color'],
              ),
            ),
            const SizedBox(height: 24),
            Text(
              feature['title'],
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w700,
                color: isDark ? Colors.white : Colors.black87,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              feature['description'],
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w400,
                color: isDark ? Colors.white.withOpacity(0.6) : Colors.black54,
                height: 1.5,
              ),
            ),
          ],
        ),
      ),
    );
  }
}