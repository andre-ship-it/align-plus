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
  bool _showSurvey = true;
  int _selectedTab = 0;
  int _streak = 0;
  int _giveawayEntries = 0;
  bool _isRitualActive = false;

  final String _day1Gif = 'https://storage.googleapis.com/msgsndr/y5pUJDsp1xPu9z0K6inm/media/6994f4341ecd71b1446848f5.gif';
  final String _bgImage = 'https://storage.googleapis.com/msgsndr/y5pUJDsp1xPu9z0K6inm/media/6610b1519b8fa973cb15b332.jpeg';
  final String _communityUrl = 'https://Align.fitwell.life';

  final List<String> _locations = ["Ubud", "Uluwatu", "Seminyak", "Canggu", "Nusa Penida", "Amed", "Sidemen"];
  final List<String> _stretches = ["Slow Chaturanga", "Segmental Cat-Cow", "90/90 Hip Reset", "Active Cobra", "Low Lunge Reach", "Lateral QL Extension", "Deep Squat"];
  final List<String> _focusAreas = ["Shoulder Stability", "Lumbar Decompression", "Pelvic Rotation", "Postural Realignment", "Anterior Chain Relief", "Lateral Line Balance", "Full Body Reset"];

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
  }

  void _calculateEntries(int streak) {
    int base = streak;
    if (streak >= 30) base += 100;
    else if (streak >= 15) base += 25;
    else if (streak >= 7) base += 10;
    setState(() => _giveawayEntries = base);
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
        duration: const Duration(milliseconds: 500),
        child: _showSurvey ? _buildSurveyUI() : _buildMainApp(),
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
    int dayIndex = _streak % 7;
    return Stack(
      children: [
        Positioned.fill(child: Image.network(_bgImage, fit: BoxFit.cover)),
        Center(
          child: _isRitualActive 
            ? _buildActiveRitual(dayIndex) 
            : _buildRitualLanding(dayIndex),
        ),
      ],
    );
  }

  Widget _buildRitualLanding(int dayIndex) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text("DAY ${_streak + 1}", style: const TextStyle(color: Colors.white, fontSize: 42, fontWeight: FontWeight.bold)),
        Text(_stretches[dayIndex], style: const TextStyle(color: Colors.white70, fontSize: 20)),
        const SizedBox(height: 40),
        ElevatedButton(
          onPressed: () => setState(() => _isRitualActive = true),
          style: ElevatedButton.styleFrom(backgroundColor: Colors.white, foregroundColor: const Color(0xFF008080), minimumSize: const Size(220, 60)),
          child: const Text("BEGIN REHAB"),
        )
      ],
    );
  }

  Widget _buildActiveRitual(int dayIndex) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(20),
          child: Image.network(_day1Gif, height: 400, fit: BoxFit.contain),
        ),
        const SizedBox(height: 20),
        Text(_stretches[dayIndex], style: const TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold)),
        Text(_focusAreas[dayIndex], style: const TextStyle(color: Colors.white60, fontSize: 16)),
        const SizedBox(height: 30),
        ElevatedButton(
          onPressed: () async {
            final prefs = await SharedPreferences.getInstance();
            int nextStreak = _streak + 1;
            await prefs.setInt('streak_count', nextStreak);
            setState(() {
              _streak = nextStreak;
              _calculateEntries(nextStreak);
              _isRitualActive = false;
            });
          },
          style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF008080), foregroundColor: Colors.white, minimumSize: const Size(200, 50)),
          child: const Text("COMPLETE"),
        )
      ],
    );
  }

  Widget _buildLibraryUI() {
    return Stack(children: [
      Positioned.fill(child: Image.network(_bgImage, fit: BoxFit.cover)),
      SafeArea(child: Column(children: [
        const Padding(
          padding: EdgeInsets.symmetric(vertical: 20),
          child: Text("REHABILITATION MAP", style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold, letterSpacing: 2)),
        ),
        Expanded(child: GridView.builder(
          padding: const EdgeInsets.fromLTRB(20, 0, 20, 100),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 2, mainAxisSpacing: 15, crossAxisSpacing: 15, childAspectRatio: 1.3),
          itemCount: 30,
          itemBuilder: (context, index) {
            bool isDone = index < _streak;
            bool isNext = index == _streak;
            return Container(
              decoration: BoxDecoration(
                color: isDone ? const Color(0xFF008080).withOpacity(0.8) : Colors.white.withOpacity(0.1),
                borderRadius: BorderRadius.circular(15),
                border: Border.all(color: isNext ? Colors.white : Colors.white24),
              ),
              child: Center(child: Text("Day ${index + 1}", style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold))),
            );
          },
        )),
      ])),
    ]);
  }

  Widget _buildShareUI() {
    return Stack(children: [
      Positioned.fill(child: Image.network(_bgImage, fit: BoxFit.cover)),
      Center(child: _glassCard(Column(mainAxisSize: MainAxisSize.min, children: [
        const Icon(Icons.card_giftcard, color: Colors.white, size: 48),
        const SizedBox(height: 10),
        const Text("Invite & Earn", style: TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold)),
        const Text("+5 entries per referral.", style: TextStyle(color: Colors.white70, fontSize: 14)),
        const SizedBox(height: 25),
        ElevatedButton(
          onPressed: () { Clipboard.setData(const ClipboardData(text: "Join the Reset on app.fitwell.life 🌴")); ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Link copied!"))); },
          style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF008080), foregroundColor: Colors.white, minimumSize: const Size(double.infinity, 50)),
          child: const Text("COPY REFERRAL LINK"),
        ),
        const SizedBox(height: 12),
        ElevatedButton(
          onPressed: () => _launchUrl(_communityUrl),
          style: ElevatedButton.styleFrom(backgroundColor: Colors.white, foregroundColor: const Color(0xFF008080), minimumSize: const Size(double.infinity, 50)),
          child: const Text("JOIN THE COMMUNITY"),
        ),
      ]))),
    ]);
  }

  Widget _buildInstallUI() {
    return Stack(children: [
      Positioned.fill(child: Image.network(_bgImage, fit: BoxFit.cover)),
      Center(child: _glassCard(Column(mainAxisSize: MainAxisSize.min, children: [
        const Icon(Icons.install_mobile_rounded, color: Colors.white, size: 48),
        const SizedBox(height: 15),
        const Text("FitWell App", style: TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold)),
        const Text("1. Tap Share\n2. Add to Home Screen", textAlign: TextAlign.center, style: TextStyle(color: Colors.white, fontSize: 16)),
      ]))),
    ]);
  }

  Widget _glassCard(Widget child) {
    return ClipRRect(borderRadius: BorderRadius.circular(25), child: BackdropFilter(filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10), child: Container(padding: const EdgeInsets.all(30), width: MediaQuery.of(context).size.width * 0.85, constraints: const BoxConstraints(maxWidth: 500), decoration: BoxDecoration(color: Colors.white.withOpacity(0.2), borderRadius: BorderRadius.circular(25), border: Border.all(color: Colors.white.withOpacity(0.3))), child: child)));
  }

  Widget _buildGlassBottomNav() {
    return Container(margin: const EdgeInsets.all(20), height: 70, child: ClipRRect(borderRadius: BorderRadius.circular(35), child: BackdropFilter(filter: ImageFilter.blur(sigmaX: 15, sigmaY: 15), child: BottomNavigationBar(currentIndex: _selectedTab, onTap: (index) => setState(() => _selectedTab = index), backgroundColor: Colors.white10, selectedItemColor: const Color(0xFF008080), unselectedItemColor: Colors.white60, showSelectedLabels: false, showUnselectedLabels: false, type: BottomNavigationBarType.fixed, items: const [
      BottomNavigationBarItem(icon: Icon(Icons.spa_rounded), label: "Ritual"),
      BottomNavigationBarItem(icon: Icon(Icons.explore_rounded), label: "Map"),
      BottomNavigationBarItem(icon: Icon(Icons.card_giftcard), label: "Earn"),
      BottomNavigationBarItem(icon: Icon(Icons.add_to_home_screen_rounded), label: "Install"),
    ]))));
  }

  Widget _buildSurveyUI() {
    return Container(color: const Color(0xFF004D40), child: Center(child: ElevatedButton(onPressed: () async {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool('survey_completed', true);
      setState(() => _showSurvey = false);
    }, child: const Text("Start 30-Day Reset"))));
  }
}
