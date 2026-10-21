import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../models/review_intervals.dart';
import '../../state/planner_state.dart';
import '../utils/adaptive_dialogs.dart';
import '../widgets/apple_card.dart';
import 'welcome_screen.dart';

class SettingsSheet extends StatefulWidget {
  const SettingsSheet({super.key});

  static Future<void> show(BuildContext context) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => const SettingsSheet(),
    );
  }

  @override
  State<SettingsSheet> createState() => _SettingsSheetState();
}

class _SettingsSheetState extends State<SettingsSheet> {
  bool _isExporting = false;
  bool _isImporting = false;

  void _handleExport() async {
    final s = context.read<PlannerState>().strings;
    setState(() => _isExporting = true);
    final box = context.findRenderObject() as RenderBox?;
    final origin = box != null
        ? box.localToGlobal(Offset.zero) & box.size
        : null;

    try {
      await context
          .read<PlannerState>()
          .exportBackup(sharePositionOrigin: origin);
    } catch (e) {
      if (mounted) {
        AdaptiveDialogs.showAlertDialog(
          context: context,
          title: s.errorExportTitle,
          content: s.errorExportMsg(e),
          okLabel: s.gotIt,
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isExporting = false);
      }
    }
  }

  void _handleImport() async {
    final s = context.read<PlannerState>().strings;
    setState(() => _isImporting = true);

    try {
      final success = await context.read<PlannerState>().importBackup();
      if (!mounted) return;

      if (success) {
        Navigator.of(context).pop();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(s.importSuccess),
            backgroundColor: const Color(0xFF588157),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        AdaptiveDialogs.showAlertDialog(
          context: context,
          title: s.errorImportTitle,
          content: s.errorImportMsg(e),
          okLabel: s.gotIt,
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isImporting = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final state = context.watch<PlannerState>();
    final s = state.strings;
    final isApple = AdaptiveDialogs.isApple(context);
    final currentStyle = state.appStyle;
    final currentThemeMode = state.themeMode;
    final currentLanguage = state.language;

    return Container(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 36),
      decoration: BoxDecoration(
        color: isDark
            ? (isApple ? const Color(0xFF1B1D25) : const Color(0xFF1E1A22))
            : Colors.white,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
        border: Border(
          top: BorderSide(
            color: isDark
                ? Colors.white.withValues(alpha: 0.1)
                : Colors.black.withValues(alpha: 0.08),
            width: 1,
          ),
        ),
      ),
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            // Drag handle
            Center(
              child: Container(
                width: 36,
                height: 5,
                decoration: BoxDecoration(
                  color: isDark ? Colors.white24 : Colors.black12,
                  borderRadius: BorderRadius.circular(2.5),
                ),
              ),
            ),

            const SizedBox(height: 18),

            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  s.settingsAndData,
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.w700,
                    letterSpacing: -0.4,
                    color: isDark ? Colors.white : const Color(0xFF1C1C1E),
                  ),
                ),
                if (isApple)
                  CupertinoButton(
                    padding: EdgeInsets.zero,
                    minimumSize: const Size(32, 32),
                    child: Icon(
                      CupertinoIcons.xmark_circle_fill,
                      size: 26,
                      color: isDark ? Colors.white30 : Colors.black26,
                    ),
                    onPressed: () => Navigator.of(context).pop(),
                  )
                else
                  IconButton(
                    icon: const Icon(Icons.close),
                    visualDensity: VisualDensity.compact,
                    onPressed: () => Navigator.of(context).pop(),
                  ),
              ],
            ),

            const SizedBox(height: 20),

