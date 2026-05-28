import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../theme/app_theme.dart';

class AboutScreen extends StatelessWidget {
  const AboutScreen({super.key});

  static const _appStoreUrl =
      'https://apps.apple.com/us/app/feelong/id6760197546';
  static const _playStoreUrl =
      'https://play.google.com/store/apps/details?id=com.feelong.app';

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
                    onPressed: () => Navigator.of(context).maybePop(),
                    icon: const Icon(
                      Icons.arrow_back_ios,
                      color: AppColors.textMuted,
                      size: 20,
                    ),
                  ),
                  const Expanded(
                    child: Text(
                      'About',
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
                padding: const EdgeInsets.fromLTRB(24, 8, 24, 48),
                child: Center(
                  child: ConstrainedBox(
                    constraints:
                        BoxConstraints(maxWidth: kIsWeb ? 560 : double.infinity),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        // BIG bold download CTA
                        Text(
                          'Download Feelong',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 32,
                            color: AppColors.textPrimary,
                            fontWeight: FontWeight.w700,
                            letterSpacing: -0.5,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Get the app on your phone',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 14,
                            color: AppColors.textDim,
                            height: 1.5,
                          ),
                        ),
                        const SizedBox(height: 24),
                        _DownloadButton(
                          icon: Icons.apple,
                          label: 'Download on the App Store',
                          onTap: () => launchUrl(
                            Uri.parse(_appStoreUrl),
                            mode: LaunchMode.externalApplication,
                          ),
                        ),
                        const SizedBox(height: 12),
                        _DownloadButton(
                          icon: Icons.shop,
                          label: 'Get it on Google Play',
                          onTap: () => launchUrl(
                            Uri.parse(_playStoreUrl),
                            mode: LaunchMode.externalApplication,
                          ),
                        ),
                        const SizedBox(height: 48),

                        // App info
                        _sectionTitle('ABOUT FEELONG'),
                        _body(
                          'Feelong is an AI-powered mood journal that helps you '
                          'understand how you feel, spot patterns over time, and '
                          'build a gentler relationship with your inner life. '
                          'Check in daily, write what’s on your mind, and '
                          'let the reflections come back to you.',
                        ),
                        const SizedBox(height: 24),

                        _sectionTitle('WHAT YOU GET'),
                        const SizedBox(height: 4),
                        _bullet('Daily mood check-ins with context tags'),
                        _bullet('AI-generated reflections grounded in your entries'),
                        _bullet('Journal Ideas — hundreds of prompts by theme'),
                        _bullet('Journal Plans — 7, 14 & 21-day structured programs'),
                        _bullet('Eisenhower Matrix for what’s on your plate'),
                        _bullet('Weekly digests and trigger discovery'),
                        _bullet('Achievements, streaks, time capsules and more'),
                        const SizedBox(height: 24),

                        _sectionTitle('YOUR DATA, YOUR DEVICE'),
                        _body(
                          'Everything you write stays on your device. There is '
                          'no cloud sync, no account, and no server-side storage '
                          'of your entries. AI reflections are generated on '
                          'request and not retained.',
                        ),
                        const SizedBox(height: 32),

                        // Footer links
                        Wrap(
                          alignment: WrapAlignment.center,
                          spacing: 16,
                          runSpacing: 8,
                          children: [
                            _footerLink(context, 'Privacy', '/privacy'),
                            _footerLink(context, 'Terms', '/terms'),
                            _footerLink(context, 'Support', '/support'),
                          ],
                        ),
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

  static Widget _bullet(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Padding(
            padding: EdgeInsets.only(top: 6),
            child: Icon(Icons.circle, size: 5, color: AppColors.accent),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              text,
              style: const TextStyle(
                fontSize: 14,
                color: AppColors.textMuted,
                height: 1.6,
              ),
            ),
          ),
        ],
      ),
    );
  }

  static Widget _footerLink(BuildContext context, String label, String route) {
    return GestureDetector(
      onTap: () => Navigator.of(context).pushNamed(route),
      child: Text(
        label,
        style: const TextStyle(
          fontSize: 13,
          color: AppColors.accent,
          decoration: TextDecoration.underline,
          decorationColor: AppColors.accentBorder,
        ),
      ),
    );
  }
}

class _DownloadButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  const _DownloadButton({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      label: label,
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          height: 56,
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Color(0x33D4A574),
                Color(0x1AD4A574),
              ],
            ),
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: AppColors.accentBorder, width: 1.5),
          ),
          alignment: Alignment.center,
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, size: 22, color: AppColors.accent),
              const SizedBox(width: 12),
              Text(
                label,
                style: const TextStyle(
                  fontSize: 16,
                  color: AppColors.accent,
                  fontWeight: FontWeight.w600,
                  letterSpacing: 0.2,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
