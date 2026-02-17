import 'dart:convert';

import 'package:http/http.dart' as http;

class GhlService {
  static const String _webhookUrl = String.fromEnvironment(
    'GHL_WEBHOOK_URL',
    defaultValue: '',
  );

  static Future<void> sendSurveyCompleted({
    required String goal,
    required String tension,
  }) async {
    await _postEvent(
      event: 'survey_completed',
      payload: {
        'goal': goal,
        'tension': tension,
      },
    );
  }

  static Future<void> sendMistFullyCleared({
    required String goal,
    required String ritual,
  }) async {
    await _postEvent(
      event: 'mist_fully_cleared',
      payload: {
        'goal': goal,
        'ritual': ritual,
      },
    );
  }

  static Future<void> _postEvent({
    required String event,
    required Map<String, String> payload,
  }) async {
    if (_webhookUrl.isEmpty) return;

    try {
      await http.post(
        Uri.parse(_webhookUrl),
        headers: const {'Content-Type': 'application/json'},
        body: jsonEncode({
          'event': event,
          'source': 'align_app',
          'timestamp': DateTime.now().toUtc().toIso8601String(),
          ...payload,
        }),
      );
    } catch (_) {
      // Webhook failures should not block the ritual flow.
    }
  }
}
