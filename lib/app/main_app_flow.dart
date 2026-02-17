import 'package:flutter/material.dart';

import '../features/library/library_screen.dart';
import '../features/onboarding/survey_screen.dart';
import '../features/ritual/mist_reveal_screen.dart';

class MainAppFlow extends StatefulWidget {
  const MainAppFlow({super.key});

  @override
  State<MainAppFlow> createState() => _MainAppFlowState();
}

class _MainAppFlowState extends State<MainAppFlow> {
  bool _showSurvey = true;
  int _selectedTab = 0;

  String _activeVideoUrl =
      'https://assets.mixkit.co/videos/preview/mixkit-tropical-beach-with-palm-trees-1549-large.mp4';
  String _activeTitle = 'Morning Ritual';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: AnimatedSwitcher(
        duration: const Duration(milliseconds: 800),
        child: _showSurvey
            ? SurveyScreen(onCompleted: () => setState(() => _showSurvey = false))
            : Scaffold(
                body: _selectedTab == 0
                    ? MistRevealScreen(
                        videoUrl: _activeVideoUrl,
                        title: _activeTitle,
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
