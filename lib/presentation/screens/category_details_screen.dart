import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../models/category.dart';
import '../../models/topic.dart';
import '../../state/planner_state.dart';
import '../utils/adaptive_dialogs.dart';
import '../widgets/add_category_sheet.dart';
import '../widgets/add_topic_sheet.dart';
import '../widgets/apple_card.dart';
import '../widgets/topic_tile.dart';

class CategoryDetailsScreen extends StatelessWidget {
  final String categoryId;

  const CategoryDetailsScreen({super.key, required this.categoryId});

  void _showEditTopicDialog(
      BuildContext context, Topic topic, dynamic s) async {
    final newTitle = await AdaptiveDialogs.showInputDialog(
      context: context,
      title: s.editTopicTitle,
      placeholder: s.topicTitlePlaceholder,
      initialValue: topic.title,
      confirmLabel: s.save,
      cancelLabel: s.cancel,
    );
    if (newTitle != null && newTitle.isNotEmpty && context.mounted) {
      context.read<PlannerState>().updateTopicTitle(topic.id, newTitle);
    }
  }

  void _showDeleteTopicDialog(
      BuildContext context, Topic topic, dynamic s) async {
    final confirmed = await AdaptiveDialogs.showConfirmDialog(
      context: context,
      title: s.deleteTopicTitle,
      content: s.deleteTopicContent(topic.title),
      confirmLabel: s.delete,
      cancelLabel: s.cancel,
      isDestructive: true,
    );
    if (confirmed && context.mounted) {
      context.read<PlannerState>().deleteTopic(topic.id);
    }
  }

