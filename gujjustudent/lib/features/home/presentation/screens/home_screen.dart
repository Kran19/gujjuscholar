import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:edustream/core/constants/app_colors.dart';
import 'package:edustream/features/explore/presentation/providers/explore_providers.dart';
import 'package:edustream/features/explore/data/models/explore_models.dart';
import 'package:edustream/features/explore/data/models/explore_subjects.dart';
import 'package:edustream/features/auth/presentation/providers/auth_providers.dart';
import 'package:edustream/features/my_courses/presentation/providers/my_courses_providers.dart';
import 'package:edustream/routes/app_routes.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  @override
  Widget build(BuildContext context) {
    final homeDataAsync = ref.watch(homeDataProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      body: homeDataAsync.when(
        data: (data) => _buildContent(context, data),
        loading: () => const Center(
          child: CircularProgressIndicator(strokeWidth: 3),
        ),
        error: (err, stack) => Center(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.cloud_off_rounded, size: 48, color: AppColors.error),
                const SizedBox(height: 12),
                Text(
                  "Could not load dashboard",
                  style: GoogleFonts.outfit(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 6),
                Text(
                  "$err",
                  textAlign: TextAlign.center,
                  style: GoogleFonts.inter(fontSize: 12, color: AppColors.textSecondary),
                ),
                const SizedBox(height: 16),
                ElevatedButton.icon(
                  onPressed: () => ref.invalidate(homeDataProvider),
                  icon: const Icon(Icons.refresh_rounded, size: 18),
                  label: const Text("Try Again"),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildContent(BuildContext context, Map<String, dynamic> data) {
    final categories = (data['categories'] as List?)?.map((e) => CategoryModel.fromJson(e)).toList() ?? [];
    final featuredCourses = (data['featured_courses'] as List?)?.map((e) => CourseModel.fromJson(e)).toList() ?? [];
    final banners = (data['banners'] as List?)?.map((e) => BannerModel.fromJson(e)).toList() ?? [];

    // Personalized Data
    final recommendedCourse = data['recommended_course'];
    final personalizedSubjects = recommendedCourse != null && recommendedCourse['subjects'] != null
        ? (recommendedCourse['subjects'] as List).map((e) => SubjectModel.fromJson(e)).toList()
        : <SubjectModel>[];
    final personalizedVideos = data['personalized_videos'] as List? ?? [];
    final personalizedNotes = data['personalized_notes'] as List? ?? [];
    final personalizedQuizzes = data['personalized_quizzes'] as List? ?? [];

    return CustomScrollView(
      physics: const BouncingScrollPhysics(),
      slivers: [
        // 1. Compact Greeting & Class Switcher Row
        _buildHeader(recommendedCourse),

        // 2. Resume Learning Hero Card (if available)
        if (personalizedVideos.isNotEmpty)
          _buildContinueLearningHero(personalizedVideos.first, recommendedCourse),

        // 3. Compact Promotional Banners
        if (banners.isNotEmpty)
          _buildBanners(banners),

        SliverToBoxAdapter(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 4. Subjects Section: High-Density 4-Column Quick Grid
              if (personalizedSubjects.isNotEmpty) ...[
                _buildSectionTitle(
                  title: "${recommendedCourse != null ? recommendedCourse['name'] : 'Course'} Subjects",
                  subtitle: "Tap to view chapters & videos",
                  icon: Icons.auto_stories_rounded,
                  accentColor: AppColors.primary,
                  onViewAll: () => Navigator.pushNamed(context, AppRoutes.explore),
                ),
                _buildSubjectsGrid(personalizedSubjects),
              ],

              // 5. Recent Video Lectures (Compact 16:9 Cards)
              if (personalizedVideos.isNotEmpty) ...[
                _buildSectionTitle(
                  title: "Recent Lectures",
                  subtitle: "Pick up where you left off",
                  icon: Icons.play_circle_fill_rounded,
                  accentColor: const Color(0xFFF43F5E),
                  onViewAll: () => Navigator.pushNamed(context, AppRoutes.explore),
                ),
                _buildCompactVideosList(personalizedVideos),
              ],

              // 6. Practice Quizzes & Mock Tests
              if (personalizedQuizzes.isNotEmpty) ...[
                _buildSectionTitle(
                  title: "Practice & Test",
                  subtitle: "Daily interactive chapter quizzes",
                  icon: Icons.bolt_rounded,
                  accentColor: AppColors.warning,
                  onViewAll: () => Navigator.pushNamed(context, AppRoutes.quizList),
                ),
                _buildCompactQuizzesList(personalizedQuizzes),
              ],

              // 7. Standards / Categories (Sleek Horizontal Chips)
              if (categories.isNotEmpty) ...[
                _buildSectionTitle(
                  title: "Explore Standards",
                  subtitle: "All classes & boards",
                  icon: Icons.grid_view_rounded,
                  accentColor: Colors.indigo,
                  onViewAll: () => Navigator.pushNamed(context, AppRoutes.explore),
                ),
                _buildCategoriesChips(categories),
              ],

              // 8. Study Notes & PDFs
              if (personalizedNotes.isNotEmpty) ...[
                _buildSectionTitle(
                  title: "Revision Notes & PDFs",
                  subtitle: "Formula sheets & summary notes",
                  icon: Icons.menu_book_rounded,
                  accentColor: Colors.teal,
                ),
                _buildCompactNotesList(personalizedNotes),
              ],

              // 9. Featured Full Courses
              if (featuredCourses.isNotEmpty) ...[
                _buildSectionTitle(
                  title: "Featured Courses",
                  subtitle: "Comprehensive curriculum packs",
                  icon: Icons.stars_rounded,
                  accentColor: Colors.amber[800]!,
                  onViewAll: () => Navigator.pushNamed(context, AppRoutes.explore),
                ),
                _buildFeaturedCoursesList(featuredCourses),
              ],

              const SizedBox(height: 32),
            ],
          ),
        ),
      ],
    );
  }

  // --------------------------------------------------------------------------
  // 1. Compact Header with 1-Tap Class Switcher Chip
  // --------------------------------------------------------------------------
  Widget _buildHeader(dynamic recommendedCourse) {
    final currentCourseName = recommendedCourse != null
        ? (recommendedCourse['name'] ?? 'Select Standard')
        : 'Select Standard';

    return SliverToBoxAdapter(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Welcome back! 👋",
                    style: GoogleFonts.inter(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textMuted,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    "Let's learn something new",
                    style: GoogleFonts.outfit(
                      fontSize: 17,
                      fontWeight: FontWeight.w800,
                      color: AppColors.textPrimary,
                      letterSpacing: -0.3,
                    ),
                  ),
                ],
              ),
            ),
            // Sleek Interactive Standard Switcher Pill
            InkWell(
              onTap: () => _showStandardSelectionModal(context, recommendedCourse),
              borderRadius: BorderRadius.circular(20),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
                decoration: BoxDecoration(
                  color: AppColors.primaryLight,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: AppColors.primary.withOpacity(0.2), width: 1),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.school_rounded, color: AppColors.primary, size: 15),
                    const SizedBox(width: 6),
                    ConstrainedBox(
                      constraints: const BoxConstraints(maxWidth: 110),
                      child: Text(
                        currentCourseName,
                        style: GoogleFonts.inter(
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                          color: AppColors.primary,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    const SizedBox(width: 4),
                    const Icon(Icons.keyboard_arrow_down_rounded, color: AppColors.primary, size: 16),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // --------------------------------------------------------------------------
  // 2. "Continue Learning" Hero Card
  // --------------------------------------------------------------------------
  Widget _buildContinueLearningHero(dynamic latestVideo, dynamic recommendedCourse) {
    final videoTitle = latestVideo['name'] ?? latestVideo['title'] ?? 'Continue Lesson';
    final courseName = recommendedCourse != null ? (recommendedCourse['name'] ?? 'Class Lesson') : 'Video Lesson';

    return SliverToBoxAdapter(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
        child: InkWell(
          onTap: () {
            final videoId = latestVideo['id'] is int
                ? latestVideo['id']
                : (int.tryParse(latestVideo['id']?.toString() ?? '1') ?? 1);
            Navigator.pushNamed(
              context,
              AppRoutes.videoPlayer,
              arguments: {
                'videoId': videoId,
                'videoName': videoTitle,
              },
            );
          },
          borderRadius: BorderRadius.circular(16),
          child: Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFF1E293B), Color(0xFF0F172A)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFF0F172A).withOpacity(0.15),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Row(
              children: [
                // Video thumbnail with Play Icon
                Container(
                  width: 52,
                  height: 52,
                  decoration: BoxDecoration(
                    color: AppColors.primary.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.white12),
                  ),
                  child: const Center(
                    child: Icon(Icons.play_arrow_rounded, color: Colors.white, size: 30),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                            decoration: BoxDecoration(
                              color: AppColors.primary,
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: const Text(
                              "CONTINUE LEARNING",
                              style: TextStyle(color: Colors.white, fontSize: 9, fontWeight: FontWeight.w800, letterSpacing: 0.5),
                            ),
                          ),
                          const SizedBox(width: 6),
                          Expanded(
                            child: Text(
                              courseName,
                              style: const TextStyle(color: Colors.white70, fontSize: 11, fontWeight: FontWeight.w500),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 5),
                      Text(
                        videoTitle,
                        style: GoogleFonts.inter(
                          color: Colors.white,
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 6),
                      // Mini Progress Track
                      Row(
                        children: [
                          Expanded(
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(3),
                              child: const LinearProgressIndicator(
                                value: 0.65,
                                minHeight: 4,
                                backgroundColor: Colors.white24,
                                valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF38BDF8)),
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          const Text(
                            "65%",
                            style: TextStyle(color: Colors.white70, fontSize: 10, fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                const Icon(Icons.arrow_forward_ios_rounded, color: Colors.white54, size: 14),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // --------------------------------------------------------------------------
  // 3. Compact 130px Promotional Banners
  // --------------------------------------------------------------------------
  Widget _buildBanners(List<BannerModel> banners) {
    return SliverToBoxAdapter(
      child: Padding(
        padding: const EdgeInsets.only(top: 4, bottom: 8),
        child: CarouselSlider(
          options: CarouselOptions(
            height: 125.0,
            autoPlay: banners.length > 1,
            enlargeCenterPage: true,
            enlargeFactor: 0.18,
            autoPlayCurve: Curves.fastOutSlowIn,
            enableInfiniteScroll: banners.length > 1,
            autoPlayAnimationDuration: const Duration(milliseconds: 700),
            viewportFraction: 0.90,
          ),
          items: banners.map((banner) {
            final colorStart = _hexColor(banner.colorStart);
            final colorEnd = _hexColor(banner.colorEnd);
            return Builder(
              builder: (BuildContext context) {
                return Container(
                  width: MediaQuery.of(context).size.width,
                  margin: const EdgeInsets.symmetric(horizontal: 4.0),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [colorStart, colorEnd],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Stack(
                    children: [
                      Positioned(
                        right: -12,
                        bottom: -12,
                        child: Icon(
                          Icons.school_rounded,
                          size: 90,
                          color: Colors.white.withOpacity(0.12),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                              decoration: BoxDecoration(
                                color: Colors.white.withOpacity(0.2),
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: const Text(
                                "FEATURED",
                                style: TextStyle(color: Colors.white, fontSize: 9, fontWeight: FontWeight.w800, letterSpacing: 0.5),
                              ),
                            ),
                            const SizedBox(height: 6),
                            Text(
                              banner.title,
                              style: GoogleFonts.outfit(
                                color: Colors.white,
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            if (banner.subtitle != null && banner.subtitle!.isNotEmpty) ...[
                              const SizedBox(height: 2),
                              Text(
                                banner.subtitle!,
                                style: GoogleFonts.inter(
                                  color: Colors.white.withOpacity(0.9),
                                  fontSize: 11,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ],
                          ],
                        ),
                      ),
                    ],
                  ),
                );
              },
            );
          }).toList(),
        ),
      ),
    );
  }

  // --------------------------------------------------------------------------
  // 4. Modern 4-Column Quick Subject Grid (High Information Density)
  // --------------------------------------------------------------------------
  Widget _buildSubjectsGrid(List<SubjectModel> subjects) {
    final displaySubjects = subjects.take(8).toList();

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 14),
      child: GridView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        itemCount: displaySubjects.length,
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 4,
          crossAxisSpacing: 6,
          mainAxisSpacing: 8,
          childAspectRatio: 0.92,
        ),
        itemBuilder: (context, index) {
          final subject = displaySubjects[index];
          return _buildSubjectGridItem(subject);
        },
      ),
    );
  }

  Widget _buildSubjectGridItem(SubjectModel subject) {
    return InkWell(
      onTap: () {
        Navigator.pushNamed(
          context,
          AppRoutes.subjectDetail,
          arguments: {
            'subjectId': subject.id,
            'subjectName': subject.name,
          },
        );
      },
      splashColor: subject.color.withValues(alpha: 0.12),
      highlightColor: Colors.transparent,
      hoverColor: Colors.transparent,
      borderRadius: BorderRadius.circular(12),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Sleek 46px squircle badge
          Container(
            width: 46,
            height: 46,
            decoration: BoxDecoration(
              color: subject.color.withValues(alpha: 0.10),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: subject.color.withValues(alpha: 0.22), width: 1),
            ),
            child: Icon(subject.icon, color: subject.color, size: 22),
          ),
          const SizedBox(height: 5),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 2),
            child: Text(
              subject.name,
              style: GoogleFonts.inter(
                fontWeight: FontWeight.w600,
                fontSize: 11,
                color: AppColors.textPrimary,
              ),
              textAlign: TextAlign.center,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }

  // --------------------------------------------------------------------------
  // 5. Compact 16:9 Recent Video Cards
  // --------------------------------------------------------------------------
  Widget _buildCompactVideosList(List<dynamic> videos) {
    return SizedBox(
      height: 165,
      child: ListView.builder(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        scrollDirection: Axis.horizontal,
        physics: const BouncingScrollPhysics(),
        itemCount: videos.length,
        itemBuilder: (context, index) {
          final video = videos[index];
          return _buildCompactVideoCard(video);
        },
      ),
    );
  }

  Widget _buildCompactVideoCard(dynamic video) {
    final videoId = video['id'] is int ? video['id'] : (int.tryParse(video['id']?.toString() ?? '1') ?? 1);
    final videoName = video['name'] ?? video['title'] ?? 'Video Lesson';

    return InkWell(
      onTap: () {
        Navigator.pushNamed(
          context,
          AppRoutes.videoPlayer,
          arguments: {
            'videoId': videoId,
            'videoName': videoName,
          },
        );
      },
      borderRadius: BorderRadius.circular(14),
      child: Container(
        width: 190,
        margin: const EdgeInsets.only(right: 12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: AppColors.border, width: 1),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Thumbnail container
            Container(
              height: 95,
              decoration: BoxDecoration(
                color: const Color(0xFF1E293B),
                borderRadius: const BorderRadius.vertical(top: Radius.circular(13)),
                image: video['thumbnail_url'] != null
                    ? DecorationImage(
                        image: NetworkImage(video['thumbnail_url']),
                        fit: BoxFit.cover,
                      )
                    : null,
              ),
              child: Stack(
                children: [
                  Center(
                    child: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.black.withOpacity(0.55),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.play_arrow_rounded, color: Colors.white, size: 22),
                    ),
                  ),
                  Positioned(
                    bottom: 6,
                    right: 6,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: Colors.black.withOpacity(0.75),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        video['duration'] ?? '12 mins',
                        style: const TextStyle(color: Colors.white, fontSize: 9.5, fontWeight: FontWeight.w600),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(10, 8, 10, 6),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    videoName,
                    style: GoogleFonts.inter(
                      fontWeight: FontWeight.w700,
                      fontSize: 12.5,
                      color: AppColors.textPrimary,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 2),
                  Row(
                    children: [
                      const Icon(Icons.verified_rounded, size: 12, color: AppColors.primary),
                      const SizedBox(width: 4),
                      Text(
                        "HD Lecture",
                        style: GoogleFonts.inter(fontSize: 10, color: AppColors.textMuted, fontWeight: FontWeight.w500),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // --------------------------------------------------------------------------
  // 6. Compact Quizzes List
  // --------------------------------------------------------------------------
  Widget _buildCompactQuizzesList(List<dynamic> quizzes) {
    return SizedBox(
      height: 110,
      child: ListView.builder(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        scrollDirection: Axis.horizontal,
        physics: const BouncingScrollPhysics(),
        itemCount: quizzes.length,
        itemBuilder: (context, index) {
          final quiz = quizzes[index];
          return _buildCompactQuizCard(quiz);
        },
      ),
    );
  }

  Widget _buildCompactQuizCard(dynamic quiz) {
    return InkWell(
      onTap: () {
        Navigator.pushNamed(
          context,
          AppRoutes.quizAttempt,
          arguments: quiz['id'],
        );
      },
      borderRadius: BorderRadius.circular(14),
      child: Container(
        width: 170,
        margin: const EdgeInsets.only(right: 12),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: AppColors.border, width: 1),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    color: AppColors.accentLight,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(Icons.bolt_rounded, color: AppColors.warning, size: 16),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    "${quiz['questions_count'] ?? 10} Questions",
                    style: GoogleFonts.inter(fontSize: 10.5, fontWeight: FontWeight.w600, color: AppColors.textSecondary),
                    maxLines: 1,
                  ),
                ),
              ],
            ),
            Text(
              quiz['title'] ?? 'Chapter Quiz',
              style: GoogleFonts.inter(fontWeight: FontWeight.w700, fontSize: 12.5, color: AppColors.textPrimary),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  "15 Mins",
                  style: GoogleFonts.inter(fontSize: 10, color: AppColors.textMuted),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: AppColors.primaryLight,
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    "Start",
                    style: GoogleFonts.inter(fontSize: 10, fontWeight: FontWeight.w700, color: AppColors.primary),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  // --------------------------------------------------------------------------
  // 7. Standards / Categories Horizontal Chips
  // --------------------------------------------------------------------------
  Widget _buildCategoriesChips(List<CategoryModel> categories) {
    return SizedBox(
      height: 40,
      child: ListView.builder(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        scrollDirection: Axis.horizontal,
        physics: const BouncingScrollPhysics(),
        itemCount: categories.length,
        itemBuilder: (context, index) {
          final category = categories[index];
          return Container(
            margin: const EdgeInsets.only(right: 8),
            child: ActionChip(
              onPressed: () {
                Navigator.pushNamed(context, AppRoutes.standardDetail, arguments: category);
              },
              backgroundColor: Colors.white,
              surfaceTintColor: Colors.transparent,
              side: const BorderSide(color: AppColors.border, width: 1),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              avatar: const Icon(Icons.school_outlined, size: 16, color: AppColors.primary),
              label: Text(
                category.name,
                style: GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.w600, color: AppColors.textPrimary),
              ),
            ),
          );
        },
      ),
    );
  }

  // --------------------------------------------------------------------------
  // 8. Revision Notes & PDFs
  // --------------------------------------------------------------------------
  Widget _buildCompactNotesList(List<dynamic> notes) {
    return SizedBox(
      height: 74,
      child: ListView.builder(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        scrollDirection: Axis.horizontal,
        physics: const BouncingScrollPhysics(),
        itemCount: notes.length,
        itemBuilder: (context, index) {
          final note = notes[index];
          return InkWell(
            onTap: () => Navigator.pushNamed(context, AppRoutes.content),
            borderRadius: BorderRadius.circular(12),
            child: Container(
              width: 170,
              margin: const EdgeInsets.only(right: 10),
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppColors.border, width: 1),
              ),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.teal.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Icon(Icons.description_rounded, color: Colors.teal, size: 20),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          note['name'] ?? 'Study Notes',
                          style: GoogleFonts.inter(fontWeight: FontWeight.w700, fontSize: 12, color: AppColors.textPrimary),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 2),
                        Text(
                          "PDF • Revision",
                          style: GoogleFonts.inter(fontSize: 9.5, color: AppColors.textMuted),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  // --------------------------------------------------------------------------
  // 9. Featured Courses List
  // --------------------------------------------------------------------------
  Widget _buildFeaturedCoursesList(List<CourseModel> courses) {
    return SizedBox(
      height: 155,
      child: ListView.builder(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        scrollDirection: Axis.horizontal,
        physics: const BouncingScrollPhysics(),
        itemCount: courses.length,
        itemBuilder: (context, index) {
          final course = courses[index];
          return InkWell(
            onTap: () {
              Navigator.pushNamed(context, AppRoutes.coursePreview, arguments: course);
            },
            borderRadius: BorderRadius.circular(14),
            child: Container(
              width: 180,
              margin: const EdgeInsets.only(right: 12),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: AppColors.border, width: 1),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    height: 80,
                    decoration: const BoxDecoration(
                      gradient: LinearGradient(
                        colors: [Color(0xFF2563EB), Color(0xFF4F46E5)],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.vertical(top: Radius.circular(13)),
                    ),
                    child: Center(
                      child: Icon(Icons.school_rounded, color: Colors.white.withOpacity(0.85), size: 36),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(10),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          course.name,
                          style: GoogleFonts.inter(fontWeight: FontWeight.w700, fontSize: 12.5, color: AppColors.textPrimary),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 3),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              "₹${course.price ?? '0'}",
                              style: GoogleFonts.outfit(
                                fontSize: 13,
                                fontWeight: FontWeight.w800,
                                color: AppColors.primary,
                              ),
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                              decoration: BoxDecoration(
                                color: AppColors.successLight,
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: const Text(
                                "ENROLL",
                                style: TextStyle(color: AppColors.success, fontSize: 8.5, fontWeight: FontWeight.w800),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  // --------------------------------------------------------------------------
  // Unified Section Header
  // --------------------------------------------------------------------------
  Widget _buildSectionTitle({
    required String title,
    required String subtitle,
    required IconData icon,
    required Color accentColor,
    VoidCallback? onViewAll,
  }) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(5),
            decoration: BoxDecoration(
              color: accentColor.withOpacity(0.12),
              borderRadius: BorderRadius.circular(7),
            ),
            child: Icon(icon, color: accentColor, size: 16),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: GoogleFonts.outfit(
                    fontSize: 15.5,
                    fontWeight: FontWeight.w800,
                    color: AppColors.textPrimary,
                    letterSpacing: -0.2,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                Text(
                  subtitle,
                  style: GoogleFonts.inter(
                    fontSize: 10.5,
                    fontWeight: FontWeight.w500,
                    color: AppColors.textMuted,
                  ),
                  maxLines: 1,
                ),
              ],
            ),
          ),
          if (onViewAll != null)
            InkWell(
              onTap: onViewAll,
              borderRadius: BorderRadius.circular(6),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      "View all",
                      style: GoogleFonts.inter(
                        color: AppColors.primary,
                        fontSize: 11.5,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(width: 2),
                    const Icon(Icons.arrow_forward_ios_rounded, size: 10, color: AppColors.primary),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }

  // --------------------------------------------------------------------------
  // Standard Switch Modal Bottom Sheet
  // --------------------------------------------------------------------------
  void _showStandardSelectionModal(BuildContext context, dynamic currentCourse) {
    final currentId = currentCourse != null ? currentCourse['id'] : null;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) {
        return Consumer(
          builder: (context, modalRef, child) {
            final allCoursesAsync = modalRef.watch(allCoursesProvider);

            return Container(
              constraints: BoxConstraints(
                maxHeight: MediaQuery.of(context).size.height * 0.70,
              ),
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
              ),
              padding: const EdgeInsets.fromLTRB(16, 14, 16, 20),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Center(
                    child: Container(
                      width: 40,
                      height: 4,
                      decoration: BoxDecoration(
                        color: AppColors.border,
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  ),
                  const SizedBox(height: 14),
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: AppColors.primaryLight,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: const Icon(Icons.school_rounded, color: AppColors.primary, size: 20),
                      ),
                      const SizedBox(width: 10),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "Switch Active Standard",
                            style: GoogleFonts.outfit(fontSize: 17, fontWeight: FontWeight.w800, color: AppColors.textPrimary),
                          ),
                          Text(
                            "Updates your subjects, videos & practice tests",
                            style: GoogleFonts.inter(color: AppColors.textMuted, fontSize: 11),
                          ),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 14),
                  const Divider(),
                  const SizedBox(height: 8),
                  Flexible(
                    child: allCoursesAsync.when(
                      data: (courses) {
                        if (courses.isEmpty) {
                          return const Center(child: Text("No courses available."));
                        }
                        return ListView.separated(
                          shrinkWrap: true,
                          itemCount: courses.length,
                          separatorBuilder: (_, __) => const SizedBox(height: 8),
                          itemBuilder: (context, index) {
                            final course = courses[index];
                            final isSelected = (course.id == currentId);

                            return InkWell(
                              onTap: () => _handleStandardSwitch(context, course.id, course.name),
                              borderRadius: BorderRadius.circular(12),
                              child: Container(
                                padding: const EdgeInsets.all(12),
                                decoration: BoxDecoration(
                                  color: isSelected ? AppColors.primaryLight : Colors.white,
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(
                                    color: isSelected ? AppColors.primary : AppColors.border,
                                    width: isSelected ? 1.5 : 1,
                                  ),
                                ),
                                child: Row(
                                  children: [
                                    Container(
                                      padding: const EdgeInsets.all(8),
                                      decoration: BoxDecoration(
                                        color: isSelected ? AppColors.primary : AppColors.cardSubtle,
                                        borderRadius: BorderRadius.circular(10),
                                      ),
                                      child: Icon(
                                        Icons.menu_book_rounded,
                                        color: isSelected ? Colors.white : AppColors.textSecondary,
                                        size: 18,
                                      ),
                                    ),
                                    const SizedBox(width: 10),
                                    Expanded(
                                      child: Text(
                                        course.name,
                                        style: GoogleFonts.inter(
                                          fontWeight: FontWeight.w700,
                                          fontSize: 14,
                                          color: isSelected ? AppColors.primary : AppColors.textPrimary,
                                        ),
                                      ),
                                    ),
                                    if (isSelected)
                                      Container(
                                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                                        decoration: BoxDecoration(
                                          color: AppColors.primary,
                                          borderRadius: BorderRadius.circular(6),
                                        ),
                                        child: const Text(
                                          "ACTIVE",
                                          style: TextStyle(color: Colors.white, fontSize: 9.5, fontWeight: FontWeight.w800),
                                        ),
                                      )
                                    else
                                      const Icon(Icons.arrow_forward_ios_rounded, size: 14, color: AppColors.textMuted),
                                  ],
                                ),
                              ),
                            );
                          },
                        );
                      },
                      loading: () => const Center(child: CircularProgressIndicator()),
                      error: (err, _) => Center(child: Text("Error: $err")),
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  Future<void> _handleStandardSwitch(BuildContext context, int courseId, String courseName) async {
    try {
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Switching standard to $courseName..."),
          duration: const Duration(seconds: 1),
          backgroundColor: AppColors.primary,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        ),
      );

      final authRepo = ref.read(authRepositoryProvider);
      await authRepo.switchCourse(courseId);

      ref.invalidate(homeDataProvider);
      ref.invalidate(myCoursesProvider);
      ref.invalidate(categoriesProvider);
      ref.invalidate(quizHubProvider);

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Active standard set to $courseName"),
          backgroundColor: AppColors.success,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        ),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Failed to switch standard: $e"),
          backgroundColor: AppColors.error,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        ),
      );
    }
  }

  Color _hexColor(String hex) {
    try {
      return Color(int.parse('FF${hex.replaceAll('#', '')}', radix: 16));
    } catch (_) {
      return AppColors.primary;
    }
  }
}
