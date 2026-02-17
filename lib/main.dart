import 'package:flutter/material.dart';
import 'package:confetti/confetti.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:ui';
import 'dart:math';
import 'dart:async';

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
  int _streak = 0;
  
  final String _ritualGifUrl = 'https://storage.googleapis.com/msgsndr/y5pUJDsp1xPu9z0K6inm/media/6994079954da040a6970fcb2.gif'; 
  final String _revealImageUrl = 'https://storage.googleapis.com/msgsndr/y5pUJDsp1xPu9z0K6inm/media/6610b1519b8fa973cb15b332.jpeg';

  @override
  void initState() {
    super.initState();
    _loadStreak();
  }

  _loadStreak() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() => _streak = prefs.getInt('streak_count') ?? 0);
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

  Widget _buildSurveyUI() {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(colors: [Color(0xFF004D40), Color(0xFF008080)]),
      ),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text("Ready to Align?", style: TextStyle(color: Colors.white, fontSize: 32, fontWeight: FontWeight.bold)),
            const SizedBox(height: 30),
            ElevatedButton(
              onPressed: () => setState(() => _showSurvey = false),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.white,
                foregroundColor: const Color(0xFF008080),
                minimumSize: const Size(220, 65),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(100)),
              ),
              child: const Text("Start My Ritual", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMainApp() {
    return Scaffold(
      extendBody: true,
      body: _selectedTab == 0 
        ? MistRevealScreen(
            gifUrl: _ritualGifUrl, 
            imageUrl: _revealImageUrl, 
            title: "Morning Ritual",
            currentStreak: _streak,
            onComplete: (newStreak) => setState(() => _streak = newStreak),
          ) 
        : _buildLibraryUI(),
      bottomNavigationBar: _buildGlassBottomNav(),
    );
  }

  Widget _buildLibraryUI() {
    return Stack(
      children: [
        Positioned.fill(
          child: Image.network(
            _revealImageUrl,
            fit: BoxFit.cover,
          ),
        ),
        Center(
          child: ClipRRect(
            borderRadius: BorderRadius.circular(25),
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
              child: Container(
                padding: const EdgeInsets.all(30),
                width: MediaQuery.of(context).size.width * 0.85,
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(25),
                  border: Border.all(color: Colors.white.withOpacity(0.3)),
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Text(
                      "Bali Library",
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        shadows: [Shadow(blurRadius: 10, color: Colors.black38)],
                      ),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      "Current Streak: $_streak Days 🔥",
                      style: const TextStyle(color: Colors.white, fontSize: 18),
                    ),
                    const SizedBox(height: 25),
                    
                    // SOCIAL SHARING BUTTON
                    ElevatedButton.icon(
                      onPressed: () async {
                        final String shareText = "I'm on a $_streak-day morning alignment streak with align+ 🌴✨";
                        final String shareUrl = "https://app.myfitvacation.com";
                        
                        // Using mailto as a fallback, but the logic is ready for Web Share
                        final Uri emailUri = Uri.parse(
                          'mailto:?subject=My Bali Alignment Streak&body=$shareText $shareUrl'
                        );
                        
                        if (await canLaunchUrl(emailUri)) {
                          await launchUrl(emailUri);
                        }
                      },
                      icon: const Icon(Icons.share_rounded),
                      label: const Text("SHARE TO SOCIALS"),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF008080),
                        foregroundColor: Colors.white,
                        minimumSize: const Size(double.infinity, 50),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(100)),
                      ),
                    ),
                    
                    const SizedBox(height: 20),
                    const Text(
                      "Full Library Coming Soon",
                      style: TextStyle(color: Colors.white70, fontSize: 12, letterSpacing: 1),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildGlassBottomNav() {
    return Container(
      margin: const EdgeInsets.all(25),
      height: 75,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(35),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
          child: BottomNavigationBar(
            currentIndex: _selectedTab,
            onTap: (index) => setState(() => _selectedTab = index),
            backgroundColor: Colors.white.withOpacity(0.1),
            selectedItemColor: const Color(0xFF004D40),
            items: const [
              BottomNavigationBarItem(icon: Icon(Icons.spa_rounded), label: "Ritual"),
              BottomNavigationBarItem(icon: Icon(Icons.explore_rounded), label: "Library"),
            ],
          ),
        ),
      ),
    );
  }
}

// ... MistRevealScreen class remains identical to your current main.dart ...
class MistRevealScreen extends StatefulWidget {
  final String gifUrl;
  final String imageUrl;
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

class _MistRevealScreenState extends State<MistRevealScreen> with TickerProviderStateMixin {
  late ConfettiController _confetti;
  late AnimationController _breatheController;
  int _movements = 0;
  bool _isStretching = false; 
  int _timerSeconds = 30; 
  Timer? _stretchTimer;

  @override
  void initState() {
    super.initState();
    _confetti = ConfettiController(duration: const Duration(seconds: 3));
    _breatheController = AnimationController(vsync: this, duration: const Duration(seconds: 4))
      ..addStatusListener((status) {
        if (status == AnimationStatus.completed) _breatheController.reverse();
        else if (status == AnimationStatus.dismissed) _breatheController.forward();
      });
  }

  void _startStretch() {
    setState(() { _isStretching = true; _timerSeconds = 30; });
    _breatheController.forward();
    _stretchTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_timerSeconds > 0) {
        setState(() => _timerSeconds--);
      } else {
        _stretchTimer?.cancel();
        _breatheController.stop();
        setState(() {
          _isStretching = false; 
          _movements++;
          if (_movements == 5) {
            _confetti.play();
            _updateStreak();
          }
        });
      }
    });
  }

  void _updateStreak() async {
    final prefs = await SharedPreferences.getInstance();
    final today = DateTime.now();
    final todayStr = "${today.year}-${today.month}-${today.day}";
    final lastDateStr = prefs.getString('last_completion_date');
    int newStreak = widget.currentStreak;
    if (lastDateStr != todayStr) {
      if (lastDateStr != null) {
        final lastDate = DateTime.parse(lastDateStr);
        if (today.difference(lastDate).inDays == 1) newStreak++;
        else if (today.difference(lastDate).inDays > 1) newStreak = 1;
      } else { newStreak = 1; }
      await prefs.setInt('streak_count', newStreak);
      await prefs.setString('last_completion_date', todayStr);
      widget.onComplete(newStreak);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Positioned.fill(
          child: Image.network(
            _movements == 5 ? widget.imageUrl : widget.gifUrl, 
            fit: BoxFit.cover,
          ),
        ),
        Align(alignment: Alignment.topCenter, child: ConfettiWidget(confettiController: _confetti, blastDirection: pi/2)),
        SafeArea(
          child: Column(
            children: [
              const SizedBox(height: 40),
              Text(widget.title.toUpperCase(), 
                style: const TextStyle(fontSize: 14, letterSpacing: 4, color: Color(0xFF008080), fontWeight: FontWeight.bold, shadows: [Shadow(blurRadius: 10, color: Colors.white)])),
              const Spacer(),
              if (_isStretching) _buildBreatheUI(),
              Padding(
                padding: const EdgeInsets.all(30.0),
                child: Container(
                  padding: const EdgeInsets.symmetric(vertical: 40, horizontal: 20),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(_isStretching ? 0.0 : 0.85), 
                    borderRadius: BorderRadius.circular(30),
                    border: Border.all(color: Colors.white.withOpacity(_isStretching ? 0.0 : 0.4)),
                  ),
                  child: Opacity(
                    opacity: _isStretching ? 0.0 : 1.0,
                    child: _movements == 5 ? _buildSummaryUI() : _buildActionUI(),
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

  Widget _buildBreatheUI() {
    return FadeTransition(
      opacity: _breatheController,
      child: Column(
        children: [
          Text(_breatheController.value > 0.5 ? "Breathe Out..." : "Breathe In...", 
            style: const TextStyle(fontSize: 28, color: Colors.white, fontWeight: FontWeight.w300, shadows: [Shadow(blurRadius: 15, color: Colors.black45)])),
          Text("$_timerSeconds", style: const TextStyle(fontSize: 60, color: Colors.white, fontWeight: FontWeight.bold, shadows: [Shadow(blurRadius: 15, color: Colors.black45)])),
        ],
      ),
    );
  }

  Widget _buildActionUI() {
    return Column(
      children: [
        Text("${_movements}/5", style: const TextStyle(fontSize: 48, fontWeight: FontWeight.w900, color: Color(0xFF004D40))),
        const Text("STRETCH PROGRESS", style: TextStyle(fontSize: 12, letterSpacing: 2, fontWeight: FontWeight.bold)),
        const SizedBox(height: 30),
        ElevatedButton(
          onPressed: _startStretch, 
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF008080),
            foregroundColor: Colors.white,
            minimumSize: const Size(double.infinity, 60),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(100)),
          ),
          child: const Text("BEGIN STRETCH ✅", style: TextStyle(fontWeight: FontWeight.bold)),
        ),
      ],
    );
  }

  Widget _buildSummaryUI() {
    return Column(
      children: [
        const Text("SESSION COMPLETE", style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Color(0xFF004D40))),
        const SizedBox(height: 20),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            _stat("2.5", "MINUTES"),
            _stat("${widget.currentStreak}", "DAY STREAK 🔥"),
          ],
        ),
        const SizedBox(height: 30),
        ElevatedButton(
          onPressed: () async {
            final Uri url = Uri.parse('https://www.myfitvacation.com/align-rewards-page');
            await launchUrl(url, mode: LaunchMode.externalApplication);
          }, 
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.orangeAccent,
            foregroundColor: Colors.white,
            minimumSize: const Size(double.infinity, 60),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(100)),
          ),
          child: const Text("CLAIM REWARD 🎁", style: TextStyle(fontWeight: FontWeight.bold)),
        ),
      ],
    );
  }

  Widget _stat(String val, String label) => Column(children: [Text(val, style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold)), Text(label, style: const TextStyle(fontSize: 10))]);

  @override
  void dispose() { 
    _confetti.dispose(); 
    _breatheController.dispose(); 
    _stretchTimer?.cancel(); 
    super.dispose(); 
  }
}
