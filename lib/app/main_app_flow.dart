import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:ui';
import 'dart:async';
import 'package:url_launcher/url_launcher.dart';

// Import your modular ritual feature
import '../features/ritual/mist_reveal_screen.dart'; 

class MainAppFlow extends StatefulWidget {
  const MainAppFlow({super.key});

  @override
  State<MainAppFlow> createState() => _MainAppFlowState();
}

class _MainAppFlowState extends State<MainAppFlow> {
  bool _showSurvey = true;
  int _selectedTab = 0;
  int _streak = 0;
  int _giveawayEntries = 0;

  final String _ritualGifUrl = 'https://storage.googleapis.com/msgsndr/y5pUJDsp1xPu9z0K6inm/media/6994f4341ecd71b1446848f5.gif';
  final String _revealImageUrl = 'https://storage.googleapis.com/msgsndr/y5pUJDsp1xPu9z0K6inm/media/6610b1519b8fa973cb15b332.jpeg';

  final List<String> _locations = [
    "Ubud Jungle Sanctuary", "Uluwatu Cliffside", "Seminyak Shoreline", 
    "Canggu Zen Garden", "Nusa Penida Peak", "Amed Volcanic Coast", "Sidemen Healing Valley"
  ];

  final List<String> _stretches = [
    "Slow Chaturanga Flow", "Segmental Cat-Cow", "90/90 Hip Reset",
    "Active Thoracic Cobra", "Low Lunge Psoas Reach", "Lateral QL Extension", "Deep Squat Integration"
  ];

