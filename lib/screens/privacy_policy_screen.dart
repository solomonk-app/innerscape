import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

class PrivacyPolicyScreen extends StatelessWidget {
  const PrivacyPolicyScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Row(
                children: [
                  IconButton(
                    onPressed: () => Navigator.of(context).pop(),
                    icon: const Icon(
                      Icons.arrow_back_ios,
                      color: AppColors.textMuted,
                      size: 20,
                    ),
                  ),
                  const Expanded(
                    child: Text(
                      'Privacy Policy',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: AppColors.textPrimary,
                        fontSize: 16,
                      ),
                    ),
                  ),
                  const SizedBox(width: 48),
                ],
              ),
            ),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(24),
                child: Center(
                  child: ConstrainedBox(
                    constraints: BoxConstraints(maxWidth: kIsWeb ? 480 : double.infinity),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _sectionTitle('Last Updated'),
                        _body('March 6, 2026'),
                        const SizedBox(height: 20),
                        _sectionTitle('Overview'),
                        _body(
                          'Feelong ("we", "our", "the app") is a mood journal app that helps you '
                          'track your emotional wellbeing. We are committed to protecting your privacy.',
                        ),
                        const SizedBox(height: 20),
                        _sectionTitle('Data We Collect'),
                        _body(
                          'Mood entries, journal text, and tags you create are stored locally on your device. '
                          'We do not collect, transmit, or store your journal data on our servers.',
                        ),
                        const SizedBox(height: 20),
                        _sectionTitle('AI Features'),
                        _body(
                          'When you use AI-powered features (reflections, conversations, weekly digests), '
                          'your mood data and journal text are sent to Google\'s Gemini API to generate '
                          'personalized insights. This data is processed in real-time and is subject to '
                          'Google\'s API data usage policies. We do not store your data on any intermediary server.',
                        ),
                        const SizedBox(height: 20),
                        _sectionTitle('Advertising'),
                        _body(
                          'The app uses Google AdMob to display ads. AdMob may collect device identifiers '
                          'and usage data for ad personalization. You can opt out of personalized ads '
                          'through your device settings.',
                        ),
                        const SizedBox(height: 20),
                        _sectionTitle('Local Storage'),
                        _body(
                          'All your journal entries, mood data, time capsules, and preferences are stored '
                          'locally on your device using SharedPreferences. No account or sign-up is required. '
                          'Clearing the app data or using the "Reset All Data" feature will permanently '
                          'delete all your entries.',
                        ),
                        const SizedBox(height: 20),
                        _sectionTitle('Third-Party Services'),
                        _body(
                          '- Google Gemini API (AI insights)\n'
                          '- Google AdMob (advertising)\n'
                          '- Google Fonts (typography)',
                        ),
                        const SizedBox(height: 20),
                        _sectionTitle('Children\'s Privacy'),
                        _body(
                          'Feelong is not intended for children under 13. We do not knowingly '
                          'collect data from children.',
                        ),
                        const SizedBox(height: 20),
                        _sectionTitle('Changes to This Policy'),
                        _body(
                          'We may update this Privacy Policy from time to time. Changes will be '
                          'reflected in the app with an updated date.',
                        ),
                        const SizedBox(height: 20),
                        _sectionTitle('Contact'),
                        _body('For questions about this policy, reach out via the app\'s GitHub repository.'),
                        const SizedBox(height: 40),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  static Widget _sectionTitle(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Text(
        text.toUpperCase(),
        style: const TextStyle(
          fontSize: 11,
          color: AppColors.accent,
          letterSpacing: 1.5,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  static Widget _body(String text) {
    return Text(
      text,
      style: const TextStyle(
        fontSize: 14,
        color: AppColors.textMuted,
        height: 1.7,
      ),
    );
  }
}
