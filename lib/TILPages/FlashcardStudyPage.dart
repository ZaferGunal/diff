import 'package:flutter/material.dart';
import 'dart:ui';
import 'dart:math';
import 'TILIDashboard.dart';
import '../widgets/theme_toggle.dart';
import '../services/authservice.dart';
import '../models/flashcard.dart';
import '../services/FlashcardProgressService.dart';
import '../UserProvider.dart';
import 'package:provider/provider.dart';
import 'TILMembershipPage.dart';
import 'package:google_fonts/google_fonts.dart';

class FlashcardStudyPage extends StatefulWidget {
  final String subject;
  final VoidCallback toggleTheme;

  const FlashcardStudyPage({
    super.key,
    required this.subject,
    required this.toggleTheme,
  });

  @override
  State<FlashcardStudyPage> createState() => _FlashcardStudyPageState();
}

class _FlashcardStudyPageState extends State<FlashcardStudyPage> with SingleTickerProviderStateMixin {
  final AuthService _authService = AuthService();
  List<Flashcard> _flashcards = [];
  bool _isLoading = true;
  int _currentIndex = 0;
  bool _showFront = true;
  bool _showNameFirst = true;
  bool _isShuffled = false;
  List<int> _shuffledIndices = [];
  
  // Progress states
  final FlashcardProgressService _progressService = FlashcardProgressService();
  Map<String, String> _cardStatuses = {}; // cardId -> status
  String _userEmail = "";

  bool _isSummaryMode = false;
  late AnimationController _flipController;
  late Animation<double> _flipAnimation;

