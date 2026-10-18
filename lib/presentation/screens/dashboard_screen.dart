import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../state/planner_state.dart';
import '../utils/adaptive_dialogs.dart';
import '../utils/date_formatters.dart';
import '../widgets/add_category_sheet.dart';
import '../widgets/add_topic_sheet.dart';
import '../widgets/apple_card.dart';
import '../widgets/category_tile.dart';
import '../widgets/up_next_card.dart';
import 'category_details_screen.dart';
import 'settings_sheet.dart';

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final state = context.watch<PlannerState>();
    final s = state.strings;
    final isApple = AdaptiveDialogs.isApple(context);

    if (state.isLoading) {
      return Scaffold(
        body: Center(
          child: isApple
              ? const CupertinoActivityIndicator(radius: 16)
              : const CircularProgressIndicator(),
        ),
      );
    }

    final upNextTopics = state.upNextTopics;
    final categories = state.categories;
    final categoriesMap = state.categoriesMap;

    return Scaffold(
      body: SafeArea(
        bottom: false,
        child: CustomScrollView(
          physics: const AlwaysScrollableScrollPhysics(
            parent: BouncingScrollPhysics(),
          ),
          slivers: [
            // Top App Bar with Date caption & Actions
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 16, 20, 12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Apple Journal Date Caption
                    Text(
                      DateFormatters.formatTodayHeader(strings: s),
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 1.2,
                        color: isDark ? Colors.white38 : Colors.black45,
                      ),
                    ),
                    const SizedBox(height: 4),

                    // Large Title & Top Action Buttons
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Text(
                          s.today,
                          style: TextStyle(
                            fontSize: 34,
                            fontWeight: FontWeight.w800,
                            letterSpacing: -0.8,
                            color: isDark
                                ? Colors.white
                                : const Color(0xFF1C1C1E),
                          ),
                        ),
                        Row(
                          children: [
                            // Add Category action
                            if (isApple)
                              CupertinoButton(
                                padding: const EdgeInsets.all(8),
                                minimumSize: const Size(38, 38),
                                child: Icon(
                                  CupertinoIcons.folder_badge_plus,
                                  size: 24,
                                  color: isDark ? Colors.white : Colors.black87,
                                ),
                                onPressed: () => AddCategorySheet.show(context),
                              )
                            else
                              IconButton(
                                icon: const Icon(Icons.create_new_folder_outlined),
                                tooltip: s.newCategorySheetTitle,
                                onPressed: () => AddCategorySheet.show(context),
                              ),
                            // Settings & Backup action
                            if (isApple)
                              CupertinoButton(
                                padding: const EdgeInsets.all(8),
                                minimumSize: const Size(38, 38),
                                child: Icon(
                                  CupertinoIcons.slider_horizontal_3,
                                  size: 24,
                                  color: isDark ? Colors.white : Colors.black87,
                                ),
                                onPressed: () => SettingsSheet.show(context),
                              )
                            else
                              IconButton(
                                icon: const Icon(Icons.tune),
                                tooltip: s.settingsAndData,
                                onPressed: () => SettingsSheet.show(context),
                              ),
                          ],
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),

            // Section 1: "Up Next"
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 12, 20, 8),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        Text(
                          s.upNext,
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w700,
                            letterSpacing: 0.8,
                            color: isDark ? Colors.white38 : Colors.black45,
                          ),
                        ),
                        if (upNextTopics.isNotEmpty) ...[
                          const SizedBox(width: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 7, vertical: 2),
                            decoration: BoxDecoration(
                              color: const Color(0xFFB8A9F8).withValues(alpha: 0.2),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Text(
                              '${upNextTopics.length}',
                              style: const TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.w700,
                                color: Color(0xFFB8A9F8),
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),
                  ],
                ),
              ),
            ),

            // Up Next Cards
            SliverToBoxAdapter(
              child: upNextTopics.isEmpty
                  ? Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 20, vertical: 8),
                      child: AppleCard(
                        padding: const EdgeInsets.all(24),
                        child: Column(
                          children: [
                            Container(
                              width: 50,
                              height: 50,
                              decoration: BoxDecoration(
                                color: const Color(0xFF8EC89A)
                                    .withValues(alpha: isDark ? 0.2 : 0.15),
                                shape: BoxShape.circle,
                              ),
                              child: Icon(
                                isApple ? CupertinoIcons.checkmark_alt : Icons.check,
                                size: 28,
                                color: const Color(0xFF8EC89A),
                              ),
                            ),
                            const SizedBox(height: 14),
                            Text(
                              s.allCaughtUpTitle,
                              style: TextStyle(
                                fontSize: 17,
                                fontWeight: FontWeight.w700,
                                color: isDark
                                    ? Colors.white
                                    : const Color(0xFF1C1C1E),
                              ),
                            ),
                            const SizedBox(height: 6),
                            Text(
                              s.allCaughtUpSubtitle,
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontSize: 13,
                                color: isDark ? Colors.white54 : Colors.black54,
                                height: 1.3,
                              ),
                            ),
                          ],
                        ),
                      ),
                    )
                  : SizedBox(
                      height: 255,
                      child: ListView.separated(
                        scrollDirection: Axis.horizontal,
                        physics: const BouncingScrollPhysics(),
                        padding: const EdgeInsets.symmetric(
                            horizontal: 20, vertical: 8),
                        itemCount: upNextTopics.length,
                        separatorBuilder: (_, _) => const SizedBox(width: 14),
                        itemBuilder: (context, index) {
                          final topic = upNextTopics[index];
                          final category = categoriesMap[topic.categoryId];

                          return SizedBox(
                            width: MediaQuery.of(context).size.width * 0.86,
                            child: UpNextCard(
                              topic: topic,
                              category: category,
                              onReview: () =>
                                  state.markTopicReviewed(topic.id),
                              onTap: category != null
                                  ? () {
                                      Navigator.of(context).push(
                                        MaterialPageRoute(
                                          builder: (_) => CategoryDetailsScreen(
                                            categoryId: category.id,
                                          ),
                                        ),
                                      );
                                    }
                                  : null,
                            ),
                          );
                        },
                      ),
                    ),
            ),

            const SliverToBoxAdapter(child: SizedBox(height: 16)),

            // Section 2: "Categories"
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 8, 20, 8),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      '${s.categories} (${categories.length})',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 0.8,
                        color: isDark ? Colors.white38 : Colors.black45,
                      ),
                    ),
                    if (isApple)
                      CupertinoButton(
                        padding: EdgeInsets.zero,
                        minimumSize: const Size(24, 24),
                        child: Text(
                          s.addCategoryBtn,
                          style: const TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            color: Color(0xFFB8A9F8),
                          ),
                        ),
                        onPressed: () => AddCategorySheet.show(context),
                      )
                    else
                      TextButton(
                        onPressed: () => AddCategorySheet.show(context),
                        child: Text(
                          s.addCategoryBtn,
                          style: const TextStyle(
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ),

            // Categories list
            if (categories.isEmpty)
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 20, vertical: 12),
                  child: AppleCard(
                    padding: const EdgeInsets.all(24),
                    child: Column(
                      children: [
                        Icon(
                          isApple
                              ? CupertinoIcons.folder_badge_plus
                              : Icons.create_new_folder_outlined,
                          size: 40,
                          color: isDark ? Colors.white24 : Colors.black26,
                        ),
                        const SizedBox(height: 12),
                        Text(
                          s.noCategoriesTitle,
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                            color: isDark ? Colors.white : Colors.black87,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          s.noCategoriesSubtitle,
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 13,
                            color: isDark ? Colors.white54 : Colors.black54,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              )
            else
              SliverPadding(
                padding: const EdgeInsets.fromLTRB(20, 4, 20, 100),
                sliver: SliverList(
                  delegate: SliverChildBuilderDelegate(
                    (context, index) {
                      final category = categories[index];
                      final activeCount =
                          state.getActiveCountForCategory(category.id);
                      final totalCount =
                          state.getTopicsForCategory(category.id).length;

                      return Padding(
                        padding: const EdgeInsets.only(bottom: 12),
                        child: CategoryTile(
                          category: category,
                          activeCount: activeCount,
                          totalCount: totalCount,
                          onTap: () {
                            Navigator.of(context).push(
                              MaterialPageRoute(
                                builder: (_) => CategoryDetailsScreen(
                                  categoryId: category.id,
                                ),
                              ),
                            );
                          },
                        ),
                      );
                    },
                    childCount: categories.length,
                  ),
                ),
              ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => AddTopicSheet.show(context),
        backgroundColor: const Color(0xFFB8A9F8),
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
