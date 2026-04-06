import 'dart:convert';
import 'dart:math';
import 'package:flutter/foundation.dart' show debugPrint, kIsWeb;
import 'package:http/http.dart' as http;
import '../models/mood_entry.dart';
import 'package:intl/intl.dart';

class AiService {
  static const String _apiKey = String.fromEnvironment('GEMINI_API_KEY');
  static const String apiUrl =
      'https://generativelanguage.googleapis.com/v1beta/models/gemini-2.0-flash:generateContent';

  static Uri get _effectiveUri {
    if (kIsWeb) {
      return Uri.parse('/api/gemini');
    }
    return Uri.parse('$apiUrl?key=$_apiKey');
  }

  static final List<String> _fallbackInsights = [
    'Thank you for checking in with yourself today. That awareness is a gift.',
    'Taking a moment to reflect like this shows real self-awareness. Keep it up.',
    'Every check-in is a step toward understanding yourself better.',
    'The fact that you\'re journaling says a lot about your commitment to growth.',
    'Your feelings are valid. Thank you for honoring them here.',
  ];

  static Future<String> getInsight({
    required MoodEntry currentEntry,
    required List<MoodEntry> recentEntries,
  }) async {
    final moodLabel =
        moodOptions.firstWhere((m) => m.value == currentEntry.mood).label;
    final dateFormat = DateFormat('EEE, MMM d');

    final recentHistory = recentEntries.take(5).map((e) {
      final label = moodOptions.firstWhere((m) => m.value == e.mood).label;
      final text = e.text.length > 80 ? '${e.text.substring(0, 80)}...' : e.text;
      final tagStr = e.tags.isNotEmpty ? ' [${e.tags.join(", ")}]' : '';
      return '${dateFormat.format(e.timestamp)}: $label - "$text"$tagStr';
    }).join('\n');

    final tagsStr = currentEntry.tags.isNotEmpty
        ? '\nContext tags: ${currentEntry.tags.join(", ")}'
        : '';

    final systemPrompt =
        'You are a warm, empathetic wellness companion inside a mood journal app. '
        'Provide brief, insightful reflections on the user\'s journal entry and mood. '
        'Be supportive, perceptive, and genuine — never clinical or preachy. '
        'Keep responses to 2-3 sentences. Notice patterns if recent history is provided. '
        'If context tags are provided (activities, people, locations), weave them naturally into your insight. '
        'Speak like a caring friend, not a therapist.';

    final userMessage =
        'Current mood: $moodLabel (${currentEntry.mood}/6)\n'
        'Journal entry: "${currentEntry.text.isNotEmpty ? currentEntry.text : '(no text entered)'}"$tagsStr\n\n'
        '${recentHistory.isNotEmpty ? 'Recent mood history:\n$recentHistory' : 'This is their first entry.'}\n\n'
        'Give a brief, warm insight about their current state. If there are patterns, gently note them.';

    return _callGemini(systemPrompt, userMessage);
  }

  /// Generate a comparison reflection for time capsules
  static Future<String> getTimeCapsuleReflection({
    required String originalLetter,
    required int moodAtCreation,
    required int currentMood,
    required DateTime createdAt,
    required List<MoodEntry> recentEntries,
  }) async {
    final creationMoodLabel =
        moodOptions.firstWhere((m) => m.value == moodAtCreation).label;
    final currentMoodLabel =
        moodOptions.firstWhere((m) => m.value == currentMood).label;
    final dateFormat = DateFormat('MMM d, yyyy');

    final systemPrompt =
        'You are a warm, reflective wellness companion. The user wrote a letter to their future self '
        'some time ago. Now they\'re reading it. Write a brief, thoughtful "then vs now" reflection '
        '(3-4 sentences) comparing where they were emotionally when they wrote it to where they are now. '
        'Be encouraging and insightful, noticing growth or offering comfort.';

    final userMessage =
        'Letter written on ${dateFormat.format(createdAt)} (mood: $creationMoodLabel, ${moodAtCreation}/6):\n'
        '"$originalLetter"\n\n'
        'Current mood: $currentMoodLabel ($currentMood/6)\n'
        'Write a warm then-vs-now reflection.';

    return _callGemini(systemPrompt, userMessage);
  }

