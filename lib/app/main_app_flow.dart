import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:ui';
import 'dart:async';
import 'package:url_launcher/url_launcher.dart';

class MainAppFlow extends StatefulWidget {
  const MainAppFlow({super.key});
  @override
  State<MainAppFlow> createState() => _MainAppFlowState();
}

class _MainAppFlowState extends State<MainAppFlow> {
  bool _showWelcome = true;
  int _selectedTab = 0;
  int _streak = 0;
  int _giveawayEntries = 0;
  bool _isRitualActive = false;

  int _breathSeconds = 30;
  Timer? _breathTimer;
  bool _isExhaling = false;

  final String _day1Gif = 'https://storage.googleapis.com/msgsndr/y5pUJDsp1xPu9z0K6inm/media/6994f4341ecd71b1446848f5.gif';
  final String _bgImage = 'https://storage.googleapis.com/msgsndr/y5pUJDsp1xPu9z0K6inm/media/6610b1519b8fa973cb15b332.jpeg';
  final String _hotelUrl = 'https://myfitvacation.hotelplanner.com';

  final List<String> _stretches = ["Slow Chaturanga", "Segmental Cat-Cow", "90/90 Hip Reset", "Active Cobra", "Low Lunge Reach", "Lateral QL Extension", "Deep Squat"];
  final List<String> _descriptors = [
    "Focus on slow descent to stabilize the scapula and strengthen the serratus anterior.",
    "Isolate each vertebrae. Move like a wave to hydrate the spinal discs and release tension.",
    "Clear hip impingement. Sit tall and rotate internally to restore natural gait patterns.",
    "Strengthen the posterior chain. Peel your chest up to counteract forward-slump posture.",
    "Release the psoas. Reach high to lengthen the anterior chain and fix pelvic tilt.",
    "Balance the quadratus lumborum. Open the side body to resolve uneven hip height.",
    "The ultimate structural test. Sit deep to integrate ankle, knee, and hip mobility."
  ];

  @override
  void initState() {
    super.initState();
    _loadProgress();
  }

