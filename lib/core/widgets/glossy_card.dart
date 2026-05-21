import 'package:flutter/material.dart';

/// Glossy Card Widget with gradient background
/// Provides consistent glossy gradient styling across all cards
class GlossyCard extends StatelessWidget {
  final Widget child;
  final EdgeInsets? padding;
  final double borderRadius;

  const GlossyCard({
    super.key,
    required this.child,
    this.padding,
    this.borderRadius = 16,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      padding: padding ?? const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: isDark
              ? [
                  const Color(0xFF1A3A34),
                  const Color(0xFF0D524A),
                  const Color(0xFF0A3D36),
                ]
              : [
                  const Color(0xFF0D6B5E),
                  const Color(0xFF14A085),
                  const Color(0xFF0D6B5E),
                ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          stops: const [0.0, 0.5, 1.0],
        ),
        borderRadius: BorderRadius.circular(borderRadius),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF0D6B5E).withValues(alpha: 0.3),
            blurRadius: 16,
            offset: const Offset(0, 8),
          ),
          BoxShadow(
            color: Colors.white.withValues(alpha: 0.1),
            blurRadius: 1,
            offset: const Offset(0, -1),
          ),
        ],
      ),
      child: Stack(
        children: [
          // Glossy overlay at top
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            height: 50,
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.vertical(
                  top: Radius.circular(borderRadius),
                ),
                gradient: LinearGradient(
                  colors: [
                    Colors.white.withValues(alpha: 0.12),
                    Colors.white.withValues(alpha: 0.04),
                    Colors.transparent,
                  ],
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                ),
              ),
            ),
          ),
          // Content
          child,
        ],
      ),
    );
  }
}

/// Extension to provide glossy text styles
extension GlossyTextStyles on BuildContext {
  TextStyle? get glossyTitle => Theme.of(this).textTheme.titleMedium?.copyWith(
        fontWeight: FontWeight.bold,
        color: Colors.white,
      );

  TextStyle? get glossySubtitle =>
      Theme.of(this).textTheme.bodyMedium?.copyWith(
            color: Colors.white.withValues(alpha: 0.8),
          );

  TextStyle? get glossyLabel => Theme.of(this).textTheme.labelSmall?.copyWith(
        color: Colors.white.withValues(alpha: 0.7),
        fontWeight: FontWeight.w600,
      );

  TextStyle? get glossyAmount => Theme.of(this).textTheme.titleLarge?.copyWith(
        fontWeight: FontWeight.bold,
        color: Colors.white,
      );
}