  @override
  void initState() {
    super.initState();
    _loadFlashcards();
    _flipController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    );
    _flipAnimation = Tween<double>(begin: 0, end: pi).animate(_flipController);
  }

  @override
  void dispose() {
    _flipController.dispose();
    super.dispose();
  }

  Future<void> _loadFlashcards() async {
    try {
      final response = widget.subject == "Mixed Study" 
          ? await _authService.getAllFlashcards()
          : await _authService.getFlashcardsBySubject(widget.subject);
          
      if (response.statusCode == 200 && response.data['success']) {
        final List data = response.data['flashcards'];
        final authProvider = Provider.of<AuthProvider>(context, listen: false);
        final bool hasPackage = authProvider.hasTiliPackage;
        _userEmail = authProvider.email ?? "";

        List<Flashcard> loadedCards = data.map((e) => Flashcard.fromJson(e)).toList();
        
        // Load persistent progress
        final progress = await _progressService.getAllProgress(_userEmail);

        setState(() {
          _flashcards = loadedCards;
          _cardStatuses = progress;
          if (widget.subject == "Mixed Study") {
            _flashcards.shuffle();
          }
          _shuffledIndices = List.generate(_flashcards.length, (index) => index);
          _isLoading = false;
        });
      } else {
        setState(() => _isLoading = false);
      }
    } catch (e) {
      print("Error loading flashcards: $e");
      setState(() => _isLoading = false);
    }
  }

  void _updateCardStatus(String cardId, String status) async {
    setState(() {
      if (_cardStatuses[cardId] == status) {
        _cardStatuses.remove(cardId); // Deselect if same
        _progressService.saveProgress(_userEmail, cardId, ""); 
      } else {
        _cardStatuses[cardId] = status;
        _progressService.saveProgress(_userEmail, cardId, status);
      }
    });
  }

  void _flipCard() {
    if (_showFront) {
      _flipController.forward();
    } else {
      _flipController.reverse();
    }
    setState(() {
      _showFront = !_showFront;
    });
  }

  void _nextCard() {
    if (_currentIndex < _flashcards.length - 1) {
      if (!_showFront) {
        _flipController.reverse();
        setState(() => _showFront = true);
      }
      setState(() => _currentIndex++);
    } else {
      // Show summary if at the end
      setState(() => _isSummaryMode = true);
    }
  }

  void _previousCard() {
    if (_currentIndex > 0) {
      if (!_showFront) {
        _flipController.reverse();
        setState(() => _showFront = true);
      }
      setState(() => _currentIndex--);
    }
  }

  void _restartSession() {
    setState(() {
      _currentIndex = 0;
      _isSummaryMode = false;
      _showFront = true;
    });
    _flipController.reset();
  }

  void _toggleShuffle() {
    setState(() {
      _isShuffled = !_isShuffled;
      if (_isShuffled) {
        _shuffledIndices.shuffle();
      } else {
        _shuffledIndices = List.generate(_flashcards.length, (index) => index);
      }
      _currentIndex = 0;
      if (!_showFront) {
        _flipController.reverse();
        _showFront = true;
      }
    });
  }

  // Removed _markAsMastered and _markAsHard in favor of _updateCardStatus

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bg = isDark ? BentoColors.darkBg : BentoColors.lightBg;
    final text = isDark ? BentoColors.darkTextPrimary : BentoColors.lightTextPrimary;
    final cardBg = isDark ? const Color(0xFF1E1E1E) : Colors.white;

    return Scaffold(
      backgroundColor: bg,
      body: Stack(
        children: [
          Positioned(
            top: -200, left: -200,
            child: Container(
              width: 500, height: 500,
              decoration: BoxDecoration(color: Colors.blue.withOpacity(0.05), shape: BoxShape.circle),
              child: BackdropFilter(filter: ImageFilter.blur(sigmaX: 100, sigmaY: 100), child: Container(color: Colors.transparent)),
            ),
          ),
          SafeArea(
            child: Padding(
              padding: EdgeInsets.all(MediaQuery.of(context).size.width < 768 ? 16.0 : 24.0),
              child: Column(
                children: [
                  _buildHeader(text, isDark),
                  const SizedBox(height: 24),
                  _buildProgressBar(text),
                  const SizedBox(height: 24),
                  if (_isLoading)
                    const Expanded(child: Center(child: CircularProgressIndicator()))
                  else if (_flashcards.isEmpty)
                    _buildEmptyState(text)
                  else if (_isSummaryMode)
                    _buildSummaryScreen(text, cardBg, isDark)
                  else
                    _buildCardContent(text, cardBg, isDark),
                  const SizedBox(height: 24),
                  if (_flashcards.isNotEmpty && !_isSummaryMode) _buildFooter(text),
                  const SizedBox(height: 16),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProgressBar(Color text) {
    if (_flashcards.isEmpty) return const SizedBox();
    double progress = (_currentIndex + 1) / _flashcards.length;
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text("Session Progress", style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: text.withOpacity(0.5))),
            Text("${((progress) * 100).toInt()}%", style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: text)),
          ],
        ),
        const SizedBox(height: 8),
        ClipRRect(
          borderRadius: BorderRadius.circular(10),
          child: LinearProgressIndicator(
            value: progress,
            backgroundColor: text.withOpacity(0.05),
            valueColor: AlwaysStoppedAnimation<Color>(Colors.teal.shade400),
            minHeight: 6,
          ),
        ),
      ],
    );
  }

  Widget _buildHeader(Color text, bool isDark) {
    return Row(
      children: [
        IconButton(
          onPressed: () => Navigator.pop(context),
          icon: Icon(Icons.close_rounded, color: text, size: 28),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                widget.subject,
                style: TextStyle(
                  fontSize: MediaQuery.of(context).size.width < 768 ? 20 : 24,
                  fontWeight: FontWeight.bold,
                  color: text,
                  letterSpacing: -0.5,
                ),
              ),
              if (_flashcards.isNotEmpty)
                Text("Card ${_currentIndex + 1} of ${_flashcards.length}", style: TextStyle(fontSize: 13, color: text.withOpacity(0.5), fontWeight: FontWeight.w500)),
            ],
          ),
        ),
        IconButton(
          onPressed: _toggleShuffle,
          tooltip: "Shuffle Cards",
          icon: Icon(_isShuffled ? Icons.shuffle_on_rounded : Icons.shuffle_rounded, color: _isShuffled ? Colors.teal : text.withOpacity(0.7)),
        ),
        IconButton(
          onPressed: () => _showSettingsDialog(isDark, text),
          icon: Icon(Icons.tune_rounded, color: text.withOpacity(0.7)),
        ),
        SunMoonToggle(isDark: isDark, onToggle: widget.toggleTheme),
      ],
    );
  }

  Widget _buildEmptyState(Color text) {
    return Expanded(
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.style_outlined, size: 80, color: text.withOpacity(0.3)),
            const SizedBox(height: 16),
            Text("No flashcards found for this subject.", style: TextStyle(color: text.withOpacity(0.5))),
          ],
        ),
      ),
    );
  }

  Widget _buildCardContent(Color text, Color cardBg, bool isDark) {
    final originalIndex = _shuffledIndices[_currentIndex];
    final flashcard = _flashcards[originalIndex];
    final isReading = flashcard.subject.toLowerCase() == 'reading';
    
    // For Reading subject, we always show Name on front and Description on back.
    // Otherwise, we follow the user's toggle preference.
    final frontContent = isReading ? flashcard.name : (_showNameFirst ? flashcard.name : flashcard.description);
    final backContent = isReading ? flashcard.description : (_showNameFirst ? flashcard.description : flashcard.name);

    return Expanded(
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 500),
          child: GestureDetector(
            onHorizontalDragEnd: (details) {
              if (details.primaryVelocity! < 0) {
                _nextCard();
              } else if (details.primaryVelocity! > 0) {
                _previousCard();
              }
            },
            onTap: _flipCard,
            child: LayoutBuilder(
              builder: (context, constraints) {
                final cardWidth = constraints.maxWidth;
                final horizontalPadding = cardWidth < 350 ? 20.0 : 32.0;
                
                final authProvider = Provider.of<AuthProvider>(context, listen: false);
                final bool isLocked = !authProvider.hasTiliPackage && originalIndex >= 20;

                if (isLocked) {
                  return _buildLockedOverlay(cardBg, text, isDark);
                }

                return AnimatedBuilder(
                  animation: _flipAnimation,
                  builder: (context, child) {
                    final angle = _flipAnimation.value;
                    return Transform(
                      transform: Matrix4.identity()
                        ..setEntry(3, 2, 0.001)
                        ..rotateY(angle),
                      alignment: Alignment.center,
                      child: angle <= pi / 2
                          ? _buildCardFace(
                              frontContent,
                              "Question",
                              cardBg,
                              text,
                              flashcard.imageUrl,
                              originalIndex,
                              horizontalPadding,
                            )
                          : Transform(
                              transform: Matrix4.identity()..rotateY(pi),
                              alignment: Alignment.center,
                              child: _buildCardFace(
                                backContent,
                                "Answer",
                                cardBg,
                                text,
                                "",
                                originalIndex,
                                horizontalPadding,
                                // Example sentence is only shown for Reading subject
                                exampleSentence: isReading ? flashcard.exampleSentence : "",
                              ),
                            ),
                    );
                  },
                );
              },
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildCardFace(String content, String type, Color cardBg, Color text, String imageUrl, int index, double horizontalPadding, {String exampleSentence = ""}) {
    final flashcard = _flashcards[index];
    final String status = _cardStatuses[flashcard.id.toString()] ?? "";
    final isMastered = status == "Mastered";
    final isHard = status == "Hard";
    final isAcknowledged = status == "Acknowledged";

    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: cardBg,
        borderRadius: BorderRadius.circular(32),
        border: Border.all(
          color: isMastered 
              ? Colors.teal.withOpacity(0.5) 
              : (isHard 
                  ? Colors.orange.withOpacity(0.5) 
                  : (isAcknowledged ? Colors.blue.withOpacity(0.5) : text.withOpacity(0.05))),
          width: 2,
        ),
        boxShadow: [
          BoxShadow(
            color: isMastered ? Colors.teal.withOpacity(0.1) : Colors.black.withOpacity(0.08),
            blurRadius: 30,
            offset: const Offset(0, 15),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(32),
        child: Stack(
          children: [
            if (status.isNotEmpty)
              Positioned(
                top: 20, right: 20,
                child: Row(
                  children: [
                    Icon(
                      status == FlashcardProgressService.statusMastered ? Icons.verified_rounded :
                      status == FlashcardProgressService.statusPracticing ? Icons.psychology_rounded :
                      Icons.help_outline_rounded,
                      color: status == FlashcardProgressService.statusMastered ? Colors.teal :
                             status == FlashcardProgressService.statusPracticing ? Colors.orange :
                             Colors.grey,
                      size: 24,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      status.toUpperCase(),
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.w900,
                        color: status == FlashcardProgressService.statusMastered ? Colors.teal :
                               status == FlashcardProgressService.statusPracticing ? Colors.orange :
                               Colors.grey,
                      ),
                    ),
                  ],
                ),
              ),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: horizontalPadding, vertical: 32),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    type.toUpperCase(),
                    style: TextStyle(fontSize: 12, fontWeight: FontWeight.w800, color: text.withOpacity(0.3), letterSpacing: 1.5),
                  ),
                  const SizedBox(height: 24),
                  if (imageUrl.isNotEmpty)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 24),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(16),
                        child: Image.network(imageUrl, height: 120, fit: BoxFit.cover),
                      ),
                    ),
                  Text(
                    content,
                    style: TextStyle(fontSize: content.length > 50 ? 20 : 28, fontWeight: FontWeight.bold, color: text, height: 1.3),
                    textAlign: TextAlign.center,
                  ),
                  if (exampleSentence.isNotEmpty) ...[
                    const SizedBox(height: 24),
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(color: text.withOpacity(0.03), borderRadius: BorderRadius.circular(16)),
                      child: Text(
                        exampleSentence,
                        style: TextStyle(fontSize: 14, fontStyle: FontStyle.italic, color: text.withOpacity(0.6), height: 1.5),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ],
                  const SizedBox(height: 32),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.touch_app_outlined, size: 16, color: text.withOpacity(0.3)),
                      const SizedBox(width: 8),
                      Text(
                        "Tap to flip",
                        style: TextStyle(fontSize: 13, color: text.withOpacity(0.3), fontWeight: FontWeight.w500),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFooter(Color text) {
    final originalIndex = _shuffledIndices[_currentIndex];
    final flashcard = _flashcards[originalIndex];
    final String currentStatus = _cardStatuses[flashcard.id.toString()] ?? "";

    return Column(
      children: [
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _buildActionButton(
                icon: Icons.help_outline_rounded,
                label: "Unknown",
                isActive: currentStatus == FlashcardProgressService.statusUnknown,
                color: Colors.grey,
                onTap: () => _updateCardStatus(flashcard.id.toString(), FlashcardProgressService.statusUnknown),
                text: text,
              ),
              const SizedBox(width: 12),
              _buildActionButton(
                icon: Icons.psychology_outlined,
                label: "Practicing",
                isActive: currentStatus == FlashcardProgressService.statusPracticing,
                color: Colors.orange,
                onTap: () => _updateCardStatus(flashcard.id.toString(), FlashcardProgressService.statusPracticing),
                text: text,
              ),
              const SizedBox(width: 12),
              _buildActionButton(
                icon: Icons.verified_outlined,
                label: "Mastered",
                isActive: currentStatus == FlashcardProgressService.statusMastered,
                color: Colors.teal,
                onTap: () => _updateCardStatus(flashcard.id.toString(), FlashcardProgressService.statusMastered),
                text: text,
              ),
            ],
          ),
        ),
        const SizedBox(height: 24),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _buildNavButton(Icons.chevron_left_rounded, _currentIndex > 0 ? _previousCard : null, text),
            const SizedBox(width: 48),
            _buildNavButton(Icons.chevron_right_rounded, _currentIndex < _flashcards.length - 1 ? _nextCard : null, text),
          ],
        ),
      ],
    );
  }

  Widget _buildActionButton({
    required IconData icon,
    required String label,
    required bool isActive,
    required Color color,
    required VoidCallback onTap,
    required Color text,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          color: isActive ? color.withOpacity(0.15) : text.withOpacity(0.05),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: isActive ? color.withOpacity(0.3) : Colors.transparent),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 18, color: isActive ? color : text.withOpacity(0.5)),
            const SizedBox(width: 8),
            Text(
              label,
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: isActive ? color : text.withOpacity(0.7),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNavButton(IconData icon, VoidCallback? onPressed, Color text) {
    final bool isDisabled = onPressed == null;
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onPressed,
        borderRadius: BorderRadius.circular(100),
        child: Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: isDisabled ? text.withOpacity(0.02) : text.withOpacity(0.08),
          ),
          child: Icon(icon, color: isDisabled ? text.withOpacity(0.1) : text, size: 32),
        ),
      ),
    );
  }

  Widget _buildSummaryScreen(Color text, Color cardBg, bool isDark) {
    final total = _flashcards.length;
    int mastered = 0;
    int practicing = 0;
    int unknown = 0;

    for (var card in _flashcards) {
      final status = _cardStatuses[card.id.toString()];
      if (status == FlashcardProgressService.statusMastered) mastered++;
      else if (status == FlashcardProgressService.statusPracticing) practicing++;
      else if (status == FlashcardProgressService.statusUnknown) unknown++;
    }
    
    final remaining = total - mastered - practicing - unknown;
    final bool hasPackage = Provider.of<AuthProvider>(context, listen: false).hasTiliPackage;
    final bool isTrialFinished = !hasPackage && mastered + practicing + unknown >= 20;

    return Expanded(
      child: Center(
        child: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(color: Colors.teal.withOpacity(0.1), shape: BoxShape.circle),
                child: const Icon(Icons.celebration_rounded, color: Colors.teal, size: 64),
              ),
              const SizedBox(height: 24),
              Text(isTrialFinished ? "Trial Set Complete!" : "Session Complete!", style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: text)),
              const SizedBox(height: 8),
              Text(isTrialFinished ? "You've mastered your trial set!" : "You've reviewed all cards in this set", style: TextStyle(fontSize: 16, color: text.withOpacity(0.5))),
              if (isTrialFinished) ...[
                const SizedBox(height: 24),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                  decoration: BoxDecoration(color: Colors.amber.withOpacity(0.1), borderRadius: BorderRadius.circular(100), border: Border.all(color: Colors.amber.withOpacity(0.3))),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.stars_rounded, color: Colors.amber, size: 20),
                      const SizedBox(width: 8),
                      Text("UPGRADE TO UNLOCK 1000+ WORDS", style: GoogleFonts.inter(color: Colors.amber, fontWeight: FontWeight.w900, fontSize: 13, letterSpacing: 0.5)),
                    ],
                  ),
                ),
              ],
              const SizedBox(height: 40),
              
              _buildStatRow("Mastered", mastered, Colors.teal, text),
              const SizedBox(height: 12),
              _buildStatRow("Practicing", practicing, Colors.orange, text),
              const SizedBox(height: 12),
              _buildStatRow("Unknown", unknown, Colors.grey, text),
              const SizedBox(height: 12),
              _buildStatRow("Remaining", remaining, text.withOpacity(0.3), text),
              
              const SizedBox(height: 56),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  _buildSummaryButton(
                    onPressed: _restartSession,
                    label: "Study Again",
                    icon: Icons.replay_rounded,
                    color: Colors.teal,
                    isFilled: true,
                  ),
                  const SizedBox(width: 16),
                  _buildSummaryButton(
                    onPressed: () => Navigator.pop(context),
                    label: "Done",
                    icon: Icons.check_rounded,
                    color: text.withOpacity(0.1),
                    isFilled: false,
                    textColor: text,
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatRow(String label, int value, Color color, Color text) {
    return Container(
      width: 260,
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      decoration: BoxDecoration(
        color: text.withOpacity(0.04),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: text.withOpacity(0.05)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Container(width: 12, height: 12, decoration: BoxDecoration(color: color, shape: BoxShape.circle)),
              const SizedBox(width: 12),
              Text(label, style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: text.withOpacity(0.7))),
            ],
          ),
          Text(value.toString(), style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: text)),
        ],
      ),
    );
  }

  Widget _buildSummaryButton({
    required VoidCallback onPressed,
    required String label,
    required IconData icon,
    required Color color,
    required bool isFilled,
    Color? textColor,
  }) {
    return ElevatedButton.icon(
      onPressed: onPressed,
      icon: Icon(icon, size: 20),
      label: Text(label),
      style: ElevatedButton.styleFrom(
        backgroundColor: isFilled ? color : Colors.transparent,
        foregroundColor: isFilled ? Colors.white : (textColor ?? color),
        elevation: 0,
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: isFilled ? BorderSide.none : BorderSide(color: color),
        ),
      ),
    );
  }

  Widget _buildLockedOverlay(Color cardBg, Color text, bool isDark) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: cardBg,
        borderRadius: BorderRadius.circular(32),
        border: Border.all(color: Colors.amber.withOpacity(0.3), width: 2),
      ),
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(color: Colors.amber.withOpacity(0.1), shape: BoxShape.circle),
              child: const Icon(Icons.lock_rounded, color: Colors.amber, size: 48),
            ),
            const SizedBox(height: 32),
            Text(
              "Upgrade for More Cards",
              style: GoogleFonts.inter(fontSize: 24, fontWeight: FontWeight.bold, color: text),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            Text(
              "You've reached the free trial limit for this subject. Upgrade to unlock all 1000+ flashcards and persistent progress tracking.",
              style: GoogleFonts.inter(fontSize: 15, color: text.withOpacity(0.5), height: 1.5),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 40),
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => TILMembershipPage(toggleTheme: widget.toggleTheme)),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.amber.shade700,
                foregroundColor: Colors.white,
                minimumSize: const Size(double.infinity, 56),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              ),
              child: Text("UNLOCK ALL CARDS", style: GoogleFonts.inter(fontWeight: FontWeight.w900, fontSize: 14)),
            ),
          ],
        ),
      ),
    );
  }

  void _showSettingsDialog(bool isDark, Color text) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: isDark ? const Color(0xFF2C2C2C) : Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        title: Text("Study Settings", style: TextStyle(color: text)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            SwitchListTile(
              title: Text("Show Name First", style: TextStyle(color: text)),
              subtitle: Text("Toggle between Name or Description as front side", style: TextStyle(color: text.withOpacity(0.6))),
              value: _showNameFirst,
              activeColor: Colors.teal,
              onChanged: (val) {
                setState(() => _showNameFirst = val);
                Navigator.pop(context);
              },
            ),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text("Close", style: TextStyle(color: Colors.teal))),
        ],
      ),
    );
  }
}
