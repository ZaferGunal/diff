import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../BocconiPages/BocconiIntroPage.dart';
import '../BocconiPages/welcome_page.dart';
import '../TILPages/TILIntroPage.dart';
import '../TILPages/TILIDashboard.dart';
import '../UserProvider.dart';
import '../MyColors.dart';
import '../BocconiPages/home_page.dart';

class DashboardPage extends StatefulWidget {
  final VoidCallback toggleTheme;
  final String token;

  const DashboardPage({
    super.key,
    required this.toggleTheme,
    required this.token,
  });

  @override
  State<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {
  int? _hoveredIndex;
  bool _hasCheckedSession = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!_hasCheckedSession) {
        _hasCheckedSession = true;
        _checkSessionStatus();
      }
    });
  }

  void _checkSessionStatus() {
    final authProvider = context.read<AuthProvider>();

    print("🔍 [DashboardPage] Checking session...");
    print("🔍 [DashboardPage] isAuthenticated: ${authProvider.isAuthenticated}");
    print("🔍 [DashboardPage] token: ${authProvider.token}");
    print("🔍 [DashboardPage] Bocconi Package: ${authProvider.hasBocconiPackage}");
    print("🔍 [DashboardPage] TILI Package: ${authProvider.hasTiliPackage}");

    if (authProvider.token == null) {
      print("❌ [DashboardPage] No token - redirecting to Welcome");
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(
          builder: (context) => WelcomePage(toggleTheme: widget.toggleTheme),
        ),
            (route) => false,
      );
    } else {
      print("✅ [DashboardPage] Session OK");
    }
  }

  void _handleBocconiTap(BuildContext context, AuthProvider authProvider) {
    if (authProvider.isBocconiPackageActive()) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => HomePage(
            toggleTheme: widget.toggleTheme,
            token: widget.token,
          ),
        ),
      );
    } else {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => BocconiIntroPage(
            toggleTheme: widget.toggleTheme,
            token: widget.token,
          ),
        ),
      );
    }
  }

  void _handleTiliTap(BuildContext context, AuthProvider authProvider) {
    // ✅ If active (Basic or Premium), go to TILIDashboard
    if (authProvider.isTiliPackageActive()) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => TILIDashboard(
            toggleTheme: widget.toggleTheme,
            token: widget.token,
          ),
        ),
      );
    } else {
      // ❌ Not active, go to intro page (which includes Free Trial option)
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => TILIIntroPage(
            toggleTheme: widget.toggleTheme,
            token: widget.token,
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Consumer<AuthProvider>(
      builder: (context, authProvider, child) {
        if (_hasCheckedSession && authProvider.token == null) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            print("❌ [DashboardPage] Session expired - logging out");
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
            body: Container(
              decoration: BoxDecoration(
                gradient: isDark
                    ? LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    const Color(0xFF0a0e1a),
                    const Color(0xFF141b2d),
                    MyColors.cyan.withOpacity(0.1),
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
                        const Spacer(),
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
                        Container(
                          margin: const EdgeInsets.only(right: 16, left: 8),
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: isDark
                                  ? MyColors.red.withOpacity(0.3)
                                  : MyColors.red.withOpacity(0.3),
                              width: 1.5,
                            ),
                          ),
                          child: IconButton(
                            icon: Icon(
                              Icons.logout_rounded,
                              color: MyColors.red,
                            ),
                            onPressed: () async {
                              await authProvider.logout();
                              Navigator.pushAndRemoveUntil(
                                context,
                                MaterialPageRoute(
                                  builder: (context) =>
                                      WelcomePage(toggleTheme: widget.toggleTheme),
                                ),
                                    (route) => false,
                              );
                            },
                          ),
                        ),
                      ],
                    ),
                  ),

                  // Body
                  Expanded(
                    child: Center(
                      child: SingleChildScrollView(
                        child: Container(
                          constraints: const BoxConstraints(maxWidth: 1400),
                          padding: EdgeInsets.all(MediaQuery.of(context).size.width < 768 ? 20 : 60),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            // Welcome Text
                            Text(
                              'Welcome Back${authProvider.name != null ? ', ${authProvider.name}' : ''}!',
                              style: TextStyle(
                                fontSize: 40,
                                fontWeight: FontWeight.w600,
                                letterSpacing: 2,
                                color: isDark ? Colors.white : Colors.black87,
                              ),
                              textAlign: TextAlign.center,
                            ),
                            const SizedBox(height: 16),
                            Text(
                              'Choose your platform to continue',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.w400,
                                color: isDark
                                    ? Colors.white.withOpacity(0.6)
                                    : Colors.black54,
                                letterSpacing: 0.8,
                              ),
                              textAlign: TextAlign.center,
                            ),
                            const SizedBox(height: 80),

                            // Platform Cards
                            Wrap(
                              spacing: 40,
                              runSpacing: 40,
                              alignment: WrapAlignment.center,
                              children: [
                                _buildPlatformCard(
                                  context: context,
                                  authProvider: authProvider,
                                  title: 'Bocconi',
                                  subtitle: 'Test Preparation Platform',
                                  icon: Icons.school_rounded,
                                  gradient: isDark
                                      ? LinearGradient(
                                    colors: [
                                      MyColors.cyan.withOpacity(0.8),
                                      MyColors.cyan.withOpacity(0.5),
                                    ],
                                  )
                                      : LinearGradient(
                                    colors: [
                                      MyColors.green.withOpacity(0.8),
                                      MyColors.green.withOpacity(0.5),
                                    ],
                                  ),
                                  isDark: isDark,
                                  index: 0,
                                  isActive: authProvider.isBocconiPackageActive(),
                                  onTap: () => _handleBocconiTap(context, authProvider),
                                ),
                                _buildPlatformCard(
                                  context: context,
                                  authProvider: authProvider,
                                  title: 'TIL-I',
                                  subtitle: 'Interactive Learning',
                                  icon: Icons.lightbulb_rounded,
                                  gradient: isDark
                                      ? LinearGradient(
                                    colors: [
                                      MyColors.orange.withOpacity(0.8),
                                      MyColors.orange.withOpacity(0.5),
                                    ],
                                  )
                                      : LinearGradient(
                                    colors: [
                                      MyColors.bocco_blue.withOpacity(0.8),
                                      MyColors.bocco_blue.withOpacity(0.5),
                                    ],
                                  ),
                                  isDark: isDark,
                                  index: 1,
                                  isActive: authProvider.isTiliPackageActive(),
                                  onTap: () => _handleTiliTap(context, authProvider),
                                ),
                              ],
                            ),
                          ],
                        ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildPlatformCard({
    required BuildContext context,
    required AuthProvider authProvider,
    required String title,
    required String subtitle,
    required IconData icon,
    required Gradient gradient,
    required bool isDark,
    required int index,
    required bool isActive,
    required VoidCallback onTap,
  }) {
    final isHovered = _hoveredIndex == index;
    final screenWidth = MediaQuery.of(context).size.width;
    final cardWidth = screenWidth > 900 
        ? 400.0 
        : (screenWidth < 768 ? screenWidth - 40 : screenWidth - 120);

    final isMobile = screenWidth < 768;

    return MouseRegion(
      onEnter: (_) => setState(() => _hoveredIndex = index),
      onExit: (_) => setState(() => _hoveredIndex = null),
      child: GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeInOut,
          width: cardWidth,
          transform: Matrix4.identity()
            ..translate(0.0, isHovered ? -8.0 : 0.0, 0.0),
          decoration: BoxDecoration(
            gradient: isActive
                ? gradient
                : LinearGradient(
              colors: [
                Colors.grey.withOpacity(0.3),
                Colors.grey.withOpacity(0.2),
              ],
            ),
            borderRadius: BorderRadius.circular(24),
            border: Border.all(
              color: isActive
                  ? (isDark ? Colors.white.withOpacity(0.1) : Colors.black.withOpacity(0.05))
                  : Colors.grey.withOpacity(0.3),
              width: 2,
            ),
            boxShadow: [
              BoxShadow(
                color: isDark
                    ? Colors.black.withOpacity(0.4)
                    : Colors.black.withOpacity(0.1),
                blurRadius: isHovered ? 30 : 20,
                offset: Offset(0, isHovered ? 12 : 8),
              ),
            ],
          ),
          child: Stack(
            children: [
              Padding(
                padding: EdgeInsets.all(isMobile ? 20 : 24),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      padding: EdgeInsets.all(isMobile ? 16 : 24),
                      decoration: BoxDecoration(
                        color: isActive
                            ? Colors.white.withOpacity(0.2)
                            : Colors.grey.withOpacity(0.1),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        icon,
                        size: isMobile ? 48 : 64,
                        color: isActive ? Colors.white : Colors.grey,
                      ),
                    ),
                    const SizedBox(height: 20),
                    Text(
                      title,
                      style: TextStyle(
                        fontSize: isMobile ? 24 : 32,
                        fontWeight: FontWeight.w700,
                        color: isActive ? Colors.white : Colors.grey,
                        letterSpacing: 1.5,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      subtitle,
                      style: TextStyle(
                        fontSize: isMobile ? 14 : 16,
                        fontWeight: FontWeight.w400,
                        color: isActive
                            ? Colors.white.withOpacity(0.9)
                            : Colors.grey.withOpacity(0.7),
                        letterSpacing: 0.5,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),

              if (!isActive)
                Positioned(
                  top: 16,
                  right: 16,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: Colors.orange.shade600,
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.orange.withOpacity(0.5),
                          blurRadius: 10,
                          spreadRadius: 2,
                        ),
                      ],
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.lock, color: Colors.white, size: 14),
                        const SizedBox(width: 4),
                        Text(
                          'LOCKED',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 11,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

              if (isActive)
                Positioned(
                  top: 16,
                  right: 16,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: Colors.green.shade600,
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.green.withOpacity(0.5),
                          blurRadius: 10,
                          spreadRadius: 2,
                        ),
                      ],
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.check_circle, color: Colors.white, size: 14),
                        const SizedBox(width: 4),
                        Text(
                          'ACTIVE',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 11,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}