import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';
import 'package:confetti/confetti.dart';
import 'package:url_launcher/url_launcher.dart'; // Added for the reward link
import 'dart:ui';
import 'dart:math';

void main() => runApp(const AlignPlusApp());

class AlignPlusApp extends StatelessWidget {
  const AlignPlusApp({super.key});
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        colorSchemeSeed: const Color(0xFF008080),
        // Using a more premium Serif font style for the wellness vibe
        textTheme: const TextTheme(
          displayLarge: TextStyle(fontFamily: 'Georgia', fontWeight: FontWeight.bold),
          bodyLarge: TextStyle(fontFamily: 'Georgia'),
        ),
      ),
      home: const MainAppFlow(),
    );
  }
}

class MainAppFlow extends StatefulWidget {
  const MainAppFlow({super.key});
  @override
  State<MainAppFlow> createState() => _MainAppFlowState();
}

class _MainAppFlowState extends State<MainAppFlow> {
  bool _showSurvey = true; 
  int _selectedTab = 0; 
  
  String _activeVideoUrl = 'https://assets.mixkit.co/videos/preview/mixkit-tropical-beach-with-palm-trees-1549-large.mp4';
  String _activeTitle = "Morning Ritual";

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: AnimatedSwitcher(
        duration: const Duration(milliseconds: 800),
        child: _showSurvey 
          ? _buildSurveyUI() 
          : Scaffold(
              extendBody: true, // Allows content to flow behind the bottom nav
              body: _selectedTab == 0 
                ? MistRevealScreen(videoUrl: _activeVideoUrl, title: _activeTitle) 
                : _buildLibraryUI(),
              bottomNavigationBar: _buildGlassBottomNav(),
            ),
      ),
    );
  }

  // --- GLASSMORPHIC UI COMPONENTS ---

  Widget _buildGlassBottomNav() {
    return Container(
      margin: const EdgeInsets.all(20),
      height: 70,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(30),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 20)],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(30),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
          child: BottomNavigationBar(
            currentIndex: _selectedTab,
            onTap: (index) => setState(() => _selectedTab = index),
            backgroundColor: Colors.white.withOpacity(0.2),
            elevation: 0,
            selectedItemColor: const Color(0xFF008080),
            unselectedItemColor: Colors.black45,
            items: const [
              BottomNavigationBarItem(icon: Icon(Icons.spa_rounded), label: "Ritual"),
              BottomNavigationBarItem(icon: Icon(Icons.auto_awesome_motion), label: "Library"),
            ],
          ),
        ),
      ),
    );
  }

  // (Survey and Library UI code remain largely the same, but styled with new theme)
  // ... _buildSurveyUI and _buildLibraryUI ...
}

class MistRevealScreen extends StatefulWidget {
  final String videoUrl;
  final String title;
  const MistRevealScreen({super.key, required this.videoUrl, required this.title});

  @override
  State<MistRevealScreen> createState() => _MistRevealScreenState();
}

class _MistRevealScreenState extends State<MistRevealScreen> with TickerProviderStateMixin {
  late VideoPlayerController _controller;
  late ConfettiController _confetti;
  double _sigma = 45.0;
  int _movements = 0;

  @override
  void initState() {
    super.initState();
    _confetti = ConfettiController(duration: const Duration(seconds: 3));
    _initVideo();
  }

  void _initVideo() {
    _controller = VideoPlayerController.networkUrl(Uri.parse(widget.videoUrl))
      ..initialize().then((_) {
        _controller.setLooping(true);
        _controller.setVolume(0);
        _controller.play();
        setState(() {});
      });
  }

  Future<void> _launchRewardLink() async {
    final Uri url = Uri.parse('https://myfitvacation.com/align-rewards');
    if (!await launchUrl(url)) {
      throw Exception('Could not launch $url');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Positioned.fill(child: _controller.value.isInitialized ? VideoPlayer(_controller) : Container(color: Colors.black)),
        
        // THE MIST
        IgnorePointer(
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: _sigma, sigmaY: _sigma),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 1000),
              color: Colors.white.withOpacity(_movements == 5 ? 0.0 : 0.8),
            ),
          ),
        ),

        Align(alignment: Alignment.topCenter, child: ConfettiWidget(confettiController: _confetti, blastDirection: pi/2)),

        SafeArea(
          child: Column(
            children: [
              const SizedBox(height: 40),
              Text(widget.title.toUpperCase(), style: const TextStyle(fontSize: 14, letterSpacing: 4, fontWeight: FontWeight.bold, color: Color(0xFF008080))),
              const Spacer(),
              
              // GLASS ACTION CARD
              Padding(
                padding: const EdgeInsets.all(30.0),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(30),
                  child: BackdropFilter(
                    filter: ImageFilter.blur(sigmaX: 15, sigmaY: 15),
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 40, horizontal: 20),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(30),
                        border: Border.all(color: Colors.white.withOpacity(0.3)),
                      ),
                      child: Column(
                        children: [
                          Text("${_movements}/5", style: const TextStyle(fontSize: 40, fontWeight: FontWeight.w900)),
                          const SizedBox(height: 10),
                          const Text("STRETCHES COMPLETED", style: TextStyle(fontSize: 12, letterSpacing: 2)),
                          const SizedBox(height: 30),
                          ElevatedButton(
                            onPressed: () {
                              if (_movements < 5) {
                                setState(() {
                                  _movements++;
                                  _sigma = (45.0 - (_movements * 9.0)).clamp(0, 45);
                                  if (_movements == 5) _confetti.play();
                                });
                              } else {
                                _launchRewardLink();
                              }
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF008080),
                              foregroundColor: Colors.white,
                              minimumSize: const Size(double.infinity, 60),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(100)),
                            ),
                            child: Text(_movements == 5 ? "CLAIM REWARD 🎁" : "I DID A STRETCH ✅"),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 100), // Space for bottom nav
            ],
          ),
        ),
      ],
    );
  }
}