  /// Generate weekly digest analysis
  static Future<String> getWeeklyDigest({
    required List<MoodEntry> weekEntries,
    required List<MoodEntry> lastWeekEntries,
  }) async {
    final dateFormat = DateFormat('EEE, MMM d');

    String formatEntries(List<MoodEntry> entries) {
      return entries.map((e) {
        final label = moodOptions.firstWhere((m) => m.value == e.mood).label;
        final text = e.text.length > 60 ? '${e.text.substring(0, 60)}...' : e.text;
        final tagStr = e.tags.isNotEmpty ? ' [${e.tags.join(", ")}]' : '';
        return '${dateFormat.format(e.timestamp)}: $label (${e.mood}/6) - "$text"$tagStr';
      }).join('\n');
    }

    final systemPrompt =
        'You are a warm, insightful wellness companion writing a weekly mood digest letter. '
        'Write in second person ("you"). Structure your response as:\n'
        '1. Opening observation about their week (1 sentence)\n'
        '2. Best and most challenging moments (2 sentences)\n'
        '3. If tags are present, note which activities/people/places correlated with better moods (1-2 sentences)\n'
        '4. Comparison to last week if data available (1 sentence)\n'
        '5. One specific, actionable suggestion for next week (1 sentence)\n\n'
        'Keep the total to about 6-8 sentences. Be warm, specific, and encouraging.';

    final thisWeek = formatEntries(weekEntries);
    final lastWeek = lastWeekEntries.isNotEmpty
        ? '\n\nLast week\'s entries:\n${formatEntries(lastWeekEntries)}'
        : '';

    final avgMood = weekEntries.isEmpty
        ? 0.0
        : weekEntries.fold<int>(0, (s, e) => s + e.mood) / weekEntries.length;

    final userMessage =
        'This week\'s mood entries:\n$thisWeek\n'
        'Average mood this week: ${avgMood.toStringAsFixed(1)}/6$lastWeek\n\n'
        'Write a warm weekly digest letter.';

    return _callGemini(systemPrompt, userMessage);
  }

  /// Generate a personalized daily challenge based on recent mood patterns
  static Future<Map<String, String>> generateDailyChallenge({
    required List<MoodEntry> recentEntries,
    required List<String> recentChallengeTitles,
  }) async {
    final recent = recentEntries.reversed.take(7).toList();
    final moodSummary = recent.isEmpty
        ? 'No recent entries.'
        : recent.map((e) {
            final label = moodOptions.firstWhere((m) => m.value == e.mood).label;
            return '$label (${e.mood}/6)';
          }).join(', ');

    final avoidStr = recentChallengeTitles.isNotEmpty
        ? '\nAvoid these recent titles: ${recentChallengeTitles.join(", ")}'
        : '';

    final systemPrompt =
        'You are a wellness companion. Generate ONE daily micro-challenge based on the user\'s recent mood pattern. '
        'If trending low (1-2), suggest self-care/relaxation/social connection. '
        'If trending high (5-6), suggest gratitude/creative/pay-it-forward. '
        'If neutral/flat (3-4), suggest novelty/mindfulness/physical activity. '
        'Return ONLY valid JSON: {"title": "short title", "description": "1-2 sentence actionable challenge", "emoji": "single emoji"} '
        'No markdown, no extra text.';

    final userMessage =
        'Recent moods (newest first): $moodSummary$avoidStr\n\n'
        'Generate one personalized daily wellness challenge.';

    final raw = await _callGeminiShort(systemPrompt, userMessage);

    // Parse JSON response
    try {
      final cleaned = raw.replaceAll(RegExp(r'```json?\s*|\s*```'), '').trim();
      final map = jsonDecode(cleaned) as Map<String, dynamic>;
      return {
        'title': map['title'] as String? ?? 'Daily Challenge',
        'description': map['description'] as String? ?? 'Take a moment for yourself today.',
        'emoji': map['emoji'] as String? ?? '\u{1F3AF}',
      };
    } catch (e) {
      debugPrint('AiService: challenge JSON parse failed: $e');
      rethrow;
    }
  }