            // Style & Theme Customization Section
            Text(
              s.appearanceAndStyle,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                letterSpacing: 0.8,
                color: isDark ? Colors.white38 : Colors.black45,
              ),
            ),
            const SizedBox(height: 10),

            AppleCard(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Language Switcher
                  Text(
                    s.languageSection,
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      color: isDark ? Colors.white : const Color(0xFF1C1C1E),
                    ),
                  ),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      Expanded(
                        child: _LanguageChoiceTile(
                          code: 'en',
                          title: s.englishLang,
                          subtitle: 'Default',
                          flag: '🇺🇸',
                          isSelected: currentLanguage == 'en',
                          onTap: () => state.setLanguage('en'),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: _LanguageChoiceTile(
                          code: 'ru',
                          title: s.russianLang,
                          subtitle: 'Русский',
                          flag: '🇷🇺',
                          isSelected: currentLanguage == 'ru',
                          onTap: () => state.setLanguage('ru'),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 16),
                  Divider(
                    height: 1,
                    color: isDark ? Colors.white12 : Colors.black12,
                  ),
                  const SizedBox(height: 14),

                  // Visual Design
                  Text(
                    s.visualDesign,
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      color: isDark ? Colors.white : const Color(0xFF1C1C1E),
                    ),
                  ),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      Expanded(
                        child: _ThemeChoiceTile(
                          title: s.appleJournalStyle,
                          subtitle: s.appleJournalSubtitle,
                          icon: isApple
                              ? CupertinoIcons.square_pencil
                              : Icons.auto_stories,
                          isSelected: currentStyle == 'appleJournal',
                          onTap: () => state.setAppStyle('appleJournal'),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: _ThemeChoiceTile(
                          title: s.material3Style,
                          subtitle: s.material3Subtitle,
                          icon: Icons.palette_outlined,
                          isSelected: currentStyle == 'material3',
                          onTap: () => state.setAppStyle('material3'),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Divider(
                    height: 1,
                    color: isDark ? Colors.white12 : Colors.black12,
                  ),
                  const SizedBox(height: 14),

                  // Color Scheme
                  Text(
                    s.colorScheme,
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      color: isDark ? Colors.white : const Color(0xFF1C1C1E),
                    ),
                  ),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      Expanded(
                        child: _ModeChip(
                          label: s.systemMode,
                          icon: Icons.brightness_auto,
                          isSelected: currentThemeMode == 'system',
                          onTap: () => state.setThemeMode('system'),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: _ModeChip(
                          label: s.lightMode,
                          icon: Icons.light_mode_outlined,
                          isSelected: currentThemeMode == 'light',
                          onTap: () => state.setThemeMode('light'),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: _ModeChip(
                          label: s.darkMode,
                          icon: Icons.dark_mode_outlined,
                          isSelected: currentThemeMode == 'dark',
                          onTap: () => state.setThemeMode('dark'),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // Sleep Schedule & Quiet Hours Section
            Text(
              s.sleepScheduleSection,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                letterSpacing: 0.8,
                color: isDark ? Colors.white38 : Colors.black45,
              ),
            ),
            const SizedBox(height: 10),

            AppleCard(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Main Toggle
                  Row(
                    children: [
                      Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          color: const Color(0xFFB8A9F8).withValues(
                            alpha: isDark ? 0.22 : 0.15,
                          ),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Icon(
                          isApple ? CupertinoIcons.moon_stars_fill : Icons.bedtime,
                          color: const Color(0xFFB8A9F8),
                          size: 20,
                        ),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              s.sleepScheduleTitle,
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                                color: isDark ? Colors.white : const Color(0xFF1C1C1E),
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              s.sleepScheduleSubtitle,
                              style: TextStyle(
                                fontSize: 13,
                                color: isDark ? Colors.white54 : Colors.black54,
                              ),
                            ),
                          ],
                        ),
                      ),
                      if (isApple)
                        CupertinoSwitch(
                          value: state.sleepSchedule.isEnabled,
                          activeTrackColor: const Color(0xFFB8A9F8),
                          onChanged: (val) {
                            state.updateSleepSchedule(isEnabled: val);
                          },
                        )
                      else
                        Switch(
                          value: state.sleepSchedule.isEnabled,
                          activeThumbColor: const Color(0xFFB8A9F8),
                          onChanged: (val) {
                            state.updateSleepSchedule(isEnabled: val);
                          },
                        ),
                    ],
                  ),

                  if (state.sleepSchedule.isEnabled) ...[
                    const SizedBox(height: 16),
                    Divider(
                      height: 1,
                      color: isDark ? Colors.white12 : Colors.black12,
                    ),
                    const SizedBox(height: 12),

                    // Bedtime tile
                    _TimePickerRow(
                      icon: isApple ? CupertinoIcons.moon_fill : Icons.nightlight_round,
                      iconColor: const Color(0xFFD0A2E2),
                      title: s.bedtimeTitle,
                      subtitle: s.bedtimeSubtitle,
                      timeFormatted: state.sleepSchedule.startTimeFormatted,
                      onTap: () async {
                        final picked = await AdaptiveDialogs.showAdaptiveTimePicker(
                          context: context,
                          initialTime: TimeOfDay(
                            hour: state.sleepSchedule.startHour,
                            minute: state.sleepSchedule.startMinute,
                          ),
                          title: s.selectBedtime,
                          confirmLabel: s.save,
                          cancelLabel: s.cancel,
                        );
                        if (picked != null) {
                          state.updateSleepSchedule(
                            startHour: picked.hour,
                            startMinute: picked.minute,
                          );
                        }
                      },
                    ),

                    const SizedBox(height: 10),

                    // Wake-up tile
                    _TimePickerRow(
                      icon: isApple ? CupertinoIcons.sun_max_fill : Icons.wb_sunny_rounded,
                      iconColor: const Color(0xFFF8B182),
                      title: s.wakeUpTitle,
                      subtitle: s.wakeUpSubtitle,
                      timeFormatted: state.sleepSchedule.endTimeFormatted,
                      onTap: () async {
                        final picked = await AdaptiveDialogs.showAdaptiveTimePicker(
                          context: context,
                          initialTime: TimeOfDay(
                            hour: state.sleepSchedule.endHour,
                            minute: state.sleepSchedule.endMinute,
                          ),
                          title: s.selectWakeUp,
                          confirmLabel: s.save,
                          cancelLabel: s.cancel,
                        );
                        if (picked != null) {
                          state.updateSleepSchedule(
                            endHour: picked.hour,
                            endMinute: picked.minute,
                          );
                        }
                      },
                    ),

                    const SizedBox(height: 14),
                    Text(
                      s.sleepScheduleDesc,
                      style: TextStyle(
                        fontSize: 12,
                        color: isDark ? Colors.white38 : Colors.black45,
                        height: 1.35,
                      ),
                    ),
                  ],
                ],
              ),
            ),

            const SizedBox(height: 24),

            // Backup & Export Section
            Text(
              s.backupSection,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                letterSpacing: 0.8,
                color: isDark ? Colors.white38 : Colors.black45,
              ),
            ),
            const SizedBox(height: 10),

            AppleCard(
              padding: EdgeInsets.zero,
              child: Column(
                children: [
                  _SettingsActionTile(
                    icon: isApple ? CupertinoIcons.share : Icons.share,
                    iconColor: const Color(0xFF85CDFD),
                    title: s.exportBackup,
                    subtitle: s.exportBackupSubtitle,
                    isLoading: _isExporting,
                    onTap: _isExporting || _isImporting ? null : _handleExport,
                  ),
                  Divider(
                    height: 1,
                    indent: 56,
                    color: isDark ? Colors.white12 : Colors.black12,
                  ),
                  _SettingsActionTile(
                    icon: isApple
                        ? CupertinoIcons.arrow_down_doc
                        : Icons.file_download,
                    iconColor: const Color(0xFF8EC89A),
                    title: s.importBackup,
                    subtitle: s.importBackupSubtitle,
                    isLoading: _isImporting,
                    onTap: _isExporting || _isImporting ? null : _handleImport,
                  ),
                  Divider(
                    height: 1,
                    indent: 56,
                    color: isDark ? Colors.white12 : Colors.black12,
                  ),
                  _SettingsActionTile(
                    icon: isApple ? CupertinoIcons.book_fill : Icons.menu_book,
                    iconColor: const Color(0xFFB8A9F8),
                    title: s.welcomeGuideAction,
                    subtitle: s.welcomeSubtitle,
                    isLoading: false,
                    onTap: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (_) => const WelcomeScreen(isFromSettings: true),
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // Ebbinghaus Forgetting Curve Reference
            Text(
              s.intervalsSection,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                letterSpacing: 0.8,
                color: isDark ? Colors.white38 : Colors.black45,
              ),
            ),
            const SizedBox(height: 10),

            AppleCard(
              padding: const EdgeInsets.all(18),
              child: Column(
                children: List.generate(ReviewIntervals.totalSteps, (index) {
                  return Padding(
                    padding: EdgeInsets.only(
                      bottom: index == ReviewIntervals.totalSteps - 1 ? 0 : 12,
                    ),
                    child: Row(
                      children: [
                        Container(
                          width: 28,
                          height: 28,
                          decoration: BoxDecoration(
                            color:
                                const Color(0xFFB8A9F8).withValues(alpha: 0.2),
                            shape: BoxShape.circle,
                          ),
                          alignment: Alignment.center,
                          child: Text(
                            '${index + 1}',
                            style: const TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w700,
                              color: Color(0xFFB8A9F8),
                            ),
                          ),
                        ),
                        const SizedBox(width: 14),
                        Expanded(
                          child: Text(
                            s.stepLabel(index, ReviewIntervals.totalSteps),
                            style: TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w600,
                              color: isDark ? Colors.white : Colors.black87,
                            ),
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(
                            color: isDark
                                ? Colors.white.withValues(alpha: 0.08)
                                : Colors.black.withValues(alpha: 0.05),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            '+ ${s.intervalDescription(index)}',
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w700,
                              color: isDark ? Colors.white70 : Colors.black87,
                            ),
                          ),
                        ),
                      ],
                    ),
                  );
                }),
              ),
            ),

            const SizedBox(height: 20),

            Center(
              child: Text(
                '${s.versionInfo} • Multi-language & Adaptive Native',
                style: TextStyle(
                  fontSize: 12,
                  color: isDark ? Colors.white30 : Colors.black38,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _LanguageChoiceTile extends StatelessWidget {
  final String code;
  final String title;
  final String subtitle;
  final String flag;
  final bool isSelected;
  final VoidCallback onTap;

  const _LanguageChoiceTile({
    required this.code,
    required this.title,
    required this.subtitle,
    required this.flag,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final primary = Theme.of(context).colorScheme.primary;

    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: isSelected
              ? primary.withValues(alpha: isDark ? 0.25 : 0.12)
              : (isDark
                  ? Colors.white.withValues(alpha: 0.05)
                  : Colors.black.withValues(alpha: 0.04)),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: isSelected ? primary : Colors.transparent,
            width: 1.5,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(flag, style: const TextStyle(fontSize: 20)),
                if (isSelected)
                  Icon(
                    Icons.check_circle,
                    size: 16,
                    color: primary,
                  ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              title,
              style: TextStyle(
                fontSize: 14,
                fontWeight: isSelected ? FontWeight.w700 : FontWeight.w600,
                color: isDark ? Colors.white : Colors.black87,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              subtitle,
              style: TextStyle(
                fontSize: 11,
                color: isDark ? Colors.white54 : Colors.black54,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ThemeChoiceTile extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData icon;
  final bool isSelected;
  final VoidCallback onTap;

  const _ThemeChoiceTile({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final primary = Theme.of(context).colorScheme.primary;

    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: isSelected
              ? primary.withValues(alpha: isDark ? 0.25 : 0.12)
              : (isDark
                  ? Colors.white.withValues(alpha: 0.05)
                  : Colors.black.withValues(alpha: 0.04)),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: isSelected ? primary : Colors.transparent,
            width: 1.5,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Icon(
                  icon,
                  size: 20,
                  color: isSelected ? primary : (isDark ? Colors.white70 : Colors.black54),
                ),
                if (isSelected)
                  Icon(
                    Icons.check_circle,
                    size: 16,
                    color: primary,
                  ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              title,
              style: TextStyle(
                fontSize: 14,
                fontWeight: isSelected ? FontWeight.w700 : FontWeight.w600,
                color: isDark ? Colors.white : Colors.black87,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              subtitle,
              style: TextStyle(
                fontSize: 11,
                color: isDark ? Colors.white54 : Colors.black54,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ModeChip extends StatelessWidget {
  final String label;
  final IconData icon;
  final bool isSelected;
  final VoidCallback onTap;

  const _ModeChip({
    required this.label,
    required this.icon,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final primary = Theme.of(context).colorScheme.primary;

    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        padding: const EdgeInsets.symmetric(vertical: 8),
        decoration: BoxDecoration(
          color: isSelected
              ? primary.withValues(alpha: isDark ? 0.25 : 0.12)
              : (isDark
                  ? Colors.white.withValues(alpha: 0.05)
                  : Colors.black.withValues(alpha: 0.04)),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: isSelected ? primary : Colors.transparent,
            width: 1.2,
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: 18,
              color: isSelected
                  ? primary
                  : (isDark ? Colors.white70 : Colors.black54),
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                fontSize: 11,
                fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                color: isDark ? Colors.white : Colors.black87,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SettingsActionTile extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final String title;
  final String subtitle;
  final bool isLoading;
  final VoidCallback? onTap;

  const _SettingsActionTile({
    required this.icon,
    required this.iconColor,
    required this.title,
    required this.subtitle,
    required this.isLoading,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final isApple = AdaptiveDialogs.isApple(context);

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          child: Row(
            children: [
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: iconColor.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(icon, size: 20, color: iconColor),
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
                        fontWeight: FontWeight.w600,
                        color: isDark ? Colors.white : const Color(0xFF1C1C1E),
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      subtitle,
                      style: TextStyle(
                        fontSize: 12,
                        color: isDark ? Colors.white38 : Colors.black45,
                      ),
                    ),
                  ],
                ),
              ),
              if (isLoading)
                (isApple
                    ? const CupertinoActivityIndicator()
                    : const SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      ))
              else
                Icon(
                  isApple
                      ? CupertinoIcons.chevron_forward
                      : Icons.arrow_forward_ios,
                  size: 16,
                  color: isDark ? Colors.white30 : Colors.black26,
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class _TimePickerRow extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final String title;
  final String subtitle;
  final String timeFormatted;
  final VoidCallback onTap;

  const _TimePickerRow({
    required this.icon,
    required this.iconColor,
    required this.title,
    required this.subtitle,
    required this.timeFormatted,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final isApple = AdaptiveDialogs.isApple(context);

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(14),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 8),
          child: Row(
            children: [
              Container(
                width: 34,
                height: 34,
                decoration: BoxDecoration(
                  color: iconColor.withValues(alpha: isDark ? 0.22 : 0.15),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(icon, color: iconColor, size: 18),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                        color: isDark ? Colors.white : const Color(0xFF1C1C1E),
                      ),
                    ),
                    const SizedBox(height: 1),
                    Text(
                      subtitle,
                      style: TextStyle(
                        fontSize: 12,
                        color: isDark ? Colors.white54 : Colors.black54,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: isDark
                      ? Colors.white.withValues(alpha: 0.08)
                      : Colors.black.withValues(alpha: 0.05),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(
                    color: isDark
                        ? Colors.white.withValues(alpha: 0.12)
                        : Colors.black.withValues(alpha: 0.08),
                    width: 0.8,
                  ),
                ),
                child: Text(
                  timeFormatted,
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 0.2,
                    color: isDark ? Colors.white : const Color(0xFF1C1C1E),
                  ),
                ),
              ),
              const SizedBox(width: 4),
              Icon(
                isApple ? CupertinoIcons.chevron_forward : Icons.chevron_right,
                size: 16,
                color: isDark ? Colors.white30 : Colors.black26,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
