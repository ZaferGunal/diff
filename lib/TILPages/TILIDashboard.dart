import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:fl_chart/fl_chart.dart';
import 'dart:ui';
import '../MyColors.dart';
import '../UserProvider.dart';
import '../services/AuthService.dart';
import 'TILPurchasePage.dart';
import 'TILPastResultsPage.dart';
import 'TILMockExamsPage.dart';
import 'TILSubjectTestsPage.dart';
import 'TILLearnPage.dart';
import 'TILCardsPage.dart';
import 'package:google_fonts/google_fonts.dart';
import 'TILMembershipPage.dart';
import '../widgets/tili_sidebar.dart';
import '../widgets/theme_toggle.dart';


class BentoColors {
  // Light Mode
  static const lightBg = Color(0xFFF2F1F6);
  static const lightSurface = Color(0xFFFFFFFF);
  static const lightTextPrimary = Color(0xFF333333);
  static const lightTextSecondary = Color(0xFF888888);
  static const lightAccent = Color(0xFF6C63FF);

  // Dark Mode
  static const darkBg = Color(0xFF18181B);
  static const darkSurface = Color(0xFF27272A);
  static const darkTextPrimary = Color(0xFFFAFAFA);
  static const darkTextSecondary = Color(0xFFA1A1AA);
  static const darkAccent = Color(0xFF818CF8);

  // Teal Dashboard Theme
  static const tealAccent = Color(0xFF00BFA5);
  static const tealLight = Color(0xFF1DE9B6);
  static const darkCard = Color(0xFF1E1E2E);
  static const darkDeep = Color(0xFF151522);
}

class TILIDashboard extends StatefulWidget {
  final VoidCallback toggleTheme;
  final String token;

  const TILIDashboard({
    super.key,
    required this.toggleTheme,
    required this.token,
  });

  @override
  State<TILIDashboard> createState() => _TILIDashboardState();
}

class _TILIDashboardState extends State<TILIDashboard> with TickerProviderStateMixin {
  int _selectedIndex = 0;
  int? _hoveredIndex;
  bool _isSidebarHovered = false;
  bool _isBadgeHovered = false;
  
  // Weekly activity data
  List<FlSpot> _weeklySpots = [];
  List<String> _weeklyDays = [];
  String _totalFormatted = "0m";
  double _percentageChange = 0;
  bool _isLoadingActivity = true;
  
  // Cleaner, more distinct icons
  final List<Map<String, dynamic>> _navItems = [
    {'icon': Icons.timer_outlined, 'label': 'Practice Exams'},
    {'icon': Icons.description_outlined, 'label': 'Subject Tests'},
    {'icon': Icons.play_lesson_outlined, 'label': 'Learn'},
    {'icon': Icons.style_outlined, 'label': 'Cards'},
    {'icon': Icons.history_rounded, 'label': 'Past Results'},
  ];

  void _handleNavigation(int index) {
    if (index >= _navItems.length) return;
    
    final label = _navItems[index]['label'];
    Widget? page;

    switch (label) {
      case 'Practice Exams':
        page = TILMockExamsPage(toggleTheme: widget.toggleTheme);
        break;
      case 'Subject Tests':
        page = TILSubjectTestsPage(toggleTheme: widget.toggleTheme);
        break;
      case 'Learn':
        page = TILLearnPage(toggleTheme: widget.toggleTheme);
        break;
      case 'Cards':
        page = TILCardsPage(toggleTheme: widget.toggleTheme);
        break;
      case 'Past Results':
        page = TILPastResultsPage(toggleTheme: widget.toggleTheme);
        break;
    }

    if (page != null) {
      Navigator.push(context, MaterialPageRoute(builder: (context) => page!));
    } else {
      setState(() => _selectedIndex = index);
    }
  }

  @override
  void initState() {
    super.initState();
    _fetchWeeklyActivity();
  }

