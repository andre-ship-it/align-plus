import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../shared/widgets/press_scale_button.dart';

class SurveyScreen extends StatefulWidget {
  final VoidCallback onCompleted;

  const SurveyScreen({super.key, required this.onCompleted});

  @override
  State<SurveyScreen> createState() => _SurveyScreenState();
}

class _SurveyScreenState extends State<SurveyScreen> {
  final PageController _surveyController = PageController();
  int _currentStep = 0;

  final List<Map<String, dynamic>> _questions = [
    {
      'q': 'What is your main goal?',
      'options': ['Relieve Pain', 'Energy', 'Sleep'],
    },
    {
      'q': 'Where is your tension?',
      'options': ['Lower Back', 'Neck', 'Hips'],
    },
  ];

  @override
  void dispose() {
    _surveyController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Theme.of(context).scaffoldBackgroundColor,
      child: SafeArea(
        child: Column(
          children: [
            LinearProgressIndicator(value: (_currentStep + 1) / _questions.length),
            Expanded(
              child: PageView.builder(
                controller: _surveyController,
                itemCount: _questions.length,
                itemBuilder: (context, index) => Padding(
                  padding: const EdgeInsets.all(40),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        _questions[index]['q'] as String,
                        style: Theme.of(context).textTheme.headlineMedium,
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 20),
                      ...(_questions[index]['options'] as List<String>).map(
                        (option) => Padding(
                          padding: const EdgeInsets.only(bottom: 12),
                          child: PressScaleButton(
                            onPressed: () {
                              HapticFeedback.lightImpact();
                              if (_currentStep < _questions.length - 1) {
                                _surveyController.nextPage(
                                  duration: const Duration(milliseconds: 450),
                                  curve: Curves.easeOutCubic,
                                );
                                setState(() => _currentStep++);
                              } else {
                                widget.onCompleted();
                              }
                            },
                            child: Text(option),
                          ),
                        ),
                      ),
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
}
