import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../models/app_data.dart';
import '../../state/planner_state.dart';
import '../../theme/app_theme.dart';

class AppleCard extends StatelessWidget {
  final Widget child;
  final Color? accentColor;
  final VoidCallback? onTap;
  final EdgeInsetsGeometry? padding;
  final double? width;
  final double? height;

  const AppleCard({
    super.key,
    required this.child,
    this.accentColor,
    this.onTap,
    this.padding = const EdgeInsets.all(20),
    this.width,
    this.height,
  });

  @override
  Widget build(BuildContext context) {
    AppVisualTheme? visualTheme;
    try {
      visualTheme = context.select<PlannerState, AppVisualTheme>((s) => s.visualTheme);
    } catch (_) {
      // In isolated tests or outside Provider
    }

    final bg = AppTheme.cardBackground(
      context,
      accentColor: accentColor,
      visualTheme: visualTheme,
    );
    final border = AppTheme.cardBorder(
      context,
      accentColor: accentColor,
      visualTheme: visualTheme,
    );
    final shadow = AppTheme.cardShadow(
      context,
      visualTheme: visualTheme,
    );
    final radius = AppTheme.cardRadius(visualTheme: visualTheme);

    Widget content = Container(
      width: width,
      height: height,
      padding: padding,
      decoration: BoxDecoration(
        color: bg,
        borderRadius: radius,
        border: border,
        boxShadow: shadow,
      ),
      child: child,
    );

    if (onTap != null) {
      return Material(
        color: Colors.transparent,
        borderRadius: radius,
        child: InkWell(
          onTap: onTap,
          borderRadius: radius,
          splashColor: (accentColor ?? Colors.grey).withValues(alpha: 0.12),
          highlightColor: (accentColor ?? Colors.grey).withValues(alpha: 0.06),
          child: content,
        ),
      );
    }

    return content;
  }
}
