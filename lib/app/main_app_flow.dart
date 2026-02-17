import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:ui';
import 'dart:async';
import 'package:url_launcher/url_launcher.dart';

// Assuming these are your feature imports
// import '../features/ritual/mist_reveal_screen.dart'; 

class MainAppFlow extends StatefulWidget {
  const MainAppFlow({super.key});

  @override
  State<MainAppFlow> createState() => _MainAppFlowState();
}

class _MainAppFlowState extends State<MainAppFlow> {
  bool _showSurvey = true;
  int _selectedTab = 0;
  int _streak = 0;

  final String _ritualGifUrl = 'https://storage.googleapis.com/msgsndr/y5pUJDsp1xPu9z0K6inm/media/6994079954da040a6970fcb2.gif';
  final String _revealImageUrl = 'https://storage.googleapis.com/msgsndr/y5pUJDsp1xPu9z0K6inm/media/6610b1519b8fa973cb15b332.jpeg';

  final List<String> _locations = ["Ubud Jungle", "Uluwatu Cliffs", "Seminyak Beach", "Canggu Rice Fields", "Nusa Penida", "Amed Coast", "Sidemen Valley"];
  final List<String> _stretches = ["Neck & Shoulders", "Lower Back Relief", "Hip Openers", "Full Body Flow", "Chest & Heart Opener", "Spinal Twist", "Hamstring Length"];

  @override
  void initState() {
    super.initState();
    _initializeData();
  }

  void _initializeData() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _streak = prefs.getInt('streak_count') ?? 0;
      _showSurvey = prefs.getBool('survey_completed') == null;
    });
    
    // Check for first-time PWA launch welcome message
    _checkFirstRun(prefs);
  }

  void _checkFirstRun(SharedPreferences prefs) {
    bool isFirstRun = prefs.getBool('is_first_run') ?? true;
    if (isFirstRun) {
      WidgetsBinding.instance.addPostFrameCallback((_) => _showWelcomeDialog());
      prefs.setBool('is_first_run', false);
    }
  }

  void _showWelcomeDialog() {
    showDialog(
      context: context,
      builder: (context) => BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
        child: AlertDialog(
          backgroundColor: Colors.white.withOpacity(0.2),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.auto_awesome, color: Colors.white, size: 50),
              const SizedBox(height: 20),
              const Text("Welcome to Your Reset", textAlign: TextAlign.center,
                style: TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold)),
              const SizedBox(height: 15),
              const Text("You've taken the first step toward alignment. Your 30-day journey starts now.",
                textAlign: TextAlign.center, style: TextStyle(color: Colors.white70, fontSize: 16, height: 1.5)),
              const SizedBox(height: 30),
              ElevatedButton(
                onPressed: () => Navigator.pop(context),
                style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF008080), foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(100)), minimumSize: const Size(200, 50)),
                child: const Text("BEGIN RITUAL"),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: AnimatedSwitcher(
        duration: const Duration(milliseconds: 800),
        child: _showSurvey ? _buildSurveyUI() : _buildMainApp(),
      ),
    );
  }

  // UI Builders (Survey, Ritual, Map, Share, Install) go here...
  // Use the same glassmorphic logic and desktop visibility fixes from previous turns.

  Widget _buildMainApp() {
    return Scaffold(
      extendBody: true,
      body: _getBody(),
      bottomNavigationBar: _buildGlassBottomNav(),
    );
  }

  Widget _getBody() {
    switch (_selectedTab) {
      case 0:
        return _buildRitualUI(); // Use MistReveal logic here
      case 1:
        return _buildLibraryUI(); // The 30-Day Map
      case 2:
        return _buildShareUI(); // The Share Card
      case 3:
        return _buildInstallUI();
      default:
        return const SizedBox.shrink();
    }
  }

  // Include _buildLibraryUI, _buildMilestoneTile, _buildShareUI, etc. from previousTurn
}
