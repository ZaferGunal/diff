import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../MyColors.dart';
import '../UserProvider.dart';
import 'BocconiPurchasePage.dart';

class BocconiIntroPage extends StatefulWidget {
  final VoidCallback toggleTheme;
  final String token;

  const BocconiIntroPage({
    super.key,
    required this.toggleTheme,
    required this.token,
  });

  @override
  State<BocconiIntroPage> createState() => _BocconiIntroPageState();
}

class _BocconiIntroPageState extends State<BocconiIntroPage> {
  int _hoveredFeatureIndex = -1;

  final List<Map<String, dynamic>> features = [
    {
      'icon': Icons.quiz_outlined,
      'title': 'Practice Tests',
      'description': '4 Full-length practice tests with detailed solutions',
      'color': Color(0xFF00D9FF),
    },
    {
      'icon': Icons.analytics_outlined,
      'title': 'Performance Tracking',
      'description': 'Track your progress and identify weak areas',
      'color': Color(0xFF667eea),
    },
    {
      'icon': Icons.psychology_outlined,
      'title': 'Subject Tests',
      'description': 'Focused practice on Logic, Math, and Reading',
      'color': Color(0xFF764ba2),
    },
    {
      'icon': Icons.auto_awesome,
      'title': 'AI-Powered Help',
      'description': 'Get instant explanations for any question',
      'color': Color(0xFFf093fb),
    },
  ];

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
                  color: isDark ? MyColors.cyan : MyColors.green,
                ),
                onPressed: () => Navigator.pop(context),
              ),
              flexibleSpace: FlexibleSpaceBar(
                title: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.school_rounded,
                      color: isDark ? MyColors.cyan : MyColors.green,
                      size: 24,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'Bocconi Test Package',
                      style: TextStyle(
                          color: isDark ? MyColors.cyan : MyColors.green,
                          fontSize: 18,
                          fontWeight: FontWeight.w700),
),
],
),
centerTitle: true,
),
),

