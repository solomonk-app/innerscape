import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../widgets/glass_card.dart';
import '../services/review_service.dart';
import '../services/tooltip_service.dart';
import 'reminder_settings_screen.dart';
import 'onboarding_screen.dart';
import 'support_screen.dart';
import 'privacy_policy_screen.dart';
import 'terms_screen.dart';
import 'reflection_prompts_screen.dart';
import 'affirmation_settings_screen.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  void _navigate(BuildContext context, Widget screen) {
    Navigator.of(context).push(
      PageRouteBuilder(
        pageBuilder: (_, __, ___) => screen,
        transitionsBuilder: (_, anim, __, child) => SlideTransition(
          position: Tween(
            begin: const Offset(1, 0),
            end: Offset.zero,
          ).animate(CurvedAnimation(
            parent: anim,
            curve: Curves.easeOutCubic,
          )),
          child: child,
        ),
        transitionDuration: const Duration(milliseconds: 350),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          children: [
            // Header
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
                      'Settings',
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

            // Settings list
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(24),
                child: Center(
                  child: ConstrainedBox(
                    constraints: BoxConstraints(
                      maxWidth: kIsWeb ? 480 : double.infinity,
                    ),
                    child: Column(
                      children: [
                        _SettingsItem(
                          icon: Icons.notifications_outlined,
                          label: 'Reminders',
                          subtitle: 'Daily check-in reminders',
                          onTap: () => _navigate(
                            context,
                            const ReminderSettingsScreen(),
                          ),
                        ),
                        const SizedBox(height: 12),
                        _SettingsItem(
                          icon: Icons.event_note_outlined,
                          label: 'Reflection schedule',
                          subtitle: 'Weekly & monthly reminders',
                          onTap: () => _navigate(
                            context,
                            const ReflectionPromptsScreen(),
                          ),
                        ),
                        const SizedBox(height: 12),
                        _SettingsItem(
                          icon: Icons.auto_awesome_outlined,
                          label: 'Affirmations',
                          subtitle: 'Reminders & timed practice',
                          onTap: () => _navigate(
                            context,
                            const AffirmationSettingsScreen(),
                          ),
                        ),
                        const SizedBox(height: 12),
                        _SettingsItem(
                          icon: Icons.star_outline,
                          label: 'Rate Feelong',
                          subtitle: 'Leave a rating on the store',
                          onTap: () => ReviewService().openStoreListing(),
                        ),
                        const SizedBox(height: 12),
                        _SettingsItem(
                          icon: Icons.refresh,
                          label: 'Replay Tutorial',
                          subtitle: 'Walk through features again',
                          onTap: () async {
                            await TooltipService().resetAllTooltips();
                            if (!context.mounted) return;
                            _navigate(
                              context,
                              const OnboardingScreen(isReplay: true),
                            );
                          },
                        ),
                        const SizedBox(height: 24),
                        _SettingsItem(
                          icon: Icons.help_outline,
                          label: 'Support',
                          subtitle: 'FAQ and contact',
                          onTap: () => _navigate(
                            context,
                            const SupportScreen(),
                          ),
                        ),
                        const SizedBox(height: 12),
                        _SettingsItem(
                          icon: Icons.shield_outlined,
                          label: 'Privacy Policy',
                          onTap: () => _navigate(
                            context,
                            const PrivacyPolicyScreen(),
                          ),
                        ),
                        const SizedBox(height: 12),
                        _SettingsItem(
                          icon: Icons.description_outlined,
                          label: 'Terms of Use',
                          onTap: () => _navigate(
                            context,
                            const TermsScreen(),
                          ),
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
}

class _SettingsItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final String? subtitle;
  final VoidCallback onTap;

  const _SettingsItem({
    required this.icon,
    required this.label,
    this.subtitle,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      label: label,
      child: GestureDetector(
        onTap: onTap,
        child: GlassCard(
          color: AppColors.surface.withOpacity(0.5),
          borderColor: AppColors.borderLight,
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          child: Row(
            children: [
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: AppColors.accentTranslucent,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(
                  icon,
                  color: AppColors.accent,
                  size: 18,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      label,
                      style: const TextStyle(
                        color: AppColors.textPrimary,
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    if (subtitle != null) ...[
                      const SizedBox(height: 2),
                      Text(
                        subtitle!,
                        style: const TextStyle(
                          color: AppColors.textDim,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              const Icon(
                Icons.chevron_right,
                color: AppColors.textDim,
                size: 20,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