  Future<void> _fetchWeeklyActivity() async {
    try {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      final token = authProvider.token;
      
      if (token == null || token.isEmpty) {
        setState(() => _isLoadingActivity = false);
        return;
      }

      final response = await AuthService().getWeeklyActivity(token);
      
      if (response != null && response.data['success'] == true) {
        final data = response.data['data'];
        final List<dynamic> dailyActivity = data['dailyActivity'] ?? [];
        
        setState(() {
          _totalFormatted = data['formattedTotal'] ?? '0m';
          _percentageChange = (data['percentageChange'] ?? 0).toDouble();
          
          // Convert daily activity to chart spots
          _weeklySpots = [];
          _weeklyDays = [];
          
          for (int i = 0; i < dailyActivity.length; i++) {
            final day = dailyActivity[i];
            final minutes = (day['minutes'] ?? 0).toDouble();
            // Convert minutes to hours for better chart display
            final hours = minutes / 60.0;
            _weeklySpots.add(FlSpot(i.toDouble(), hours));
            _weeklyDays.add(day['day'] ?? '');
          }
          
          // If no data, fill with zeros
          if (_weeklySpots.isEmpty) {
            _weeklySpots = List.generate(7, (i) => FlSpot(i.toDouble(), 0));
            _weeklyDays = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
          }
          
          _isLoadingActivity = false;
        });
      } else {
        setState(() => _isLoadingActivity = false);
      }
    } catch (e) {
      print('❌ Error fetching weekly activity: $e');
      setState(() => _isLoadingActivity = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final authProvider = context.watch<AuthProvider>();
    final width = MediaQuery.of(context).size.width;
    final isDesktop = width > 1000;

    final bg = isDark ? BentoColors.darkBg : BentoColors.lightBg;
    final text = isDark ? BentoColors.darkTextPrimary : BentoColors.lightTextPrimary;

    // Safety check for index out of range
    if (_selectedIndex >= _navItems.length) {
      _selectedIndex = 0;
    }

    return Scaffold(
      backgroundColor: bg,
      body: Stack(
        children: [
          // Ambient Background
          Positioned(
            top: -150, right: -100,
            child: _buildBlurCircle(isDark, Colors.deepPurple.withOpacity(isDark ? 0.2 : 0.08), 500),
          ),
          Positioned(
            bottom: -100, left: -50,
            child: _buildBlurCircle(isDark, Colors.tealAccent.withOpacity(isDark ? 0.15 : 0.06), 600),
          ),
          Positioned(
            top: 200, left: -150,
            child: _buildBlurCircle(isDark, Colors.blueAccent.withOpacity(isDark ? 0.12 : 0.05), 400),
          ),

          Row(
            children: [
              // Expandable Sidebar
              if (isDesktop) 
                MouseRegion(
                  onEnter: (_) => setState(() => _isSidebarHovered = true),
                  onExit: (_) => setState(() => _isSidebarHovered = false),
                  child: _buildExpandableSidebar(isDark),
                ),

              // Main Content
              Expanded(
                child: Padding(
                  padding: EdgeInsets.all(isDesktop ? 32 : 16),
                  child: Column(
                    children: [
                      _buildHeader(isDark, authProvider, text, context),
                      const SizedBox(height: 32),
                      Expanded(
                        child: SingleChildScrollView(
                          padding: const EdgeInsets.only(bottom: 32),
                          child: _buildNewLayout(isDark, isDesktop),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
      bottomNavigationBar: isDesktop ? null : _buildMobileNav(isDark),
      floatingActionButton: isDesktop ? null : _buildThemeFab(isDark),
    );
  }

  Widget _buildBlurCircle(bool isDark, Color color, double size) {
    return Container(
      width: size, height: size,
      decoration: BoxDecoration(color: color, shape: BoxShape.circle),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 120, sigmaY: 120),
        child: Container(color: Colors.transparent),
      ),
    );
  }

  Widget _buildExpandableSidebar(bool isDark) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 250),
      curve: Curves.easeInOut,
      width: _isSidebarHovered ? 200 : 80,
      margin: const EdgeInsets.symmetric(vertical: 24, horizontal: 24),
      decoration: BoxDecoration(
        color: (isDark ? BentoColors.darkSurface : BentoColors.lightSurface).withOpacity(0.9),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: Colors.white.withOpacity(isDark ? 0.05 : 0.4)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 20,
            offset: const Offset(4, 0),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(24),
        child: Column(
          children: [
            const SizedBox(height: 32),
            // Brand Icon
            SizedBox(
              width: 56,
              height: 56,
              child: Image.asset(
                'assets/soleLogo.png',
                fit: BoxFit.contain,
              ),
            ),
            if (_isSidebarHovered) ...[
              const SizedBox(height: 12),
              Text(
                "PractiCo",
                style: GoogleFonts.jost(
                  color: isDark ? BentoColors.darkTextPrimary : BentoColors.lightTextPrimary,
                  fontSize: 22,
                  fontWeight: FontWeight.w900,
                  letterSpacing: -0.5,
                ),
              )
            ],
            const Spacer(),
            ...List.generate(_navItems.length, (index) => _buildSidebarItemExpanded(isDark, index)),
            const Spacer(),
            
            // Back Button
            InkWell(
              onTap: () => Navigator.of(context).pop(),
              child: Container(
                margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
                decoration: BoxDecoration(
                   borderRadius: BorderRadius.circular(12),
                   color: Colors.white.withOpacity(0.05),
                ),
                child: Row(
                   mainAxisAlignment: _isSidebarHovered ? MainAxisAlignment.start : MainAxisAlignment.center,
                   children: [
                     Icon(Icons.arrow_back_ios_new_rounded, color: isDark ? BentoColors.darkTextSecondary : BentoColors.lightTextSecondary, size: 20),
                     if (_isSidebarHovered) ...[
                       const SizedBox(width: 12),
                       Text("Go Back", style: TextStyle(color: isDark ? BentoColors.darkTextSecondary : BentoColors.lightTextSecondary)),
                     ]
                   ],
                ),
              ),
            ),

            // Logout/Home Button
            InkWell(
              onTap: () async {
                 await Provider.of<AuthProvider>(context, listen: false).logout();
                 if (context.mounted) {
                   Navigator.of(context).pushNamedAndRemoveUntil('/', (route) => false);
                 }
              },
              child: Container(
                margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
                decoration: BoxDecoration(
                   borderRadius: BorderRadius.circular(12),
                   color: Colors.redAccent.withOpacity(0.1),
                ),
                child: Row(
                   mainAxisAlignment: _isSidebarHovered ? MainAxisAlignment.start : MainAxisAlignment.center,
                   children: [
                     const Icon(Icons.logout_rounded, color: Colors.redAccent, size: 20),
                     if (_isSidebarHovered) ...[
                       const SizedBox(width: 12),
                       const Text("Logout", style: TextStyle(color: Colors.redAccent, fontWeight: FontWeight.bold)),
                     ]
                   ],
                ),
              ),
            ),

            const SizedBox(height: 16),
             Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8),
                child: SunMoonToggle(
                  isDark: isDark,
                  onToggle: widget.toggleTheme,
                ),
              ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  Widget _buildSidebarItemExpanded(bool isDark, int index) {
    final isSelected = _selectedIndex == index;
    final color = isSelected 
        ? (isDark ? BentoColors.darkAccent : BentoColors.lightAccent)
        : (isDark ? BentoColors.darkTextSecondary : BentoColors.lightTextSecondary);

    return InkWell(
      onTap: () => _handleNavigation(index),
      child: Container(
        height: 50,
        margin: const EdgeInsets.symmetric(vertical: 4, horizontal: 12),
        padding: const EdgeInsets.symmetric(horizontal: 12),
        decoration: BoxDecoration(
          color: isSelected ? color.withOpacity(0.1) : Colors.transparent,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          mainAxisAlignment: _isSidebarHovered ? MainAxisAlignment.start : MainAxisAlignment.center,
          children: [
            Icon(_navItems[index]['icon'], color: color, size: 24),
            if (_isSidebarHovered) ...[
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  _navItems[index]['label'],
                  style: TextStyle(
                    color: color,
                    fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ]
          ],
        ),
      ),
    );
  }



  Widget _buildHeader(bool isDark, AuthProvider authProvider, Color textColor, BuildContext context) {
    final isMobile = MediaQuery.of(context).size.width < 768;
    
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Expanded(
          child: Row(
            children: [
              // Mobile Exit Button (if sidebar hidden)
              if (MediaQuery.of(context).size.width <= 1000)
                Padding(
                  padding: const EdgeInsets.only(right: 16),
                  child: IconButton(
                    icon: const Icon(Icons.arrow_back_ios_new_rounded),
                    onPressed: () => Navigator.maybePop(context),
                    color: textColor,
                  ),
                ),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Hello, ${authProvider.name?.split(' ')[0] ?? 'Student'}",
                      style: TextStyle(
                        fontSize: isMobile ? 24 : 28,
                        fontWeight: FontWeight.w800,
                        color: textColor,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      "Welcome to PractiCo.",
                      style: TextStyle(
                        fontSize: isMobile ? 14 : 16,
                        color: isDark ? BentoColors.darkTextSecondary : BentoColors.lightTextSecondary,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        const SizedBox(width: 12),
        // Membership Badge with hover effect
        MouseRegion(
          onEnter: (_) => setState(() => _isBadgeHovered = true),
          onExit: (_) => setState(() => _isBadgeHovered = false),
          cursor: SystemMouseCursors.click,
          child: GestureDetector(
            onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => TILMembershipPage(toggleTheme: widget.toggleTheme))),
            child: AnimatedScale(
              scale: _isBadgeHovered ? 1.05 : 1.0,
              duration: const Duration(milliseconds: 200),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: authProvider.hasTiliPackage 
                      ? [const Color(0xFF00C9A7), const Color(0xFF00D9B5)]
                      : [const Color(0xFF6C63FF), const Color(0xFF818CF8)],
                  ),
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: (authProvider.hasTiliPackage ? const Color(0xFF00C9A7) : const Color(0xFF6C63FF)).withOpacity(0.3),
                      blurRadius: _isBadgeHovered ? 15 : 10,
                      offset: Offset(0, _isBadgeHovered ? 6 : 4),
                    )
                  ],
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      authProvider.hasTiliPackage ? Icons.workspace_premium_rounded : Icons.star_outline_rounded,
                      color: Colors.white,
                      size: 16,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      authProvider.tiliPackageTier?.toUpperCase() ?? "FREE",
                      style: GoogleFonts.inter(
                        fontSize: 12,
                        fontWeight: FontWeight.w800,
                        color: Colors.white,
                        letterSpacing: 0.5,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildNewLayout(bool isDark, bool isDesktop) {
    return Column(
      children: [
        // 1. TOP SECTION: Actions & Flashcards
        if (isDesktop)
          SizedBox(
            height: 160,
            child: Row(
              children: [
                Expanded(child: _buildActionBento(isDark, "Practice Exams", Icons.timer_outlined, Colors.green, 0)),
                const SizedBox(width: 24),
                Expanded(child: _buildActionBento(isDark, "Subject Tests", Icons.description_outlined, Colors.orange, 1)),
                const SizedBox(width: 24),
                Expanded(child: _buildActionBento(isDark, "Learn", Icons.play_lesson_outlined, Colors.blue, 2)),
                const SizedBox(width: 24),
                Expanded(child: _buildActionBento(isDark, "Cards", Icons.style_outlined, Colors.purple, 3)),
              ],
            ),
          )
        else ...[
          // Mobile Grid for Actions
          GridView.count(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            crossAxisCount: 2,
            crossAxisSpacing: 16,
            mainAxisSpacing: 16,
            childAspectRatio: MediaQuery.of(context).size.width < 380 ? 1.1 : 1.3,
            children: [
              _buildActionBento(isDark, "Practice Exams", Icons.timer_outlined, Colors.green, 0),
              _buildActionBento(isDark, "Subject Tests", Icons.description_outlined, Colors.orange, 1),
              _buildActionBento(isDark, "Learn", Icons.play_lesson_outlined, Colors.blue, 2),
              _buildActionBento(isDark, "Cards", Icons.style_outlined, Colors.purple, 3),
            ],
          ),
        ],

        const SizedBox(height: 32),

        // 3. BOTTOM SECTION: Weekly Chart (Big)
        _buildWeeklyChartSection(isDark),

        const SizedBox(height: 32),

        // 4. NEW SECTION: Past Results
        _buildPastResultsSection(isDark),
      ],
    );
  }

  Widget _buildActionBento(bool isDark, String title, IconData icon, Color color, int index) {
    final isMobile = MediaQuery.of(context).size.width < 768;
    return _buildHoverContainer(
      padding: EdgeInsets.all(isMobile ? 16 : 24),
      isDark: isDark,
      index: index,
      child: InkWell(
        onTap: () {
          Widget? page;
          switch (title) {
            case "Practice Exams":
              page = TILMockExamsPage(toggleTheme: widget.toggleTheme);
              break;
            case "Subject Tests":
              page = TILSubjectTestsPage(toggleTheme: widget.toggleTheme);
              break;
            case "Learn":
              page = TILLearnPage(toggleTheme: widget.toggleTheme);
              break;
            case "Cards":
              page = TILCardsPage(toggleTheme: widget.toggleTheme);
              break;
          }
          if (page != null) {
            Navigator.push(context, MaterialPageRoute(builder: (context) => page!));
          }
        },
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Container(
              padding: EdgeInsets.all(isMobile ? 8 : 12),
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Icon(icon, color: color, size: isMobile ? 24 : 28),
            ),
            Text(
              title,
              style: TextStyle(
                fontSize: isMobile ? 14 : 16,
                fontWeight: FontWeight.bold,
                color: isDark ? BentoColors.darkTextPrimary : BentoColors.lightTextPrimary,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }



  Widget _buildWeeklyChartSection(bool isDark) {
    final isMobile = MediaQuery.of(context).size.width < 768;
    // Show loading state
    if (_isLoadingActivity) {
      return _buildHoverContainer(
        isDark: isDark,
        index: 100,
        height: 300,
        child: const Center(
          child: CircularProgressIndicator(),
        ),
      );
    }
    
    // Determine if change is positive or negative
    final bool isPositive = _percentageChange >= 0;
    final Color changeColor = isPositive ? Colors.green : Colors.red;
    final String changeText = isPositive 
        ? "+${_percentageChange.toStringAsFixed(1)}%" 
        : "${_percentageChange.toStringAsFixed(1)}%";
    
    // Calculate max Y for chart based on data
    double maxY = 1;
    for (var spot in _weeklySpots) {
      if (spot.y > maxY) maxY = spot.y;
    }
    maxY = (maxY * 1.2).ceilToDouble(); // Add 20% padding
    if (maxY < 1) maxY = 1;
    
    return _buildHoverContainer(
      isDark: isDark,
      index: 100,
      height: 300,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Weekly Activity (Last 7 Days)", 
                      style: TextStyle(
                        fontSize: isMobile ? 18 : 20, 
                        fontWeight: FontWeight.bold, 
                        color: isDark ? Colors.white : Colors.black
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                    Text(
                      "Total $_totalFormatted this week", 
                      style: TextStyle(
                        color: isDark ? Colors.white54 : Colors.black45,
                        fontSize: isMobile ? 12 : 14,
                      )
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              if (_percentageChange != 0)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(color: changeColor.withOpacity(0.1), borderRadius: BorderRadius.circular(20)),
                  child: Text(changeText, style: TextStyle(color: changeColor, fontWeight: FontWeight.bold, fontSize: 12)),
                ),
            ],
          ),
          const SizedBox(height: 24),
          Expanded(
            child: _weeklySpots.isEmpty
                ? Center(
                    child: Text(
                      "No activity data yet.\nStart studying to see your progress!",
                      textAlign: TextAlign.center,
                      style: TextStyle(color: isDark ? Colors.white54 : Colors.black45),
                    ),
                  )
                : LineChart(
              LineChartData(
                minX: 0, maxX: 6, // Force strictly 7 days (0 to 6)
                minY: 0, maxY: maxY,
                gridData: FlGridData(
                  show: true, 
                  drawVerticalLine: false,
                  getDrawingHorizontalLine: (value) => FlLine(color: isDark ? Colors.white10 : Colors.black12, strokeWidth: 1),
                ),
                titlesData: FlTitlesData(
                  leftTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: 40,
                      getTitlesWidget: (value, meta) {
                        if (value == 0) return const SizedBox();
                        return Padding(
                          padding: const EdgeInsets.only(right: 8),
                          child: Text(
                            "${value.toInt()}h",
                            style: TextStyle(fontSize: 10, color: isDark ? Colors.white38 : Colors.black38),
                          ),
                        );
                      },
                    ),
                  ),
                  rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      interval: 1, // Ensure every integer step is shown
                      getTitlesWidget: (value, meta) {
                        final idx = value.toInt();
                        if (idx >= 0 && idx < _weeklyDays.length) {
                           return Padding(
                             padding: const EdgeInsets.only(top: 10),
                             child: Text(_weeklyDays[idx], style: TextStyle(fontSize: 12, color: isDark ? Colors.white38 : Colors.black38)),
                           );
                         }
                         return const SizedBox();
                      },
                    ),
                  ),
                ),
                borderData: FlBorderData(show: false),
                lineBarsData: [
                  LineChartBarData(
                    spots: _weeklySpots.isNotEmpty 
                        ? _weeklySpots 
                        : List.generate(7, (i) => FlSpot(i.toDouble(), 0)),
                    isCurved: true,
                    curveSmoothness: 0.35, // Reduce "wobble" that might look like extra days
                    color: isDark ? BentoColors.darkAccent : BentoColors.lightAccent,
                    barWidth: 5,
                    isStrokeCapRound: true,
                    dotData: FlDotData(show: true), // Show dots to emphasize 7 distinct points
                    belowBarData: BarAreaData(show: true, color: (isDark ? BentoColors.darkAccent : BentoColors.lightAccent).withOpacity(0.2)),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPastResultsSection(bool isDark) {
    final isMobile = MediaQuery.of(context).size.width < 768;

    return _buildHoverContainer(
      isDark: isDark,
      index: 101,
      padding: EdgeInsets.all(isMobile ? 16 : 24),
      child: InkWell(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => TILPastResultsPage(toggleTheme: widget.toggleTheme)),
          );
        },
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "View Past Results",
                    style: TextStyle(
                      fontSize: isMobile ? 18 : 20,
                      fontWeight: FontWeight.bold,
                      color: isDark ? Colors.white : Colors.black,
                    ),
                  ),
                  SizedBox(height: 4),
                  Text(
                    "Access your complete exam history",
                    style: TextStyle(
                      fontSize: isMobile ? 13 : 14,
                      color: isDark ? Colors.white54 : Colors.black54,
                    ),
                  ),
                ],
              ),
            ),
            Container(
              padding: EdgeInsets.all(isMobile ? 8 : 12),
              decoration: BoxDecoration(
                color: (isDark ? Colors.white : Colors.black).withOpacity(0.05),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.arrow_forward_rounded,
                color: isDark ? Colors.white : Colors.black,
                size: isMobile ? 20 : 24,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildResultItem(bool isDark, String title, String date, String score, Color color) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Row(
        children: [
          Container(
            width: 8, height: 8,
            decoration: BoxDecoration(color: color, shape: BoxShape.circle),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: TextStyle(fontWeight: FontWeight.w600, color: isDark ? Colors.white : Colors.black87)),
                Text(date, style: TextStyle(fontSize: 12, color: isDark ? Colors.white38 : Colors.black38)),
              ],
            ),
          ),
          Container(
             padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
             decoration: BoxDecoration(
               color: color.withOpacity(0.1),
               borderRadius: BorderRadius.circular(12),
               border: Border.all(color: color.withOpacity(0.3)),
             ),
             child: Text(score, style: TextStyle(fontWeight: FontWeight.bold, color: color)),
          ),
        ],
      ),
    );
  }

  Widget _buildHoverContainer({
    required bool isDark,
    required int index,
    required Widget child,
    double? height,
    double? width,
    EdgeInsets? padding,
  }) {
    final bg = isDark ? BentoColors.darkSurface : BentoColors.lightSurface;
    return MouseRegion(
      onEnter: (_) => setState(() => _hoveredIndex = index),
      onExit: (_) => setState(() => _hoveredIndex = null),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        height: height,
        width: width,
        transform: Matrix4.identity()..translate(0, _hoveredIndex == index ? -5 : 0),
        padding: padding ?? const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: bg,
          borderRadius: BorderRadius.circular(32),
          border: Border.all(color: Colors.white.withOpacity(isDark ? 0.05 : 0.6), width: 1.5),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(_hoveredIndex == index ? 0.08 : 0.03),
              blurRadius: _hoveredIndex == index ? 24 : 12,
              offset: Offset(0, _hoveredIndex == index ? 8 : 4),
            ),
          ],
        ),
        child: child,
      ),
    );
  }

  Widget _buildMobileNav(bool isDark) {
    return BottomNavigationBar(
      backgroundColor: isDark ? BentoColors.darkSurface : BentoColors.lightSurface,
      selectedItemColor: isDark ? BentoColors.darkAccent : BentoColors.lightAccent,
      unselectedItemColor: isDark ? Colors.white38 : Colors.black38,
      type: BottomNavigationBarType.fixed,
      showSelectedLabels: false,
      showUnselectedLabels: false,
      currentIndex: _selectedIndex > 4 ? 0 : _selectedIndex, 
      onTap: _handleNavigation,
      items: _navItems.take(5).map((e) => BottomNavigationBarItem(icon: Icon(e['icon']), label: e['label'])).toList(),
    );
  }

  Widget _buildThemeFab(bool isDark) {
    return SunMoonToggle(
      isDark: isDark,
      onToggle: widget.toggleTheme,
    );
  }
}
