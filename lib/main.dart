import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_web_plugins/url_strategy.dart';
import 'package:intl/intl.dart';
import 'theme/app_theme.dart';
import 'models/mood_entry.dart';
import 'models/weekly_digest.dart';
import 'services/storage_service.dart';
import 'services/notification_service.dart';
import 'services/atmosphere_service.dart';
import 'services/digest_service.dart';
import 'services/consent_service.dart';
import 'services/ad_service.dart';
import 'screens/checkin_screen.dart';
import 'screens/history_screen.dart';
import 'screens/insights_screen.dart';
import 'screens/reminder_settings_screen.dart';
import 'screens/weekly_digest_screen.dart';
import 'screens/time_capsule_screen.dart';
import 'widgets/ambient_particles.dart';
import 'widgets/glass_card.dart';
import 'widgets/adaptive_banner_ad.dart';
import 'screens/privacy_policy_screen.dart';
import 'screens/terms_screen.dart';
import 'screens/support_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  usePathUrlStrategy();
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.light,
      systemNavigationBarColor: AppColors.surface,
    ),
  );

  // Initialize notifications
  final notificationService = NotificationService();
  await notificationService.init();
  await notificationService.rescheduleIfEnabled();
  await notificationService.scheduleWeeklyDigestReminder();

  runApp(const FeelongApp());
}

class FeelongApp extends StatelessWidget {
  const FeelongApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Feelong',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.darkTheme,
      routes: {
        '/': (_) => const HomeScreen(),
        '/privacy': (_) => const PrivacyPolicyScreen(),
        '/terms': (_) => const TermsScreen(),
        '/support': (_) => const SupportScreen(),
      },
    );
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
    setState(() {
      _entries = entries;
      _streak = storage.calculateStreak(entries);
      _atmosphereMode = AtmosphereService.getMode(entries);
    });
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
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Stack(
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
                        Container(
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
                      const SizedBox(width: 8),
                      GestureDetector(
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
                        onTap: () => setState(() => _currentIndex = 0),
                      ),
                      const SizedBox(width: 6),
                      _TabButton(
                        label: 'History',
                        isActive: _currentIndex == 1,
                        onTap: () => setState(() => _currentIndex = 1),
                      ),
                      const SizedBox(width: 6),
                      _TabButton(
                        label: 'Insights',
                        isActive: _currentIndex == 2,
                        onTap: () => setState(() => _currentIndex = 2),
                      ),
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
        );
      default:
        return const SizedBox();
    }
  }

  Widget? _buildDigestCard() {
    if (_latestDigest == null) return null;

    final dateFormat = DateFormat.MMMd();
    return GestureDetector(
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
    );
  }

  Widget _buildCapsuleCard() {
    return GestureDetector(
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
    return GestureDetector(
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
    );
  }
}

