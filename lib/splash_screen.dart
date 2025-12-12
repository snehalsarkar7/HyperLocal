import 'package:flutter/material.dart';
import 'package:hyperlocal/main.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  bool _isOn = false; // State to track if the button is "ON" or "OFF"

  void _togglePower() {
    // 1. Set the state to ON
    setState(() {
      _isOn = true;
    });

    // 2. Wait for 300 milliseconds (to let the user see the button turn green)
    Future.delayed(const Duration(milliseconds: 300), () {
      // 3. Navigate to the main dashboard
      _navigateToHome();
    });
  }

  void _navigateToHome() {
    // This function no longer has a Timer.
    // It navigates immediately when called.
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (context) => const HomePage()),
    );
  }

  @override
  void initState() {
    super.initState();
    // We REMOVED the _navigateToHome() call from here.
    // Navigation is now triggered by the button tap.
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF222222), // App background
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // App Title
            Text(
              'Hyper Local Weather Station',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                color: Colors.white,
                fontSize: 28,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 50),

            // --- The Custom Power Button ---
            GestureDetector(
              onTap: _togglePower, // Call our toggle function on tap
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200), // Smooth animation
                width: 150,
                height: 150,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: _isOn
                      ? const Color(0xFF00E676) // Green when ON
                      : Colors.grey.shade700, // Grey when OFF
                  boxShadow: _isOn
                      ? [ // Add a glow effect when ON
                    BoxShadow(
                      color: const Color(0xFF00E676).withOpacity(0.5),
                      blurRadius: 15,
                      spreadRadius: 2,
                    ),
                  ]
                      : [],
                ),
                child: Center(
                  child: Text(
                    _isOn ? 'ON' : 'OFF', // Text changes based on state
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 36,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ),
            // --- End Power Button ---

            const SizedBox(height: 50),

            // Hint text that disappears when button is pressed
            if (!_isOn)
              Text(
                'Tap to power on',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Colors.grey,
                ),
              ),
          ],
        ),
      ),
    );
  }
}