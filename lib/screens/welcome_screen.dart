import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class WelcomeScreen extends StatelessWidget {
  const WelcomeScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFAF6EE),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
              '27',
              style: TextStyle(
                fontSize: 72,
                fontWeight: FontWeight.bold,
                fontFamily: 'Serif',
                color: Color(0xFF1F1B16),
              ),
            ),
            const SizedBox(height: 24),
            const Text(
              'Your personal JEE planner',
              style: TextStyle(
                fontSize: 18,
                color: Color(0xFF1F1B16),
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 48),
            ElevatedButton(
              onPressed: () {
                // Navigate to day planner
                Navigator.of(context).pushReplacementNamed('/');
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFC2651A),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(
                  horizontal: 48,
                  vertical: 16,
                ),
              ),
              child: const Text('Get Started'),
            ),
          ],
        ),
      ),
    );
  }
}
