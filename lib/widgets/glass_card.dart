import 'package:flutter/material.dart';

class GlassCard extends StatelessWidget {
  final Widget child;
  final Color? color;
  final Gradient? gradient;
  final Color borderColor;
  final EdgeInsetsGeometry padding;
  final EdgeInsetsGeometry margin;
  final double borderRadius;

  const GlassCard({
    super.key,
    required this.child,
    this.color,
    this.gradient,
    this.borderColor = const Color(0x268B7E74),
    this.padding = const EdgeInsets.all(16),
    this.margin = EdgeInsets.zero,
    this.borderRadius = 20,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: margin,
      padding: padding,
      decoration: BoxDecoration(
        color: gradient == null ? (color ?? const Color(0x662C2621)) : null,
        gradient: gradient,
        borderRadius: BorderRadius.circular(borderRadius),
        border: Border.all(color: borderColor, width: 1),
      ),
      child: child,
    );
  }
}
