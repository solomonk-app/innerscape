import 'dart:convert';
import 'dart:math';
import 'package:http/http.dart' as http;
import '../constants/bible_verses.dart';

class BibleVerseService {
  static final BibleVerseService _instance = BibleVerseService._internal();
  factory BibleVerseService() => _instance;
  BibleVerseService._internal();

  final _random = Random();

  Future<BibleVerse> getVerse(int mood) async {
    final category = moodToCategory(mood);
    final verses = curatedVerses[category]!;
    final picked = verses[_random.nextInt(verses.length)];

    try {
      final encoded = Uri.encodeComponent(picked.reference);
      final response = await http
          .get(Uri.parse('https://bible-api.com/$encoded'))
          .timeout(const Duration(seconds: 3));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final text = (data['text'] as String?)?.trim();
        final reference = data['reference'] as String?;
        if (text != null && text.isNotEmpty && reference != null) {
          return BibleVerse(text: text, reference: reference);
        }
      }
    } catch (_) {
      // Network error or timeout — fall through to local verse
    }

    return picked;
  }
}
