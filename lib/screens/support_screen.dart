import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

class SupportScreen extends StatelessWidget {
  const SupportScreen({super.key});

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
                      'Support',
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
                        const Center(
                          child: Text('💬', style: TextStyle(fontSize: 48)),
                        ),
                        const SizedBox(height: 16),
                        Center(
                          child: Text(
                            'We\'re here to help',
                            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                  color: AppColors.textSecondary,
                                  fontStyle: FontStyle.italic,
                                ),
                          ),
                        ),
                        const SizedBox(height: 8),
                        Center(
                          child: Text(
                            'Have a question, found a bug, or want to share feedback?\nReach out through any of the channels below.',
                            textAlign: TextAlign.center,
                            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                  color: AppColors.textDim,
                                  height: 1.6,
                                ),
                          ),
                        ),
                        const SizedBox(height: 36),
                        _sectionTitle('EMAIL'),
                        _body('support@feelong.app'),
                        const SizedBox(height: 20),
                        _sectionTitle('GITHUB'),
                        _body('Report issues or request features at:\ngithub.com/solomonk-app/innerscape'),
                        const SizedBox(height: 20),
                        _sectionTitle('FAQ'),
                        const SizedBox(height: 12),
                        _faqItem(
                          'Where is my data stored?',
                          'All your journal entries and mood data are stored locally on your device. '
                              'We do not have access to your data and there is no cloud backup.',
                        ),
                        _faqItem(
                          'How does the AI work?',
                          'Feelong uses Google\'s Gemini AI to generate personalized reflections based on '
                              'your mood and journal entries. Your data is sent to the AI in real-time and is '
                              'not stored on any server.',
                        ),
                        _faqItem(
                          'Can I recover deleted data?',
                          'No. Once you use "Reset All Data" in the Insights tab, all entries are permanently '
                              'deleted. There is no undo or cloud backup.',
                        ),
                        _faqItem(
                          'Is Feelong a replacement for therapy?',
                          'No. Feelong is a wellness tool, not a medical or mental health service. '
                              'If you are experiencing a mental health crisis, please contact a qualified '
                              'professional or emergency services.',
                        ),
                        _faqItem(
                          'How do I turn off ads?',
                          'Ads help keep Feelong free. A premium ad-free option may be available in the future.',
                        ),
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
        text,
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

  static Widget _faqItem(String question, String answer) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            question,
            style: const TextStyle(
              fontSize: 14,
              color: AppColors.textSecondary,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            answer,
            style: const TextStyle(
              fontSize: 13,
              color: AppColors.textDim,
              height: 1.6,
            ),
          ),
        ],
      ),
    );
  }
}
