import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../state/planner_state.dart';
import '../utils/adaptive_dialogs.dart';

class AddTopicSheet extends StatefulWidget {
  final String? initialCategoryId;

  const AddTopicSheet({super.key, this.initialCategoryId});

  static Future<void> show(BuildContext context, {String? initialCategoryId}) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => AddTopicSheet(initialCategoryId: initialCategoryId),
    );
  }

  @override
  State<AddTopicSheet> createState() => _AddTopicSheetState();
}

class _AddTopicSheetState extends State<AddTopicSheet> {
  final TextEditingController _textController = TextEditingController();
  late String? _selectedCategoryId;
  bool _isSubmitting = false;

  @override
  void initState() {
    super.initState();
    _selectedCategoryId = widget.initialCategoryId;
  }

  @override
  void dispose() {
    _textController.dispose();
    super.dispose();
  }

  void _submit() async {
    final title = _textController.text.trim();
    if (title.isEmpty) return;

    final state = context.read<PlannerState>();
    final s = state.strings;
    final catId = _selectedCategoryId ??
        (state.categories.isNotEmpty ? state.categories.first.id : null);

    if (catId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(s.needCategoryNotice)),
      );
      return;
    }

    setState(() => _isSubmitting = true);

    try {
      await state.addTopic(
        categoryId: catId,
        title: title,
      );
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
    final state = context.watch<PlannerState>();
    final s = state.strings;
    final categories = state.categories;
    final isApple = AdaptiveDialogs.isApple(context);

    if (_selectedCategoryId == null && categories.isNotEmpty) {
      _selectedCategoryId = categories.first.id;
    }

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
                  s.newTopicTitle,
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

            const SizedBox(height: 16),

            // Category selector (if there are categories)
            if (categories.isNotEmpty) ...[
              Text(
                s.sectionLabel,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  letterSpacing: 0.8,
                  color: isDark ? Colors.white38 : Colors.black45,
                ),
              ),
              const SizedBox(height: 8),
              SizedBox(
                height: 38,
                child: ListView.separated(
                  scrollDirection: Axis.horizontal,
                  itemCount: categories.length,
                  separatorBuilder: (_, _) => const SizedBox(width: 8),
                  itemBuilder: (context, index) {
                    final cat = categories[index];
                    final isSelected = cat.id == _selectedCategoryId;

                    return GestureDetector(
                      onTap: () {
                        setState(() {
                          _selectedCategoryId = cat.id;
                        });
                      },
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 150),
                        padding: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 7),
                        decoration: BoxDecoration(
                          color: isSelected
                              ? cat.color.withValues(alpha: isDark ? 0.35 : 0.25)
                              : (isDark
                                  ? Colors.white.withValues(alpha: 0.06)
                                  : Colors.black.withValues(alpha: 0.04)),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: isSelected
                                ? cat.color
                                : Colors.transparent,
                            width: 1.5,
                          ),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Container(
                              width: 8,
                              height: 8,
                              decoration: BoxDecoration(
                                color: cat.color,
                                shape: BoxShape.circle,
                              ),
                            ),
                            const SizedBox(width: 6),
                            Text(
                              cat.title,
                              style: TextStyle(
                                fontSize: 13,
                                fontWeight: isSelected
                                    ? FontWeight.w700
                                    : FontWeight.w500,
                                color: isDark ? Colors.white : Colors.black87,
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
              const SizedBox(height: 16),
            ],

            // Topic title input field
            Text(
              s.topicTitleLabel,
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
                controller: _textController,
                autofocus: true,
                placeholder: s.topicTitlePlaceholder,
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
                controller: _textController,
                autofocus: true,
                decoration: InputDecoration(
                  hintText: s.topicTitlePlaceholder,
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

            const SizedBox(height: 14),

            // Ebbinghaus info card
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: const Color(0xFFB8A9F8).withValues(alpha: isDark ? 0.12 : 0.1),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(
                  color: const Color(0xFFB8A9F8).withValues(alpha: 0.2),
                ),
              ),
              child: Row(
                children: [
                  Icon(
                    isApple ? CupertinoIcons.sparkles : Icons.auto_awesome,
                    size: 18,
                    color: const Color(0xFFB8A9F8),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      s.firstReviewNotice,
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                        color: Color(0xFFB8A9F8),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            // Submit Button
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
                              s.createTopicBtn,
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
                              s.createTopicBtn,
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
