import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:flutter_web_plugins/url_strategy.dart';
import 'package:intl/intl.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'theme/app_theme.dart';
import 'models/mood_entry.dart';
import 'models/weekly_digest.dart';
import 'models/achievement.dart';
import 'models/daily_challenge.dart';
import 'services/storage_service.dart';
import 'services/notification_service.dart';
import 'services/atmosphere_service.dart';
import 'services/digest_service.dart';
import 'services/consent_service.dart';
import 'services/ad_service.dart';
import 'services/analytics_service.dart';
import 'services/achievement_service.dart';
import 'services/challenge_service.dart';
import 'screens/checkin_screen.dart';
import 'screens/history_screen.dart';
import 'screens/insights_screen.dart';
import 'screens/reminder_settings_screen.dart';
import 'screens/weekly_digest_screen.dart';
import 'screens/time_capsule_screen.dart';
import 'screens/achievement_gallery_screen.dart';
import 'widgets/ambient_particles.dart';
import 'widgets/glass_card.dart';
import 'widgets/adaptive_banner_ad.dart';
import 'widgets/achievement_celebration.dart';
import 'screens/privacy_policy_screen.dart';
import 'screens/terms_screen.dart';
import 'screens/support_screen.dart';
import 'screens/onboarding_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  usePathUrlStrategy();
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.light,
      systemNavigationBarColor: AppColors.surface,
    ),
  );

  runApp(const FeelongApp());

  // Initialize notifications after first frame (non-blocking)
  _initNotifications();
}

Future<void> _initNotifications() async {
  try {
    final notificationService = NotificationService();
    await notificationService.init();
    try {
      await notificationService.rescheduleIfEnabled();
    } catch (e) {
      debugPrint('Notification reschedule error: $e');
    }
    try {
      await notificationService.scheduleWeeklyDigestReminder();
    } catch (e) {
      debugPrint('Notification digest reminder error: $e');
    }
  } catch (e) {
    debugPrint('Notification init error: $e');
  }
}

class FeelongApp extends StatelessWidget {
  const FeelongApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Feelong',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.darkTheme,
      navigatorObservers: [AnalyticsService().observer],
      routes: {
        '/': (_) => const _RootNavigation(),
        '/privacy': (_) => const PrivacyPolicyScreen(),
        '/terms': (_) => const TermsScreen(),
        '/support': (_) => const SupportScreen(),
      },
    );
  }
}

class _RootNavigation extends StatefulWidget {
  const _RootNavigation();

  @override
  State<_RootNavigation> createState() => _RootNavigationState();
}

class _RootNavigationState extends State<_RootNavigation> {
  bool _isLoading = true;
  bool _showOnboarding = false;

  @override
  void initState() {
    super.initState();
    _checkOnboarding();
  }