  void _showDeleteCategoryDialog(
      BuildContext context, Category category, dynamic s) async {
    final confirmed = await AdaptiveDialogs.showConfirmDialog(
      context: context,
      title: s.deleteCategoryTitle(category.title),
      content: s.deleteCategoryContent,
      confirmLabel: s.delete,
      cancelLabel: s.cancel,
      isDestructive: true,
    );
    if (confirmed && context.mounted) {
      context.read<PlannerState>().deleteCategory(category.id);
      Navigator.of(context).pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final state = context.watch<PlannerState>();
    final s = state.strings;
    final category = state.getCategoryById(categoryId);
    final isApple = AdaptiveDialogs.isApple(context);

    if (category == null) {
      return Scaffold(
        appBar: AppBar(),
        body: Center(child: Text(s.categoryNotFound)),
      );
    }

    final allTopics = state.getTopicsForCategory(categoryId);
    final activeTopics = allTopics.where((t) => !t.isCompleted).toList();
    final completedTopics = allTopics.where((t) => t.isCompleted).toList();

    final color = category.color;

    return Scaffold(
      body: SafeArea(
        bottom: false,
        child: CustomScrollView(
          physics: const AlwaysScrollableScrollPhysics(
            parent: BouncingScrollPhysics(),
          ),
          slivers: [
            // Adaptive Large Title Style App Bar
            SliverAppBar(
              floating: false,
              pinned: true,
              expandedHeight: 120,
              backgroundColor: Theme.of(context).scaffoldBackgroundColor,
              leading: isApple
                  ? CupertinoButton(
                      padding: EdgeInsets.zero,
                      minimumSize: const Size(40, 40),
                      child: Icon(
                        CupertinoIcons.chevron_back,
                        size: 26,
                        color: isDark ? Colors.white : Colors.black,
                      ),
                      onPressed: () => Navigator.of(context).pop(),
                    )
                  : IconButton(
                      icon: const Icon(Icons.arrow_back),
                      onPressed: () => Navigator.of(context).pop(),
                    ),
              actions: [
                PopupMenuButton<String>(
                  icon: Icon(
                    isApple ? CupertinoIcons.ellipsis_circle : Icons.more_vert,
                    size: 24,
                    color: isDark ? Colors.white : Colors.black,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  onSelected: (value) {
                    if (value == 'edit') {
                      AddCategorySheet.show(context,
                          existingCategory: category);
                    } else if (value == 'delete') {
                      _showDeleteCategoryDialog(context, category, s);
                    }
                  },
                  itemBuilder: (context) => [
                    PopupMenuItem(
                      value: 'edit',
                      child: Row(
                        children: [
                          Icon(
                            isApple ? CupertinoIcons.pencil : Icons.edit,
                            size: 18,
                          ),
                          const SizedBox(width: 10),
                          Text(s.edit),
                        ],
                      ),
                    ),
                    const PopupMenuDivider(),
                    PopupMenuItem(
                      value: 'delete',
                      child: Row(
                        children: [
                          Icon(
                            isApple ? CupertinoIcons.trash : Icons.delete,
                            size: 18,
                            color: const Color(0xFFE5484D),
                          ),
                          const SizedBox(width: 10),
                          Text(s.delete,
                              style: const TextStyle(color: Color(0xFFE5484D))),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(width: 8),
              ],
              flexibleSpace: FlexibleSpaceBar(
                titlePadding: const EdgeInsets.only(left: 20, bottom: 16),
                title: Text(
                  category.title,
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.w700,
                    letterSpacing: -0.4,
                    color: isDark ? Colors.white : const Color(0xFF1C1C1E),
                  ),
                ),
              ),
            ),

            // Content
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(20, 8, 20, 100),
              sliver: SliverList(
                delegate: SliverChildListDelegate([
                  // Stats card
                  AppleCard(
                    accentColor: color,
                    padding: const EdgeInsets.all(18),
                    child: Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                s.activeTopicsHeader,
                                style: TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w700,
                                  letterSpacing: 0.8,
                                  color: isDark
                                      ? Colors.white54
                                      : Colors.black45,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                '${activeTopics.length}',
                                style: TextStyle(
                                  fontSize: 28,
                                  fontWeight: FontWeight.w800,
                                  letterSpacing: -0.5,
                                  color: isDark
                                      ? Colors.white
                                      : const Color(0xFF1C1C1E),
                                ),
                              ),
                            ],
                          ),
                        ),
                        Container(
                          width: 1,
                          height: 40,
                          color: isDark ? Colors.white12 : Colors.black12,
                        ),
                        Expanded(
                          child: Padding(
                            padding: const EdgeInsets.only(left: 18.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  s.memorizedHeader,
                                  style: TextStyle(
                                    fontSize: 11,
                                    fontWeight: FontWeight.w700,
                                    letterSpacing: 0.8,
                                    color: isDark
                                        ? Colors.white54
                                        : Colors.black45,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  '${completedTopics.length}',
                                  style: const TextStyle(
                                    fontSize: 28,
                                    fontWeight: FontWeight.w800,
                                    letterSpacing: -0.5,
                                    color: Color(0xFF8EC89A),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 24),

                  // Active Topics Header
                  Text(
                    s.topicsToReviewHeader,
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 0.8,
                      color: isDark ? Colors.white38 : Colors.black45,
                    ),
                  ),

                  const SizedBox(height: 12),

                  if (activeTopics.isEmpty)
                    AppleCard(
                      padding: const EdgeInsets.all(24),
                      child: Column(
                        children: [
                          Icon(
                            isApple
                                ? CupertinoIcons.checkmark_seal
                                : Icons.verified,
                            size: 40,
                            color: isDark ? Colors.white30 : Colors.black26,
                          ),
                          const SizedBox(height: 12),
                          Text(
                            s.allCaughtUpTitle,
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w700,
                              color: isDark ? Colors.white : Colors.black87,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            s.allCaughtUpSubtitle,
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 13,
                              color: isDark ? Colors.white54 : Colors.black54,
                            ),
                          ),
                        ],
                      ),
                    )
                  else
                    ...activeTopics.map((topic) {
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 12),
                        child: TopicTile(
                          topic: topic,
                          category: category,
                          onReview: () => state.markTopicReviewed(topic.id),
                          onReset: () => state.resetTopicProgress(topic.id),
                          onEdit: () => _showEditTopicDialog(context, topic, s),
                          onDelete: () =>
                              _showDeleteTopicDialog(context, topic, s),
                        ),
                      );
                    }),

                  if (completedTopics.isNotEmpty) ...[
                    const SizedBox(height: 20),
                    Text(
                      s.memorizedCountHeader(completedTopics.length),
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 0.8,
                        color: isDark ? Colors.white38 : Colors.black45,
                      ),
                    ),
                    const SizedBox(height: 12),
                    ...completedTopics.map((topic) {
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 10),
                        child: TopicTile(
                          topic: topic,
                          category: category,
                          onReview: () {},
                          onReset: () => state.resetTopicProgress(topic.id),
                          onEdit: () => _showEditTopicDialog(context, topic, s),
                          onDelete: () =>
                              _showDeleteTopicDialog(context, topic, s),
                        ),
                      );
                    }),
                  ],
                ]),
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () =>
            AddTopicSheet.show(context, initialCategoryId: category.id),
        backgroundColor: color,
        elevation: isApple ? 4 : 2,
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(isApple ? 20 : 16)),
        icon: Icon(
          isApple ? CupertinoIcons.add : Icons.add,
          color: isDark ? const Color(0xFF0F1015) : Colors.white,
          size: 20,
        ),
        label: Text(
          s.newTopic,
          style: TextStyle(
            color: isDark ? const Color(0xFF0F1015) : Colors.white,
            fontWeight: FontWeight.w700,
            fontSize: 15,
          ),
        ),
      ),
    );
  }
}
