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
  
  String _activeTitle = "Morning Ritual";
  final String _revealImageUrl = 'https://storage.googleapis.com/msgsndr/y5pUJDsp1xPu9z0K6inm/media/6610b1519b8fa973cb15b332.jpeg';

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
                ? MistRevealScreen(imageUrl: _revealImageUrl, title: _activeTitle) 
                : _buildLibraryUI(),
              bottomNavigationBar: _buildGlassBottomNav(),
            ),
      ),
    );
  }

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
                      Text(_questions[index]['q'], style: const TextStyle(fontSize: 32, fontWeight: FontWeight.w900), textAlign: TextAlign.center),
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
          _libCard("Lower Back Relief", "Post-work tension release"),
          _libCard("Deep Neck Stretch", "Desk-worker recovery"),
        ],
      ),
    );
  }

  Widget _libCard(String title, String subtitle) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: ListTile(
        contentPadding: const EdgeInsets.all(15),
        leading: const CircleAvatar(backgroundColor: Color(0xFF008080), child: Icon(Icons.play_arrow, color: Colors.white)),
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Text(subtitle),
        onTap: () => setState(() => _selectedTab = 0),
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

class MistRevealScreen extends StatefulWidget {
  final String imageUrl;
  final String title;
  const MistRevealScreen({super.key, required this.imageUrl, required this.title});

  @override
  State<MistRevealScreen> createState() => _MistRevealScreenState();
}

class _MistRevealScreenState extends State<MistRevealScreen> {
  late ConfettiController _confetti;
  double _sigma = 45.0;
  int _movements = 0;

  @override
  void initState() {
    super.initState();
    _confetti = ConfettiController(duration: const Duration(seconds: 3));
  }

  @override
  void dispose() {
    _confetti.dispose();
    super.dispose();
  }

  Future<void> _launchRewardLink() async {
    // UPDATED: Now points to your HotelPlanner portal
    final Uri url = Uri.parse('https://myfitvacation.hotelplanner.com/');
    if (!await launchUrl(url)) throw Exception('Could not launch $url');
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Positioned.fill(
          child: Image.network(widget.imageUrl, fit: BoxFit.cover),
        ),
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
              const SizedBox(height: 100),
            ],
          ),
        ),
      ],
    );
  }
}
