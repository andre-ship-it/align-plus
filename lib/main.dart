import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:video_player/video_player.dart';
import 'package:confetti/confetti.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:ui';
import 'dart:math';
import 'dart:async';

// Conditional import to prevent crashes on non-web platforms
import 'dart:html' as html if (dart.library.html) 'dart:html';

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
  
  final String _ritualVideoUrl = 'https://storage.googleapis.com/msgsndr/y5pUJDsp1xPu9z0K6inm/media/68815f271933f6215ec16c99.mp4';
  final String _revealImageUrl = 'https://storage.googleapis.com/msgsndr/y5pUJDsp1xPu9z0K6inm/media/6610b1519b8fa973cb15b332.jpeg';

  @override
  void initState() {
    super.initState();
    _loadStreak();
    // PWA Check is moved to post-frame to prevent initialization crashes
    if (kIsWeb) {
      WidgetsBinding.instance.addPostFrameCallback((_) => _checkInstallation());
    }
  }

  void _checkInstallation() {
    try {
      final userAgent = html.window.navigator.userAgent.toLowerCase();
      final bool isIOS = userAgent.contains('iphone') || userAgent.contains('ipad');
      final bool isStandalone = html.window.matchMedia('(display-mode: standalone)').matches ||
                                (html.window.navigator as dynamic).standalone == true;

      if (isIOS && !isStandalone) {
        _showPWAInstallModal();
      }
    } catch (e) {
      debugPrint("PWA Check suppressed: $e");
    }
  }

  void _showPWAInstallModal() {
    showDialog(
      context: context,
      builder: (context) => BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
        child: AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: const Text("Install align+", style: TextStyle(fontWeight: FontWeight.bold)),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: const [
              Text("Add to Home Screen for the full Bali experience."),
              SizedBox(height: 20),
              ListTile(leading: Icon(Icons.ios_share), title: Text("1. Tap Share")),
              ListTile(leading: Icon(Icons.add_box_outlined), title: Text("2. Add to Home Screen")),
            ],
          ),
          actions: [TextButton(onPressed: () => Navigator.pop(context), child: const Text("GOT IT"))],
        ),
      ),
    );
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
        child: _showSurvey 
          ? _buildSurveyUI() 
          : Scaffold(
              extendBody: true,
              body: _selectedTab == 0 
                ? MistRevealScreen(
                    videoUrl: _ritualVideoUrl, 
                    imageUrl: _revealImageUrl, 
                    title: "Morning Ritual",
                    currentStreak: _streak,
                    onComplete: (newStreak) => setState(() => _streak = newStreak),
                  ) 
                : _buildLibraryUI(),
              bottomNavigationBar: _buildGlassBottomNav(),
            ),
      ),
    );
  }

  Widget _buildSurveyUI() {
    return Container(
      key: const ValueKey('survey'),
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
              style: ElevatedButton.styleFrom(minimumSize: const Size(200, 60)),
              child: const Text("Start My Ritual"),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLibraryUI() {
    return Container(
      decoration: const BoxDecoration(gradient: LinearGradient(colors: [Color(0xFFE0F2F1), Color(0xFFB2DFDB)])),
      child: const Center(child: Text("Library coming soon...")),
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

class MistRevealScreen extends StatefulWidget {
  final String videoUrl;
  final String imageUrl;
  final String title;
  final int currentStreak;
  final Function(int) onComplete;

  const MistRevealScreen({
    super.key, 
    required this.videoUrl, 
    required this.imageUrl, 
    required this.title,
    required this.currentStreak,
    required this.onComplete,
  });

  @override
  State<MistRevealScreen> createState() => _MistRevealScreenState();
}

class _MistRevealScreenState extends State<MistRevealScreen> with TickerProviderStateMixin {
  VideoPlayerController? _controller; // Made nullable for safety
  late ConfettiController _confetti;
  late AnimationController _breatheController;
  
  double _sigma = 45.0;
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

    _initVideo();
  }

  void _initVideo() {
    _controller = VideoPlayerController.networkUrl(Uri.parse(widget.videoUrl))
      ..initialize().then((_) {
        if (mounted) {
          _controller?.setLooping(true);
          _controller?.setVolume(0);
          _controller?.play();
          setState(() {});
        }
      }).catchError((e) => debugPrint("Video Init Error: $e"));
  }

  void _updateStreakLogic() async {
    final prefs = await SharedPreferences.getInstance();
    final String? lastDateStr = prefs.getString('last_completion_date');
    final DateTime now = DateTime.now();
    final String todayStr = "${now.year}-${now.month}-${now.day}";

    int newStreak = widget.currentStreak;
    if (lastDateStr != todayStr) {
      if (lastDateStr != null) {
        final DateTime lastDate = DateTime.parse(lastDateStr);
        if (now.difference(lastDate).inDays == 1) newStreak++;
        else if (now.difference(lastDate).inDays > 1) newStreak = 1;
      } else {
        newStreak = 1;
      }
      await prefs.setInt('streak_count', newStreak);
      await prefs.setString('last_completion_date', todayStr);
      widget.onComplete(newStreak);
    }
  }

  void _startStretch() {
    setState(() { _isStretching = true; _timerSeconds = 30; });
    _breatheController.forward();
    _stretchTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_timerSeconds > 0) setState(() => _timerSeconds--);
      else {
        _stretchTimer?.cancel();
        _breatheController.stop();
        setState(() {
          _isStretching = false; 
          _movements++;
          _sigma = (45.0 - (_movements * 9.0)).clamp(0, 45);
          if (_movements == 5) {
            _confetti.play();
            _updateStreakLogic();
          }
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Positioned.fill(
          child: (_controller != null && _controller!.value.isInitialized)
              ? VideoPlayer(_controller!)
              : Image.network(widget.imageUrl, fit: BoxFit.cover),
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
              if (_isStretching) _buildBreatheUI(),
              Padding(
                padding: const EdgeInsets.all(30.0),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(30),
                  child: BackdropFilter(
                    filter: ImageFilter.blur(sigmaX: 15, sigmaY: 15),
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 40, horizontal: 20),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(_isStretching ? 0.0 : 0.25),
                        borderRadius: BorderRadius.circular(30),
                        border: Border.all(color: Colors.white.withOpacity(_isStretching ? 0.0 : 0.4)),
                      ),
                      child: Opacity(
                        opacity: _isStretching ? 0.0 : 1.0,
                        child: _movements == 5 ? _buildSummaryUI() : _buildActionUI(),
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

  Widget _buildBreatheUI() {
    return Center(
      child: FadeTransition(
        opacity: _breatheController,
        child: Column(
          children: [
            Text(_breatheController.value > 0.5 ? "Breathe Out..." : "Breathe In...", 
              style: const TextStyle(fontSize: 28, color: Colors.white, fontWeight: FontWeight.w300, shadows: [Shadow(blurRadius: 15, color: Colors.black54)])),
            Text("$_timerSeconds", style: const TextStyle(fontSize: 60, color: Colors.white, fontWeight: FontWeight.bold)),
          ],
        ),
      ),
    );
  }

  Widget _buildActionUI() {
    return Column(
      children: [
        Text("${_movements}/5", style: const TextStyle(fontSize: 48, fontWeight: FontWeight.w900, color: Color(0xFF004D40))),
        const Text("STRETCH PROGRESS", style: TextStyle(fontSize: 12, letterSpacing: 2, fontWeight: FontWeight.bold)),
        const SizedBox(height: 30),
        ElevatedButton(onPressed: _startStretch, child: const Text("BEGIN STRETCH ✅")),
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
          onPressed: () => launchUrl(Uri.parse('https://www.myfitvacation.com/align-rewards-page')), 
          child: const Text("CLAIM REWARD 🎁"),
        ),
      ],
    );
  }

  Widget _stat(String val, String label) => Column(children: [Text(val, style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold)), Text(label, style: const TextStyle(fontSize: 10))]);

  @override
  void dispose() { 
    _controller?.dispose(); 
    _confetti.dispose(); 
    _breatheController.dispose(); 
    _stretchTimer?.cancel(); 
    super.dispose(); 
  }
}
