import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../state/planner_state.dart';
import '../utils/adaptive_dialogs.dart';
import '../widgets/apple_card.dart';

class WelcomeScreen extends StatelessWidget {
  final bool isFromSettings;

  const WelcomeScreen({super.key, this.isFromSettings = false});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final state = context.watch<PlannerState>();
    final s = state.strings;
    final isApple = AdaptiveDialogs.isApple(context);

    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (isFromSettings)
                Align(
                  alignment: Alignment.topRight,
                  child: isApple
                      ? CupertinoButton(
                          padding: EdgeInsets.zero,
                          minimumSize: const Size(32, 32),
                          child: Icon(
                            CupertinoIcons.xmark_circle_fill,
                            size: 28,
                            color: isDark ? Colors.white38 : Colors.black26,
                          ),
                          onPressed: () => Navigator.of(context).pop(),
                        )
                      : IconButton(
                          icon: const Icon(Icons.close),
                          onPressed: () => Navigator.of(context).pop(),
                        ),
                ),

              Expanded(
                child: SingleChildScrollView(
                  physics: const BouncingScrollPhysics(),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 12),

                      // App Logo / Symbol Banner
                      Center(
                        child: Container(
                          width: 80,
                          height: 80,
                          decoration: BoxDecoration(
                            gradient: const LinearGradient(
                              colors: [Color(0xFFB8A9F8), Color(0xFF85CDFD)],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ),
                            borderRadius: BorderRadius.circular(24),
                            boxShadow: [
                              BoxShadow(
                                color: const Color(0xFFB8A9F8).withValues(alpha: 0.35),
                                blurRadius: 20,
                                offset: const Offset(0, 8),
                              ),
                            ],
                          ),
                          child: Icon(
                            isApple ? CupertinoIcons.sparkles : Icons.auto_awesome,
                            size: 42,
                            color: Colors.white,
                          ),
                        ),
                      ),

                      const SizedBox(height: 24),

                      // Welcome Title & Subtitle
                      Center(
                        child: Text(
                          s.welcomeTitle,
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 26,
                            fontWeight: FontWeight.w800,
                            letterSpacing: -0.6,
                            color: isDark ? Colors.white : const Color(0xFF1C1C1E),
                          ),
                        ),
                      ),
                      const SizedBox(height: 8),
                      Center(
                        child: Text(
                          s.welcomeSubtitle,
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 14,
                            color: isDark ? Colors.white54 : Colors.black54,
                            height: 1.3,
                          ),
                        ),
                      ),

                      const SizedBox(height: 32),

                      // Feature 1: Spaced Repetition
                      _FeatureItem(
                        icon: isApple
                            ? CupertinoIcons.arrow_counterclockwise_circle_fill
                            : Icons.repeat_rounded,
                        accentColor: const Color(0xFFB8A9F8), // Lavender
                        title: s.onbFeature1Title,
                        description: s.onbFeature1Desc,
                      ),

                      const SizedBox(height: 16),

                      // Feature 2: Smart Notifications
                      _FeatureItem(
                        icon: isApple ? CupertinoIcons.bell_fill : Icons.notifications_active,
                        accentColor: const Color(0xFF8EC89A), // Sage
                        title: s.onbFeature2Title,
                        description: s.onbFeature2Desc,
                      ),

                      const SizedBox(height: 16),

                      // Feature 3: Categories & 100% Privacy
                      _FeatureItem(
                        icon: isApple ? CupertinoIcons.lock_shield_fill : Icons.shield_outlined,
                        accentColor: const Color(0xFF85CDFD), // Sky Blue
                        title: s.onbFeature3Title,
                        description: s.onbFeature3Desc,
                      ),

                      const SizedBox(height: 24),
                    ],
                  ),
                ),
              ),

              // Action button
              SizedBox(
                width: double.infinity,
                child: isApple
                    ? CupertinoButton.filled(
                        padding: const EdgeInsets.symmetric(vertical: 15),
                        borderRadius: BorderRadius.circular(18),
                        onPressed: () {
                          if (isFromSettings) {
                            Navigator.of(context).pop();
                          } else {
                            state.completeOnboarding();
                          }
                        },
                        child: Text(
                          s.getStartedBtn,
                          style: const TextStyle(
                            fontSize: 17,
                            fontWeight: FontWeight.w700,
                            letterSpacing: -0.2,
                          ),
                        ),
                      )
                    : FilledButton(
                        style: FilledButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 15),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(18),
                          ),
                        ),
                        onPressed: () {
                          if (isFromSettings) {
                            Navigator.of(context).pop();
                          } else {
                            state.completeOnboarding();
                          }
                        },
                        child: Text(
                          s.getStartedBtn,
                          style: const TextStyle(
                            fontSize: 17,
                            fontWeight: FontWeight.w700,
                            letterSpacing: -0.2,
                          ),
                        ),
                      ),
              ),
              const SizedBox(height: 12),
            ],
          ),
        ),
      ),
    );
  }
}

class _FeatureItem extends StatelessWidget {
  final IconData icon;
  final Color accentColor;
  final String title;
  final String description;

  const _FeatureItem({
    required this.icon,
    required this.accentColor,
    required this.title,
    required this.description,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return AppleCard(
      accentColor: accentColor,
      padding: const EdgeInsets.all(16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: accentColor.withValues(alpha: isDark ? 0.25 : 0.2),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, size: 24, color: accentColor),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                    letterSpacing: -0.2,
                    color: isDark ? Colors.white : const Color(0xFF1C1C1E),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  description,
                  style: TextStyle(
                    fontSize: 12.5,
                    color: isDark ? Colors.white60 : Colors.black54,
                    height: 1.35,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
