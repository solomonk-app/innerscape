import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:animate_do/animate_do.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../constants/bible_verses.dart';
import '../models/mood_entry.dart';
import '../services/conversation_service.dart';
import '../services/ad_service.dart';
import '../services/analytics_service.dart';
import '../theme/app_theme.dart';
import '../widgets/glass_card.dart';
import 'time_capsule_screen.dart';

class ResultScreen extends StatefulWidget {
  final MoodEntry entry;
  final String wellnessTip;
  final BibleVerse? bibleVerse;
  final VoidCallback onNewCheckIn;

  const ResultScreen({
    super.key,
    required this.entry,
    required this.wellnessTip,
    this.bibleVerse,
    required this.onNewCheckIn,
  });

  @override
  State<ResultScreen> createState() => _ResultScreenState();
}

class _ResultScreenState extends State<ResultScreen> {
  // Conversation state
  bool _showConversation = false;
  ConversationService? _conversationService;
  final List<_ChatMessage> _messages = [];
  final _chatController = TextEditingController();
  bool _isAiTyping = false;
  final _scrollController = ScrollController();

  static const String _checkInCountKey = 'checkin_count_for_ads';
  static const int _interstitialFrequency = 2;

  @override
  void initState() {
    super.initState();
    _incrementCheckInCount();
  }

  @override
  void dispose() {
    _chatController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _incrementCheckInCount() async {
    final prefs = await SharedPreferences.getInstance();
    final count = (prefs.getInt(_checkInCountKey) ?? 0) + 1;
    await prefs.setInt(_checkInCountKey, count);

    if (count % _interstitialFrequency == 0) {
      final shown = await AdService().showInterstitial();
      if (shown) AnalyticsService().logInterstitialShown();
    }
  }

  Future<void> _startConversation() async {
    await AnalyticsService().logAiConversationStart();
    setState(() {
      _showConversation = true;
      _isAiTyping = true;
    });

    _conversationService = ConversationService(entry: widget.entry);
    try {
      final response = await _conversationService!.startConversation();

      if (!mounted) return;
      setState(() {
        _messages.add(_ChatMessage(text: response, isUser: false));
        _isAiTyping = false;
      });
      _scrollToBottom();
    } catch (e) {
      if (!mounted) return;
      setState(() => _isAiTyping = false);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Could not connect. Please try again.')),
      );
    }
  }

