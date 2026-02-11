import 'package:flutter/material.dart';
import 'dart:math' as math;

class SunMoonToggle extends StatefulWidget {
  final bool isDark;
  final VoidCallback onToggle;

  const SunMoonToggle({
    super.key,
    required this.isDark,
    required this.onToggle,
  });

  @override
  State<SunMoonToggle> createState() => _SunMoonToggleState();
}

class _SunMoonToggleState extends State<SunMoonToggle> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _rotationAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );
    _rotationAnimation = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOutBack),
    );

    if (widget.isDark) {
      _controller.value = 1.0;
    }
  }

  @override
  void didUpdateWidget(SunMoonToggle oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isDark != oldWidget.isDark) {
      if (widget.isDark) {
        _controller.forward();
      } else {
        _controller.reverse();
      }
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: widget.onToggle,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        width: 64,
        height: 32,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          color: widget.isDark ? const Color(0xFF27272A) : const Color(0xFFF2F1F6),
          border: Border.all(
            color: widget.isDark ? Colors.white.withOpacity(0.1) : Colors.black.withOpacity(0.1),
            width: 1,
          ),
          boxShadow: [
            if (!widget.isDark)
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 4,
                offset: const Offset(0, 2),
              ),
          ],
        ),
        child: Stack(
          children: [
            AnimatedPositioned(
              duration: const Duration(milliseconds: 400),
              curve: Curves.easeInOutBack,
              left: widget.isDark ? 34 : 4,
              top: 3,
              child: RotationTransition(
                turns: _rotationAnimation,
                child: Container(
                  width: 24,
                  height: 24,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: widget.isDark
                          ? [const Color(0xFF818CF8), const Color(0xFF6366F1)]
                          : [const Color(0xFFFFB347), const Color(0xFFFFCC33)],
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: (widget.isDark ? Colors.indigo : Colors.orange).withOpacity(0.3),
                        blurRadius: 8,
                        spreadRadius: 1,
                      ),
                    ],
                  ),
                  child: Center(
                    child: Icon(
                      widget.isDark ? Icons.dark_mode_rounded : Icons.light_mode_rounded,
                      size: 14,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
