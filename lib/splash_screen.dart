import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:hyperlocal/main.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> with SingleTickerProviderStateMixin {
  bool _isOn = false;
  late AnimationController _pulseController;
  late Animation<double> _pulseAnimation;

  @override
  void initState() {
    super.initState();
    // Continuous pulsing animation
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat(reverse: true);

    _pulseAnimation = Tween<double>(begin: 0.2, end: 0.8).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  void _togglePower() {
    if (_isOn) return;
    
    setState(() {
      _isOn = true;
    });
    
    // Stop the pulsing when turned on
    _pulseController.stop();

    // Wait a moment for the user to enjoy the ON animation, then navigate
    Future.delayed(const Duration(milliseconds: 900), () {
      if (mounted) {
        Navigator.of(context).pushReplacement(
          PageRouteBuilder(
            pageBuilder: (context, animation, secondaryAnimation) => const HomePage(),
            transitionsBuilder: (context, animation, secondaryAnimation, child) {
              return FadeTransition(opacity: animation, child: child);
            },
            transitionDuration: const Duration(milliseconds: 800),
          ),
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        decoration: const BoxDecoration(
          // Rich, dark premium gradient background
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Color(0xFF0D0D1A), // Deep midnight blue
              Color(0xFF1A1A2E), // Darker slate
              Color(0xFF0F0F1A), // Almost black
            ],
          ),
        ),
        child: SafeArea(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Premium Title with Neon Gradient
              ShaderMask(
                shaderCallback: (bounds) => const LinearGradient(
                  colors: [Color(0xFF00E676), Color(0xFF18FFFF)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ).createShader(bounds),
                child: const Text(
                  'Hyper Local\nWeather Station',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Colors.white, // Required for ShaderMask to apply gradient
                    fontSize: 34,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 1.2,
                    height: 1.2,
                  ),
                ),
              ),
              const SizedBox(height: 100),

              // Glassmorphic Glowing Power Button
              GestureDetector(
                onTap: _togglePower,
                child: AnimatedBuilder(
                  animation: _pulseAnimation,
                  builder: (context, child) {
                    final glowIntensity = _isOn ? 1.0 : _pulseAnimation.value;
                    final buttonColor = _isOn ? const Color(0xFF00E676) : const Color(0xFF444455);
                    final shadowColor = _isOn 
                        ? const Color(0xFF00E676) 
                        : const Color(0xFF00E676).withValues(alpha: 0.3);

                    return AnimatedContainer(
                      duration: const Duration(milliseconds: 500),
                      curve: Curves.easeOutQuart,
                      width: _isOn ? 130 : 150, // Slightly shrink on press for physical feel
                      height: _isOn ? 130 : 150,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: buttonColor.withValues(alpha: _isOn ? 0.2 : 0.1),
                        border: Border.all(
                          color: buttonColor.withValues(alpha: _isOn ? 0.9 : 0.4),
                          width: _isOn ? 4 : 2,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: shadowColor.withValues(alpha: glowIntensity * 0.7),
                            blurRadius: _isOn ? 50 : 25,
                            spreadRadius: _isOn ? 15 : 2,
                          ),
                          if (_isOn)
                            BoxShadow(
                              color: Colors.white.withValues(alpha: 0.6),
                              blurRadius: 15,
                              spreadRadius: 2,
                            ),
                        ],
                      ),
                      child: Center(
                        child: Icon(
                          FontAwesomeIcons.powerOff,
                          size: _isOn ? 55 : 60,
                          color: _isOn ? Colors.white : Colors.white.withValues(alpha: 0.8),
                        ),
                      ),
                    );
                  },
                ),
              ),
              
              const SizedBox(height: 80),

              // Subtle Hint Text
              AnimatedOpacity(
                opacity: _isOn ? 0.0 : 0.5,
                duration: const Duration(milliseconds: 300),
                child: const Text(
                  'SYSTEM STANDBY\nTAP TO INITIALIZE',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 13,
                    letterSpacing: 4,
                    fontWeight: FontWeight.w600,
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