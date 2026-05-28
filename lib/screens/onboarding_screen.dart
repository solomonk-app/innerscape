import 'package:flutter/material.dart';
import 'package:animate_do/animate_do.dart';
import '../theme/app_theme.dart';
import '../widgets/glass_card.dart';
import '../widgets/ambient_particles.dart';
import '../services/atmosphere_service.dart';
import '../services/storage_service.dart';
import '../main.dart';

class OnboardingScreen extends StatefulWidget {
  final bool isReplay;

  const OnboardingScreen({super.key, this.isReplay = false});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen>
    with TickerProviderStateMixin {
  final _pageController = PageController();
  int _currentPage = 0;

  // Page 1: interactive mood selection
  int? _selectedDemoMood;

  // Page 2: typewriter animation
  late AnimationController _typewriterController;
  final String _typewriterText =
      'You tend to feel better on weekends. Consider what makes those days different \u2014 and bring more of that into your week.';
  bool _typewriterStarted = false;

  // Page 3: pulsing glow
  late AnimationController _pulseController;

  @override
  void initState() {
    super.initState();
    _typewriterController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2200),
    );
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    );

    _pageController.addListener(_onPageScroll);
  }

  void _onPageScroll() {
    final page = _pageController.page?.round() ?? 0;
    if (page == 1 && !_typewriterStarted) {
      _typewriterStarted = true;
      Future.delayed(const Duration(milliseconds: 800), () {
        if (mounted) _typewriterController.forward();
      });
    }
    if (page == 2) {
      if (!_pulseController.isAnimating) {
        _pulseController.repeat(reverse: true);
      }
    }
  }

  Future<void> _complete() async {
    if (widget.isReplay) {
      if (!mounted) return;
      Navigator.of(context).pop();
      return;
    }
    final storage = await StorageService.getInstance();
    await storage.setOnboardingSeen();
    if (!mounted) return;
    Navigator.of(context).pushReplacement(
      PageRouteBuilder(
        pageBuilder: (_, __, ___) => const HomeScreen(),
        transitionsBuilder: (_, anim, __, child) =>
            FadeTransition(opacity: anim, child: child),
        transitionDuration: const Duration(milliseconds: 400),
      ),
    );
  }

  void _nextPage() {
    _pageController.nextPage(
      duration: const Duration(milliseconds: 350),
      curve: Curves.easeOutCubic,
    );
  }

  @override
  void dispose() {
    _pageController.removeListener(_onPageScroll);
    _pageController.dispose();
    _typewriterController.dispose();
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Stack(
        children: [
          const Positioned.fill(
            child: AmbientParticles(mode: AtmosphereMode.neutral),
          ),
          SafeArea(
            child: Column(
              children: [
                // Skip button
                if (_currentPage < 2)
                  Align(
                    alignment: Alignment.centerRight,
                    child: Semantics(
                      button: true,
                      label: 'Skip onboarding',
                      child: TextButton(
                        onPressed: _complete,
                        child: const Text(
                          'Skip',
                          style: TextStyle(
                            color: AppColors.textDim,
                            fontSize: 14,
                          ),
                        ),
                      ),
                    ),
                  )
                else
                  const SizedBox(height: 48),

                // Pages
                Expanded(
                  child: PageView(
                    controller: _pageController,
                    onPageChanged: (page) =>
                        setState(() => _currentPage = page),
                    children: [
                      _buildPage1(context),
                      _buildPage2(context),
                      _buildPage3(context),
                    ],
                  ),
                ),

                // Dot indicators
                Padding(
                  padding: const EdgeInsets.only(bottom: 16),
                  child: Semantics(
                    label: 'Page ${_currentPage + 1} of 3',
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: List.generate(3, (i) {
                        final isActive = i == _currentPage;
                        return AnimatedContainer(
                          duration: const Duration(milliseconds: 250),
                          margin: const EdgeInsets.symmetric(horizontal: 4),
                          width: isActive ? 24 : 8,
                          height: 8,
                          decoration: BoxDecoration(
                            color: isActive
                                ? AppColors.accent
                                : AppColors.textDim,
                            borderRadius: BorderRadius.circular(4),
                          ),
                        );
                      }),
                    ),
                  ),
                ),

                // Next / Get Started button
                Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                  child: SizedBox(
                    width: double.infinity,
                    height: 56,
                    child: _currentPage < 2
                        ? Semantics(
                            button: true,
                            label: 'Next page',
                            child: ElevatedButton(
                              onPressed: _nextPage,
                              style: ElevatedButton.styleFrom(
                                backgroundColor:
                                    AppColors.surface.withOpacity(0.6),
                                foregroundColor: AppColors.textPrimary,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(16),
                                  side: const BorderSide(
                                      color: AppColors.borderLight),
                                ),
                                elevation: 0,
                              ),
                              child: const Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text(
                                    'Next',
                                    style: TextStyle(
                                      fontSize: 15,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                  SizedBox(width: 8),
                                  Icon(Icons.arrow_forward, size: 18),
                                ],
                              ),
                            ),
                          )
                        : AnimatedBuilder(
                            animation: _pulseController,
                            builder: (context, child) {
                              final glowOpacity =
                                  0.15 + (_pulseController.value * 0.25);
                              return Container(
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(16),
                                  boxShadow: [
                                    BoxShadow(
                                      color: AppColors.accent
                                          .withOpacity(glowOpacity),
                                      blurRadius: 20,
                                      spreadRadius: 2,
                                    ),
                                  ],
                                ),
                                child: child,
                              );
                            },
                            child: ElevatedButton(
                              onPressed: _complete,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppColors.accent,
                                foregroundColor: AppColors.background,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(16),
                                ),
                                elevation: 8,
                                shadowColor: AppColors.accent.withOpacity(0.3),
                                minimumSize: const Size(double.infinity, 56),
                              ),
                              child: Text(
                                widget.isReplay
                                    ? 'Back to App'
                                    : 'Begin Your First Check-In',
                                style: const TextStyle(
                                  fontSize: 15,
                                  fontWeight: FontWeight.w600,
                                  letterSpacing: 0.5,
                                ),
                              ),
                            ),
                          ),
                  ),
                ),
                const SizedBox(height: 16),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ─── Page 1: Interactive mood selection ───

  Widget _buildPage1(BuildContext context) {
    final emojis = ['😢', '😟', '😐', '🙂', '😊', '🤩'];
    final labels = ['Awful', 'Bad', 'Meh', 'Okay', 'Good', 'Amazing'];

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 32),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          FadeInDown(
            key: const ValueKey('page1-header'),
            duration: const Duration(milliseconds: 500),
            child: Text(
              'Welcome to Feelong',
              style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                    color: AppColors.warmGold,
                  ),
            ),
          ),
          const SizedBox(height: 12),
          FadeInDown(
            key: const ValueKey('page1-subtitle'),
            delay: const Duration(milliseconds: 150),
            duration: const Duration(milliseconds: 500),
            child: Text(
              'Track your moods with a simple daily check-in',
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    color: AppColors.textMuted,
                  ),
            ),
          ),
          const SizedBox(height: 40),
          FadeInUp(
            key: const ValueKey('page1-emojis'),
            delay: const Duration(milliseconds: 300),
            duration: const Duration(milliseconds: 500),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(emojis.length, (i) {
                final isSelected = _selectedDemoMood == i;
                return GestureDetector(
                  onTap: () => setState(() => _selectedDemoMood = i),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 250),
                    curve: Curves.easeOutBack,
                    margin: const EdgeInsets.symmetric(horizontal: 4),
                    padding: const EdgeInsets.all(10),
                    transform: isSelected
                        ? (Matrix4.identity()..scale(1.2))
                        : Matrix4.identity(),
                    transformAlignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: isSelected
                          ? AppColors.accent.withOpacity(0.2)
                          : AppColors.surface.withOpacity(0.6),
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(
                        color: isSelected
                            ? AppColors.accent
                            : AppColors.borderLight,
                      ),
                    ),
                    child: Text(emojis[i],
                        style: const TextStyle(fontSize: 22)),
                  ),
                );
              }),
            ),
          ),
          const SizedBox(height: 24),
          AnimatedSwitcher(
            duration: const Duration(milliseconds: 300),
            child: _selectedDemoMood != null
                ? FadeInUp(
                    key: ValueKey('mood-selected-$_selectedDemoMood'),
                    duration: const Duration(milliseconds: 400),
                    child: Column(
                      children: [
                        Text(
                          'Feeling ${labels[_selectedDemoMood!]}',
                          style: Theme.of(context)
                              .textTheme
                              .bodyMedium
                              ?.copyWith(
                                color: AppColors.warmGold,
                                fontWeight: FontWeight.w600,
                              ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          "That's how easy it is!",
                          style:
                              Theme.of(context).textTheme.bodySmall?.copyWith(
                                    color: AppColors.textDim,
                                    fontStyle: FontStyle.italic,
                                  ),
                        ),
                      ],
                    ),
                  )
                : Text(
                    'Tap a mood to try it',
                    key: const ValueKey('tap-hint'),
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: AppColors.textDim,
                          fontStyle: FontStyle.italic,
                        ),
                  ),
          ),
        ],
      ),
    );
  }

  // ─── Page 2: Typewriter AI reflection ───

  Widget _buildPage2(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 32),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          FadeInDown(
            key: const ValueKey('page2-header'),
            duration: const Duration(milliseconds: 500),
            child: Text(
              'Discover Patterns',
              style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                    color: AppColors.warmGold,
                  ),
            ),
          ),
          const SizedBox(height: 12),
          FadeInDown(
            key: const ValueKey('page2-subtitle'),
            delay: const Duration(milliseconds: 150),
            duration: const Duration(milliseconds: 500),
            child: Text(
              'AI-powered insights help you understand your emotional patterns',
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    color: AppColors.textMuted,
                  ),
            ),
          ),
          const SizedBox(height: 32),
          FadeInUp(
            key: const ValueKey('page2-card'),
            delay: const Duration(milliseconds: 300),
            duration: const Duration(milliseconds: 500),
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
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '✨ AI REFLECTION',
                    style: Theme.of(context).textTheme.labelSmall?.copyWith(
                          color: AppColors.accent,
                        ),
                  ),
                  const SizedBox(height: 10),
                  AnimatedBuilder(
                    animation: _typewriterController,
                    builder: (context, _) {
                      final charCount =
                          (_typewriterController.value * _typewriterText.length)
                              .round();
                      final displayText =
                          _typewriterText.substring(0, charCount);
                      return Text(
                        displayText,
                        style:
                            Theme.of(context).textTheme.bodyMedium?.copyWith(
                                  color: AppColors.textSecondary,
                                  fontStyle: FontStyle.italic,
                                  height: 1.6,
                                ),
                      );
                    },
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          FadeInUp(
            key: const ValueKey('page2-capsule'),
            delay: const Duration(milliseconds: 450),
            duration: const Duration(milliseconds: 500),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text('💌', style: TextStyle(fontSize: 20)),
                const SizedBox(width: 10),
                Text(
                  'Write letters to your future self',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: AppColors.warmGold,
                      ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ─── Page 3: Pulsing CTA ───

  Widget _buildPage3(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 32),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          FadeInDown(
            key: const ValueKey('page3-emoji'),
            duration: const Duration(milliseconds: 500),
            child: const Text('🌱', style: TextStyle(fontSize: 64)),
          ),
          const SizedBox(height: 20),
          FadeInDown(
            key: const ValueKey('page3-header'),
            delay: const Duration(milliseconds: 150),
            duration: const Duration(milliseconds: 500),
            child: Text(
              'Your Journey Begins',
              style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                    color: AppColors.warmGold,
                  ),
            ),
          ),
          const SizedBox(height: 12),
          FadeInUp(
            key: const ValueKey('page3-body'),
            delay: const Duration(milliseconds: 300),
            duration: const Duration(milliseconds: 500),
            child: Text(
              'A few moments of reflection each day\ncan transform how you understand yourself.',
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    color: AppColors.textMuted,
                    height: 1.6,
                  ),
            ),
          ),
        ],
      ),
    );
  }
}
