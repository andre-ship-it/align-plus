import 'dart:math';
import 'dart:ui';

import 'package:confetti/confetti.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:video_player/video_player.dart';

import '../../app/theme.dart';
import '../../shared/widgets/press_scale_button.dart';

class MistRevealScreen extends StatefulWidget {
  final String videoUrl;
  final String title;

  const MistRevealScreen({
    super.key,
    required this.videoUrl,
    required this.title,
  });

  @override
  State<MistRevealScreen> createState() => _MistRevealScreenState();
}

class _MistRevealScreenState extends State<MistRevealScreen> {
  late VideoPlayerController _controller;
  late ConfettiController _confetti;
  double _sigma = 45;
  double _mistOpacity = 1;
  int _movements = 0;

  @override
  void initState() {
    super.initState();
    _confetti = ConfettiController(duration: const Duration(seconds: 2));
    _initVideo();
  }

  void _initVideo() {
    _controller = VideoPlayerController.networkUrl(Uri.parse(widget.videoUrl))
      ..initialize().then((_) {
        _controller
          ..setLooping(true)
          ..setVolume(0)
          ..play();
        if (mounted) {
          setState(() {});
        }
      });
  }

  @override
  void didUpdateWidget(covariant MistRevealScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.videoUrl != widget.videoUrl) {
      _controller.dispose();
      _sigma = 45;
      _mistOpacity = 0;
      _movements = 0;
      _initVideo();
      Future.delayed(const Duration(milliseconds: 100), () {
        if (mounted) {
          setState(() => _mistOpacity = 1);
        }
      });
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    _confetti.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Positioned.fill(
          child: _controller.value.isInitialized
              ? VideoPlayer(_controller)
              : Container(color: Colors.black),
        ),
        IgnorePointer(
          child: AnimatedOpacity(
            duration: const Duration(milliseconds: 950),
            curve: Curves.easeInOutCubic,
            opacity: _mistOpacity,
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: _sigma, sigmaY: _sigma),
              child: Container(color: Colors.white.withOpacity(0.85)),
            ),
          ),
        ),
        Align(
          alignment: Alignment.topCenter,
          child: ConfettiWidget(
            confettiController: _confetti,
            blastDirection: pi / 2,
          ),
        ),
        SafeArea(
          child: Column(
            children: [
              const SizedBox(height: 40),
              Text(
                widget.title,
                style: Theme.of(
                  context,
                ).textTheme.titleLarge?.copyWith(color: AppPalette.deepTeal),
              ),
              const Spacer(),
              PressScaleButton(
                onPressed: () {
                  HapticFeedback.lightImpact();
                  setState(() {
                    if (_movements < 5) {
                      _movements++;
                      _sigma -= 9;
                      if (_movements == 5) {
                        _confetti.play();
                      }
                    }
                  });
                },
                child: Text(_movements == 5 ? 'ALIGNED' : 'STRETCH DONE'),
              ),
              const SizedBox(height: 40),
            ],
          ),
        ),
      ],
    );
  }
}
