import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../models/category.dart';
import '../../state/planner_state.dart';
import '../../theme/app_theme.dart';
import '../utils/adaptive_dialogs.dart';

class AddCategorySheet extends StatefulWidget {
  final Category? existingCategory;

  const AddCategorySheet({super.key, this.existingCategory});

  static Future<void> show(BuildContext context, {Category? existingCategory}) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) =>
          AddCategorySheet(existingCategory: existingCategory),
    );
  }

  @override
  State<AddCategorySheet> createState() => _AddCategorySheetState();
}

class _AddCategorySheetState extends State<AddCategorySheet> {
  late final TextEditingController _titleController;
  late String _selectedColorHex;
  bool _isSubmitting = false;

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(
      text: widget.existingCategory?.title ?? '',
    );
    _selectedColorHex = widget.existingCategory?.colorHex ??
        AppTheme.pastelColorsHex.first;
  }

  @override
  void dispose() {
    _titleController.dispose();
    super.dispose();
  }

  Color _colorFromHex(String hex) {
    final clean = hex.replaceAll('#', '');
    return Color(int.parse('FF$clean', radix: 16));
  }

  void _submit() async {
    final title = _titleController.text.trim();
    if (title.isEmpty) return;

    final state = context.read<PlannerState>();
    setState(() => _isSubmitting = true);

    try {
      if (widget.existingCategory != null) {
        await state.updateCategory(
          id: widget.existingCategory!.id,
          title: title,
          colorHex: _selectedColorHex,
        );
      } else {
        await state.addCategory(
          title: title,
          colorHex: _selectedColorHex,
        );
      }
      if (mounted) {
        Navigator.of(context).pop();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e')),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isSubmitting = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final isEditing = widget.existingCategory != null;
    final isApple = AdaptiveDialogs.isApple(context);
    final s = context.watch<PlannerState>().strings;
    final bottomInset = MediaQuery.of(context).viewInsets.bottom;

    return Container(
      padding: EdgeInsets.fromLTRB(20, 16, 20, 20 + bottomInset),
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
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
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
                  isEditing ? s.editCategorySheetTitle : s.newCategorySheetTitle,
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

            const SizedBox(height: 18),

            // Title input
            Text(
              s.categoryNameLabel,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                letterSpacing: 0.8,
                color: isDark ? Colors.white38 : Colors.black45,
              ),
            ),
            const SizedBox(height: 8),

            if (isApple)
              CupertinoTextField(
                controller: _titleController,
                autofocus: true,
                placeholder: s.categoryNamePlaceholder,
                placeholderStyle: TextStyle(
                  color: isDark ? Colors.white24 : Colors.black26,
                  fontSize: 16,
                ),
                style: TextStyle(
                  color: isDark ? Colors.white : Colors.black,
                  fontSize: 16,
                ),
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                decoration: BoxDecoration(
                  color: isDark
                      ? Colors.white.withValues(alpha: 0.06)
                      : Colors.black.withValues(alpha: 0.04),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: isDark
                        ? Colors.white.withValues(alpha: 0.12)
                        : Colors.black.withValues(alpha: 0.08),
                    width: 1,
                  ),
                ),
                textCapitalization: TextCapitalization.sentences,
                onSubmitted: (_) => _submit(),
              )
            else
              TextField(
                controller: _titleController,
                autofocus: true,
                decoration: InputDecoration(
                  hintText: s.categoryNamePlaceholder,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 14,
                  ),
                ),
                textCapitalization: TextCapitalization.sentences,
                onSubmitted: (_) => _submit(),
              ),

            const SizedBox(height: 20),

            // Pastel color selection
            Text(
              s.pastelColorLabel,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                letterSpacing: 0.8,
                color: isDark ? Colors.white38 : Colors.black45,
              ),
            ),
            const SizedBox(height: 12),

            Wrap(
              spacing: 12,
              runSpacing: 12,
              children: AppTheme.pastelColorsHex.map((hex) {
                final isSelected = hex == _selectedColorHex;
                final color = _colorFromHex(hex);

                return GestureDetector(
                  onTap: () {
                    setState(() {
                      _selectedColorHex = hex;
                    });
                  },
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 150),
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      color: color,
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: isSelected
                            ? (isDark ? Colors.white : Colors.black87)
                            : Colors.transparent,
                        width: isSelected ? 3 : 0,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: color.withValues(alpha: 0.4),
                          blurRadius: isSelected ? 8 : 4,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: isSelected
                        ? Icon(
                            isApple ? CupertinoIcons.checkmark : Icons.check,
                            size: 20,
                            color: isDark ? Colors.black : Colors.white,
                          )
                        : null,
                  ),
                );
              }).toList(),
            ),

            const SizedBox(height: 26),

            // Save button
            SizedBox(
              width: double.infinity,
              child: isApple
                  ? CupertinoButton.filled(
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      borderRadius: BorderRadius.circular(16),
                      onPressed: _isSubmitting ? null : _submit,
                      child: _isSubmitting
                          ? const CupertinoActivityIndicator(color: Colors.white)
                          : Text(
                              isEditing ? s.saveChangesBtn : s.createCategoryBtn,
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                    )
                  : FilledButton(
                      style: FilledButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                      ),
                      onPressed: _isSubmitting ? null : _submit,
                      child: _isSubmitting
                          ? const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: Colors.white,
                              ),
                            )
                          : Text(
                              isEditing ? s.saveChangesBtn : s.createCategoryBtn,
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                    ),
            ),
          ],
        ),
      ),
    );
  }
}
