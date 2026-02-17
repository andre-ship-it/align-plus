import 'package:flutter/material.dart';
import 'package:flutter/services.dart'; 
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
      body: _getBody(),
      bottomNavigationBar: _buildGlassBottomNav(),
    );
  }

  Widget _getBody() {
    switch (_selectedTab) {
      case 0:
        return MistRevealScreen(
          gifUrl: _ritualGifUrl, 
          imageUrl: _revealImageUrl, 
          title: "Morning Ritual",
          currentStreak: _streak,
          onComplete: (newStreak) => setState(() => _streak = newStreak),
        );
      case 1:
        return _buildLibraryUI();
      case 2:
        return _buildInstallUI();
      default:
        return const SizedBox.shrink();
    }
  }

  Widget _buildLibraryUI() {
    return Stack(
      children: [
        Positioned.fill(child: Image.network(_revealImageUrl, fit: BoxFit.cover)),
        SafeArea(
          child: Column(
            children: [
              const SizedBox(height: 20),
              const Text("30-DAY RESET MAP", 
                style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold, letterSpacing: 2, shadows: [Shadow(blurRadius: 10, color: Colors.black45)])),
              Expanded(
                child: GridView.builder(
                  padding: const EdgeInsets.fromLTRB(25, 30, 25, 120),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 4,
                    mainAxisSpacing: 15,
                    crossAxisSpacing: 15,
                  ),
                  itemCount: 30,
                  itemBuilder: (context, index) {
                    int dayNumber = index + 1;
                    bool isCompleted = dayNumber <= _streak;
                    bool isNext = dayNumber == _streak + 1;

                    return _buildMilestoneTile(dayNumber, isCompleted, isNext);
                  },
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildMilestoneTile(int day, bool isCompleted, bool isNext) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(15),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
        child: Container(
          decoration: BoxDecoration(
            color: isCompleted ? const Color(0xFF008080).withOpacity(0.6) : Colors.white.withOpacity(0.15),
            borderRadius: BorderRadius.circular(15),
            border: Border.all(
              color: isNext ? Colors.white : (isCompleted ? const Color(0xFFB2DFDB) : Colors.white.withOpacity(0.2)),
              width: isNext ? 2 : 1,
            ),
          ),
          child: Center(
            child: Text(
              "$day",
              style: TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: isCompleted || isNext ? FontWeight.bold : FontWeight.normal,
                opacity: isCompleted || isNext ? 1.0 : 0.5,
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildInstallUI() {
    return Stack(
      children: [
        Positioned.fill(child: Image.network(_revealImageUrl, fit: BoxFit.cover)),
        Center(child: _glassCard(
          Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.install_mobile_rounded, color: Colors.white, size: 48),
              const SizedBox(height: 15),
              const Text("Download align+", style: TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold)),
              const SizedBox(height: 15),
              const Text("1. Tap Share\n2. Select 'Add to Home Screen'", 
                textAlign: TextAlign.center, style: TextStyle(color: Colors.white, fontSize: 16, height: 1.5)),
              const SizedBox(height: 25),
              ElevatedButton.icon(
                onPressed: () {
                  Clipboard.setData(const ClipboardData(text: "https://app.myfitvacation.com"));
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text("Invite link copied to clipboard! 📋"), duration: Duration(seconds: 2)),
                  );
                },
                icon: const Icon(Icons.copy_rounded),
                label: const Text("COPY INVITE LINK"),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.white,
                  foregroundColor: const Color(0xFF008080),
                  minimumSize: const Size(double.infinity, 50),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(100)),
                ),
              ),
            ],
          ),
          false,
        )),
      ],
    );
  }

  Widget _glassCard(Widget child, bool isMilestone) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(25),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
        child: Container(
          padding: const EdgeInsets.all(30),
          width: MediaQuery.of(context).size.width * 0.85,
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.2),
            borderRadius: BorderRadius.circular(25),
            border: Border.all(color: isMilestone ? Colors.amber.withOpacity(0.5) : Colors.white.withOpacity(0.3), width: isMilestone ? 2 : 1),
          ),
          child: child,
        ),
      ),
    );
  }

  Widget _buildGlassBottomNav() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 30),
      height: 70,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(35),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 15, sigmaY: 15),
          child: BottomNavigationBar(
            currentIndex: _selectedTab,
            onTap: (index) => setState(() => _selectedTab = index),
            backgroundColor: Colors.white.withOpacity(0.1),
            selectedItemColor: const Color(0xFF008080),
            unselectedItemColor: Colors.white60,
            showSelectedLabels: false,
            showUnselectedLabels: false,
            type: BottomNavigationBarType.fixed,
            items: const [
              BottomNavigationBarItem(icon: Icon(Icons.spa_rounded), label: "Ritual"),
              BottomNavigationBarItem(icon: Icon(Icons.explore_rounded), label: "Map"),
              BottomNavigationBarItem(icon: Icon(Icons.add_to_home_screen_rounded), label: "Install"),
            ],
          ),
        ),
      ),
    );
  }
}

// MistRevealScreen remains unchanged as it handles the core ritual logic.
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