  void _loadProgress() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _streak = prefs.getInt('streak_count') ?? 0;
      _calculateEntries(_streak);
    });
  }

  void _calculateEntries(int s) {
    int b = s + (s >= 30 ? 100 : s >= 15 ? 25 : s >= 7 ? 10 : 0);
    setState(() => _giveawayEntries = b);
  }

  void _startBreathing() {
    _breathSeconds = 30;
    _breathTimer?.cancel();
    _breathTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_breathSeconds > 0) {
        setState(() {
          _breathSeconds--;
          if (_breathSeconds % 5 == 0) _isExhaling = !_isExhaling;
        });
      } else {
        timer.cancel();
      }
    });
  }

  Future<void> _launchUrl(String url) async {
    final Uri uri = Uri.parse(url);
    if (!await launchUrl(uri, mode: LaunchMode.externalApplication)) {
      throw Exception('Could not launch $url');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: AnimatedSwitcher(
        duration: const Duration(milliseconds: 600),
        child: _showWelcome ? _buildWelcomeUI() : _buildMainApp(),
      ),
    );
  }

  Widget _buildWelcomeUI() {
    return Container(
      width: double.infinity,
      decoration: const BoxDecoration(
        gradient: LinearGradient(colors: [Color(0xFF004D40), Color(0xFF008080)]),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.auto_awesome, color: Colors.white, size: 80),
          const SizedBox(height: 20),
          const Text("FitWell Align+", style: TextStyle(color: Colors.white, fontSize: 36, fontWeight: FontWeight.bold)),
          const Padding(
            padding: EdgeInsets.all(30.0),
            child: Text("Your daily rehabilitative reset.\nAlign your body. Earn your escape.", 
              textAlign: TextAlign.center, style: TextStyle(color: Colors.white70, fontSize: 18)),
          ),
          const SizedBox(height: 40),
          ElevatedButton(
            onPressed: () => setState(() => _showWelcome = false),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.white, foregroundColor: const Color(0xFF008080), minimumSize: const Size(250, 65), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(100))),
            child: const Text("START MY RESET", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  Widget _buildMainApp() {
    return Scaffold(extendBody: true, body: _getBody(), bottomNavigationBar: _buildGlassBottomNav());
  }

  Widget _getBody() {
    switch (_selectedTab) {
      case 0: return _buildRitualUI();
      case 1: return _buildMapUI();
      case 2: return _buildIncentiveUI();
      case 3: return _buildInstallUI();
      default: return Container();
    }
  }

  Widget _buildRitualUI() {
    int dayIdx = _streak % 7;
    return Stack(
      children: [
        Positioned.fill(child: Image.network(_bgImage, fit: BoxFit.cover)),
        Center(
          child: _isRitualActive 
            ? _buildActiveRitual(dayIdx) 
            : _buildRitualIntro(dayIdx),
        ),
      ],
    );
  }

  Widget _buildRitualIntro(int idx) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 30),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text("DAY ${_streak + 1}", style: const TextStyle(color: Colors.white, fontSize: 48, fontWeight: FontWeight.bold)),
          Text(_stretches[idx], style: const TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold)),
          const SizedBox(height: 20),
          // High Contrast Descriptor
          Container(
            padding: const EdgeInsets.all(15),
            decoration: BoxDecoration(color: Colors.black45, borderRadius: BorderRadius.circular(15)),
            child: Text(_descriptors[idx], 
              textAlign: TextAlign.center, 
              style: const TextStyle(color: Colors.white, fontSize: 16, height: 1.5, fontWeight: FontWeight.w600)),
          ),
          const SizedBox(height: 50),
          ElevatedButton(
            onPressed: () {
              setState(() => _isRitualActive = true);
              _startBreathing();
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.white, foregroundColor: const Color(0xFF008080), minimumSize: const Size(220, 60)),
            child: const Text("BEGIN MOVEMENT"),
          )
        ],
      ),
    );
  }

  Widget _buildActiveRitual(int idx) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 12),
          decoration: BoxDecoration(color: Colors.black54, borderRadius: BorderRadius.circular(50)),
          child: Text(
            _breathSeconds > 0 ? (_isExhaling ? "BREATHE OUT: $_breathSeconds" : "BREATHE IN: $_breathSeconds") : "READY TO COMPLETE",
            style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
          ),
        ),
        const SizedBox(height: 30),
        ClipRRect(borderRadius: BorderRadius.circular(20), child: Image.network(_day1Gif, height: 350, fit: BoxFit.contain)),
        const SizedBox(height: 40),
        if (_breathSeconds == 0)
          ElevatedButton(
            onPressed: () async {
              final prefs = await SharedPreferences.getInstance();
              int n = _streak + 1;
              await prefs.setInt('streak_count', n);
              setState(() { _streak = n; _calculateEntries(n); _isRitualActive = false; _showWelcome = true; });
            },
            style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF008080), foregroundColor: Colors.white, minimumSize: const Size(200, 55)),
            child: const Text("COMPLETE"),
          )
      ],
    );
  }

  Widget _buildMapUI() {
    return Stack(children: [
      Positioned.fill(child: Image.network(_bgImage, fit: BoxFit.cover)),
      GridView.builder(
        padding: const EdgeInsets.fromLTRB(20, 20, 20, 100),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 2, mainAxisSpacing: 15, crossAxisSpacing: 15),
        itemCount: 30,
        itemBuilder: (c, i) => Container(
          decoration: BoxDecoration(color: i < _streak ? const Color(0xFF008080).withOpacity(0.8) : Colors.white10, borderRadius: BorderRadius.circular(15)),
          child: Center(child: Text("Day ${i + 1}", style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold))),
        ),
      ),
    ]);
  }

  Widget _buildIncentiveUI() {
    return Stack(children: [
      Positioned.fill(child: Image.network(_bgImage, fit: BoxFit.cover)),
      Center(child: _glassCard(Column(mainAxisSize: MainAxisSize.min, children: [
        const Icon(Icons.card_giftcard, color: Colors.white, size: 48),
        const SizedBox(height: 10),
        Text("$_giveawayEntries ENTRIES", style: const TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold)),
        const SizedBox(height: 20),
        ElevatedButton.icon(
          onPressed: () => _launchUrl(_hotelUrl),
          icon: const Icon(Icons.hotel),
          label: const Text("BOOK EXCLUSIVE HOTELS"),
          style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF008080), foregroundColor: Colors.white, minimumSize: const Size(double.infinity, 50)),
        ),
        const SizedBox(height: 12),
        ElevatedButton(
          onPressed: () { Clipboard.setData(const ClipboardData(text: "Join me on app.fitwell.life 🌴")); ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Invite Link Copied!"))); },
          style: ElevatedButton.styleFrom(backgroundColor: Colors.white, foregroundColor: const Color(0xFF008080), minimumSize: const Size(double.infinity, 50)),
          child: const Text("INVITE FRIENDS (+5 ENTRIES)"),
        ),
      ]))),
    ]);
  }

  Widget _buildInstallUI() {
    return Stack(children: [
      Positioned.fill(child: Image.network(_bgImage, fit: BoxFit.cover)),
      Center(child: _glassCard(Column(mainAxisSize: MainAxisSize.min, children: [
        const Icon(Icons.install_mobile, color: Colors.white, size: 48),
        const SizedBox(height: 15),
        const Text("Install Align+", style: TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold)),
        const Text("1. Tap Share\n2. Add to Home Screen", textAlign: TextAlign.center, style: TextStyle(color: Colors.white, fontSize: 16)),
      ]))),
    ]);
  }

  Widget _glassCard(Widget child) {
    return ClipRRect(borderRadius: BorderRadius.circular(25), child: BackdropFilter(filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10), child: Container(padding: const EdgeInsets.all(30), decoration: BoxDecoration(color: Colors.white.withOpacity(0.2), borderRadius: BorderRadius.circular(25), border: Border.all(color: Colors.white.withOpacity(0.3))), child: child)));
  }

  Widget _buildGlassBottomNav() {
    return BottomNavigationBar(
      currentIndex: _selectedTab,
      onTap: (i) => setState(() => _selectedTab = i),
      backgroundColor: Colors.black87,
      selectedItemColor: const Color(0xFF008080),
      unselectedItemColor: Colors.white38,
      type: BottomNavigationBarType.fixed,
      items: const [
        BottomNavigationBarItem(icon: Icon(Icons.spa), label: "Ritual"),
        BottomNavigationBarItem(icon: Icon(Icons.map), label: "Map"),
        BottomNavigationBarItem(icon: Icon(Icons.card_giftcard), label: "Earn"),
        BottomNavigationBarItem(icon: Icon(Icons.download), label: "Install"),
      ],
    );
  }
}
