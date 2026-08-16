import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:edustream/core/constants/app_colors.dart';
import 'package:edustream/routes/app_routes.dart';
import 'package:edustream/features/home/presentation/screens/main_entry_screen.dart';
import 'package:edustream/features/explore/presentation/providers/explore_providers.dart';
import 'package:edustream/features/explore/data/models/explore_models.dart';
import 'package:edustream/features/explore/data/models/explore_subjects.dart';
import 'package:edustream/features/explore/presentation/widgets/hero_banner_carousel.dart';
import 'package:edustream/features/explore/presentation/widgets/recommended_course_card.dart';
import 'package:edustream/features/explore/presentation/widgets/subject_card.dart';
import 'package:edustream/features/explore/presentation/widgets/standard_poster_card.dart';
import 'package:edustream/features/auth/presentation/providers/auth_providers.dart';

class StandardListScreen extends ConsumerWidget {
  const StandardListScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final categoriesAsync = ref.watch(categoriesProvider);
    final bannersAsync = ref.watch(exploreBannersProvider);
    final homeDataAsync = ref.watch(homeDataProvider);
    final profileAsync = ref.watch(profileProvider);

    return Scaffold(
      backgroundColor: Colors.white,
      body: categoriesAsync.when(
        data: (categories) => _buildContent(
          context, 
          ref, 
          categories, 
          bannersAsync, 
          homeDataAsync,
          profileAsync,
        ),
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, stack) => Center(child: Text("Error: $err")),
      ),
    );
  }

  Widget _buildContent(
    BuildContext context, 
    WidgetRef ref, 
    List<CategoryModel> categories, 
    AsyncValue<List<BannerModel>> bannersAsync,
    AsyncValue<Map<String, dynamic>> homeDataAsync,
    AsyncValue<Map<String, dynamic>> profileAsync,
  ) {
    final recommendedCourseAsync = ref.watch(recommendedCourseProvider);
    
    return recommendedCourseAsync.when(
      data: (course) {
        if (course == null) return const Center(child: Text("No courses available"));

        // Map dynamic subjects from API to SubjectModel for UI
        final List<SubjectModel> subjects = (course.subjects ?? [])
            .map((s) => SubjectModel.fromJson(s as Map<String, dynamic>))
            .toList();

        return CustomScrollView(
          physics: const BouncingScrollPhysics(),
          slivers: [
            // 1. Explore Header with Back Button
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 12),
                child: Row(
                  children: [
                    InkWell(
                      onTap: () {
                        if (Navigator.canPop(context)) {
                          Navigator.pop(context);
                        } else {
                          ref.read(bottomNavIndexProvider.notifier).state = 0;
                        }
                      },
                      borderRadius: BorderRadius.circular(12),
                      child: Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: AppColors.background,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: AppColors.border, width: 1),
                        ),
                        child: const Icon(Icons.arrow_back_ios_new_rounded, color: AppColors.textPrimary, size: 18),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Explore Courses',
                            style: GoogleFonts.outfit(
                              fontSize: 22,
                              fontWeight: FontWeight.w800,
                              color: AppColors.textPrimary,
                              letterSpacing: -0.5,
                            ),
                          ),
                          Text(
                            'Boost your learning today',
                            style: GoogleFonts.inter(
                              color: AppColors.textMuted,
                              fontSize: 12,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.all(9),
                      decoration: BoxDecoration(
                        color: AppColors.primaryLight,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Icon(Icons.search, color: AppColors.primary, size: 20),
                    ),
                  ],
                ),
              ),
            ),

            // 2. Banner slider
            SliverToBoxAdapter(
              child: bannersAsync.when(
                data: (banners) {
                  final bannerItems = banners.map((b) => BannerItem(
                    title: b.title,
                    subtitle: b.subtitle ?? '',
                    price: null,
                    icon: b.icon,
                    gradientColors: [
                      _parseColor(b.colorStart),
                      _parseColor(b.colorEnd),
                    ],
                    onTap: () {},
                  )).toList();

                  if (bannerItems.isEmpty) {
                    bannerItems.add(BannerItem(
                      title: 'Best Value – ${course.name}',
                      subtitle: 'Top rated courses by experts',
                      price: null,
                      icon: 'fa-graduation-cap',
                      gradientColors: [const Color(0xFF00695C), const Color(0xFF00897B)],
                      onTap: () {},
                    ));
                  }

                  return Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8.0),
                    child: HeroBannerCarousel(banners: bannerItems),
                  );
                },
                loading: () => const SizedBox(height: 180, child: Center(child: CircularProgressIndicator())),
                error: (err, stack) => const SizedBox.shrink(),
              ),
            ),

            // 3. Recommended Course Section
            SliverMainAxisGroup(
              slivers: [
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(20, 32, 20, 12),
                    child: Row(
                      children: [
                        const Icon(Icons.star, color: Colors.orangeAccent, size: 20),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            'Recommended: ${course.name}',
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w800,
                              color: Color(0xFF1A1A2E),
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                SliverToBoxAdapter(
                  child: RecommendedCourseCard(
                    title: course.name,
                    subtitle: course.description ?? 'Complete curriculum for the entire year',
                    price: course.price ?? '0',
                    mrp: course.mrp ?? '0',
                    saveAmount: course.save ?? '0',
                    subjects: (course.subjects ?? []).map((s) => SubjectModel.fromJson(s as Map<String, dynamic>)).toList(),
                    classTag: course.name,
                    onViewBuy: () {
                      Navigator.pushNamed(
                        context, 
                        AppRoutes.coursePreview, 
                        arguments: course
                      );
                    },
                  ),
                ),
              ],
            ),

            // 4. Individual Subjects Section
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 40, 20, 16),
                child: Text(
                  'Buy Individual Subjects',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w800,
                    color: Colors.black.withValues(alpha: 0.5),
                  ),
                ),
              ),
            ),
            SliverPadding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              sliver: SliverList(
                delegate: SliverChildBuilderDelegate(
                  (context, index) {
                    final int firstIndex = index * 2;
                    final int secondIndex = firstIndex + 1;

                    return Padding(
                      padding: const EdgeInsets.only(bottom: 16),
                      child: IntrinsicHeight(
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            // First Card
                            Expanded(
                              child: SubjectCard(
                                subject: subjects[firstIndex],
                                onViewDetails: () {
                                  Navigator.pushNamed(
                                    context,
                                    AppRoutes.subjectDetail,
                                    arguments: {
                                      'subjectId': subjects[firstIndex].id,
                                      'subjectName': subjects[firstIndex].name,
                                    },
                                  );
                                },
                              ),
                            ),
                            const SizedBox(width: 16),
                            // Second Card (or empty space)
                            Expanded(
                              child: secondIndex < subjects.length
                                  ? SubjectCard(
                                      subject: subjects[secondIndex],
                                      onViewDetails: () {
                                        Navigator.pushNamed(
                                          context,
                                          AppRoutes.subjectDetail,
                                          arguments: {
                                            'subjectId': subjects[secondIndex].id,
                                            'subjectName': subjects[secondIndex].name,
                                          },
                                        );
                                      },
                                    )
                                  : const SizedBox.shrink(),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                  childCount: (subjects.length / 2).ceil(),
                ),
              ),
            ),

            // 5. All Courses Section (Categories)
            const SliverToBoxAdapter(child: SizedBox(height: 48)),
            ...categories.map((category) => _buildCategorySection(context, ref, category)),
            const SliverToBoxAdapter(child: SizedBox(height: 40)),
          ],
        );
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (err, stack) => Center(child: Text("Error: $err")),
    );
  }

  Widget _buildCategorySection(BuildContext context, WidgetRef ref, CategoryModel category) {
    return SliverToBoxAdapter(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            child: Row(
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      category.name,
                      style: const TextStyle(fontSize: 24, fontWeight: FontWeight.w900, color: Color(0xFF1A1A2E)),
                    ),
                    const SizedBox(height: 2),
                    Container(
                      height: 3,
                      width: 40,
                      decoration: BoxDecoration(
                        color: AppColors.primary,
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  ],
                ),
                const Spacer(),
                TextButton(
                  onPressed: () {},
                  child: const Text('See All', style: TextStyle(color: AppColors.primary, fontWeight: FontWeight.bold)),
                ),
              ],
            ),
          ),
          _CoursesHorizontalList(categoryId: category.id),
          const SizedBox(height: 24),
        ],
      ),
    );
  }

  Color _parseColor(String? colorStr) {
    if (colorStr == null) return AppColors.primary;
    try {
      return Color(int.parse('FF${colorStr.replaceAll('#', '')}', radix: 16));
    } catch (_) {
      return AppColors.primary;
    }
  }
}

class _CoursesHorizontalList extends ConsumerWidget {
  final int categoryId;
  const _CoursesHorizontalList({required this.categoryId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final coursesAsync = ref.watch(categoryCoursesProvider(categoryId));

    return coursesAsync.when(
      data: (courses) => SizedBox(
        height: 220,
        child: ListView.builder(
          scrollDirection: Axis.horizontal,
          padding: const EdgeInsets.symmetric(horizontal: 20),
          itemCount: courses.length,
          itemBuilder: (context, index) {
            final course = courses[index];
            return StandardPosterCard(
              course: course,
              onTap: () {
                Navigator.pushNamed(context, AppRoutes.coursePreview, arguments: course);
              },
            );
          },
        ),
      ),
      loading: () => const SizedBox(height: 220, child: Center(child: CircularProgressIndicator())),
      error: (err, stack) => const SizedBox(height: 220, child: Center(child: Text("Error loading courses"))),
    );
  }
}
