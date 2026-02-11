import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'dart:ui';
import 'TILIDashboard.dart'; // For BentoColors
import '../services/authservice.dart';
import '../UserProvider.dart';
import 'TILSubjectTestingPage.dart';
import 'package:google_fonts/google_fonts.dart';
import 'TILMembershipPage.dart';

class TILSubjectTestViewPage extends StatefulWidget {
  final String title;
  final String subjectType;
  final Color accentColor;
  final IconData icon;
  final VoidCallback? toggleTheme;

  const TILSubjectTestViewPage({
    super.key,
    required this.title,
    required this.subjectType,
    required this.accentColor,
    required this.icon,
    this.toggleTheme,
  });

  @override
  State<TILSubjectTestViewPage> createState() => _TILSubjectTestViewPageState();
}

class _TILSubjectTestViewPageState extends State<TILSubjectTestViewPage> {
  bool isLoading = true;
  String? errorMessage;
  Map<int, String?> testTopics = {};
  int? _hoveredIndex;

  int get testCount {
    switch (widget.subjectType) {
      case 'Mathematics': return 32;
      case 'Reading Comprehension': return 20;
      case 'Physics': return 24;
      case 'Technical Knowledge': return 18;
      default: return 0;
    }
  }

  @override
  void initState() {
    super.initState();
    _loadTestTopics();
  }

