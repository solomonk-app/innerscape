import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../services/tooltip_service.dart';

class FeatureTooltip {
  static OverlayEntry? _currentEntry;

  static Future<void> show({
    required BuildContext context,
    required String message,
    required String featureKey,
    required GlobalKey targetKey,
  }) async {
    final seen = await TooltipService().hasSeenTooltip(featureKey);
    if (seen) return;

    await TooltipService().markTooltipSeen(featureKey);

    if (!context.mounted) return;

    _currentEntry?.remove();

    final overlay = Overlay.of(context);
    final renderBox = targetKey.currentContext?.findRenderObject() as RenderBox?;
    if (renderBox == null) return;

    final targetPosition = renderBox.localToGlobal(Offset.zero);
    final targetSize = renderBox.size;

    late OverlayEntry entry;
    entry = OverlayEntry(
      builder: (ctx) => _TooltipOverlay(
        message: message,
        targetPosition: targetPosition,
        targetSize: targetSize,
        onDismiss: () {
          entry.remove();
          if (_currentEntry == entry) _currentEntry = null;
        },
      ),
    );

    _currentEntry = entry;
    overlay.insert(entry);
  }

  static void dismiss() {
    _currentEntry?.remove();
    _currentEntry = null;
  }
}

class _TooltipOverlay extends StatefulWidget {
  final String message;
  final Offset targetPosition;
  final Size targetSize;
  final VoidCallback onDismiss;

  const _TooltipOverlay({
    required this.message,
    required this.targetPosition,
    required this.targetSize,
    required this.onDismiss,
  });

  @override
  State<_TooltipOverlay> createState() => _TooltipOverlayState();
}

class _TooltipOverlayState extends State<_TooltipOverlay>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
    _fadeAnimation = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOut,
    );
    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _dismiss() {
    _controller.reverse().then((_) => widget.onDismiss());
  }

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;
    final targetCenter = widget.targetPosition.dx + widget.targetSize.width / 2;
    const tooltipWidth = 280.0;

    // Position tooltip below the target
    double left = targetCenter - tooltipWidth / 2;
    if (left < 16) left = 16;
    if (left + tooltipWidth > screenSize.width - 16) {
      left = screenSize.width - tooltipWidth - 16;
    }

    final top = widget.targetPosition.dy + widget.targetSize.height + 12;

    return FadeTransition(
      opacity: _fadeAnimation,
      child: Stack(
        children: [
          // Dismiss on tap outside
          Positioned.fill(
            child: GestureDetector(
              onTap: _dismiss,
              behavior: HitTestBehavior.opaque,
              child: Container(color: Colors.black26),
            ),
          ),
          Positioned(
            left: left,
            top: top,
            child: Material(
              color: Colors.transparent,
              child: Container(
                width: tooltipWidth,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppColors.surface.withOpacity(0.95),
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(
                    color: AppColors.accent.withOpacity(0.3),
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.accent.withOpacity(0.1),
                      blurRadius: 20,
                      spreadRadius: 2,
                    ),
                  ],
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.message,
                      style: const TextStyle(
                        color: AppColors.textSecondary,
                        fontSize: 13,
                        height: 1.5,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Align(
                      alignment: Alignment.centerRight,
                      child: GestureDetector(
                        onTap: _dismiss,
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 14,
                            vertical: 6,
                          ),
                          decoration: BoxDecoration(
                            color: AppColors.accent.withOpacity(0.15),
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(
                              color: AppColors.accentBorder,
                            ),
                          ),
                          child: const Text(
                            'Got it',
                            style: TextStyle(
                              color: AppColors.accent,
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
