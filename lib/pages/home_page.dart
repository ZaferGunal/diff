import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:untitled5/pages/practicePastResultsPage.dart';

import '../UserProvider.dart';
import '../MyColors.dart';
import '../publicPages/learningHall.dart';
import 'welcome_page.dart' hide TestsPage;
import 'practices_page.dart';
import 'tests_page.dart';


class HomePage extends StatefulWidget {
  final VoidCallback toggleTheme;
  final String token;

  const HomePage({
    super.key,
    required this.toggleTheme,
    required this.token,
  });

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> with SingleTickerProviderStateMixin {
  bool _hasCheckedSession = false;
  late AnimationController _drawerController;
  late Animation<double> _drawerAnimation;
  bool _isDrawerOpen = false;
  int? _hoveredIndex;

  @override
  void initState() {
    super.initState();

    _drawerController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    );

    _drawerAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _drawerController, curve: Curves.easeInOutCubic),
    );

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!_hasCheckedSession) {
        _hasCheckedSession = true;
        _checkSessionStatus();
      }
    });
  }

  @override
  void dispose() {
    _drawerController.dispose();
    super.dispose();
  }

  void _toggleDrawer() {
    setState(() {
      _isDrawerOpen = !_isDrawerOpen;
    });
    if (_isDrawerOpen) {
      _drawerController.forward();
    } else {
      _drawerController.reverse();
    }
  }

  void _checkSessionStatus() {
    final authProvider = context.read<AuthProvider>();

    print("🔍 [HomePage] Checking session...");
    print("🔍 [HomePage] isAuthenticated: ${authProvider.isAuthenticated}");
    print("🔍 [HomePage] token: ${authProvider.token}");

    if (authProvider.token == null) {
      print("❌ [HomePage] No token - redirecting to Welcome");
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(
          builder: (context) => WelcomePage(toggleTheme: widget.toggleTheme),
        ),
            (route) => false,
      );
    } else {
      print("✅ [HomePage] Session OK");
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final drawerWidth = 280.0;
    final collapsedWidth = 70.0;

    return Consumer<AuthProvider>(
      builder: (context, authProvider, child) {
        if (_hasCheckedSession && authProvider.token == null) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            print("❌ [HomePage] Session expired - logging out");
            Navigator.pushAndRemoveUntil(
              context,
              MaterialPageRoute(
                builder: (context) => WelcomePage(toggleTheme: widget.toggleTheme),
              ),
                  (route) => false,
            );
          });
        }

        return WillPopScope(
          onWillPop: () async {
            if (_isDrawerOpen) {
              _toggleDrawer();
              return false;
            }
            await authProvider.logout();
            Navigator.pushAndRemoveUntil(
              context,
              MaterialPageRoute(
                builder: (context) => WelcomePage(toggleTheme: widget.toggleTheme),
              ),
                  (route) => false,
            );
            return false;
          },
          child: Scaffold(
            body: Stack(
              children: [
                // Main Content
                AnimatedBuilder(
                  animation: _drawerAnimation,
                  builder: (context, child) {
                    return Container(
                      margin: EdgeInsets.only(
                        left: collapsedWidth + (_drawerAnimation.value * (drawerWidth - collapsedWidth)),
                      ),
                      child: Column(
                        children: [
                          // AppBar
                          Container(
                            height: 70,
                            decoration: BoxDecoration(
                              color: isDark ? const Color(0xFF0f172a) : Colors.white,
                              boxShadow: [
                                BoxShadow(
                                  color: isDark
                                      ? Colors.black.withOpacity(0.3)
                                      : Colors.black.withOpacity(0.05),
                                  blurRadius: 10,
                                  offset: const Offset(0, 2),
                                ),
                              ],
                            ),
                            child: Row(
                              children: [
                                const SizedBox(width: 40),
                                Image.asset(
                                  'assets/soleLogo.png',
                                  width: 22,
                                  height: 22,
                                ),
                                const SizedBox(width: 12),
                                Text(
                                  'PractiCo',
                                  style: TextStyle(
                                    fontSize: 22,
                                    letterSpacing: 2,
                                    fontWeight: FontWeight.w700,
                                    color: isDark ? MyColors.cyan : MyColors.green,
                                  ),
                                ),
                                Spacer(),
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
                                const SizedBox(width: 8),
                              ],
                            ),
                          ),
                          // Body
                          Expanded(
                            child: Container(
                              color: isDark ? const Color(0xFF0a0e27) : const Color(0xFFf5f7fa),
                              child: Center(
                                child: Container(
                                  constraints: const BoxConstraints(maxWidth: 1400),
                                  padding: const EdgeInsets.all(60),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        'Welcome Back${authProvider.name != null ? ', ${authProvider.name}' : ''}!',
                                        style: TextStyle(
                                          fontSize: 35,
                                          fontWeight: FontWeight.w500,
                                          letterSpacing: 2,
                                          color: isDark ? Colors.white : Colors.black87,
                                        ),
                                      ),
                                      const SizedBox(height: 40),
                                      Expanded(
                                        child: SingleChildScrollView(
                                          child: Wrap(
                                            spacing: 24,
                                            runSpacing: 24,
                                            children: [
                                              _buildCard('📝 Practices', () {
                                                Navigator.push(
                                                  context,
                                                  MaterialPageRoute(
                                                    builder: (context) => PracticesPage(toggleTheme: widget.toggleTheme),
                                                  ),
                                                );
                                              }, isDark, context),
                                              _buildCard('🎯 Subject Tests', () {
                                                Navigator.push(
                                                  context,
                                                  MaterialPageRoute(
                                                    builder: (context) => TestsPage(toggleTheme: widget.toggleTheme),
                                                  ),
                                                );
                                              }, isDark, context),
                                              _buildCard("📊 Past Results", () {
                                                Navigator.push(
                                                  context,
                                                  MaterialPageRoute(
                                                    builder: (context) => PastPracticeResults(),
                                                  ),
                                                );
                                              }, isDark, context),
                                              // ✅ YENİ KART
                                              _buildCard('💡 Tips & Methods', () {
                                                Navigator.push(
                                                  context,
                                                  MaterialPageRoute(
                                                    builder: (context) => LearningHall(toggleTheme: widget.toggleTheme),
                                                  ),
                                                );
                                              }, isDark, context),
                                            ],
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),

                // Custom Drawer - Tıklanabilir
                AnimatedBuilder(
                  animation: _drawerAnimation,
                  builder: (context, child) {
                    final currentWidth = collapsedWidth + (_drawerAnimation.value * (drawerWidth - collapsedWidth));

                    return GestureDetector(
                      onTap: _toggleDrawer,
                      behavior: HitTestBehavior.translucent,
                      child: Container(
                        width: currentWidth,
                        decoration: BoxDecoration(
                          color: isDark ? const Color(0xFF1a1f37) : const Color(0xFFfafbfc),
                          border: Border(
                            right: BorderSide(
                              color: isDark ? Colors.white.withOpacity(0.05) : Colors.black.withOpacity(0.05),
                              width: 1,
                            ),
                          ),
                        ),
                        child: Column(
                          children: [
                            // Header - User Profile
                            Container(
                              padding: EdgeInsets.only(
                                top: MediaQuery.of(context).padding.top + 60,
                                bottom: 30,
                                left: 20,
                                right: 20,
                              ),
                              child: _drawerAnimation.value > 0.5
                                  ? Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  CircleAvatar(
                                    radius: 35,
                                    backgroundColor: isDark ? MyColors.cyan.withOpacity(0.2) : MyColors.green.withOpacity(0.2),
                                    child: Text(
                                      authProvider.name != null
                                          ? authProvider.name![0].toUpperCase()
                                          : 'U',
                                      style: TextStyle(
                                        fontSize: 32,
                                        fontWeight: FontWeight.bold,
                                        color: isDark ? MyColors.cyan : MyColors.green,
                                      ),
                                    ),
                                  ),
                                  const SizedBox(height: 16),
                                  Text(
                                    authProvider.name ?? 'User',
                                    style: TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.w600,
                                      color: isDark ? Colors.white : Colors.black87,
                                      letterSpacing: 0.3,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    authProvider.email ?? '',
                                    style: TextStyle(
                                      fontSize: 13,
                                      color: isDark ? Colors.white70 : Colors.black54,
                                      letterSpacing: 0.2,
                                    ),
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  const SizedBox(height: 20),
                                  Divider(
                                    color: isDark ? Colors.white.withOpacity(0.1) : Colors.black.withOpacity(0.1),
                                  ),
                                ],
                              )
                                  : Column(
                                children: [
                                  CircleAvatar(
                                    radius: 22,
                                    backgroundColor: isDark ? MyColors.cyan.withOpacity(0.2) : MyColors.green.withOpacity(0.2),
                                    child: Text(
                                      authProvider.name != null
                                          ? authProvider.name![0].toUpperCase()
                                          : 'U',
                                      style: TextStyle(
                                        fontSize: 20,
                                        fontWeight: FontWeight.bold,
                                        color: isDark ? MyColors.cyan : MyColors.green,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            // Menu Items
                            Expanded(
                              child: ListView(
                                padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
                                children: [
                                  GestureDetector(
                                    onTap: () {
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (context) => PracticesPage(toggleTheme: widget.toggleTheme),
                                        ),
                                      );
                                    },
                                    child: _buildDrawerItem(
                                      index: 0,
                                      icon: Icons.edit_note_rounded,
                                      title: 'Practices',
                                      isDark: isDark,
                                      isExpanded: _drawerAnimation.value > 0.5,
                                    ),
                                  ),
                                  const SizedBox(height: 6),
                                  GestureDetector(
                                    onTap: () {
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (context) => TestsPage(toggleTheme: widget.toggleTheme),
                                        ),
                                      );
                                    },
                                    child: _buildDrawerItem(
                                      index: 1,
                                      icon: Icons.quiz_rounded,
                                      title: 'Tests',
                                      isDark: isDark,
                                      isExpanded: _drawerAnimation.value > 0.5,
                                    ),
                                  ),
                                  const SizedBox(height: 6),
                                  GestureDetector(
                                    onTap: () {
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (context) => PastPracticeResults(),
                                        ),
                                      );
                                    },
                                    child: _buildDrawerItem(
                                      index: 2,
                                      icon: Icons.assessment_rounded,
                                      title: 'Past Results',
                                      isDark: isDark,
                                      isExpanded: _drawerAnimation.value > 0.5,
                                    ),
                                  ),
                                  const SizedBox(height: 6),
                                  // ✅ YENİ DRAWER ITEM
                                  GestureDetector(
                                    onTap: () {
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (context) => LearningHall(toggleTheme: widget.toggleTheme),
                                        ),
                                      );
                                    },
                                    child: _buildDrawerItem(
                                      index: 3,
                                      icon: Icons.lightbulb_outline_rounded,
                                      title: 'Tips & Methods',
                                      isDark: isDark,
                                      isExpanded: _drawerAnimation.value > 0.5,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Divider(
                              color: isDark ? Colors.white.withOpacity(0.1) : Colors.black.withOpacity(0.1),
                              indent: 20,
                              endIndent: 20,
                            ),
                            Padding(
                              padding: const EdgeInsets.all(12),
                              child: GestureDetector(
                                onTap: () async {
                                  await authProvider.logout();
                                  Navigator.pushAndRemoveUntil(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => WelcomePage(toggleTheme: widget.toggleTheme),
                                    ),
                                        (route) => false,
                                  );
                                },
                                child: _buildDrawerItem(
                                  index: 4, // ✅ Index değişti
                                  icon: Icons.logout_rounded,
                                  title: 'Logout',
                                  isDark: isDark,
                                  isExpanded: _drawerAnimation.value > 0.5,
                                  isDestructive: true,
                                ),
                              ),
                            ),
                            const SizedBox(height: 8),
                          ],
                        ),
                      ),
                    );
                  },
                ),

                // Toggle Button
                AnimatedBuilder(
                  animation: _drawerAnimation,
                  builder: (context, child) {
                    final currentWidth = collapsedWidth + (_drawerAnimation.value * (drawerWidth - collapsedWidth));

                    return Positioned(
                      left: currentWidth - 20,
                      top: MediaQuery.of(context).padding.top + 15,
                      child: GestureDetector(
                        onTap: _toggleDrawer,
                        child: Container(
                          width: 40,
                          height: 40,
                          decoration: BoxDecoration(
                            color: isDark ? MyColors.cyan : MyColors.green,
                            shape: BoxShape.circle,
                            boxShadow: [
                              BoxShadow(
                                color: (isDark ? MyColors.cyan : MyColors.green).withOpacity(0.3),
                                blurRadius: 8,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                          child: Icon(
                            _isDrawerOpen ? Icons.close : Icons.arrow_forward_ios_rounded,
                            color: Colors.white,
                            size: _isDrawerOpen ? 24 : 18,
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildDrawerItem({
    required int index,
    required IconData icon,
    required String title,
    required bool isDark,
    required bool isExpanded,
    bool isDestructive = false,
  }) {
    final isHovered = _hoveredIndex == index;

    return MouseRegion(
      onEnter: (_) => setState(() => _hoveredIndex = index),
      onExit: (_) => setState(() => _hoveredIndex = null),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeOut,
        child: Container(
          padding: EdgeInsets.symmetric(
            horizontal: isExpanded ? 16 : 0,
            vertical: 14,
          ),
          decoration: BoxDecoration(
            color: isHovered
                ? (isDestructive
                ? MyColors.red.withOpacity(0.08)
                : (isDark ? MyColors.cyan : MyColors.green).withOpacity(0.08))
                : Colors.transparent,
            borderRadius: BorderRadius.circular(10),
          ),
          child: isExpanded
              ? Row(
            children: [
              Icon(
                icon,
                color: isDestructive
                    ? MyColors.red
                    : (isDark ? MyColors.cyan : MyColors.green),
                size: 22,
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Text(
                  title,
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: isHovered ? FontWeight.w600 : FontWeight.w500,
                    color: isDestructive
                        ? MyColors.red
                        : (isDark ? Colors.white : Colors.black87),
                    letterSpacing: 0.2,
                  ),
                ),
              ),
            ],
          )
              : Center(
            child: Icon(
              icon,
              color: isDestructive
                  ? MyColors.red
                  : (isDark ? MyColors.cyan : MyColors.green),
              size: 22,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildCard(String title, VoidCallback onTap, bool isDark, BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    double cardWidth = screenWidth > 1100 ? 350 : screenWidth > 700 ? (screenWidth / 2) - 120 : screenWidth - 120;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: cardWidth,
        height: 200,
        decoration: BoxDecoration(
          color: isDark ? const Color(0xFF1a1f37) : Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isDark ? Colors.white.withOpacity(0.05) : Colors.black.withOpacity(0.05),
            width: 1,
          ),
          boxShadow: [
            BoxShadow(
              color: isDark ? Colors.black.withOpacity(0.3) : Colors.black.withOpacity(0.04),
              blurRadius: 10,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Center(
          child: Text(
            title,
            style: TextStyle(
              fontSize: 26,
              fontWeight: FontWeight.w500,
              color: isDark ? Colors.white : Colors.black87,
              letterSpacing: 0.5,
            ),
          ),
        ),
      ),
    );
  }
}