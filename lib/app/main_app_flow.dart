import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../core/integrations/ghl_service.dart';
import '../features/library/library_screen.dart';
import '../features/onboarding/survey_screen.dart';
import '../features/ritual/mist_reveal_screen.dart';

class MainAppFlow extends StatefulWidget {
  const MainAppFlow({super.key});

  @override
  State<MainAppFlow> createState() => _MainAppFlowState();
}

class _MainAppFlowState extends State<MainAppFlow> {
  static const String _surveyCompletedKey = 'survey_completed';
  static const String _surveyGoalKey = 'survey_goal';
  static const String _surveyTensionKey = 'survey_tension';

  bool _isHydrated = false;
  bool _showSurvey = true;
  int _selectedTab = 0;
  String _surveyGoal = 'general_wellness';
  String _surveyTension = '';

  String _activeVideoUrl =
      'https://assets.mixkit.co/videos/preview/mixkit-tropical-beach-with-palm-trees-1549-large.mp4';
  String _activeTitle = 'Morning Ritual';

  @override
  void initState() {
    super.initState();
    _hydrateSurveyState();
  }

  Future<void> _hydrateSurveyState() async {
    final prefs = await SharedPreferences.getInstance();
    final isSurveyCompleted = prefs.getBool(_surveyCompletedKey) ?? false;
    final goal = prefs.getString(_surveyGoalKey);
    final tension = prefs.getString(_surveyTensionKey);

    if (!mounted) return;
    setState(() {
      _showSurvey = !isSurveyCompleted;
      _surveyGoal = goal ?? _surveyGoal;
      _surveyTension = tension ?? _surveyTension;
      _isHydrated = true;
    });
  }

  Future<void> _handleSurveyCompleted(Map<String, String> answers) async {
    final goal = answers['goal'] ?? _surveyGoal;
    final tension = answers['tension'] ?? _surveyTension;

    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_surveyCompletedKey, true);
    await prefs.setString(_surveyGoalKey, goal);
    await prefs.setString(_surveyTensionKey, tension);
    await GhlService.sendSurveyCompleted(goal: goal, tension: tension);

    if (!mounted) return;
    setState(() {
      _surveyGoal = goal;
      _surveyTension = tension;
      _showSurvey = false;
    });
  }

  Future<void> _handleMistFullyCleared() async {
    await GhlService.sendMistFullyCleared(
      goal: _surveyGoal,
      ritual: _activeTitle,
    );
  }

  @override
  Widget build(BuildContext context) {
    if (!_isHydrated) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      body: AnimatedSwitcher(
        duration: const Duration(milliseconds: 800),
        child: _showSurvey
            ? SurveyScreen(onCompleted: _handleSurveyCompleted)
            : Scaffold(
                body: _selectedTab == 0
                    ? MistRevealScreen(
                        videoUrl: _activeVideoUrl,
                        title: _activeTitle,
                        userGoal: _surveyGoal,
                        onMistFullyCleared: _handleMistFullyCleared,
                      )
                    : LibraryScreen(
                        onSessionSelected: (title, url) {
                          setState(() {
                            _activeVideoUrl = url;
                            _activeTitle = title;
                            _selectedTab = 0;
                          });
                        },
                      ),
                bottomNavigationBar: BottomNavigationBar(
                  currentIndex: _selectedTab,
                  onTap: (index) => setState(() => _selectedTab = index),
                  items: const [
                    BottomNavigationBarItem(
                      icon: Icon(Icons.spa),
                      label: 'Ritual',
                    ),
                    BottomNavigationBarItem(
                      icon: Icon(Icons.explore),
                      label: 'Library',
                    ),
                  ],
                ),
              ),
      ),
    );
  }
}