  Future<void> _loadTestTopics() async {
    setState(() {
      isLoading = true;
      errorMessage = null;
    });

    try {
      final futures = List.generate(testCount, (index) async {
        final testIndex = index + 1;
        try {
          var response = await AuthService().getTILSubjectTest(
            widget.subjectType,
            testIndex,
          );

          if (response?.data['success'] == true) {
            var test = response!.data['test'];
            final topicFromDB = test['topic'];

            if (topicFromDB != null &&
                topicFromDB.toString().trim().isNotEmpty &&
                topicFromDB.toString().trim().toLowerCase() != 'unknown') {
              return MapEntry(testIndex, topicFromDB.toString().trim());
            }
          }
          return MapEntry(testIndex, null);
        } catch (e) {
          print('❌ Test $testIndex topic load error: $e');
          return MapEntry(testIndex, null);
        }
      });

      final results = await Future.wait(futures);

      if (mounted) {
        setState(() {
          testTopics = Map.fromEntries(results);
          isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          errorMessage = "Topics couldn't be loaded: $e";
          isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bg = isDark ? BentoColors.darkBg : BentoColors.lightBg;
    final text = isDark ? BentoColors.darkTextPrimary : BentoColors.lightTextPrimary;
    final isDesktop = MediaQuery.of(context).size.width > 900;

    return Scaffold(
      backgroundColor: bg,
      body: Stack(
        children: [
          // Ambient Background Gradients
          if (isDark) ...[
            Positioned(
              top: -150,
              right: -100,
              child: _buildBlurCircle(widget.accentColor.withOpacity(0.08), 400),
            ),
            Positioned(
              bottom: -100,
              left: -80,
              child: _buildBlurCircle(BentoColors.tealAccent.withOpacity(0.05), 400),
            ),
          ],

          SafeArea(
            child: Column(
              children: [
                _buildPremiumHeader(isDark, text),
                Expanded(
                  child: isLoading
                      ? _buildLoadingState(text)
                      : errorMessage != null
                          ? _buildErrorState(text)
                          : _buildTestGrid(isDark, text, isDesktop),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBlurCircle(Color color, double size) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(color: color, shape: BoxShape.circle),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 100, sigmaY: 100),
        child: Container(color: Colors.transparent),
      ),
    );
  }

  Widget _buildPremiumHeader(bool isDark, Color text) {
    final isMobile = MediaQuery.of(context).size.width < 768;

    return Container(
      padding: EdgeInsets.fromLTRB(isMobile ? 16 : 24, 16, isMobile ? 16 : 24, 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
               _buildGlassIconButton(
                isDark, 
                Icons.arrow_back_ios_new_rounded, 
                () => Navigator.pop(context),
                text
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Subject Selection",
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                        color: text.withOpacity(0.4),
                        letterSpacing: 1,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      widget.title,
                      style: TextStyle(
                        fontSize: isMobile ? 16 : 18,
                        color: widget.accentColor,
                        fontWeight: FontWeight.w800,
                        letterSpacing: -0.5,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
              if (!isMobile && widget.toggleTheme != null) ...[
                _buildThemeToggle(isDark),
                const SizedBox(width: 12),
              ],
              _buildModernBadge(
                "${testCount} Tests",
                widget.accentColor,
              ),
            ],
          ),
          const SizedBox(height: 32),
          
          // Hero Container
          Container(
            padding: EdgeInsets.all(isMobile ? 20 : 28),
            decoration: BoxDecoration(
              color: isDark ? BentoColors.darkSurface : BentoColors.lightSurface,
              borderRadius: BorderRadius.circular(32),
              border: Border.all(
                color: isDark ? Colors.white.withOpacity(0.06) : Colors.black.withOpacity(0.04),
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(isDark ? 0.3 : 0.05),
                  blurRadius: 20,
                  offset: const Offset(0, 10),
                ),
              ],
            ),
            child: Row(
              children: [
                Container(
                  width: isMobile ? 56 : 72,
                  height: isMobile ? 56 : 72,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [widget.accentColor, widget.accentColor.withOpacity(0.7)],
                    ),
                    borderRadius: BorderRadius.circular(24),
                    boxShadow: [
                      BoxShadow(
                        color: widget.accentColor.withOpacity(0.3),
                        blurRadius: 16,
                        offset: const Offset(0, 8),
                      ),
                    ],
                  ),
                  child: Icon(widget.icon, color: Colors.white, size: isMobile ? 28 : 34),
                ),
                SizedBox(width: isMobile ? 16 : 24),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "${widget.title} Practice",
                        style: TextStyle(
                          fontSize: isMobile ? 20 : 26,
                          fontWeight: FontWeight.w900,
                          color: text,
                          letterSpacing: -0.8,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        "Master the core concepts through simulated exams.",
                        style: TextStyle(
                          fontSize: isMobile ? 12 : 14,
                          color: text.withOpacity(0.5),
                          fontWeight: FontWeight.w500,
                          height: 1.4,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          
          const SizedBox(height: 32),
          Text(
            "CHOOSE A MODULE",
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w800,
              color: text.withOpacity(0.4),
              letterSpacing: 1.5,
            ),
          ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }

  Widget _buildGlassIconButton(bool isDark, IconData icon, VoidCallback onTap, Color textColor) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(16),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(16),
          child: Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: isDark ? Colors.white.withOpacity(0.06) : Colors.black.withOpacity(0.04),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: isDark ? Colors.white.withOpacity(0.08) : Colors.black.withOpacity(0.06),
              ),
            ),
            child: Icon(icon, color: textColor, size: 20),
          ),
        ),
      ),
    );
  }

  Widget _buildThemeToggle(bool isDark) {
    return InkWell(
      onTap: widget.toggleTheme,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: isDark ? Colors.white.withOpacity(0.05) : Colors.black.withOpacity(0.03),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: isDark ? Colors.white.withOpacity(0.1) : Colors.black.withOpacity(0.05)),
        ),
        child: Row(
          children: [
            Icon(isDark ? Icons.light_mode_rounded : Icons.dark_mode_rounded, size: 16, color: isDark ? Colors.orangeAccent : Colors.indigo),
            const SizedBox(width: 8),
            Text(isDark ? "Light" : "Dark", style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: isDark ? Colors.white70 : Colors.black87)),
          ],
        ),
      ),
    );
  }

  Widget _buildModernBadge(String label, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      decoration: BoxDecoration(
        color: color.withOpacity(0.12),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withOpacity(0.25)),
      ),
      child: Text(
        label,
        style: TextStyle(color: color, fontWeight: FontWeight.w800, fontSize: 13),
      ),
    );
  }

  Widget _buildLoadingState(Color text) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          SizedBox(
            width: 50,
            height: 50,
            child: CircularProgressIndicator(
              color: widget.accentColor,
              strokeWidth: 4,
              strokeCap: StrokeCap.round,
            ),
          ),
          const SizedBox(height: 24),
          Text(
            'Retrieving testing modules...',
            style: TextStyle(fontSize: 16, color: text.withOpacity(0.6), fontWeight: FontWeight.w500),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorState(Color text) {
    return Center(
      child: Container(
        margin: const EdgeInsets.all(32),
        padding: const EdgeInsets.all(32),
        decoration: BoxDecoration(
          color: Colors.red.withOpacity(0.05),
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: Colors.red.withOpacity(0.15)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.warning_amber_rounded, color: Colors.redAccent, size: 48),
            const SizedBox(height: 20),
            Text(errorMessage!, style: TextStyle(color: text, fontWeight: FontWeight.w500), textAlign: TextAlign.center),
            const SizedBox(height: 28),
            ElevatedButton(
              onPressed: _loadTestTopics,
              style: ElevatedButton.styleFrom(
                backgroundColor: widget.accentColor,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 14),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                elevation: 0,
              ),
              child: const Text("Reconnect System", style: TextStyle(fontWeight: FontWeight.w700)),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTestGrid(bool isDark, Color text, bool isDesktop) {
    final isMobile = MediaQuery.of(context).size.width < 768;

    return Scrollbar(
      thickness: 4,
      radius: const Radius.circular(10),
      child: GridView.builder(
        padding: EdgeInsets.fromLTRB(isMobile ? 16 : 24, 0, isMobile ? 16 : 24, 40),
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: isDesktop ? 4 : (MediaQuery.of(context).size.width > 600 ? 3 : 2),
          crossAxisSpacing: 20,
          mainAxisSpacing: 20,
          childAspectRatio: isDesktop ? 1.1 : 1.0,
        ),
        itemCount: testCount,
        itemBuilder: (context, index) {
          final AuthProvider authProvider = Provider.of<AuthProvider>(context, listen: false);
          final bool hasPackage = authProvider.hasTiliPackage;
          final int testIndexVal = index + 1;
          final bool isLocked = !hasPackage && testIndexVal > 1;

          final topic = testTopics[testIndexVal];
          return _buildPremiumTestCard(testIndexVal, topic, isDark, text, isLocked);
        },
      ),
    );
  }

  Widget _buildPremiumTestCard(int index, String? topic, bool isDark, Color text, bool isLocked) {
    final isHovered = _hoveredIndex == index;
    final surface = isDark ? BentoColors.darkSurface : BentoColors.lightSurface;

    return MouseRegion(
      onEnter: (_) => setState(() => _hoveredIndex = index),
      onExit: (_) => setState(() => _hoveredIndex = null),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOutQuart,
        transform: Matrix4.identity()..translate(0.0, isHovered ? -6.0 : 0.0),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: isLocked ? _showUpgradeDialog : () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => TILSubjectTestingPage(
                    toggleTheme: widget.toggleTheme ?? () {},
                    subjectType: widget.subjectType,
                    testIndex: index,
                    title: widget.title,
                    accentColor: widget.accentColor,
                    testNumber: index,
                  ),
                ),
              );
            },
            borderRadius: BorderRadius.circular(24),
            child: Container(
              decoration: BoxDecoration(
                color: surface,
                borderRadius: BorderRadius.circular(24),
                border: Border.all(
                  color: isHovered
                      ? widget.accentColor.withOpacity(0.4)
                      : (isDark ? Colors.white.withOpacity(0.06) : Colors.black.withOpacity(0.04)),
                  width: 1.5,
                ),
                boxShadow: [
                  BoxShadow(
                    color: isHovered ? widget.accentColor.withOpacity(0.12) : Colors.black.withOpacity(isDark ? 0.25 : 0.04),
                    blurRadius: isHovered ? 24 : 12,
                    offset: Offset(0, isHovered ? 12 : 6),
                  ),
                ],
              ),
              child: Stack(
                children: [
                  Positioned(
                    right: -10,
                    top: -10,
                    child: Container(
                      width: 80,
                      height: 80,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: RadialGradient(
                          colors: [widget.accentColor.withOpacity(isHovered ? 0.12 : 0.04), Colors.transparent],
                        ),
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              "#$index",
                              style: TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w800,
                                color: widget.accentColor,
                                letterSpacing: 0.5,
                              ),
                            ),
                            AnimatedContainer(
                              duration: const Duration(milliseconds: 200),
                              padding: const EdgeInsets.all(6),
                              decoration: BoxDecoration(
                                color: isHovered ? widget.accentColor.withOpacity(0.12) : Colors.transparent,
                                shape: BoxShape.circle,
                              ),
                              child: Icon(
                                isLocked ? Icons.lock_outline_rounded : Icons.arrow_forward_rounded,
                                size: 14,
                                color: isLocked ? Colors.amber : (isHovered ? widget.accentColor : text.withOpacity(0.25)),
                              ),
                            ),
                          ],
                        ),
                        const Spacer(),
                        Text(
                          "Module $index",
                          style: TextStyle(
                            fontSize: 17,
                            fontWeight: FontWeight.w900,
                            color: text,
                            letterSpacing: -0.5,
                          ),
                        ),
                        if (topic != null) ...[
                          const SizedBox(height: 4),
                          Text(
                            topic,
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w500,
                              color: text.withOpacity(0.4),
                              height: 1.2,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                        const SizedBox(height: 16),
                        _buildModuleButton(isHovered, isLocked),
                      ],
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

  Widget _buildModuleButton(bool isHovered, bool isLocked) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 10),
      decoration: BoxDecoration(
        color: isLocked 
            ? Colors.amber.withOpacity(0.1)
            : (isHovered ? widget.accentColor : widget.accentColor.withOpacity(0.1)),
        borderRadius: BorderRadius.circular(12),
        boxShadow: (isHovered && !isLocked) ? [
          BoxShadow(
            color: widget.accentColor.withOpacity(0.3),
            blurRadius: 10,
            offset: const Offset(0, 4),
          )
        ] : null,
      ),
      child: Center(
        child: Text(
          isLocked ? "UPGRADE" : (isHovered ? "START NOW" : "BEGIN"),
          style: TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w900,
            color: isLocked ? Colors.amber : (isHovered ? Colors.white : widget.accentColor),
            letterSpacing: 1,
          ),
        ),
      ),
    );
  }

  void _showUpgradeDialog() {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        backgroundColor: Colors.transparent,
        child: Container(
          constraints: const BoxConstraints(maxWidth: 400),
          padding: const EdgeInsets.all(28),
          decoration: BoxDecoration(
            color: const Color(0xFF1E1E2E),
            borderRadius: BorderRadius.circular(28),
            border: Border.all(color: Colors.white.withOpacity(0.1), width: 1),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.5),
                blurRadius: 40,
                offset: const Offset(0, 20),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.amber.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.lock_rounded, color: Colors.amber, size: 32),
              ),
              const SizedBox(height: 20),
              Text(
                "Upgrade Required",
                style: GoogleFonts.inter(
                  fontSize: 22,
                  fontWeight: FontWeight.w900,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                "Upgrade your account to unlock all subject tests and topic-based assessment modules.",
                textAlign: TextAlign.center,
                style: GoogleFonts.inter(
                  fontSize: 14,
                  color: Colors.white70,
                  height: 1.5,
                ),
              ),
              const SizedBox(height: 28),
              ElevatedButton(
                onPressed: () {
                  Navigator.pop(context);
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => TILMembershipPage(toggleTheme: widget.toggleTheme ?? () {}),
                    ),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.amber.shade700,
                  foregroundColor: Colors.white,
                  minimumSize: const Size(double.infinity, 54),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  elevation: 0,
                ),
                child: const Text("SEE UPGRADE PLANS", style: TextStyle(fontWeight: FontWeight.w900, fontSize: 14)),
              ),
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: Text("Maybe Later", style: TextStyle(color: Colors.white.withOpacity(0.5))),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
