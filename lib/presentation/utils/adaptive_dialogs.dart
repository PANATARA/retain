import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class AdaptiveDialogs {
  AdaptiveDialogs._();

  static bool isApple(BuildContext context) {
    return Theme.of(context).platform == TargetPlatform.iOS;
  }

  /// Shows an adaptive text input dialog (Cupertino on iOS, Material 3 on Android).
  static Future<String?> showInputDialog({
    required BuildContext context,
    required String title,
    String? placeholder,
    String? initialValue,
    String confirmLabel = 'Сохранить',
    String cancelLabel = 'Отмена',
  }) async {
    final controller = TextEditingController(text: initialValue ?? '');

    if (isApple(context)) {
      return showCupertinoDialog<String>(
        context: context,
        builder: (ctx) => CupertinoAlertDialog(
          title: Text(title),
          content: Padding(
            padding: const EdgeInsets.only(top: 14),
            child: CupertinoTextField(
              controller: controller,
              autofocus: true,
              placeholder: placeholder,
            ),
          ),
          actions: [
            CupertinoDialogAction(
              child: Text(cancelLabel),
              onPressed: () => Navigator.of(ctx).pop(null),
            ),
            CupertinoDialogAction(
              isDefaultAction: true,
              child: Text(confirmLabel),
              onPressed: () => Navigator.of(ctx).pop(controller.text.trim()),
            ),
          ],
        ),
      );
    } else {
      // Material 3 Dialog
      return showDialog<String>(
        context: context,
        builder: (ctx) => AlertDialog(
          title: Text(title),
          content: TextField(
            controller: controller,
            autofocus: true,
            decoration: InputDecoration(
              hintText: placeholder,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(14),
              ),
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 14,
              ),
            ),
          ),
          actions: [
            TextButton(
              child: Text(cancelLabel),
              onPressed: () => Navigator.of(ctx).pop(null),
            ),
            FilledButton(
              child: Text(confirmLabel),
              onPressed: () => Navigator.of(ctx).pop(controller.text.trim()),
            ),
          ],
        ),
      );
    }
  }

  /// Shows an adaptive confirmation/destructive dialog.
  static Future<bool> showConfirmDialog({
    required BuildContext context,
    required String title,
    required String content,
    String confirmLabel = 'Удалить',
    String cancelLabel = 'Отмена',
    bool isDestructive = false,
  }) async {
    if (isApple(context)) {
      final result = await showCupertinoDialog<bool>(
        context: context,
        builder: (ctx) => CupertinoAlertDialog(
          title: Text(title),
          content: Padding(
            padding: const EdgeInsets.only(top: 8.0),
            child: Text(content),
          ),
          actions: [
            CupertinoDialogAction(
              child: Text(cancelLabel),
              onPressed: () => Navigator.of(ctx).pop(false),
            ),
            CupertinoDialogAction(
              isDestructiveAction: isDestructive,
              child: Text(confirmLabel),
              onPressed: () => Navigator.of(ctx).pop(true),
            ),
          ],
        ),
      );
      return result ?? false;
    } else {
      final result = await showDialog<bool>(
        context: context,
        builder: (ctx) {
          final theme = Theme.of(ctx);
          return AlertDialog(
            title: Text(title),
            content: Text(content),
            actions: [
              TextButton(
                child: Text(cancelLabel),
                onPressed: () => Navigator.of(ctx).pop(false),
              ),
              FilledButton(
                style: isDestructive
                    ? FilledButton.styleFrom(
                        backgroundColor: theme.colorScheme.error,
                        foregroundColor: theme.colorScheme.onError,
                      )
                    : null,
                child: Text(confirmLabel),
                onPressed: () => Navigator.of(ctx).pop(true),
              ),
            ],
          );
        },
      );
      return result ?? false;
    }
  }

  /// Shows an adaptive alert / information dialog.
  static Future<void> showAlertDialog({
    required BuildContext context,
    required String title,
    required String content,
    String okLabel = 'Понятно',
  }) async {
    if (isApple(context)) {
      return showCupertinoDialog<void>(
        context: context,
        builder: (ctx) => CupertinoAlertDialog(
          title: Text(title),
          content: Padding(
            padding: const EdgeInsets.only(top: 8.0),
            child: Text(content),
          ),
          actions: [
            CupertinoDialogAction(
              child: Text(okLabel),
              onPressed: () => Navigator.of(ctx).pop(),
            ),
          ],
        ),
      );
    } else {
      return showDialog<void>(
        context: context,
        builder: (ctx) => AlertDialog(
          title: Text(title),
          content: Text(content),
          actions: [
            FilledButton(
              child: Text(okLabel),
              onPressed: () => Navigator.of(ctx).pop(),
            ),
          ],
        ),
      );
    }
  }

  /// Shows an adaptive time picker (Cupertino sheet on iOS, Material 3 dialog on Android).
  static Future<TimeOfDay?> showAdaptiveTimePicker({
    required BuildContext context,
    required TimeOfDay initialTime,
    String title = 'Время',
    String confirmLabel = 'Готово',
    String cancelLabel = 'Отмена',
  }) async {
    if (isApple(context)) {
      TimeOfDay selected = initialTime;
      final isDark = Theme.of(context).brightness == Brightness.dark;

      final result = await showCupertinoModalPopup<TimeOfDay>(
        context: context,
        builder: (ctx) {
          return Container(
            height: 290,
            decoration: BoxDecoration(
              color: isDark ? const Color(0xFF1E2029) : Colors.white,
              borderRadius:
                  const BorderRadius.vertical(top: Radius.circular(22)),
            ),
            child: SafeArea(
              top: false,
              child: Column(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 10),
                    decoration: BoxDecoration(
                      border: Border(
                        bottom: BorderSide(
                          color: isDark ? Colors.white12 : Colors.black12,
                          width: 0.5,
                        ),
                      ),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        CupertinoButton(
                          padding: EdgeInsets.zero,
                          child: Text(cancelLabel,
                              style: const TextStyle(fontSize: 16)),
                          onPressed: () => Navigator.of(ctx).pop(null),
                        ),
                        Text(
                          title,
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: isDark ? Colors.white : Colors.black87,
                            decoration: TextDecoration.none,
                          ),
                        ),
                        CupertinoButton(
                          padding: EdgeInsets.zero,
                          child: Text(
                            confirmLabel,
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          onPressed: () => Navigator.of(ctx).pop(selected),
                        ),
                      ],
                    ),
                  ),
                  Expanded(
                    child: CupertinoDatePicker(
                      mode: CupertinoDatePickerMode.time,
                      use24hFormat:
                          MediaQuery.of(context).alwaysUse24HourFormat,
                      initialDateTime: DateTime(
                        2026,
                        1,
                        1,
                        initialTime.hour,
                        initialTime.minute,
                      ),
                      onDateTimeChanged: (DateTime newDateTime) {
                        selected = TimeOfDay(
                          hour: newDateTime.hour,
                          minute: newDateTime.minute,
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      );
      return result;
    } else {
      return showTimePicker(
        context: context,
        initialTime: initialTime,
      );
    }
  }
}
