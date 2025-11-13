import 'package:flutter/material.dart';
import 'home_screen.dart';

class ProcessedScreen extends StatelessWidget {
  const ProcessedScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Stack(
          children: [
            // Centered content
            Center(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // Check circle icon
                    Container(
                      width: 86,
                      height: 86,
                      decoration: const BoxDecoration(
                        color: Color(0xFFD42F4D),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.check,
                        color: Colors.white,
                        size: 48,
                      ),
                    ),
                    const SizedBox(height: 24),
                    // Title text
                    const Text(
                      'Your booking is now being processed!',
                      style: TextStyle(
                        fontSize: 26,
                        fontWeight: FontWeight.w500,
                        color: Colors.black,
                        height: 34 / 26, // line height
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 16),
                    // Subtitle text
                    const Text(
                      'You will be notified right away once the operator approves your content.',
                      style: TextStyle(
                        fontSize: 16,
                        color: Color(0xFF717375),
                        height: 18 / 16, // line height
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
            ),
            // Back to home button at bottom
            Positioned(
              left: 24,
              right: 24,
              bottom: 55,
              child: Container(
                width: double.infinity,
                child: OutlinedButton(
                  onPressed: () {
                    Navigator.of(context).pushReplacement(
                      MaterialPageRoute(builder: (context) => const HomeScreen()),
                    );
                  },
                  style: OutlinedButton.styleFrom(
                    side: const BorderSide(color: Color(0xFFD8DCE0)),
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(6),
                    ),
                  ),
                  child: const Text(
                    'Back to home',
                    style: TextStyle(
                      color: Color(0xFF717375),
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
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