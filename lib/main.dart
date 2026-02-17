import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';
import 'package:confetti/confetti.dart';
import 'package:url_launcher/url_launcher.dart';
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
        fontFamily: 'Georgia',
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

  // Survey Data
  final PageController _surveyController = PageController();
  int _currentStep = 0;
  final List<Map<String, dynamic>> _questions = [
    {"q": "What is your main goal?", "options": ["Relieve Pain", "Energy", "Sleep"]},
    {"q": "Where is your tension?", "options": ["Lower Back", "Neck", "Hips"]},
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: AnimatedSwitcher(
        duration: const Duration(milliseconds: 800),
        child: _showSurvey 
          ? _buildSurveyUI() 
          : Scaffold(
              extendBody: true,
              body: _selectedTab == 0 
                ? MistRevealScreen(videoUrl: _activeVideoUrl, title: _activeTitle) 
                : _buildLibraryUI(),
              bottomNavigationBar: _buildGlassBottomNav(),
            ),
      ),
    );
  }

  // --- ADDING THE MISSING METHODS ---

  Widget _buildSurveyUI() {
    return Container(
      color: const Color(0xFFF9F7F2),
      child: SafeArea(
        child: Column(
          children: [
            const SizedBox(height: 20),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 40),
              child: LinearProgressIndicator(
                value: (_currentStep + 1) / _questions.length,
                minHeight: 8,
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            Expanded(
              child: PageView.builder(
                controller: _surveyController,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: _questions.length,
                itemBuilder: (context, index) => Padding(
                  padding: const EdgeInsets.all(40.0),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(_questions[index]['q'], 
                        style: const TextStyle(fontSize: 32, fontWeight: FontWeight.w900),
                        textAlign: TextAlign.center),
                      const SizedBox(height: 30),
                      ...(_questions[index]['options'] as List).map((opt) => Padding(
                        padding: const EdgeInsets.only(bottom: 12),
                        child: ElevatedButton(
                          onPressed: () {
                            if (_currentStep < _questions.length - 1) {
                              _surveyController.nextPage(duration: const Duration(milliseconds: 300), curve: Curves.ease);
                              setState(() => _currentStep++);
                            } else {
                              setState(() => _showSurvey = false);
                            }
                          },
                          style: ElevatedButton.styleFrom(
                            minimumSize: const Size(double.infinity, 65),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                          ),
                          child: Text(opt, style: const TextStyle(fontSize: 18)),
                        ),
                      )),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLibraryUI() {
    return Container(
      color: const Color(0xFFF9F7F2),
      child: ListView(
        padding: const EdgeInsets.all(24),
        children: [
          const SizedBox(height: 40),
          const Text("Explore Bali", style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold)),
          const SizedBox(height: 20),
          _libCard("Lower Back Relief", "https://assets.mixkit.co/videos/preview/mixkit-top-view-of-a-beach-resort-with-palm-trees-1551-large.mp4"),
          _libCard("Deep Neck Stretch", "https://assets.mixkit.co/videos/preview/mixkit-waterfall-in-the-forest-1553-large.mp4"),
          _libCard("Morning Energy Flow", "https://assets.mixkit.co/videos/preview/mixkit-tropical-beach-with-palm-trees-1549-large.mp4"),
        ],
      ),
    );
  }

  Widget _libCard(String title, String url) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: ListTile(
        contentPadding: const EdgeInsets.all(15),
        leading: const CircleAvatar(backgroundColor: Color(0xFF008080), child: Icon(Icons.play_arrow, color: Colors.white)),
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
        onTap: () => setState(() {
          _activeVideoUrl = url;
          _activeTitle = title;
          _selectedTab = 0;
        }),
      ),
    );
  }

  Widget _buildGlassBottomNav() {
    return Container(
      margin: const EdgeInsets.all(25),
      height: 70,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(35),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
          child: BottomNavigationBar(
            currentIndex: _selectedTab,
            onTap: (index) => setState(() => _selectedTab = index),
            backgroundColor: Colors.white.withOpacity(0.3),
            selectedItemColor: const Color(0xFF008080),
            items: const [
              BottomNavigationBarItem(icon: Icon(Icons.spa), label: "Ritual"),
              BottomNavigationBarItem(icon: Icon(Icons.explore), label: "Library"),
            ],
          ),
        ),
      ),
    );
  }
}

// ... Rest of MistRevealScreen class from previous version ...
