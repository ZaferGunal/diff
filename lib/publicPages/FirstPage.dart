import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:url_launcher/url_launcher.dart';

import '../MyColors.dart';

class FirstPage extends StatefulWidget {
  const FirstPage({Key? key}) : super(key: key);
  @override
  State<FirstPage> createState() => _FirstPageState();
}

class _FirstPageState extends State<FirstPage> with SingleTickerProviderStateMixin {
  final ScrollController _scrollController = ScrollController();
  late AnimationController _animationController;
  late Animation<double> _heightAnimation;
  final DateTime _discountEndDate = DateTime(2026, 1, 13, 23, 59, 59);
  late Duration _remainingTime;
  bool _showTiliPopup = false;
  bool _hasScrolledOnce = false;

  double _targetHeight = 0;
  double _buttonOpacity = 0.0;
  double _arrowOpacity = 1.0;
  bool _isCollapsed = false;
  Color _scaffoldBackgroundColor = MyColors.cyan2;

  // ✅ YENİ: Loading state
  bool _isLoading = true;
  bool _imagesLoaded = false;

  @override
  void initState() {
    super.initState();

    _animationController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    // ✅ İlk olarak görselleri yükle
    _precacheImages();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      final screenHeight = MediaQuery.of(context).size.height;
      setState(() {
        _targetHeight = screenHeight;
      });

      _heightAnimation = Tween<double>(
        begin: screenHeight,
        end: screenHeight,
      ).animate(CurvedAnimation(
        parent: _animationController,
        curve: Curves.easeInOutCubic,
      ));
    });

    _scrollController.addListener(_onScroll);
    _updateRemainingTime();

    Future.delayed(Duration.zero, () {
      if (mounted) {
        _startCountdown();
      }
    });


  }

  // ✅ YENİ: Görselleri önceden yükle
  Future<void> _precacheImages() async {
    try {
      final List<String> imagePaths = [
        "assets/practico.png",
        "assets/lat.png",
        "assets/pr1.png",
        "assets/info1.png",
        "assets/info2.png",
        "assets/paymentNetworks/pay_with_iyzico_horizontal_colored.png",
        "assets/paymentNetworks/Mastercard-logo.png",
        "assets/paymentNetworks/visa.png",
      ];

      await Future.wait(
        imagePaths.map((path) => precacheImage(AssetImage(path), context)),
      );

      if (mounted) {
        setState(() {
          _imagesLoaded = true;
        });

        // Kısa bir gecikme sonrası loading'i kaldır
        await Future.delayed(Duration(milliseconds: 500));

        if (mounted) {
          setState(() {
            _isLoading = false;
          });
        }
      }
    } catch (e) {
      print('Error precaching images: $e');
      // Hata durumunda da loading'i kaldır
      if (mounted) {
        setState(() {
          _isLoading = false;
          _imagesLoaded = true;
        });
      }
    }
  }

  void _startCountdown() {
    Future.delayed(Duration(seconds: 1), () {
      if (mounted) {
        _updateRemainingTime();
        _startCountdown();
      }
    });
  }

  void _updateRemainingTime() {
    setState(() {
      _remainingTime = _discountEndDate.difference(DateTime.now());
      if (_remainingTime.isNegative) {
        _remainingTime = Duration.zero;
      }
    });
  }

  void _onScroll() {
    final offset = _scrollController.offset;
    final screenHeight = MediaQuery.of(context).size.height;

    if (offset > 0) {
      double newHeight = screenHeight - offset;
      if (newHeight < 90) {
        newHeight = 90;
      }

      double newOpacity = 0.0;
      if (newHeight <= 90) {
        newOpacity = 1.0;
      } else if (newHeight < 240) {
        newOpacity = (240 - newHeight) / 150;
      }

      double newArrowOpacity = 1.0;
      if (newHeight <= 90) {
        newArrowOpacity = 0.0;
      } else if (newHeight < 240) {
        newArrowOpacity = (newHeight - 90) / 150;
      }

      if ((newHeight - _targetHeight).abs() > 1 ||
          (_buttonOpacity - newOpacity).abs() > 0.01) {
        setState(() {
          _targetHeight = newHeight;
          _isCollapsed = newHeight <= 90;
          _buttonOpacity = newOpacity;
          _arrowOpacity = newArrowOpacity;


          if (_isCollapsed && !_hasScrolledOnce) {
            _hasScrolledOnce = true;
            Future.delayed(Duration(milliseconds: 600), () {
              if (mounted) {
                setState(() {
                  _showTiliPopup = true;
                });
              }
            });
          }
        });


        _heightAnimation = Tween<double>(
          begin: _heightAnimation.value,
          end: newHeight,
        ).animate(CurvedAnimation(
          parent: _animationController,
          curve: Curves.easeOutCubic,
        ));

        _animationController.forward(from: 0);
      }
    } else {
      if (_targetHeight != screenHeight || _buttonOpacity != 0.0 ||
          _arrowOpacity != 1.0) {
        setState(() {
          _targetHeight = screenHeight;
          _isCollapsed = false;
          _buttonOpacity = 0.0;
          _arrowOpacity = 1.0;

        });

        _heightAnimation = Tween<double>(
          begin: _heightAnimation.value,
          end: screenHeight,
        ).animate(CurvedAnimation(
          parent: _animationController,
          curve: Curves.easeOutCubic,
        ));

        _animationController.forward(from: 0);


      }
    }
  }

  void _toggleCollapse() {
    final screenHeight = MediaQuery.of(context).size.height;

    if (_isCollapsed) {
      _scrollController.animateTo(
        0,
        duration: const Duration(milliseconds: 800),
        curve: Curves.easeInOutCubic,
      );
    } else {
      _scrollController.animateTo(
        screenHeight - 90,
        duration: const Duration(milliseconds: 800),
        curve: Curves.easeInOutCubic,
      );

      Future.delayed(const Duration(milliseconds: 800), () {
        if (mounted) {
          setState(() {
            _scaffoldBackgroundColor = Colors.black;
          });
        }
      });
    }
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // ✅ Loading ekranı göster
    if (_isLoading) {
      return Scaffold(
        backgroundColor: MyColors.cyan2,
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // PractiCo Logo/Text
              Text(
                "PractiCo",
                style: GoogleFonts.ramabhadra(
                  color: Colors.white,
                  fontSize: 48,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: 30),

              // Loading indicator
              SizedBox(
                width: 60,
                height: 60,
                child: CircularProgressIndicator(
                  strokeWidth: 5,
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                ),
              ),
              SizedBox(height: 20),

              // Loading text
              Text(
                _imagesLoaded ? 'Almost ready...' : 'Loading...',
                style: TextStyle(
                  color: Colors.white.withOpacity(0.8),
                  fontSize: 18,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      );
    }

    final screenHeight = MediaQuery.of(context).size.height;
    final screenWidth = MediaQuery.of(context).size.width;
    final isSmallScreen = screenWidth < 900;
    final isMediumScreen = screenWidth >= 900 && screenWidth < 1200;

    return Scaffold(
      backgroundColor: _scaffoldBackgroundColor,
      body: Stack(
        children: [
          SingleChildScrollView(
            controller: _scrollController,
            // ✅ Physics optimizasyonu
            physics: ClampingScrollPhysics(),
            child: Column(
              children: [
                SizedBox(height: _targetHeight),
                Padding(
                  padding: EdgeInsets.zero,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Container(
                        height: isSmallScreen ? 800 : 500,
                        color: MyColors.cyan2,
                        child: const Center(),
                      ),
                      _buildHeroSection(isSmallScreen, isMediumScreen),
                      _buildInfoSection1(isSmallScreen, isMediumScreen),
                      _buildPricingSection(isSmallScreen, isMediumScreen),
                      _buildPersonalizedSection(isSmallScreen, isMediumScreen),
                      _buildStrategySection(isSmallScreen, isMediumScreen),
                      _buildTestimonialsSection(isSmallScreen, isMediumScreen),
                      _buildContactSection(isSmallScreen, isMediumScreen),
                      _buildFooterSection(isSmallScreen, isMediumScreen),
                      _buildPaymentNetworksSection(isSmallScreen, isMediumScreen),
                    ],
                  ),
                ),
              ],
            ),
          ),
          _buildHeader(screenHeight, isSmallScreen, isMediumScreen),

          if (_showTiliPopup)
            Positioned(
              left: isSmallScreen ? 0 : 20,
              bottom: isSmallScreen ? 0 : 20,
              right: isSmallScreen ? 0 : null,
              child: _buildTiliPopup(),
            ),
        ],
      ),
    );
  }






  Widget _buildTiliPopup() {
    final screenWidth = MediaQuery.of(context).size.width;
    final isSmallScreen = screenWidth < 600;

    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0.0, end: 1.0),
      duration: Duration(milliseconds: 1000),
      curve: Curves.easeOutBack,
      builder: (context, value, child) {
        return Transform.scale(
          scale: value,
          alignment: Alignment.bottomLeft,
          child: Transform.translate(
            offset: Offset(0, (1 - value) * 80),
            child: Opacity(
              opacity: value,
              child: child,
            ),
          ),
        );
      },
      child: ClipRRect(
        borderRadius: BorderRadius.circular(isSmallScreen ? 0 : 25),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
          child: Container(
            width: isSmallScreen ? double.infinity : 420,
            margin: EdgeInsets.all(isSmallScreen ? 0 : 20),
            padding: EdgeInsets.all(isSmallScreen ? 20 : 28),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  MyColors.cyan2.withOpacity(0.95),
                  MyColors.cyan2.withOpacity(0.85),
                ],
              ),
              borderRadius: BorderRadius.circular(isSmallScreen ? 0 : 25),
              border: Border.all(
                color: MyColors.cyan.withOpacity(0.5),
                width: 2,
              ),
              boxShadow: [
                BoxShadow(
                  color: MyColors.cyan2.withOpacity(0.4),
                  blurRadius: 35,
                  offset: Offset(0, 12),
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: EdgeInsets.all(isSmallScreen ? 8 : 10),
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [
                                Colors.white.withOpacity(0.3),
                                Colors.white.withOpacity(0.2),
                              ],
                            ),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Icon(
                            Icons.auto_awesome,
                            color: Colors.white,
                            size: isSmallScreen ? 20 : 24,
                          ),
                        ),
                        SizedBox(width: 12),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'TIL-I Exam',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: isSmallScreen ? 20 : 24,
                                fontWeight: FontWeight.w900,
                                letterSpacing: 0.5,
                              ),
                            ),
                            SizedBox(height: 2),
                            Text(
                              'Formula Library',
                              style: TextStyle(
                                color: Colors.white.withOpacity(0.8),
                                fontSize: isSmallScreen ? 11 : 12,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                    Container(
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.2),
                        shape: BoxShape.circle,
                      ),
                      child: IconButton(
                        onPressed: () {
                          setState(() {
                            _showTiliPopup = false;
                          });
                        },
                        icon: Icon(Icons.close, color: Colors.white),
                        iconSize: isSmallScreen ? 18 : 20,
                        padding: EdgeInsets.all(6),
                      ),
                    ),
                  ],
                ),

                SizedBox(height: isSmallScreen ? 16 : 20),

                // Formulas
                _buildPopupItem('📐', 'Physics', Color(0xFF4A90E2), isSmallScreen),
                SizedBox(height: 10),
                _buildPopupItem('🔢', 'Math', Color(0xFF9B59B6), isSmallScreen),
                SizedBox(height: 10),
                _buildPopupItem('🧩', 'Logic', Color(0xFFE67E22), isSmallScreen),

                SizedBox(height: isSmallScreen ? 16 : 20),

                // Coming Soon
                Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: isSmallScreen ? 12 : 14,
                    vertical: isSmallScreen ? 8 : 10,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(
                      color: Colors.amber.withOpacity(0.4),
                      width: 1,
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.schedule,
                        color: Colors.amber,
                        size: isSmallScreen ? 14 : 16,
                      ),
                      SizedBox(width: 8),
                      Text(
                        'Tests & Practices Coming Soon',
                        style: TextStyle(
                          color: Colors.amber.shade100,
                          fontSize: isSmallScreen ? 11 : 13,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),

                SizedBox(height: isSmallScreen ? 16 : 20),

                // Visit Button
                Container(
                  width: double.infinity,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        Colors.white,
                        Colors.white.withOpacity(0.95),
                      ],
                    ),
                    borderRadius: BorderRadius.circular(15),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.white.withOpacity(0.3),
                        blurRadius: 15,
                        offset: Offset(0, 6),
                      ),
                    ],
                  ),
                  child: ElevatedButton.icon(
                    onPressed: () {
                      setState(() {
                        _showTiliPopup = false;
                      });
                      Navigator.pushNamed(context, '/tili');
                    },
                    icon: Icon(Icons.arrow_forward, size: isSmallScreen ? 18 : 20),
                    label: Text(
                      'Visit TIL-I',
                      style: TextStyle(
                        fontSize: isSmallScreen ? 15 : 17,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 0.5,
                      ),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.transparent,
                      foregroundColor: MyColors.cyan2,
                      padding: EdgeInsets.symmetric(
                        vertical: isSmallScreen ? 12 : 14,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(15),
                      ),
                      elevation: 0,
                      shadowColor: Colors.transparent,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildPopupItem(String emoji, String title, Color accentColor, bool isSmallScreen) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: isSmallScreen ? 10 : 12,
        vertical: isSmallScreen ? 8 : 10,
      ),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.15),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: Colors.white.withOpacity(0.3),
          width: 1,
        ),
      ),
      child: Row(
        children: [
          Container(
            width: isSmallScreen ? 32 : 38,
            height: isSmallScreen ? 32 : 38,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Colors.white.withOpacity(0.25),
                  Colors.white.withOpacity(0.15),
                ],
              ),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Center(
              child: Text(emoji, style: TextStyle(fontSize: isSmallScreen ? 16 : 18)),
            ),
          ),
          SizedBox(width: 12),
          Expanded(
            child: Text(
              title,
              style: TextStyle(
                color: Colors.white,
                fontSize: isSmallScreen ? 14 : 15,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),

        ],
      ),
    );
  }

  Widget _buildLegalButton(BuildContext context, String text, IconData icon, String route) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isSmallScreen = screenWidth < 600;

    return InkWell(
      onTap: () => Navigator.pushNamed(context, route),
      child: Container(
        padding: EdgeInsets.symmetric(
            horizontal: isSmallScreen ? 16 : 28,
            vertical: isSmallScreen ? 12 : 18
        ),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Colors.white.withOpacity(0.08),
              Colors.white.withOpacity(0.04),
            ],
          ),
          borderRadius: BorderRadius.circular(15),
          border: Border.all(
            color: MyColors.cyan.withOpacity(0.3),
            width: 1.5,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              color: MyColors.cyan,
              size: isSmallScreen ? 18 : 22,
            ),
            SizedBox(width: isSmallScreen ? 8 : 12),
            Flexible(
              child: Text(
                text,
                style: TextStyle(
                  color: Colors.white,
                  fontSize: isSmallScreen ? 13 : 16,
                  fontWeight: FontWeight.w600,
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
    );
  }

// PART 2 - Widget Building Methods
  Widget _buildInstagramButton(bool isSmallScreen) {
    return Padding(
      padding: EdgeInsets.only(left: 10),
      child: InkWell(
        onTap: () async {
          final url = Uri.parse('https://www.instagram.com/practicotesting/');
          if (await canLaunchUrl(url)) {
            await launchUrl(url, mode: LaunchMode.externalApplication);
          }
        },
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            FaIcon(
              FontAwesomeIcons.instagram,
              color: Colors.white,
              size: isSmallScreen ? 18 : 22,
            ),
            SizedBox(width: isSmallScreen ? 6 : 8),
            Text(
              'practicotesting',
              style: TextStyle(
                color: Colors.white,
                fontSize: isSmallScreen ? 16 : 20,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeroSection(bool isSmallScreen, bool isMediumScreen) {
    return Container(
      color: Colors.blue,
      child: Stack(
        fit: StackFit.passthrough,
        children: [
          // ✅ RepaintBoundary ile optimize edildi
          RepaintBoundary(
            child: Image.asset(
              "assets/pr1.png",
              fit: BoxFit.cover,
              gaplessPlayback: true,
              cacheWidth: MediaQuery.of(context).size.width.toInt() * 2, // ✅ Cache optimize
            ),
          ),
          if (!isSmallScreen)
            Positioned(
              left: isMediumScreen ? 300 : 600,
              bottom: 180,
              child: ClipRRect(
                borderRadius: BorderRadius.circular(35),
                child: BackdropFilter(
                  filter: ImageFilter.blur(sigmaX: 25, sigmaY: 25),
                  child: Container(
                    width: isMediumScreen ? 450 : 650,
                    height: 575,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [
                          Colors.white.withOpacity(0.12),
                          Colors.white.withOpacity(0.08),
                        ],
                      ),
                      borderRadius: BorderRadius.circular(35),
                      border: Border.all(
                        color: Colors.white.withOpacity(0.25),
                        width: 1.5,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.15),
                          blurRadius: 30,
                          offset: Offset(0, 10),
                        ),
                      ],
                    ),
                    child: Padding(
                      padding: EdgeInsets.symmetric(horizontal: isMediumScreen ? 35 : 50, vertical: 60),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Master the Bocconi Online English Test With Smart, Targeted Practice',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: isMediumScreen ? 32 : 42,
                              fontWeight: FontWeight.w700,
                              height: 1.3,
                              letterSpacing: -1,
                            ),
                          ),
                          SizedBox(height: 30),
                          Text(
                            'Your Complete Preparation Hub for the Bocconi English Exam',
                            style: TextStyle(
                              color: Colors.white.withOpacity(0.85),
                              fontSize: isMediumScreen ? 16 : 20,
                              fontWeight: FontWeight.w500,
                              height: 1.5,
                            ),
                          ),
                          SizedBox(height: 25),
                          Text(
                            'Prepare Smarter. Score Higher.\nJoin the Bocconi English Success Path.',
                            style: TextStyle(
                              color: Colors.white.withOpacity(0.75),
                              fontSize: isMediumScreen ? 15 : 18,
                              fontWeight: FontWeight.w400,
                              height: 1.6,
                            ),
                          ),
                          SizedBox(height: 40),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Container(
                                height: 2,
                                width: 60,
                                color: Colors.white.withOpacity(0.4),
                              ),
                              SizedBox(height: 15),
                              Text(
                                'PRACTICO MAKES PERFECT',
                                style: GoogleFonts.kalam(
                                  fontSize: isMediumScreen ? 20 : 24,
                                  fontWeight: FontWeight.bold,
                                  color: MyColors.cyan2,
                                ),
                              )
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          if (isSmallScreen)
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: Container(
                margin: EdgeInsets.all(20),
                padding: EdgeInsets.all(30),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      Colors.white.withOpacity(0.12),
                      Colors.white.withOpacity(0.08),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(25),
                  border: Border.all(
                    color: Colors.white.withOpacity(0.25),
                    width: 1.5,
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Master the Bocconi Online English Test',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 24,
                        fontWeight: FontWeight.w700,
                        height: 1.3,
                      ),
                    ),
                    SizedBox(height: 15),
                    Text(
                      'Your Complete Preparation Hub',
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.85),
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildPricingSection(bool isSmallScreen, bool isMediumScreen) {
    final days = _remainingTime.inDays;
    final hours = _remainingTime.inHours % 24;
    final minutes = _remainingTime.inMinutes % 60;
    final seconds = _remainingTime.inSeconds % 60;

    return Container(
      height: isSmallScreen ? 490 : 620,
      color: MyColors.cyan2,
      child: Center(
        child: Padding(
          padding: EdgeInsets.symmetric(
            horizontal: isSmallScreen ? 20 : 40,
            vertical: 20,
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      Colors.red.shade400,
                      Colors.red.shade600,
                    ],
                  ),
                  borderRadius: BorderRadius.circular(30),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.red.withOpacity(0.3),
                      blurRadius: 15,
                      offset: Offset(0, 5),
                    ),
                  ],
                ),
                child: Text(
                  '🔥 LIMITED TIME OFFER',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: isSmallScreen ? 12 : 14,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 1.2,
                  ),
                ),
              ),
              SizedBox(height: 18),
              Container(
                padding: EdgeInsets.symmetric(
                  horizontal: isSmallScreen ? 16 : 24,
                  vertical: isSmallScreen ? 12 : 16,
                ),
                decoration: BoxDecoration(
                  color: Colors.black.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(15),
                  border: Border.all(
                    color: Colors.white.withOpacity(0.3),
                    width: 1.5,
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.timer,
                      color: Colors.white,
                      size: isSmallScreen ? 18 : 22,
                    ),
                    SizedBox(width: 10),
                    Text(
                      'Last ',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: isSmallScreen ? 14 : 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    Text(
                      '$days',
                      style: TextStyle(
                        color: Colors.amber,
                        fontSize: isSmallScreen ? 18 : 22,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    Text(
                      ' days ',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: isSmallScreen ? 14 : 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    Text(
                      '$hours:${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}',
                      style: TextStyle(
                        color: Colors.amber,
                        fontSize: isSmallScreen ? 16 : 20,
                        fontWeight: FontWeight.w900,
                        fontFeatures: [FontFeature.tabularFigures()],
                      ),
                    ),
                    Text(
                      ' for discount!',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: isSmallScreen ? 14 : 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(height: 20),
              Text(
                'One Price, Everything Included',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: isSmallScreen ? 20 : 32,
                  fontWeight: FontWeight.w800,
                  letterSpacing: -1,
                ),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 8),
              Container(
                height: 2.5,
                width: 50,
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.6),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              SizedBox(height: 25),
              Container(
                constraints: BoxConstraints(
                  maxWidth: isSmallScreen ? double.infinity : 800,
                ),
                padding: EdgeInsets.symmetric(
                  horizontal: isSmallScreen ? 20 : 40,
                  vertical: isSmallScreen ? 20 : 28,
                ),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 25,
                      offset: Offset(0, 10),
                    ),
                  ],
                ),
                child: isSmallScreen
                    ? Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          '€99.99',
                          style: TextStyle(
                            color: Colors.red.withOpacity(0.6),
                            fontSize: 24,
                            fontWeight: FontWeight.w700,
                            decoration: TextDecoration.lineThrough,
                            decorationColor: Colors.red,
                            decorationThickness: 2.5,
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 10),
                    Text(
                      '€79.99',
                      style: TextStyle(
                        color: Colors.green.shade700,
                        fontSize: 42,
                        fontWeight: FontWeight.w900,
                        letterSpacing: -1,
                        height: 1,
                      ),
                    ),
                    SizedBox(height: 6),
                    Container(
                      padding: EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.green.shade100,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        'SAVE €20',
                        style: TextStyle(
                          color: Colors.green.shade700,
                          fontSize: 12,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ),
                    SizedBox(height: 8),
                    Text(
                      'Complete Access',
                      style: TextStyle(
                        color: Colors.black.withOpacity(0.6),
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    SizedBox(height: 20),
                    Wrap(
                      alignment: WrapAlignment.center,
                      spacing: 8,
                      runSpacing: 8,
                      children: [
                        _buildFeatureChip('1000+ Questions', isSmallScreen),
                        _buildFeatureChip('50+ Tests', isSmallScreen),
                        _buildFeatureChip('5 Exams', isSmallScreen),
                      ],
                    ),
                  ],
                )
                    : Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Column(
                      children: [
                        Text(
                          '€99.99',
                          style: TextStyle(
                            color: Colors.red.withOpacity(0.6),
                            fontSize: 28,
                            fontWeight: FontWeight.w700,
                            decoration: TextDecoration.lineThrough,
                            decorationColor: Colors.red,
                            decorationThickness: 3,
                          ),
                        ),
                        SizedBox(height: 8),
                        Text(
                          '€79.99',
                          style: TextStyle(
                            color: Colors.green.shade700,
                            fontSize: 52,
                            fontWeight: FontWeight.w900,
                            letterSpacing: -1.5,
                            height: 1,
                          ),
                        ),
                        SizedBox(height: 10),
                        Container(
                          padding: EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                          decoration: BoxDecoration(
                            color: Colors.green.shade100,
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Text(
                            'SAVE €20',
                            style: TextStyle(
                              color: Colors.green.shade700,
                              fontSize: 14,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                        ),
                        SizedBox(height: 8),
                        Text(
                          'Complete Access',
                          style: TextStyle(
                            color: Colors.black.withOpacity(0.6),
                            fontSize: 15,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                    SizedBox(width: 50),
                    Container(
                      height: 120,
                      width: 2,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [
                            Colors.green.shade700.withOpacity(0.5),
                            Colors.green.shade700.withOpacity(0.1),
                          ],
                        ),
                      ),
                    ),
                    SizedBox(width: 50),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildFeatureChip('1000+ Questions', isSmallScreen),
                        SizedBox(height: 10),
                        _buildFeatureChip('50+ Tests', isSmallScreen),
                        SizedBox(height: 10),
                        _buildFeatureChip('5 Practice Exams', isSmallScreen),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFeatureChip(String text, bool isSmallScreen) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: isSmallScreen ? 10 : 14,
        vertical: isSmallScreen ? 6 : 8,
      ),
      decoration: BoxDecoration(
        color: MyColors.cyan2.withOpacity(0.1),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: MyColors.cyan2.withOpacity(0.3),
          width: 1,
        ),
      ),
      child: Text(
        '✓ $text',
        style: TextStyle(
          color: MyColors.cyan2,
          fontSize: isSmallScreen ? 12 : 14,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  Widget _buildPricingFeatureRow(String icon, String text, bool isSmallScreen) {
    return Row(
      children: [
        Container(
          width: isSmallScreen ? 28 : 32,
          height: isSmallScreen ? 28 : 32,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                MyColors.cyan.withOpacity(0.3),
                Colors.green.withOpacity(0.2),
              ],
            ),
            shape: BoxShape.circle,
            border: Border.all(
              color: MyColors.cyan.withOpacity(0.5),
              width: 1.5,
            ),
          ),
          child: Center(
            child: Text(
              icon,
              style: TextStyle(
                color: MyColors.cyan,
                fontSize: isSmallScreen ? 14 : 16,
                fontWeight: FontWeight.w900,
              ),
            ),
          ),
        ),
        SizedBox(width: 15),
        Expanded(
          child: Text(
            text,
            style: TextStyle(
              color: Colors.white.withOpacity(0.9),
              fontSize: isSmallScreen ? 15 : 17,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildInfoSection1(bool isSmallScreen, bool isMediumScreen) {
    return Container(
      color: Colors.black,
      child: Stack(
        fit: StackFit.passthrough,
        children: [
          RepaintBoundary(
            child: Image.asset(
              "assets/info1.png",
              fit: BoxFit.cover,
              gaplessPlayback: true,
              cacheWidth: MediaQuery.of(context).size.width.toInt() * 2,
            ),
          ),
          if (!isSmallScreen) ...[
            Positioned(
              right: 150,
              bottom: 180,
              child: _buildNumbersCard(isMediumScreen),
            ),
            Positioned(
              right: isMediumScreen ? 300 : 600,
              bottom: 180,
              child: _buildContentCard(isMediumScreen),
            ),
          ],
          if (isSmallScreen)
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: Container(
                margin: EdgeInsets.all(20),
                padding: EdgeInsets.all(25),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      Colors.white.withOpacity(0.12),
                      Colors.white.withOpacity(0.08),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(25),
                  border: Border.all(
                    color: Colors.white.withOpacity(0.25),
                    width: 1.5,
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Text(
                      'By the Numbers',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 22,
                        fontWeight: FontWeight.w800,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    SizedBox(height: 20),
                    _buildStatItem('1000+', 'Questions', MyColors.cyan),
                    SizedBox(height: 12),
                    _buildStatItem('50+', 'Tests', Colors.amber.shade200),
                    SizedBox(height: 12),
                    _buildStatItem('4', 'Exams', Colors.green.shade200),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }Widget _buildNumbersCard(bool isMediumScreen) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(35),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 25, sigmaY: 25),
        child: Container(
          width: isMediumScreen ? 280 : 320,
          height: 575,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Colors.white.withOpacity(0.12),
                Colors.white.withOpacity(0.08),
              ],
            ),
            borderRadius: BorderRadius.circular(35),
            border: Border.all(
              color: Colors.white.withOpacity(0.25),
              width: 1.5,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.15),
                blurRadius: 30,
                offset: Offset(0, 10),
              ),
            ],
          ),
          child: Padding(
            padding: EdgeInsets.all(30),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Container(
                  padding: EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        MyColors.cyan.withOpacity(0.3),
                        Colors.blue.withOpacity(0.2),
                      ],
                    ),
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: MyColors.cyan.withOpacity(0.5),
                      width: 2,
                    ),
                  ),
                  child: Text(
                    '📊',
                    style: TextStyle(fontSize: isMediumScreen ? 40 : 50),
                  ),
                ),
                SizedBox(height: 35),
                Text(
                  'By the Numbers',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: isMediumScreen ? 24 : 28,
                    fontWeight: FontWeight.w800,
                    height: 1.2,
                  ),
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: 30),
                _buildStatItem('1000+', 'Total Questions', MyColors.cyan),
                SizedBox(height: 20),
                _buildStatItem('50+', 'Subject Tests', Colors.amber.shade200),
                SizedBox(height: 20),
                _buildStatItem('5', 'Practice Exams', Colors.green.shade200),
                SizedBox(height: 20),
                _buildStatItem('5', 'Different Subjects', Colors.purple.shade200),
                SizedBox(height: 30),
                Container(
                  height: 2,
                  width: 80,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        MyColors.cyan,
                        Colors.blue,
                      ],
                    ),
                    borderRadius: BorderRadius.circular(1),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildContentCard(bool isMediumScreen) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(35),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 25, sigmaY: 25),
        child: Container(
          width: isMediumScreen ? 450 : 650,
          height: 575,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Colors.white.withOpacity(0.12),
                Colors.white.withOpacity(0.08),
              ],
            ),
            borderRadius: BorderRadius.circular(35),
            border: Border.all(
              color: Colors.white.withOpacity(0.25),
              width: 1.5,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.15),
                blurRadius: 30,
                offset: Offset(0, 10),
              ),
            ],
          ),
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: isMediumScreen ? 35 : 50, vertical: 60),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Great Content and Practice',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: isMediumScreen ? 32 : 42,
                    fontWeight: FontWeight.w700,
                    height: 1.3,
                    letterSpacing: -1,
                  ),
                ),
                SizedBox(height: 40),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '🏆',
                      style: TextStyle(fontSize: isMediumScreen ? 28 : 32),
                    ),
                    SizedBox(width: 20),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Big Question Pool:',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: isMediumScreen ? 19 : 22,
                              fontWeight: FontWeight.w600,
                              height: 1.4,
                            ),
                          ),
                          SizedBox(height: 10),
                          Text(
                            'Our platform has over 1000 original and current questions that match the real Online Bocconi Test format. This big pool makes sure you are ready for every possible question type on the exam.',
                            style: TextStyle(
                              color: Colors.white.withOpacity(0.85),
                              fontSize: isMediumScreen ? 15 : 18,
                              fontWeight: FontWeight.w400,
                              height: 1.6,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 35),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '🔄',
                      style: TextStyle(fontSize: isMediumScreen ? 28 : 32),
                    ),
                    SizedBox(width: 20),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Always New Questions:',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: isMediumScreen ? 19 : 22,
                              fontWeight: FontWeight.w600,
                              height: 1.4,
                            ),
                          ),
                          SizedBox(height: 10),
                          Text(
                            'Our question bank keeps changing. We add new questions often. Even if you sign up early, you still get new practice materials as the exam gets closer.',
                            style: TextStyle(
                              color: Colors.white.withOpacity(0.85),
                              fontSize: isMediumScreen ? 15 : 18,
                              fontWeight: FontWeight.w400,
                              height: 1.6,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildPersonalizedSection(bool isSmallScreen, bool isMediumScreen) {
    return Container(
      constraints: BoxConstraints(
        minHeight: isSmallScreen ? 650 : (isMediumScreen ? 800 : 900),
      ),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            MyColors.cyan,
            MyColors.cyan.withOpacity(0.8),
            MyColors.cyan.withOpacity(0.6),
            MyColors.cyan.withOpacity(0.3),
            Colors.black.withOpacity(0.5),
            Colors.black.withOpacity(0.8),
            Colors.black,
          ],
          stops: [0.0, 0.3, 0.5, 0.65, 0.75, 0.85, 1.0],
        ),
      ),
      child: SingleChildScrollView(
        physics: NeverScrollableScrollPhysics(),
        child: Padding(
          padding: EdgeInsets.symmetric(
            horizontal: isSmallScreen ? 20 : (isMediumScreen ? 60 : 120),
            vertical: isSmallScreen ? 40 : (isMediumScreen ? 70 : 100),
          ),
          child: isSmallScreen
              ? Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(30),
                ),
                child: Text(
                  '✨ PERSONALIZED LEARNING',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    letterSpacing: 1.2,
                  ),
                ),
              ),
              SizedBox(height: 20),
              Text(
                'Smart Learning Made Just for You',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 28,
                  fontWeight: FontWeight.w800,
                  height: 1.15,
                  letterSpacing: -1.5,
                ),
              ),
              SizedBox(height: 15),
              Container(
                height: 3,
                width: 70,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      Colors.white,
                      Colors.white.withOpacity(0.3),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              SizedBox(height: 20),
              Text(
                'Experience targeted preparation designed specifically for the Bocconi English Test',
                style: TextStyle(
                  color: Colors.white.withOpacity(0.9),
                  fontSize: 15,
                  fontWeight: FontWeight.w400,
                  height: 1.6,
                ),
              ),
              SizedBox(height: 30),
              _buildFeatureCard(
                '🔬',
                'Only for the Bocconi Test',
                'Our app is different from general English tests. It is made only to copy the structure and difficulty of the Bocconi Online English Test.',
              ),
              SizedBox(height: 18),
              _buildFeatureCard(
                '📈',
                'Steps from Easy to Hard',
                'We have a study path for everyone, from beginners to students aiming for the top score.',
              ),
              SizedBox(height: 18),
              _buildFeatureCard(
                '📚',
                'Tests for Every Topic',
                'We have special test sets for every skill and grammar topic on the exam.',
              ),
            ],
          )
              : Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Expanded(
                flex: 5,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(30),
                      ),
                      child: Text(
                        '✨ PERSONALIZED LEARNING',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          letterSpacing: 1.2,
                        ),
                      ),
                    ),
                    SizedBox(height: 30),
                    Text(
                      'Smart Learning\nMade Just for You',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: isMediumScreen ? 42 : 56,
                        fontWeight: FontWeight.w800,
                        height: 1.15,
                        letterSpacing: -2,
                      ),
                    ),
                    SizedBox(height: 25),
                    Container(
                      height: 4,
                      width: 100,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            Colors.white,
                            Colors.white.withOpacity(0.3),
                          ],
                        ),
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                    SizedBox(height: 35),
                    Text(
                      'Experience targeted preparation designed specifically for the Bocconi English Test',
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.9),
                        fontSize: isMediumScreen ? 17 : 20,
                        fontWeight: FontWeight.w400,
                        height: 1.6,
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(width: isMediumScreen ? 50 : 80),
              Expanded(
                flex: 5,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    _buildFeatureCard(
                      '🔬',
                      'Only for the Bocconi Test',
                      'Our app is different from general English tests. It is made only to copy the structure and difficulty of the Bocconi Online English Test. Every time you study here, you are getting closer to passing the real exam.',
                    ),
                    SizedBox(height: 25),
                    _buildFeatureCard(
                      '📈',
                      'Steps from Easy to Hard',
                      'We have a study path for everyone, from beginners to students aiming for the top score. Questions start easy and get harder slowly. This helps you learn the basics first, then easily move to the hard level of the exam.',
                    ),
                    SizedBox(height: 25),
                    _buildFeatureCard(
                      '📚',
                      'Tests for Every Topic',
                      'We have special test sets for every skill and grammar topic on the exam. You can focus exactly on the areas where you are weak and practice until you are strong.',
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFeatureCard(String emoji, String title, String description) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isSmallScreen = screenWidth < 900;

    return Container(
      padding: EdgeInsets.all(isSmallScreen ? 18 : 28),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 20,
            offset: Offset(0, 10),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: EdgeInsets.all(isSmallScreen ? 8 : 12),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  MyColors.cyan.withOpacity(0.2),
                  MyColors.cyan.withOpacity(0.1),
                ],
              ),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              emoji,
              style: TextStyle(fontSize: isSmallScreen ? 22 : 26),
            ),
          ),
          SizedBox(width: isSmallScreen ? 12 : 18),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    color: Colors.black87,
                    fontSize: isSmallScreen ? 16 : 19,
                    fontWeight: FontWeight.w700,
                    height: 1.3,
                  ),
                ),
                SizedBox(height: 8),
                Text(
                  description,
                  style: TextStyle(
                    color: Colors.black.withOpacity(0.65),
                    fontSize: isSmallScreen ? 13 : 15,
                    fontWeight: FontWeight.w400,
                    height: 1.5,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStrategySection(bool isSmallScreen, bool isMediumScreen) {
    return Container(
      color: Colors.black,
      child: Stack(
        fit: StackFit.passthrough,
        children: [
          RepaintBoundary(
            child: Image.asset(
              "assets/info2.png",
              fit: BoxFit.cover,
              gaplessPlayback: true,
              cacheWidth: MediaQuery.of(context).size.width.toInt() * 2,
            ),
          ),
          if (!isSmallScreen)
            Positioned(
              right: isMediumScreen ? 300 : 600,
              bottom: 180,
              child: ClipRRect(
                borderRadius: BorderRadius.circular(35),
                child: BackdropFilter(
                  filter: ImageFilter.blur(sigmaX: 25, sigmaY: 25),
                  child: Container(
                    width: isMediumScreen ? 500 : 680,
                    height: 690,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [
                          Colors.white.withOpacity(0.12),
                          Colors.white.withOpacity(0.08),
                        ],
                      ),
                      borderRadius: BorderRadius.circular(35),
                      border: Border.all(
                        color: Colors.white.withOpacity(0.25),
                        width: 1.5,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.15),
                          blurRadius: 30,
                          offset: Offset(0, 10),
                        ),
                      ],
                    ),
                    child: Padding(
                      padding: EdgeInsets.symmetric(
                        horizontal: isMediumScreen ? 40 : 50,
                        vertical: 60,
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                colors: [
                                  Colors.amber.withOpacity(0.3),
                                  Colors.orange.withOpacity(0.3),
                                ],
                              ),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Text(
                              '💡 SMART STRATEGY',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 13,
                                fontWeight: FontWeight.w700,
                                letterSpacing: 1.5,
                              ),
                            ),
                          ),
                          SizedBox(height: 25),
                          Text(
                            'Smart Strategy and\nLearning Tips',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: isMediumScreen ? 36 : 44,
                              fontWeight: FontWeight.w800,
                              height: 1.2,
                              letterSpacing: -1.5,
                            ),
                          ),
                          SizedBox(height: 35),
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Container(
                                padding: EdgeInsets.all(10),
                                decoration: BoxDecoration(
                                  color: Colors.white.withOpacity(0.15),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Text(
                                  '🧠',
                                  style: TextStyle(fontSize: isMediumScreen ? 22 : 26),
                                ),
                              ),
                              SizedBox(width: 18),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'BOET Strategy Workshop',
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontSize: isMediumScreen ? 18 : 21,
                                        fontWeight: FontWeight.w700,
                                        height: 1.3,
                                      ),
                                    ),
                                    SizedBox(height: 8),
                                    Text(
                                      'Don\'t Just Solve, Learn How to Win',
                                      style: TextStyle(
                                        color: Colors.amber.shade300,
                                        fontSize: isMediumScreen ? 14 : 16,
                                        fontWeight: FontWeight.w600,
                                        fontStyle: FontStyle.italic,
                                      ),
                                    ),
                                    SizedBox(height: 10),
                                    Text(
                                      'Before you start solving tests, you can strengthen your knowledge with tactics, sample solutions, and lessons for every single topic. This helps you learn how to get the right answer, so you save time during the exam and get a big advantage.',
                                      style: TextStyle(
                                        color: Colors.white.withOpacity(0.85),
                                        fontSize: isMediumScreen ? 14 : 16,
                                        fontWeight: FontWeight.w400,
                                        height: 1.6,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                          SizedBox(height: 28),
                          Container(
                            height: 1,
                            color: Colors.white.withOpacity(0.2),
                          ),
                          SizedBox(height: 28),
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Container(
                                padding: EdgeInsets.all(10),
                                decoration: BoxDecoration(
                                  color: Colors.white.withOpacity(0.15),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Text(
                                  '🎯',
                                  style: TextStyle(fontSize: isMediumScreen ? 22 : 26),
                                ),
                              ),
                              SizedBox(width: 18),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'More Than Just an App',
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontSize: isMediumScreen ? 18 : 21,
                                        fontWeight: FontWeight.w700,
                                        height: 1.3,
                                      ),
                                    ),
                                    SizedBox(height: 10),
                                    Text(
                                      'The platform is not just a tool to solve questions. It\'s your study assistant in your pocket, giving you constant updates, strategy tips, and lessons.',
                                      style: TextStyle(
                                        color: Colors.white.withOpacity(0.85),
                                        fontSize: isMediumScreen ? 14 : 16,
                                        fontWeight: FontWeight.w400,
                                        height: 1.6,
                                      ),
                                    ),
                                  ],
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
            ),
          if (isSmallScreen)
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: Container(
                margin: EdgeInsets.all(20),
                padding: EdgeInsets.all(25),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      Colors.white.withOpacity(0.12),
                      Colors.white.withOpacity(0.08),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(25),
                  border: Border.all(
                    color: Colors.white.withOpacity(0.25),
                    width: 1.5,
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Smart Strategy',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 24,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    SizedBox(height: 15),
                    Text(
                      'Learn tactics and strategies for every topic',
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.85),
                        fontSize: 16,
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }Widget _buildTestimonialsSection(bool isSmallScreen, bool isMediumScreen) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Colors.black,
            Colors.black.withOpacity(0.95),
            Color(0xFF1a1a2e),
          ],
        ),
      ),
      child: Padding(
        padding: EdgeInsets.symmetric(
          horizontal: isSmallScreen ? 20 : (isMediumScreen ? 60 : 100),
          vertical: isSmallScreen ? 50 : 80,
        ),
        child: Column(
          children: [
            Column(
              children: [
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        MyColors.cyan.withOpacity(0.3),
                        Colors.blue.withOpacity(0.3),
                      ],
                    ),
                    borderRadius: BorderRadius.circular(30),
                    border: Border.all(
                      color: MyColors.cyan.withOpacity(0.5),
                      width: 1,
                    ),
                  ),
                  child: Text(
                    '💬 STUDENT VOICES',
                    style: TextStyle(
                      color: MyColors.cyan,
                      fontSize: isSmallScreen ? 11 : 13,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 1.5,
                    ),
                  ),
                ),
                SizedBox(height: 25),
                Text(
                  'What Our Users Say',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: isSmallScreen ? 28 : (isMediumScreen ? 36 : 42),
                    fontWeight: FontWeight.w800,
                    letterSpacing: -1.5,
                  ),
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: 15),
                Container(
                  height: 3,
                  width: 70,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        MyColors.cyan,
                        Colors.blue,
                      ],
                    ),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ],
            ),
            SizedBox(height: isSmallScreen ? 40 : 60),
            Column(
              children: [
                _buildTestimonialCard(
                  '"My stress on exam day was zero! The practice tests were exactly like the real Bocconi format. It felt like taking another practice test at home. It\'s definitely a must-have practice tool."',
                ),
                SizedBox(height: 25),
                _buildTestimonialCard(
                  '"Over 1000 questions and constant updates. This is clearly the most complete and up-to-date Bocconi resource out there. I started in 11th grade, and this resource will help me for a long time."',
                ),
                SizedBox(height: 25),
                _buildTestimonialCard(
                  '"If you are aiming for a high score, the super realistic hard level here will save you. Other platforms felt too easy. I went into the real exam ready for the hardest situation."',
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildContactSection(bool isSmallScreen, bool isMediumScreen) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Color(0xFF1a1a2e),
            Color(0xFF16213e),
            Colors.black,
          ],
        ),
      ),
      child: Padding(
        padding: EdgeInsets.symmetric(
          horizontal: isSmallScreen ? 20 : (isMediumScreen ? 60 : 100),
          vertical: isSmallScreen ? 50 : 80,
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SizedBox(height: 10),
            Text(
              'Contact Information',
              style: TextStyle(
                color: Colors.white,
                fontSize: isSmallScreen ? 32 : (isMediumScreen ? 40 : 48),
                fontWeight: FontWeight.w800,
                letterSpacing: -1.5,
              ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 15),
            Container(
              height: 3,
              width: 70,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    MyColors.cyan,
                    Colors.blue,
                  ],
                ),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            SizedBox(height: 40),
            Text(
              'Have questions or need support?',
              style: TextStyle(
                color: Colors.white.withOpacity(0.8),
                fontSize: isSmallScreen ? 16 : 18,
                fontWeight: FontWeight.w400,
                height: 1.6,
              ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 10),
            Text(
              'We\'re here to help you succeed!',
              style: TextStyle(
                color: Colors.white.withOpacity(0.8),
                fontSize: isSmallScreen ? 16 : 18,
                fontWeight: FontWeight.w400,
                height: 1.6,
              ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 50),
            Container(
              constraints: BoxConstraints(maxWidth: 500),
              padding: EdgeInsets.symmetric(
                horizontal: isSmallScreen ? 30 : 40,
                vertical: isSmallScreen ? 25 : 30,
              ),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    Colors.white.withOpacity(0.08),
                    Colors.white.withOpacity(0.04),
                  ],
                ),
                borderRadius: BorderRadius.circular(25),
                border: Border.all(
                  color: MyColors.cyan.withOpacity(0.3),
                  width: 1.5,
                ),
                boxShadow: [
                  BoxShadow(
                    color: MyColors.cyan.withOpacity(0.15),
                    blurRadius: 30,
                    offset: Offset(0, 15),
                  ),
                ],
              ),
              child: Column(
                children: [
                  Icon(
                    Icons.email_outlined,
                    color: MyColors.cyan,
                    size: isSmallScreen ? 40 : 48,
                  ),
                  SizedBox(height: 20),
                  Text(
                    'Email Us',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: isSmallScreen ? 20 : 22,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  SizedBox(height: 15),
                  SelectableText(
                    'practico.testing@gmail.com',
                    style: TextStyle(
                      color: MyColors.cyan,
                      fontSize: isSmallScreen ? 16 : 20,
                      fontWeight: FontWeight.w600,
                      letterSpacing: 0.5,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPaymentNetworksSection(bool isSmallScreen, bool isMediumScreen) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Color(0xFF0a0a0a),
            MyColors.gradient1,
            MyColors.gradient2
          ],
        ),
      ),
      padding: EdgeInsets.symmetric(
        horizontal: isSmallScreen ? 20 : (isMediumScreen ? 60 : 100),
        vertical: isSmallScreen ? 40 : 60,
      ),
      child: Center(
        child: Container(
          constraints: BoxConstraints(
            maxWidth: isSmallScreen ? double.infinity : 900,
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Expanded(
                flex: 2,
                child: Padding(
                  padding: EdgeInsets.symmetric(horizontal: isSmallScreen ? 8 : 20),
                  child: Image.asset(
                    'assets/paymentNetworks/pay_with_iyzico_horizontal_colored.png',
                    height: isSmallScreen ? 35 : 50,
                    fit: BoxFit.contain,
                  ),
                ),
              ),
              Expanded(
                child: Padding(
                  padding: EdgeInsets.symmetric(horizontal: isSmallScreen ? 8 : 15),
                  child: Image.asset(
                    'assets/paymentNetworks/Mastercard-logo.png',
                    height: isSmallScreen ? 50 : 67,
                    fit: BoxFit.contain,
                  ),
                ),
              ),
              Expanded(
                child: Padding(
                  padding: EdgeInsets.symmetric(horizontal: isSmallScreen ? 8 : 15),
                  child: Image.asset(
                    'assets/paymentNetworks/visa.png',
                    height: isSmallScreen ? 30 : 45,
                    fit: BoxFit.contain,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFooterSection(bool isSmallScreen, bool isMediumScreen) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Colors.black,
            Color(0xFF0a0a0a),
          ],
        ),
      ),
      child: Padding(
        padding: EdgeInsets.symmetric(
          horizontal: isSmallScreen ? 20 : (isMediumScreen ? 60 : 100),
          vertical: isSmallScreen ? 40 : 60,
        ),
        child: Column(
          children: [
            SizedBox(height: 25),
            Text(
              'Terms & Policies',
              style: TextStyle(
                color: Colors.white,
                fontSize: isSmallScreen ? 28 : (isMediumScreen ? 36 : 42),
                fontWeight: FontWeight.w800,
                letterSpacing: -1.5,
              ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 15),
            Container(
              height: 3,
              width: 70,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    MyColors.cyan,
                    Colors.blue,
                  ],
                ),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            SizedBox(height: 50),
            isSmallScreen
                ? Column(
              children: [
                _buildLegalButton(
                  context,
                  'Terms of Service',
                  Icons.description_outlined,
                  '/terms',
                ),
                SizedBox(height: 15),
                _buildLegalButton(
                  context,
                  'Privacy Policy',
                  Icons.privacy_tip_outlined,
                  '/privacy',
                ),
                SizedBox(height: 15),
                _buildLegalButton(
                  context,
                  'Distance Sales Agreement',
                  Icons.assignment_outlined,
                  '/distance_sales_agreement',
                ),
              ],
            )
                : Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _buildLegalButton(
                  context,
                  'Terms of Service',
                  Icons.description_outlined,
                  '/terms',
                ),
                SizedBox(width: 20),
                _buildLegalButton(
                  context,
                  'Privacy Policy',
                  Icons.privacy_tip_outlined,
                  '/privacy',
                ),
                SizedBox(width: 20),
                _buildLegalButton(
                  context,
                  'Distance Sales Agreement',
                  Icons.assignment_outlined,
                  '/distance_sales_agreement',
                ),
              ],
            ),
            SizedBox(height: 40),
            Text(
              '© 2025 PractiCo. All rights reserved.',
              style: TextStyle(
                color: Colors.white.withOpacity(0.5),
                fontSize: isSmallScreen ? 12 : 14,
                fontWeight: FontWeight.w400,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(double screenHeight, bool isSmallScreen, bool isMediumScreen) {
    return Positioned(
      top: 0,
      left: 0,
      right: 0,
      child: GestureDetector(
        onTap: _toggleCollapse,
        child: AnimatedBuilder(
          animation: _animationController,
          builder: (context, child) {
            final currentHeight = _heightAnimation.value;

            return Container(
              height: currentHeight,
              width: double.infinity,
              clipBehavior: Clip.hardEdge,
              decoration: const BoxDecoration(),
              child: Stack(
                children: [
                  Positioned(
                    bottom: 0,
                    left: 0,
                    right: 0,
                    child: RepaintBoundary(
                      child: Image.asset(
                        MediaQuery.of(context).size.width < 600
                            ? "assets/lat.png"
                            : "assets/practico.png",
                        fit: BoxFit.cover,
                        width: double.infinity,
                        height: screenHeight,
                        alignment: Alignment.bottomCenter,
                        cacheWidth: MediaQuery.of(context).size.width.toInt() * 2,
                      ),
                    ),
                  ),
                  Positioned(
                    bottom: 80,
                    left: 0,
                    right: 0,
                    child: Opacity(
                      opacity: _arrowOpacity,
                      child: Center(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Container(
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: Colors.white.withOpacity(0.2),
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(
                                Icons.keyboard_arrow_down,
                                size: 40,
                                color: Colors.white,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  Positioned.fill(
                    child: Opacity(
                      opacity: _buttonOpacity,
                      child: SafeArea(
                        child: Padding(
                          padding: EdgeInsets.symmetric(
                            horizontal: isSmallScreen ? 10 : 16,
                            vertical: 10,
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Flexible(
                                child: SingleChildScrollView(
                                  scrollDirection: Axis.horizontal,
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      SizedBox(width: isSmallScreen ? 8 : 16),
                                      Text(
                                        "PractiCo",
                                        style: GoogleFonts.ramabhadra(
                                          color: MyColors.white,
                                          fontSize: isSmallScreen ? 26 : (isMediumScreen ? 30 : 33),
                                        ),
                                      ),
                                      SizedBox(width: isSmallScreen ? 20 : (isMediumScreen ? 40 : 65)),
                                      _buildButton(
                                            () => Navigator.pushNamed(context, '/app'),
                                        isSmallScreen ? 'Login' : 'Start Studying / Login',
                                        Colors.white,
                                        Colors.blue.shade700,
                                        Icons.school,
                                        isSmallScreen: isSmallScreen,
                                      ),
                                      SizedBox(width: isSmallScreen ? 8 : 14),
                                      _buildButton(
                                            () => Navigator.pushNamed(context, '/signup'),
                                        'Sign Up',
                                        Colors.green.shade600,
                                        Colors.white,
                                        Icons.person_add,
                                        isSmallScreen: isSmallScreen,
                                      ),
                                      SizedBox(width: isSmallScreen ? 8 : 14),

                                      _buildButton(
                                            () => Navigator.pushNamed(context, '/free-trial'),
                                        'Try Free',
                                        Colors.amber,
                                        Colors.black87,
                                        Icons.star,
                                        isSmallScreen: isSmallScreen,
                                      ),SizedBox(width: isSmallScreen ? 8 : 14),
                                      Container(
                                        decoration: BoxDecoration(
                                          gradient: LinearGradient(
                                            begin: Alignment.topLeft,
                                            end: Alignment.bottomRight,
                                            colors: [
                                              Color(0xFF35107E), // Turuncu
                                              Color(0xFF052546), // Koyu turuncu
                                            ],
                                          ),
                                          borderRadius: BorderRadius.circular(20),
                                          boxShadow: [
                                            BoxShadow(
                                              color: Colors.purple.withOpacity(0.5),
                                              blurRadius: 15,
                                              offset: Offset(0, 6),
                                              spreadRadius: 1,
                                            ),
                                            BoxShadow(
                                              color: Colors.black.withOpacity(0.3),
                                              blurRadius: 10,
                                              offset: Offset(0, 4),
                                            ),
                                          ],
                                          border: Border.all(
                                            color: Colors.white.withOpacity(0.3),
                                            width: 1.5,
                                          ),
                                        ),
                                        child: ElevatedButton.icon(
                                          onPressed: () =>  Navigator.pushNamed(context, '/tili'),
                                          icon: Icon(Icons.lightbulb, size: isSmallScreen ? 16 : 22),
                                          label: Text(
                                            'TIL-I Exam',
                                            style: TextStyle(
                                              fontSize: isSmallScreen ? 13 : 18,
                                              fontWeight: FontWeight.w700,
                                              letterSpacing: 1.2,
                                            ),
                                          ),
                                          style: ElevatedButton.styleFrom(
                                            backgroundColor: Colors.transparent,
                                            foregroundColor: Colors.white,
                                            padding: EdgeInsets.symmetric(
                                              horizontal: isSmallScreen ? 14 : 24,
                                              vertical: isSmallScreen ? 10 : 14,
                                            ),
                                            shape: RoundedRectangleBorder(
                                              borderRadius: BorderRadius.circular(20),
                                            ),
                                            elevation: 0,
                                            shadowColor: Colors.transparent,
                                          ),
                                        ),
                                      )
                                    ],
                                  ),
                                ),
                              ),
                              _buildInstagramButton(isSmallScreen),
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
      ),
    );
  }

  Widget _buildButton(
      VoidCallback onTap,
      String text,
      Color bgColor,
      Color textColor,
      IconData icon, {
        bool border = false,
        bool isSmallScreen = false,
      }) {
    return ElevatedButton.icon(
      onPressed: onTap,
      icon: Icon(icon, size: isSmallScreen ? 13 : 20),
      label: Text(
        text,
        style: TextStyle(
          fontSize: isSmallScreen ? 11 : 16,
          fontWeight: FontWeight.w500,
        ),
      ),
      style: ElevatedButton.styleFrom(
        backgroundColor: bgColor,
        foregroundColor: textColor,
        padding: EdgeInsets.symmetric(
          horizontal: isSmallScreen ? 10 : 20,
          vertical: isSmallScreen ? 8 : 14,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side: border
              ? const BorderSide(color: Colors.white, width: 2)
              : BorderSide.none,
        ),
        elevation: border ? 0 : 2,
      ),
    );
  }

  Widget _buildTestimonialCard(String testimonial) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isSmallScreen = screenWidth < 900;

    return Container(
      padding: EdgeInsets.all(isSmallScreen ? 20 : 30),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Colors.white.withOpacity(0.05),
            Colors.white.withOpacity(0.02),
          ],
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: MyColors.cyan.withOpacity(0.2),
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: MyColors.cyan.withOpacity(0.1),
            blurRadius: 20,
            offset: Offset(0, 10),
          ),
        ],
      ),
      child: Text(
        testimonial,
        style: TextStyle(
          color: Colors.white.withOpacity(0.9),
          fontSize: isSmallScreen ? 14 : 16,
          fontWeight: FontWeight.w400,
          height: 1.7,
          fontStyle: FontStyle.italic,
        ),
      ),
    );
  }

  Widget _buildStatItem(String number, String label, Color color) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Flexible(
          child: Text(
            label,
            style: TextStyle(
              color: Colors.white.withOpacity(0.9),
              fontSize: 15,
              fontWeight: FontWeight.w500,
            ),
            overflow: TextOverflow.ellipsis,
          ),
        ),
        SizedBox(width: 10),
        Container(
          padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          decoration: BoxDecoration(
            color: color.withOpacity(0.2),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: color.withOpacity(0.4),
              width: 1.5,
            ),
          ),
          child: Text(
            number,
            style: TextStyle(
              color: color,
              fontSize: 20,
              fontWeight: FontWeight.w900,
            ),
          ),
        ),
      ],
    );
  }
}