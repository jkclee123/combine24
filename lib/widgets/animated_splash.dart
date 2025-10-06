import 'dart:math';

import 'package:combine24/config/const.dart';
import 'package:combine24/pages/home/home_page.dart';
import 'package:combine24/utils/text_warmer.dart';
import 'package:flutter/material.dart';

class AnimatedSplash extends StatefulWidget {
  const AnimatedSplash({super.key});

  @override
  State<AnimatedSplash> createState() => _AnimatedSplashState();
}

class _AnimatedSplashState extends State<AnimatedSplash>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  late Animation<double> _opacityAnimation;
  late Animation<double> _rotationAnimation;

  @override
  void initState() {
    super.initState();

    // Create animation controller
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    );

    // Scale animation: start small, grow to normal size
    _scaleAnimation = Tween<double>(
      begin: 0.7,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOutBack,
    ));

    // Opacity animation: fade in
    _opacityAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeIn,
    ));

    // Rotation animation: slight rotation then back to center
    _rotationAnimation = Tween<double>(
      begin: 0.0,
      end: pi * 1.95, 
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOut,
    ));

    // Start the animation and text warming in parallel
    _startSplashSequence();
  }

  Future<void> _startSplashSequence() async {
    // Start both animation and text warming simultaneously
    final animationFuture = _controller.forward();
    final warmUpFuture = TextWarmer.warmUpChineseText();

    // Wait for both to complete
    await Future.wait([animationFuture, warmUpFuture]);

    // Navigate to main app if widget is still mounted
    if (mounted) {
      Navigator.of(context).pushReplacement(
        PageRouteBuilder(
          pageBuilder: (context, animation, secondaryAnimation) => const HomePage(),
          transitionsBuilder: (context, animation, secondaryAnimation, child) => 
          FadeTransition(
            opacity: animation,
            child: child,
          ),
        ),
      );
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.primaryColor,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Animated icon with scale, opacity, and rotation
            AnimatedBuilder(
              animation: _controller,
              builder: (context, child) {
                return Transform.scale(
                  scale: _scaleAnimation.value,
                  child: Transform.rotate(
                    angle: _rotationAnimation.value,
                    child: Opacity(
                      opacity: _opacityAnimation.value,
                      child: Icon(
                        Icons.calculate,
                        size: 80,
                        color: Colors.amber,
                      ),
                    ),
                  ),
                );
              },
            ),
            const SizedBox(height: 24),
            // Animated app title
            FadeTransition(
              opacity: _opacityAnimation,
              child: Text(
                Const.title,
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
