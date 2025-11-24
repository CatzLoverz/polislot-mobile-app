// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';

/// Animated parking logo: scale + subtle floating loop
class AnimatedParkingLogo extends StatefulWidget {
  final double size;
  final Duration duration;

  const AnimatedParkingLogo({super.key, this.size = 100, this.duration = const Duration(seconds: 3)});

  @override
  State<AnimatedParkingLogo> createState() => _AnimatedParkingLogoState();
}

class _AnimatedParkingLogoState extends State<AnimatedParkingLogo> with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;
  late final Animation<double> _floatAnim;
  late final Animation<double> _scaleAnim;
  late final Animation<double> _opacityAnim;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(vsync: this, duration: widget.duration)..repeat(reverse: true);

    _floatAnim = Tween<double>(begin: -6.0, end: 6.0).animate(
      CurvedAnimation(parent: _ctrl, curve: Curves.easeInOut),
    );

    _scaleAnim = TweenSequence<double>([
      TweenSequenceItem(tween: Tween(begin: 0.96, end: 1.03).chain(CurveTween(curve: Curves.easeOut)), weight: 50),
      TweenSequenceItem(tween: Tween(begin: 1.03, end: 0.96).chain(CurveTween(curve: Curves.easeIn)), weight: 50),
    ]).animate(_ctrl);

    _opacityAnim = Tween<double>(begin: 0.92, end: 1.0).animate(
      CurvedAnimation(parent: _ctrl, curve: const Interval(0.0, 1.0, curve: Curves.easeInOut)),
    );
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _ctrl,
      builder: (context, child) {
        return Opacity(
          opacity: _opacityAnim.value,
          child: Transform.translate(
            offset: Offset(0, _floatAnim.value),
            child: Transform.scale(
              scale: _scaleAnim.value,
              child: child,
            ),
          ),
        );
      },
      child: Container(
        width: widget.size,
        height: widget.size,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          gradient: const LinearGradient(
            colors: [Color(0xFF2196F3), Color(0xFF42A5F5)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          boxShadow: [BoxShadow(color: Colors.white.withOpacity(0.12), blurRadius: 18, spreadRadius: 2, offset: Offset(0, 6))],
        ),
        child: Icon(
          Icons.local_parking_rounded,
          color: Colors.white,
          size: widget.size * 0.52,
        ),
      ),
    );
  }
}