  Future<void> _sendMessage() async {
    final text = _chatController.text.trim();
    if (text.isEmpty || _isAiTyping) return;
    if (_conversationService == null || _conversationService!.isComplete) return;

    _chatController.clear();
    setState(() {
      _messages.add(_ChatMessage(text: text, isUser: true));
      _isAiTyping = true;
    });
    _scrollToBottom();

    try {
      final response = await _conversationService!.sendMessage(text);

      if (!mounted) return;
      setState(() {
        _messages.add(_ChatMessage(text: response, isUser: false));
        _isAiTyping = false;
      });
      _scrollToBottom();
    } catch (e) {
      if (!mounted) return;
      setState(() => _isAiTyping = false);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Could not connect. Please try again.')),
      );
    }
  }

  void _scrollToBottom() {
    Future.delayed(const Duration(milliseconds: 100), () {
      if (!mounted) return;
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final mood = moodOptions.firstWhere((m) => m.value == widget.entry.mood);
    final dateFormat = DateFormat('EEE, MMM d');
    final timeFormat = DateFormat('h:mm a');

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: _showConversation
            ? _buildConversationView(context)
            : _buildResultView(context, mood, dateFormat, timeFormat),
      ),
    );
  }

  Widget _buildResultView(BuildContext context, MoodOption mood,
      DateFormat dateFormat, DateFormat timeFormat) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Center(
        child: ConstrainedBox(
          constraints: BoxConstraints(maxWidth: kIsWeb ? 480 : double.infinity),
          child: Column(
            children: [
          // Back button
          Align(
            alignment: Alignment.centerLeft,
            child: GestureDetector(
              onTap: widget.onNewCheckIn,
              child: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: AppColors.surface.withOpacity(0.6),
                  border: Border.all(color: AppColors.borderLight),
                ),
                child: const Icon(
                  Icons.arrow_back_ios_new,
                  color: AppColors.textMuted,
                  size: 18,
                ),
              ),
            ),
          ),
          const SizedBox(height: 20),

          // Mood emoji
          FadeInDown(
            duration: const Duration(milliseconds: 600),
            child: Text(mood.emoji, style: const TextStyle(fontSize: 64)),
          ),
          const SizedBox(height: 12),

          // Mood label
          FadeInDown(
            delay: const Duration(milliseconds: 200),
            duration: const Duration(milliseconds: 500),
            child: Text(
              'Feeling ${mood.label}',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    color: AppColors.warmGold,
                    fontSize: 18,
                  ),
            ),
          ),
          const SizedBox(height: 4),

          // Date/time
          FadeInDown(
            delay: const Duration(milliseconds: 300),
            duration: const Duration(milliseconds: 500),
            child: Text(
              '${dateFormat.format(widget.entry.timestamp)} · ${timeFormat.format(widget.entry.timestamp)}',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: AppColors.textDim,
                  ),
            ),
          ),
          const SizedBox(height: 36),

          // AI Insight card
          if (widget.entry.aiInsight.isNotEmpty)
            FadeInUp(
              delay: const Duration(milliseconds: 400),
              duration: const Duration(milliseconds: 600),
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
                padding: const EdgeInsets.all(24),
                margin: const EdgeInsets.only(bottom: 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '✨ AI REFLECTION',
                      style:
                          Theme.of(context).textTheme.labelSmall?.copyWith(
                                color: AppColors.accent,
                              ),
                    ),
                    const SizedBox(height: 14),
                    Text(
                      widget.entry.aiInsight,
                      style:
                          Theme.of(context).textTheme.bodyLarge?.copyWith(
                                color: AppColors.textSecondary,
                                fontStyle: FontStyle.italic,
                              ),
                    ),
                  ],
                ),
              ),
            ),

          // Bible verse card
          if (widget.bibleVerse != null)
            FadeInUp(
              delay: const Duration(milliseconds: 450),
              duration: const Duration(milliseconds: 600),
              child: GlassCard(
                gradient: const LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    Color(0x147B9ECF),
                    Color(0x14A78BCA),
                  ],
                ),
                borderColor: const Color(0x26A78BCA),
                padding: const EdgeInsets.all(24),
                margin: const EdgeInsets.only(bottom: 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '\u{1F4D6} DAILY VERSE',
                      style:
                          Theme.of(context).textTheme.labelSmall?.copyWith(
                                color: const Color(0xFFB8CCE5),
                              ),
                    ),
                    const SizedBox(height: 14),
                    Text(
                      widget.bibleVerse!.text,
                      style:
                          Theme.of(context).textTheme.bodyLarge?.copyWith(
                                color: AppColors.textSecondary,
                                fontStyle: FontStyle.italic,
                                height: 1.6,
                              ),
                    ),
                    const SizedBox(height: 12),
                    Align(
                      alignment: Alignment.centerRight,
                      child: Text(
                        '— ${widget.bibleVerse!.reference}',
                        style:
                            Theme.of(context).textTheme.bodySmall?.copyWith(
                                  color: AppColors.textDim,
                                ),
                      ),
                    ),
                  ],
                ),
              ),
            ),

          // "Talk about this" button
          FadeInUp(
            delay: const Duration(milliseconds: 500),
            duration: const Duration(milliseconds: 500),
            child: GestureDetector(
              onTap: _startConversation,
              child: GlassCard(
                gradient: const LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    Color(0x147B9ECF),
                    Color(0x0FA78BCA),
                  ],
                ),
                borderColor: const Color(0x267B9ECF),
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
                margin: const EdgeInsets.only(bottom: 16),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text('💬', style: TextStyle(fontSize: 18)),
                    const SizedBox(width: 10),
                    Text(
                      'I\'d like to talk about this',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: const Color(0xFFB8CCE5),
                            fontWeight: FontWeight.w600,
                          ),
                    ),
                  ],
                ),
              ),
            ),
          ),

          // Wellness tip card
          FadeInUp(
            delay: const Duration(milliseconds: 600),
            duration: const Duration(milliseconds: 600),
            child: GlassCard(
              color: AppColors.surface.withOpacity(0.5),
              borderColor: AppColors.borderLight,
              padding: const EdgeInsets.all(20),
              margin: const EdgeInsets.only(bottom: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '💡 WELLNESS TIP',
                    style: Theme.of(context).textTheme.labelSmall,
                  ),
                  const SizedBox(height: 12),
                  Text(
                    widget.wellnessTip,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: AppColors.textMuted,
                          height: 1.6,
                        ),
                  ),
                ],
              ),
            ),
          ),

          // Write to Future You button
          FadeInUp(
            delay: const Duration(milliseconds: 700),
            duration: const Duration(milliseconds: 500),
            child: GestureDetector(
              onTap: () {
                Navigator.of(context).push(
                  PageRouteBuilder(
                    pageBuilder: (_, __, ___) => TimeCapsuleScreen(
                      currentMood: widget.entry.mood,
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
                    Color(0x14D4A574),
                    Color(0x0FE8945A),
                  ],
                ),
                borderColor: const Color(0x26D4A574),
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
                margin: const EdgeInsets.only(bottom: 32),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text('💌', style: TextStyle(fontSize: 18)),
                    const SizedBox(width: 10),
                    Text(
                      'Write to Future You',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: AppColors.warmGold,
                            fontWeight: FontWeight.w600,
                          ),
                    ),
                  ],
                ),
              ),
            ),
          ),

          // New check-in button
          FadeInUp(
            delay: const Duration(milliseconds: 800),
            duration: const Duration(milliseconds: 500),
            child: SizedBox(
              width: double.infinity,
              height: 54,
              child: OutlinedButton(
                onPressed: widget.onNewCheckIn,
                style: OutlinedButton.styleFrom(
                  side: const BorderSide(
                    color: AppColors.accentBorder,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
                child: const Text(
                  'New Check-In',
                  style: TextStyle(
                    color: AppColors.accent,
                    fontSize: 14,
                    letterSpacing: 0.5,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
        ),
      ),
    );
  }

  Widget _buildConversationView(BuildContext context) {
    final isComplete =
        _conversationService != null && _conversationService!.isComplete;

    return Column(
      children: [
        // Header
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Row(
            children: [
              IconButton(
                onPressed: () {
                  setState(() => _showConversation = false);
                },
                icon: const Icon(
                  Icons.arrow_back_ios,
                  color: AppColors.textMuted,
                  size: 20,
                ),
              ),
              Expanded(
                child: Column(
                  children: [
                    const Text(
                      'Conversation',
                      style: TextStyle(
                        color: AppColors.textPrimary,
                        fontSize: 16,
                      ),
                    ),
                    if (!isComplete && _conversationService != null)
                      Text(
                        '${_conversationService!.turnsRemaining} turns remaining',
                        style: const TextStyle(
                          color: AppColors.textDim,
                          fontSize: 11,
                        ),
                      ),
                  ],
                ),
              ),
              const SizedBox(width: 48),
            ],
          ),
        ),

        // Messages
        Expanded(
          child: ListView.builder(
            controller: _scrollController,
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
            itemCount: _messages.length + (_isAiTyping ? 1 : 0),
            itemBuilder: (ctx, idx) {
              if (idx == _messages.length && _isAiTyping) {
                return _buildTypingIndicator();
              }
              return _buildChatBubble(_messages[idx]);
            },
          ),
        ),

        // Input area
        if (!isComplete)
          Container(
            padding: const EdgeInsets.fromLTRB(20, 8, 20, 16),
            decoration: const BoxDecoration(
              border: Border(
                top: BorderSide(color: AppColors.borderLight),
              ),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    decoration: BoxDecoration(
                      color: AppColors.surface.withOpacity(0.6),
                      borderRadius: BorderRadius.circular(24),
                      border: Border.all(color: AppColors.borderLight),
                    ),
                    child: TextField(
                      controller: _chatController,
                      style: const TextStyle(
                        color: AppColors.textPrimary,
                        fontSize: 14,
                      ),
                      decoration: const InputDecoration(
                        hintText: 'Share your thoughts...',
                        hintStyle: TextStyle(
                          color: AppColors.textDim,
                          fontSize: 14,
                        ),
                        border: InputBorder.none,
                        contentPadding: EdgeInsets.symmetric(vertical: 12),
                      ),
                      onSubmitted: (_) => _sendMessage(),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                GestureDetector(
                  onTap: _sendMessage,
                  child: Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      color: AppColors.accent,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.arrow_upward,
                      color: AppColors.background,
                      size: 20,
                    ),
                  ),
                ),
              ],
            ),
          ),

        // Conversation complete
        if (isComplete)
          Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              children: [
                const Text(
                  'Conversation complete',
                  style: TextStyle(
                    color: AppColors.textMuted,
                    fontSize: 12,
                    letterSpacing: 1,
                  ),
                ),
                const SizedBox(height: 12),
                SizedBox(
                  width: double.infinity,
                  height: 48,
                  child: OutlinedButton(
                    onPressed: () {
                      setState(() => _showConversation = false);
                    },
                    style: OutlinedButton.styleFrom(
                      side: const BorderSide(color: AppColors.accentBorder),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: const Text(
                      'Back to Results',
                      style: TextStyle(
                        color: AppColors.accent,
                        fontSize: 14,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
      ],
    );
  }

  Widget _buildChatBubble(_ChatMessage message) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        mainAxisAlignment:
            message.isUser ? MainAxisAlignment.end : MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (!message.isUser) ...[
            Container(
              width: 28,
              height: 28,
              decoration: BoxDecoration(
                color: AppColors.accentTranslucent,
                shape: BoxShape.circle,
              ),
              child: const Center(
                child: Text('✨', style: TextStyle(fontSize: 12)),
              ),
            ),
            const SizedBox(width: 8),
          ],
          Flexible(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: message.isUser
                    ? AppColors.accent.withOpacity(0.15)
                    : AppColors.surface.withOpacity(0.6),
                borderRadius: BorderRadius.only(
                  topLeft: const Radius.circular(16),
                  topRight: const Radius.circular(16),
                  bottomLeft:
                      Radius.circular(message.isUser ? 16 : 4),
                  bottomRight:
                      Radius.circular(message.isUser ? 4 : 16),
                ),
                border: Border.all(
                  color: message.isUser
                      ? AppColors.accentBorder
                      : AppColors.borderLight,
                ),
              ),
              child: Text(
                message.text,
                style: TextStyle(
                  color: message.isUser
                      ? AppColors.textPrimary
                      : AppColors.textSecondary,
                  fontSize: 14,
                  height: 1.5,
                ),
              ),
            ),
          ),
          if (message.isUser) const SizedBox(width: 36),
        ],
      ),
    );
  }

  Widget _buildTypingIndicator() {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 28,
            height: 28,
            decoration: BoxDecoration(
              color: AppColors.accentTranslucent,
              shape: BoxShape.circle,
            ),
            child: const Center(
              child: Text('✨', style: TextStyle(fontSize: 12)),
            ),
          ),
          const SizedBox(width: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: AppColors.surface.withOpacity(0.6),
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(16),
                topRight: Radius.circular(16),
                bottomLeft: Radius.circular(4),
                bottomRight: Radius.circular(16),
              ),
              border: Border.all(color: AppColors.borderLight),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: List.generate(3, (i) {
                return Padding(
                  padding: EdgeInsets.only(left: i > 0 ? 4 : 0),
                  child: _TypingDot(delay: i * 200),
                );
              }),
            ),
          ),
        ],
      ),
    );
  }
}

class _ChatMessage {
  final String text;
  final bool isUser;

  _ChatMessage({required this.text, required this.isUser});
}

class _TypingDot extends StatefulWidget {
  final int delay;

  const _TypingDot({required this.delay});

  @override
  State<_TypingDot> createState() => _TypingDotState();
}

class _TypingDotState extends State<_TypingDot>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
    _animation = Tween<double>(begin: 0.3, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
    Future.delayed(Duration(milliseconds: widget.delay), () {
      if (mounted) _controller.repeat(reverse: true);
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: _animation,
      child: Container(
        width: 6,
        height: 6,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: AppColors.textMuted,
        ),
      ),
    );
  }
}