  Future<void> _checkOnboarding() async {
    final storage = await StorageService.getInstance();
    final entries = await storage.getEntries();
    setState(() {
      _showOnboarding = !storage.hasSeenOnboarding && entries.isEmpty;
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        backgroundColor: AppColors.background,
        body: SizedBox.shrink(),
      );
    }
    return _showOnboarding ? const OnboardingScreen() : const HomeScreen();
  }
}

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _currentIndex = 0;
  List<MoodEntry> _entries = [];
  int _streak = 0;
  AtmosphereMode _atmosphereMode = AtmosphereMode.neutral;
  WeeklyDigest? _latestDigest;
  bool _digestChecked = false;
  List<AchievementDefinition> _newAchievements = [];
  int _earnedAchievementCount = 0;
  List<DailyChallenge> _challenges = [];
  int _challengeWeekCompleted = 0;
  int _challengeTotalCompleted = 0;

  @override
  void initState() {
    super.initState();
    _loadEntries();
    _checkDigest();
    _initAds();
  }

  Future<void> _initAds() async {
    // Request ATT after the first frame is rendered (iOS requirement)
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      await ConsentService().requestATTIfNeeded();
    });
    // Initialize consent + ad SDK in background (non-blocking)
    await ConsentService().requestConsent();
    await AdService().initialize();
  }

  Future<void> _loadEntries() async {
    final storage = await StorageService.getInstance();
    final entries = await storage.getEntries();
    final capsules = await storage.getCapsules();
    final streak = storage.calculateStreak(entries);
    setState(() {
      _entries = entries;
      _streak = streak;
      _atmosphereMode = AtmosphereService.getMode(entries);
    });

    // Evaluate achievements
    final newAchievements = await AchievementService().evaluateAndAward(
      entries: entries,
      streak: streak,
      capsules: capsules,
    );
    final earned = await AchievementService().getEarned();

    // Log new achievements
    for (final a in newAchievements) {
      AnalyticsService().logAchievementEarned(
        achievementId: a.id,
        category: a.category.name,
        tier: a.tier.index,
      );
    }

    // Load challenge stats
    final challenges = await storage.getChallenges();
    final challengeStats = ChallengeService().getStats(challenges);

    if (mounted) {
      setState(() {
        _newAchievements = newAchievements;
        _earnedAchievementCount = earned.length;
        _challenges = challenges;
        _challengeWeekCompleted = challengeStats['weekCompleted'] ?? 0;
        _challengeTotalCompleted = challengeStats['totalCompleted'] ?? 0;
      });
    }

    // Update analytics user properties
    String? mostCommonMood;
    if (entries.isNotEmpty) {
      final moodCounts = <int, int>{};
      for (final e in entries) {
        moodCounts[e.mood] = (moodCounts[e.mood] ?? 0) + 1;
      }
      final topMood = moodCounts.entries.reduce((a, b) => a.value > b.value ? a : b).key;
      mostCommonMood = moodOptions.firstWhere((m) => m.value == topMood).label;
    }
    AnalyticsService().setUserProperties(
      totalEntries: entries.length,
      currentStreak: _streak,
      mostCommonMood: mostCommonMood,
      achievementsEarned: earned.length,
      challengesCompleted: challengeStats['totalCompleted'],
    );
  }

  Future<void> _checkDigest() async {
    if (_digestChecked) return;
    _digestChecked = true;

    // Check if we should auto-generate a digest
    if (await DigestService.shouldGenerateDigest()) {
      await DigestService.generateDigest();
    }

    final latest = await DigestService.getLatestDigest();
    if (mounted) {
      setState(() => _latestDigest = latest);
    }
  }

  Future<void> _clearAllData() async {
    final storage = await StorageService.getInstance();
    await storage.clearAll();
    setState(() {
      _entries = [];
      _streak = 0;
      _atmosphereMode = AtmosphereMode.neutral;
      _earnedAchievementCount = 0;
      _challenges = [];
      _challengeWeekCompleted = 0;
      _challengeTotalCompleted = 0;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Stack(
        alignment: Alignment.topLeft,
        children: [
          // Ambient particle system
          Positioned.fill(
            child: IgnorePointer(
              child: AmbientParticles(mode: _atmosphereMode),
            ),
          ),

          // Static ambient glow effects
          Positioned(
            top: -100,
            right: -50,
            child: Container(
              width: 350,
              height: 350,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [
                    AppColors.accent.withOpacity(0.05),
                    Colors.transparent,
                  ],
                ),
              ),
            ),
          ),
          Positioned(
            bottom: -80,
            left: -30,
            child: Container(
              width: 280,
              height: 280,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [
                    AppColors.warmGold.withOpacity(0.03),
                    Colors.transparent,
                  ],
                ),
              ),
            ),
          ),

          // Main content
          SafeArea(
            child: Column(
              children: [
                // Header
                Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Feelong',
                            style: Theme.of(context)
                                .textTheme
                                .headlineLarge
                                ?.copyWith(
                                  fontFamily: 'Palatino',
                                ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            'AI MOOD JOURNAL',
                            style: TextStyle(
                              fontSize: 11,
                              color: AppColors.textMuted,
                              letterSpacing: 3,
                            ),
                          ),
                        ],
                      ),
                      if (_streak > 0)
                        Semantics(
                          label: '$_streak day streak',
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 14, vertical: 8),
                            decoration: BoxDecoration(
                              color: AppColors.accentTranslucent,
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(
                                color: AppColors.accentBorder,
                              ),
                            ),
                            child: Text(
                              '\u{1F525} ${_streak}d streak',
                              style: const TextStyle(
                                fontSize: 13,
                                color: AppColors.accent,
                              ),
                            ),
                          ),
                        ),
                      const SizedBox(width: 8),
                      Semantics(
                        button: true,
                        label: 'Notification settings',
                        child: GestureDetector(
                        onTap: () {
                          Navigator.of(context).push(
                            PageRouteBuilder(
                              pageBuilder: (_, __, ___) =>
                                  const ReminderSettingsScreen(),
                              transitionsBuilder: (_, anim, __, child) =>
                                  SlideTransition(
                                position: Tween(
                                  begin: const Offset(1, 0),
                                  end: Offset.zero,
                                ).animate(CurvedAnimation(
                                  parent: anim,
                                  curve: Curves.easeOutCubic,
                                )),
                                child: child,
                              ),
                              transitionDuration:
                                  const Duration(milliseconds: 350),
                            ),
                          );
                        },
                        child: Container(
                          width: 40,
                          height: 40,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: AppColors.surface.withOpacity(0.6),
                            border: Border.all(color: AppColors.borderLight),
                          ),
                          child: const Icon(
                            Icons.notifications_outlined,
                            color: AppColors.textMuted,
                            size: 20,
                          ),
                        ),
                      ),
                      ),
                    ],
                  ),
                ),

                // Tab bar
                Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 24, vertical: 4),
                  child: Row(
                    children: [
                      _TabButton(
                        label: 'Check In',
                        isActive: _currentIndex == 0,
                        onTap: () {
                          setState(() => _currentIndex = 0);
                          AnalyticsService().logScreenView('check_in');
                        },
                      ),
                      const SizedBox(width: 6),
                      _TabButton(
                        label: 'History',
                        isActive: _currentIndex == 1,
                        onTap: () {
                          setState(() => _currentIndex = 1);
                          AnalyticsService().logScreenView('history');
                        },
                      ),
                      const SizedBox(width: 6),
                      _TabButton(
                        label: 'Insights',
                        isActive: _currentIndex == 2,
                        onTap: () {
                          setState(() => _currentIndex = 2);
                          AnalyticsService().logScreenView('insights');
                        },
                      ),
                      if (kIsWeb) ...[
                        const Spacer(),
                        _StoreButton(
                          icon: Icons.apple,
                          label: 'App Store',
                          onTap: () => launchUrl(
                            Uri.parse('https://apps.apple.com/us/app/feelong/id6760197546'),
                            mode: LaunchMode.externalApplication,
                          ),
                        ),
                        const SizedBox(width: 6),
                        _StoreButton(
                          icon: Icons.shop,
                          label: 'Google Play',
                          onTap: () => launchUrl(
                            Uri.parse('https://play.google.com/store/apps/details?id=com.feelong.app'),
                            mode: LaunchMode.externalApplication,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
                const SizedBox(height: 16),

                // Screen content
                Expanded(
                  child: AnimatedSwitcher(
                    duration: const Duration(milliseconds: 300),
                    child: _buildScreen(),
                  ),
                ),

                // Banner ad pinned to bottom
                const AdaptiveBannerAd(),
              ],
            ),
          ),

          // Achievement celebration overlay (on top of everything)
          if (_newAchievements.isNotEmpty)
            Positioned.fill(
              child: AchievementCelebration(
                achievements: _newAchievements,
                onDismiss: () async {
                  await AchievementService().markAllSeen();
                  if (mounted) setState(() => _newAchievements = []);
                },
              ),
            ),

        ],
      ),
    );
  }

  Widget _buildScreen() {
    switch (_currentIndex) {
      case 0:
        return CheckInScreen(
          key: const ValueKey('checkin'),
          onEntryAdded: _loadEntries,
        );
      case 1:
        return HistoryScreen(
          key: const ValueKey('history'),
          entries: _entries,
        );
      case 2:
        return InsightsScreen(
          key: const ValueKey('insights'),
          entries: _entries,
          streak: _streak,
          onClearData: _clearAllData,
          digestCard: _buildDigestCard(),
          capsuleCard: _buildCapsuleCard(),
          achievementCard: _buildAchievementCard(),
          challengeCard: _buildChallengeStatsCard(),
        );
      default:
        return const SizedBox();
    }
  }

  Widget? _buildDigestCard() {
    if (_latestDigest == null) return null;

    final dateFormat = DateFormat.MMMd();
    return Semantics(
      button: true,
      label: 'View weekly digest',
      child: GestureDetector(
      onTap: () {
        Navigator.of(context).push(
          PageRouteBuilder(
            pageBuilder: (_, __, ___) => WeeklyDigestScreen(
              initialDigest: _latestDigest,
            ),
            transitionsBuilder: (_, anim, __, child) =>
                FadeTransition(opacity: anim, child: child),
            transitionDuration: const Duration(milliseconds: 400),
          ),
        );
      },
      child: GlassCard(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color(0x14E8945A),
            Color(0x0FD4A574),
          ],
        ),
        borderColor: const Color(0x26E8945A),
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            const Text('\u{1F4CA}', style: TextStyle(fontSize: 24)),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Weekly Digest',
                    style: TextStyle(
                      fontSize: 14,
                      color: AppColors.accent,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  Text(
                    'Week of ${dateFormat.format(_latestDigest!.weekStart)} · ${_latestDigest!.entryCount} entries',
                    style: const TextStyle(
                      fontSize: 11,
                      color: AppColors.textDim,
                    ),
                  ),
                ],
              ),
            ),
            const Icon(
              Icons.arrow_forward_ios,
              color: AppColors.accent,
              size: 14,
            ),
          ],
        ),
      ),
    ),
    );
  }

  Widget _buildCapsuleCard() {
    return Semantics(
      button: true,
      label: 'View time capsules',
      child: GestureDetector(
      onTap: () {
        Navigator.of(context).push(
          PageRouteBuilder(
            pageBuilder: (_, __, ___) => const TimeCapsuleScreen(),
            transitionsBuilder: (_, anim, __, child) =>
                FadeTransition(opacity: anim, child: child),
            transitionDuration: const Duration(milliseconds: 400),
          ),
        );
      },
      child: GlassCard(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color(0x14D4A574),
            Color(0x0FE8945A),
          ],
        ),
        borderColor: const Color(0x26D4A574),
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            const Text('\u{1F48C}', style: TextStyle(fontSize: 24)),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Time Capsules',
                    style: TextStyle(
                      fontSize: 14,
                      color: AppColors.warmGold,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const Text(
                    'Letters to your future self',
                    style: TextStyle(
                      fontSize: 11,
                      color: AppColors.textDim,
                    ),
                  ),
                ],
              ),
            ),
            const Icon(
              Icons.arrow_forward_ios,
              color: AppColors.warmGold,
              size: 14,
            ),
          ],
        ),
      ),
    ),
    );
  }

  Widget _buildAchievementCard() {
    return Semantics(
      button: true,
      label: 'View achievements gallery',
      child: GestureDetector(
        onTap: () {
          Navigator.of(context).push(
            PageRouteBuilder(
              pageBuilder: (_, __, ___) => const AchievementGalleryScreen(),
              transitionsBuilder: (_, anim, __, child) =>
                  FadeTransition(opacity: anim, child: child),
              transitionDuration: const Duration(milliseconds: 400),
            ),
          );
        },
        child: GlassCard(
          gradient: const LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Color(0x14FFD700),
              Color(0x0FC4A882),
            ],
          ),
          borderColor: const Color(0x26FFD700),
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              const Text('\u{1F3C6}', style: TextStyle(fontSize: 24)),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Achievements',
                      style: TextStyle(
                        fontSize: 14,
                        color: Color(0xFFFFD700),
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    Text(
                      '$_earnedAchievementCount of ${allAchievements.length} earned',
                      style: const TextStyle(
                        fontSize: 11,
                        color: AppColors.textDim,
                      ),
                    ),
                  ],
                ),
              ),
              const Icon(
                Icons.arrow_forward_ios,
                color: Color(0xFFFFD700),
                size: 14,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget? _buildChallengeStatsCard() {
    if (_challengeTotalCompleted == 0 && _challenges.isEmpty) return null;

    return GlassCard(
      gradient: const LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [
          Color(0x1A7BC47F),
          Color(0x14A5C9A0),
        ],
      ),
      borderColor: const Color(0x267BC47F),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Text('\u{1F3AF}', style: TextStyle(fontSize: 20)),
              const SizedBox(width: 10),
              const Text(
                'Challenges This Week',
                style: TextStyle(
                  fontSize: 14,
                  color: Color(0xFFA5C9A0),
                  fontWeight: FontWeight.w600,
                ),
              ),
              const Spacer(),
              Text(
                '$_challengeWeekCompleted / 7',
                style: const TextStyle(
                  fontSize: 13,
                  color: Color(0xFF7BC47F),
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: SizedBox(
              height: 6,
              child: LinearProgressIndicator(
                value: (_challengeWeekCompleted / 7).clamp(0.0, 1.0),
                backgroundColor: AppColors.borderLight,
                valueColor: const AlwaysStoppedAnimation(Color(0xFF7BC47F)),
              ),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            '$_challengeTotalCompleted total completed',
            style: const TextStyle(
              fontSize: 11,
              color: AppColors.textDim,
            ),
          ),
        ],
      ),
    );
  }
}

class _TabButton extends StatelessWidget {
  final String label;
  final bool isActive;
  final VoidCallback onTap;

  const _TabButton({
    required this.label,
    required this.isActive,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      selected: isActive,
      label: '$label tab',
      child: GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 250),
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
          decoration: BoxDecoration(
            color: isActive ? AppColors.accentTranslucent : Colors.transparent,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: isActive ? AppColors.accentBorder : AppColors.borderLight,
            ),
          ),
          child: Text(
            label,
            style: TextStyle(
              fontSize: 13,
              color: isActive ? AppColors.accent : AppColors.textMuted,
              letterSpacing: 0.5,
            ),
          ),
        ),
      ),
    );
  }
}

class _StoreButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  const _StoreButton({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      label: 'Download on $label',
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          decoration: BoxDecoration(
            color: AppColors.accentTranslucent,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: AppColors.accentBorder),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, size: 16, color: AppColors.accent),
              const SizedBox(width: 6),
              Text(
                label,
                style: const TextStyle(
                  fontSize: 12,
                  color: AppColors.accent,
                  letterSpacing: 0.5,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

