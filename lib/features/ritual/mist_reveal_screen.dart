import 'package:flutter/material.dart';
import 'dart:ui';

class MistRevealScreen extends StatefulWidget {
  final String gifUrl; // The rehabilitative movement video
  final String imageUrl; // The background Bali image
  final String title;
  final int currentStreak;
  final Function(int) onComplete;

  const MistRevealScreen({
    super.key,
    required this.gifUrl,
    required this.imageUrl,
    required this.title,
    required this.currentStreak,
    required this.onComplete,
  });

  @override
  State<MistRevealScreen> createState() => _MistRevealScreenState();
}

class _MistRevealScreenState extends State<MistRevealScreen> {
  double _opacity = 1.0;
  bool _isFinished = false;

  void _onRevealUpdate(double value) {
    setState(() {
      _opacity = value;
      if (_opacity <= 0.1 && !_isFinished) {
        _isFinished = true;
        _handleCompletion();
      }
    });
  }

  void _handleCompletion() {
    // Increment the streak and trigger the callback
    widget.onComplete(widget.currentStreak + 1);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          // The Movement Video (Gif)
          Center(
            child: Image.network(
              widget.gifUrl,
              fit: BoxFit.contain,
              loadingBuilder: (context, child, loadingProgress) {
                if (loadingProgress == null) return child;
                return const CircularProgressIndicator(color: Color(0xFF008080));
              },
            ),
          ),

          // The Mist/Blur Overlay
          IgnorePointer(
            ignoring: _isFinished,
            child: Opacity(
              opacity: _opacity,
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
                child: Container(
                  color: Colors.black.withOpacity(0.3),
                  alignment: Alignment.center,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        widget.title,
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          fontFamily: 'Georgia',
                        ),
                      ),
                      const SizedBox(height: 40),
                      const Text(
                        "Swipe down to clear the mist\nand begin your ritual",
                        textAlign: TextAlign.center,
                        style: TextStyle(color: Colors.white70, fontSize: 16),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),

          // Gesture Detector for the Reveal
          if (!_isFinished)
            GestureDetector(
              onVerticalDragUpdate: (details) {
                // Logic to reduce opacity as user swipes down
                double newOpacity = _opacity - (details.primaryDelta! / 300);
                _onRevealUpdate(newOpacity.clamp(0.0, 1.0));
              },
            ),
        ],
      ),
    );
  }
}