  /// Short Gemini API call (150 tokens max) for challenge generation
  static Future<String> _callGeminiShort(String systemPrompt, String userMessage) async {
    final response = await http.post(
      _effectiveUri,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'system_instruction': {
          'parts': [{'text': systemPrompt}]
        },
        'contents': [
          {
            'parts': [{'text': userMessage}]
          }
        ],
        'generationConfig': {'maxOutputTokens': 150},
      }),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      final candidates = data['candidates'] as List;
      if (candidates.isNotEmpty) {
        final parts = candidates[0]['content']['parts'] as List;
        return parts.map((p) => p['text'] as String).join('');
      }
    }
    throw Exception('Gemini API call failed: ${response.statusCode}');
  }

  /// Core Gemini API call — single turn
  static Future<String> _callGemini(String systemPrompt, String userMessage) async {
    try {
      final response = await http.post(
        _effectiveUri,
        headers: {
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'system_instruction': {
            'parts': [
              {'text': systemPrompt}
            ]
          },
          'contents': [
            {
              'parts': [
                {'text': userMessage}
              ]
            }
          ],
          'generationConfig': {
            'maxOutputTokens': 300,
          },
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final candidates = data['candidates'] as List;
        if (candidates.isNotEmpty) {
          final parts = candidates[0]['content']['parts'] as List;
          return parts.map((p) => p['text'] as String).join('');
        }
        return _getRandomFallback();
      } else {
        return _getRandomFallback();
      }
    } catch (e) {
      debugPrint('AiService: _callGemini error: $e');
      return _getRandomFallback();
    }
  }

  /// Multi-turn Gemini call for conversation mode
  static Future<String> callGeminiMultiTurn({
    required String systemPrompt,
    required List<Map<String, dynamic>> contents,
  }) async {
    try {
      final response = await http.post(
        _effectiveUri,
        headers: {
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'system_instruction': {
            'parts': [
              {'text': systemPrompt}
            ]
          },
          'contents': contents,
          'generationConfig': {
            'maxOutputTokens': 400,
          },
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final candidates = data['candidates'] as List;
        if (candidates.isNotEmpty) {
          final parts = candidates[0]['content']['parts'] as List;
          return parts.map((p) => p['text'] as String).join('');
        }
        return _getRandomFallback();
      } else {
        return _getRandomFallback();
      }
    } catch (e) {
      debugPrint('AiService: callGeminiMultiTurn error: $e');
      return _getRandomFallback();
    }
  }

  static String _getRandomFallback() {
    return _fallbackInsights[Random().nextInt(_fallbackInsights.length)];
  }
}

class WellnessTips {
  static final Map<String, List<String>> _tips = {
    'low': [
      'Try a 5-minute breathing exercise — inhale 4s, hold 4s, exhale 6s',
      'Step outside for a brief walk, even just around the block',
      'Reach out to someone you trust — connection heals',
      'Be gentle with yourself today. Bad days pass.',
    ],
    'mid': [
      'A short gratitude list can shift your perspective',
      'Try stretching or light movement for 10 minutes',
      'Put on a song that always lifts your mood',
      'Take a mindful break — notice 5 things you can see right now',
    ],
    'high': [
      'Capture this energy! What contributed to feeling great?',
      'Share your good vibes — compliment someone today',
      'This is a perfect time to tackle something you\'ve been putting off',
      'Celebrate this moment. You deserve to feel good.',
    ],
  };

  static String getTip(int moodValue) {
    final category = moodValue <= 2
        ? 'low'
        : moodValue <= 4
            ? 'mid'
            : 'high';
    final tips = _tips[category]!;
    return tips[Random().nextInt(tips.length)];
  }
}

final List<String> dailyPrompts = [
  'What\'s on your mind right now?',
  'How did your day unfold?',
  'What are you grateful for today?',
  'Anything weighing on you?',
  'What made you smile recently?',
  'What\'s one thing you\'d like to let go of?',
  'Describe your energy level today.',
  'What are you looking forward to?',
];