  final List<String> _focusAreas = [
    "Shoulder & Scapular Stability", "Lumbar Spine Decompression", "Pelvic Internal Rotation",
    "Postural Chain Realignment", "Anterior Chain Relief", "Lateral Line Balance", "Full Body Structural Reset"
  ];

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
      _calculateEntries(_streak);
    });
    _checkFirstRun(prefs);
  }

  void _calculateEntries(int streak) {
    int baseEntries = streak;
    int bonus = 0;
    if (streak >= 7) bonus += 10;
    if (streak >= 15) bonus += 25;
    if (streak >= 30) bonus += 100;
    _giveawayEntries = baseEntries + bonus;
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
              const Text("Welcome to FitWell", textAlign: TextAlign.center,
                style: TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold)),
              const SizedBox(height: 15),
              const Text("Perform daily Proof-of-Work movements to earn entries for the Bali Vacation Giveaway.",
                textAlign: TextAlign.center, style: TextStyle(color: Colors.white70, fontSize: 16, height: 1.5)),
              const SizedBox(height: 30),
              ElevatedButton(
                onPressed: () => Navigator.pop(context),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF008080), 
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(100)),
                  minimumSize: const Size(200, 50)
                ),
                child: const Text("BEGIN REHAB"),
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

  Widget _buildSurveyUI() {
    return Container(
      width: double.infinity,
      height: double.infinity,
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
              onPressed: () async {
                final prefs = await SharedPreferences.getInstance();
                await prefs.setBool('survey_completed', true);
                setState(() => _showSurvey = false);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.white, 
                foregroundColor: const Color(0xFF008080),
                minimumSize: const Size(220, 65),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(100))
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
      case 0: return _buildRitualUI();
      case 1: return _buildLibraryUI();
      case 2: return _buildShareUI();
      case 3: return _buildInstallUI();
      default: return const SizedBox.shrink();
    }
  }

  Widget _buildRitualUI() {
    return Stack(
      children: [
        SizedBox.expand(
          child: Image.network(_revealImageUrl, fit: BoxFit.cover,
            errorBuilder: (context, error, stackTrace) => Container(color: Colors.black)),
        ),
        MistRevealScreen(
          gifUrl: _ritualGifUrl, 
          imageUrl: _revealImageUrl, 
          title: "Entries: $_giveawayEntries | ${_stretches[_streak % 7]}",
          currentStreak: _streak,
          onComplete: (newStreak) async {
            final prefs = await SharedPreferences.getInstance();
            await prefs.setInt('streak_count', newStreak);
            setState(() {
              _streak = newStreak;
              _calculateEntries(newStreak);
            });
          },
        ),
      ],
    );
  }

  Widget _buildLibraryUI() {
    return Stack(
      children: [
        Positioned.fill(child: Image.network(_revealImageUrl, fit: BoxFit.cover)),
        SafeArea(
          child: Column(
            children: [
              const SizedBox(height: 20),
              const Text("REHABILITATION MAP", 
                style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold, letterSpacing: 2, shadows: [Shadow(blurRadius: 10, color: Colors.black45)])),
              Expanded(
                child: GridView.builder(
                  padding: const EdgeInsets.fromLTRB(25, 30, 25, 120),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2, mainAxisSpacing: 15, crossAxisSpacing: 15, childAspectRatio: 1.2),
                  itemCount: 30,
                  itemBuilder: (context, index) {
                    int day = index + 1;
                    return _buildMilestoneTile(
                      day, 
                      day <= _streak, 
                      day == _streak + 1,
                      _locations[index % 7], 
                      _stretches[index % 7], 
                      _focusAreas[index % 7]
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildMilestoneTile(int day, bool isComp, bool isNext, String loc, String foc, String area) {
    bool isBonusDay = (day == 7 || day == 15 || day == 30);
    return ClipRRect(
      borderRadius: BorderRadius.circular(15),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
        child: Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: isComp ? const Color(0xFF008080).withOpacity(0.7) : Colors.white.withOpacity(0.1),
            borderRadius: BorderRadius.circular(15),
            border: Border.all(color: isNext ? Colors.white : (isBonusDay ? Colors.amberAccent : Colors.white.withOpacity(0.2)), width: isNext ? 2 : 1),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text("D$day", style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 10)),
                  if (isBonusDay) const Icon(Icons.star, color: Colors.amberAccent, size: 12),
                ],
              ),
              const Spacer(),
              Text(foc, maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold)),
              Text(area, maxLines: 1, overflow: TextOverflow.ellipsis, style: TextStyle(color: Colors.white.withOpacity(0.6), fontSize: 9, fontStyle: FontStyle.italic)),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildShareUI() {
    return Stack(
      children: [
        Positioned.fill(child: Image.network(_revealImageUrl, fit: BoxFit.cover)),
        Center(child: _glassCard(
          Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.card_giftcard, color: Colors.white, size: 48),
              const SizedBox(height: 15),
              const Text("Invite & Earn", style: TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold)),
              const SizedBox(height: 15),
              const Text("Multiply your entries by inviting friends to the Reset. +5 entries per referral.", 
                textAlign: TextAlign.center, style: TextStyle(color: Colors.white, fontSize: 14, height: 1.5)),
              const SizedBox(height: 25),
              ElevatedButton.icon(
                onPressed: () {
                  Clipboard.setData(const ClipboardData(text: "I'm earning entries for a free Bali vacation on app.fitwell.life 🌴 Join the 30-Day Reset!"));
                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Referral copied! 🌴")));
                },
                icon: const Icon(Icons.copy_rounded),
                label: const Text("COPY REFERRAL LINK"),
                style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF008080), foregroundColor: Colors.white, minimumSize: const Size(double.infinity, 50), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(100))),
              ),
            ],
          ),
        )),
      ],
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
              const Text("FitWell Home Screen", style: TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold)),
              const SizedBox(height: 15),
              const Text("1. Tap Share\n2. Select 'Add to Home Screen'", textAlign: TextAlign.center, style: TextStyle(color: Colors.white, fontSize: 16, height: 1.5)),
              const SizedBox(height: 25),
              ElevatedButton.icon(
                onPressed: () {
                  Clipboard.setData(const ClipboardData(text: "https://app.fitwell.life"));
                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Link copied! 📋")));
                },
                icon: const Icon(Icons.link_rounded),
                label: const Text("COPY APP LINK"),
                style: ElevatedButton.styleFrom(backgroundColor: Colors.white, foregroundColor: const Color(0xFF008080), minimumSize: const Size(double.infinity, 50), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(100))),
              ),
            ],
          ),
        )),
      ],
    );
  }

  Widget _glassCard(Widget child) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(25),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
        child: Container(
          padding: const EdgeInsets.all(30),
          width: MediaQuery.of(context).size.width * 0.85,
          constraints: const BoxConstraints(maxWidth: 500),
          decoration: BoxDecoration(color: Colors.white.withOpacity(0.2), borderRadius: BorderRadius.circular(25), border: Border.all(color: Colors.white.withOpacity(0.3))),
          child: child,
        ),
      ),
    );
  }

  Widget _buildGlassBottomNav() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 15, vertical: 30),
      height: 70,
      constraints: const BoxConstraints(maxWidth: 700),
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
              BottomNavigationBarItem(icon: Icon(Icons.card_giftcard), label: "Earn"),
              BottomNavigationBarItem(icon: Icon(Icons.add_to_home_screen_rounded), label: "Install"),
            ],
          ),
        ),
      ),
    );
  }
}