// Hero Section
SliverToBoxAdapter(
child: Container(
padding: EdgeInsets.all(isSmallScreen ? 40 : 80),
child: Column(
children: [
// Main Title
Container(
padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
decoration: BoxDecoration(
gradient: LinearGradient(
colors: [
MyColors.cyan.withOpacity(0.2),
MyColors.green.withOpacity(0.2),
],
),
borderRadius: BorderRadius.circular(50),
border: Border.all(
color: isDark ? MyColors.cyan.withOpacity(0.3) : MyColors.green.withOpacity(0.3),
width: 2,
),
),
child: Text(
'🎓 BOCCONI TEST PREPARATION',
style: TextStyle(
fontSize: isSmallScreen ? 14 : 16,
fontWeight: FontWeight.w700,
color: isDark ? MyColors.cyan : MyColors.green,
letterSpacing: 2,
),
),
),
const SizedBox(height: 30),
Text(
'Master Your Bocconi\nEntrance Exam',
textAlign: TextAlign.center,
style: TextStyle(
fontSize: isSmallScreen ? 36 : 52,
fontWeight: FontWeight.w800,
color: isDark ? Colors.white : Colors.black87,
height: 1.2,
shadows: isDark
? [
Shadow(
color: MyColors.cyan.withOpacity(0.3),
blurRadius: 20,
)
]
    : [],
),
),
const SizedBox(height: 20),
Text(
'Comprehensive practice tests, AI-powered explanations,\nand detailed performance analytics',
textAlign: TextAlign.center,
style: TextStyle(
fontSize: isSmallScreen ? 16 : 18,
fontWeight: FontWeight.w400,
color: isDark ? Colors.white.withOpacity(0.7) : Colors.black54,
height: 1.6,
),
),
const SizedBox(height: 50),

// Price Card
Container(
padding: const EdgeInsets.all(40),
decoration: BoxDecoration(
gradient: LinearGradient(
begin: Alignment.topLeft,
end: Alignment.bottomRight,
colors: isDark
? [
MyColors.cyan.withOpacity(0.2),
MyColors.green.withOpacity(0.1),
]
    : [
MyColors.green.withOpacity(0.1),
MyColors.cyan.withOpacity(0.05),
],
),
borderRadius: BorderRadius.circular(24),
border: Border.all(
color: isDark ? MyColors.cyan.withOpacity(0.3) : MyColors.green.withOpacity(0.3),
width: 2,
),
boxShadow: [
BoxShadow(
color: isDark
? MyColors.cyan.withOpacity(0.2)
    : Colors.black.withOpacity(0.1),
blurRadius: 30,
offset: const Offset(0, 10),
),
],
),
child: Column(
children: [
Row(
mainAxisAlignment: MainAxisAlignment.center,
crossAxisAlignment: CrossAxisAlignment.start,
children: [
Text(
'€',
style: TextStyle(
fontSize: 32,
fontWeight: FontWeight.w700,
color: isDark ? MyColors.cyan : MyColors.green,
),
),
Text(
'79.99',
style: TextStyle(
fontSize: 64,
fontWeight: FontWeight.w900,
color: isDark ? MyColors.cyan : MyColors.green,
height: 1,
),
),
],
),
const SizedBox(height: 10),
Text(
'One-time payment • Lifetime access',
style: TextStyle(
fontSize: 16,
fontWeight: FontWeight.w500,
color: isDark ? Colors.white.withOpacity(0.6) : Colors.black54,
),
),
const SizedBox(height: 30),
SizedBox(
width: isSmallScreen ? double.infinity : 300,
height: 60,
child: ElevatedButton(
onPressed: () {
final authProvider = context.read<AuthProvider>();
Navigator.push(
context,
MaterialPageRoute(
builder: (context) => BocconiPurchasePage(
toggleTheme: widget.toggleTheme,
token: widget.token,
userId: authProvider.email ?? '',
userEmail: authProvider.email ?? '',
userName: authProvider.name ?? '',
),
),
);
},
style: ElevatedButton.styleFrom(
backgroundColor: isDark ? MyColors.cyan : MyColors.green,
foregroundColor: Colors.white,
shape: RoundedRectangleBorder(
borderRadius: BorderRadius.circular(16),
),
elevation: 0,
),
child: Row(
mainAxisAlignment: MainAxisAlignment.center,
children: [
Icon(Icons.shopping_cart_outlined, size: 24),
const SizedBox(width: 12),
Text(
'Get Started Now',
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
),

// Features Section
SliverToBoxAdapter(
child: Container(
padding: EdgeInsets.all(isSmallScreen ? 40 : 80),
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

// Bottom CTA
SliverToBoxAdapter(
child: Container(
padding: EdgeInsets.all(isSmallScreen ? 40 : 80),
child: Container(
padding: const EdgeInsets.all(60),
decoration: BoxDecoration(
gradient: LinearGradient(
colors: isDark
? [
MyColors.cyan.withOpacity(0.3),
MyColors.green.withOpacity(0.2),
]
    : [
MyColors.green.withOpacity(0.2),
MyColors.cyan.withOpacity(0.1),
],
),
borderRadius: BorderRadius.circular(32),
border: Border.all(
color: isDark ? MyColors.cyan.withOpacity(0.3) : MyColors.green.withOpacity(0.3),
width: 2,
),
),
child: Column(
children: [
Text(
'Ready to ace your exam?',
textAlign: TextAlign.center,
style: TextStyle(
fontSize: isSmallScreen ? 28 : 36,
fontWeight: FontWeight.w800,
color: isDark ? Colors.white : Colors.black87,
),
),
const SizedBox(height: 20),
Text(
'Join hundreds of successful students',
textAlign: TextAlign.center,
style: TextStyle(
fontSize: 18,
fontWeight: FontWeight.w400,
color: isDark ? Colors.white.withOpacity(0.7) : Colors.black54,
),
),
const SizedBox(height: 40),
SizedBox(
width: isSmallScreen ? double.infinity : 350,
height: 60,
child: ElevatedButton(
onPressed: () {
final authProvider = context.read<AuthProvider>();
Navigator.push(
context,
MaterialPageRoute(
builder: (context) => BocconiPurchasePage(
toggleTheme: widget.toggleTheme,
token: widget.token,
userId: authProvider.email ?? '',
userEmail: authProvider.email ?? '',
userName: authProvider.name ?? '',
),
),
);
},
style: ElevatedButton.styleFrom(
backgroundColor: isDark ? MyColors.cyan : MyColors.green,
foregroundColor: Colors.white,
shape: RoundedRectangleBorder(
borderRadius: BorderRadius.circular(16),
),
elevation: 5,
),
child: Text(
'Purchase Now - €79.99',
style: TextStyle(
fontSize: 18,
fontWeight: FontWeight.w700,
letterSpacing: 1,
),
),
),
),
],
),
),
),
),

SliverToBoxAdapter(child: SizedBox(height: 80)),
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
padding: const EdgeInsets.all(32),
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