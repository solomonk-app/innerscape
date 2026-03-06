import '../models/mood_entry.dart';
import 'ai_service.dart';

class ConversationService {
  static const int maxTurns = 5;

  static const String _systemPrompt =
      'You are a warm, empathetic wellness companion having a brief therapeutic conversation. '
      'Use Socratic method — ask thoughtful follow-up questions to help the user explore their feelings, '
      'rather than lecturing or giving advice. Be curious, gentle, and validating. '
      'Keep each response to 2-3 sentences, always ending with a question to explore deeper. '
      'On the FINAL turn (when told it\'s the last), instead of asking a question, '
      'provide a warm summary of what you discussed and one actionable takeaway. '
      'Never be clinical or preachy. Speak like a caring, wise friend.';

  final MoodEntry entry;
  final List<Map<String, dynamic>> _contents = [];
  int _turnCount = 0;

  ConversationService({required this.entry});

  int get turnCount => _turnCount;
  bool get isComplete => _turnCount >= maxTurns;
  int get turnsRemaining => maxTurns - _turnCount;

  /// Start the conversation with the initial context
  Future<String> startConversation() async {
    final moodLabel =
        moodOptions.firstWhere((m) => m.value == entry.mood).label;
    final tagsStr = entry.tags.isNotEmpty
        ? '\nContext: ${entry.tags.join(", ")}'
        : '';

    final initialMessage =
        'The user just logged their mood as "$moodLabel" (${entry.mood}/6). '
        'Journal entry: "${entry.text.isNotEmpty ? entry.text : '(no text)'}"\n'
        'AI reflection already given: "${entry.aiInsight}"$tagsStr\n\n'
        'The user wants to explore this further. This is turn 1 of $maxTurns. '
        'Ask a thoughtful, Socratic follow-up question about their entry to help them reflect deeper.';

    _contents.add({
      'role': 'user',
      'parts': [
        {'text': initialMessage}
      ]
    });

    final response = await AiService.callGeminiMultiTurn(
      systemPrompt: _systemPrompt,
      contents: _contents,
    );

    _contents.add({
      'role': 'model',
      'parts': [
        {'text': response}
      ]
    });
    _turnCount = 1;

    return response;
  }

  /// Send a user message and get AI response
  Future<String> sendMessage(String userMessage) async {
    _turnCount++;
    final isFinal = _turnCount >= maxTurns;

    final turnNote = isFinal
        ? '\n\n[System: This is the FINAL turn ($maxTurns of $maxTurns). '
            'Provide a warm summary of the conversation and one actionable takeaway. Do NOT ask another question.]'
        : '\n\n[System: Turn $_turnCount of $maxTurns. Continue with a thoughtful follow-up question.]';

    _contents.add({
      'role': 'user',
      'parts': [
        {'text': userMessage + turnNote}
      ]
    });

    final response = await AiService.callGeminiMultiTurn(
      systemPrompt: _systemPrompt,
      contents: _contents,
    );

    _contents.add({
      'role': 'model',
      'parts': [
        {'text': response}
      ]
    });

    return response;
  }
}
