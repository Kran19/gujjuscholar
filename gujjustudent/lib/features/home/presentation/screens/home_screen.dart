import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:edustream/core/constants/app_colors.dart';
import 'package:edustream/features/explore/presentation/providers/explore_providers.dart';
import 'package:edustream/features/explore/data/models/explore_models.dart';
import 'package:edustream/features/explore/data/models/explore_subjects.dart';
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
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, stack) => Center(child: Text("Error: $err")),
      ),
    );
  }

  Widget _buildContent(BuildContext context, Map<String, dynamic> data) {
    final categories = (data['categories'] as List).map((e) => CategoryModel.fromJson(e)).toList();
    final featuredCourses = (data['featured_courses'] as List).map((e) => CourseModel.fromJson(e)).toList();
    final banners = (data['banners'] as List?)?.map((e) => BannerModel.fromJson(e)).toList() ?? [];
    
    // Personalized Data
    final recommendedCourse = data['recommended_course'];
    final personalizedSubjects = recommendedCourse != null ? (recommendedCourse['subjects'] as List).map((e) => SubjectModel.fromJson(e)).toList() : <SubjectModel>[];
    final personalizedVideos = data['personalized_videos'] as List? ?? [];
    final personalizedNotes = data['personalized_notes'] as List? ?? [];
    final personalizedQuizzes = data['personalized_quizzes'] as List? ?? [];

    return CustomScrollView(
      physics: const BouncingScrollPhysics(),
      slivers: [
        _buildHeader(),
        _buildBanners(banners),
        SliverToBoxAdapter(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (personalizedSubjects.isNotEmpty) ...[
                _buildSectionTitle("${recommendedCourse['name']} Subjects", Icons.auto_stories_rounded, Colors.indigo),
                _buildPersonalizedSubjectsList(personalizedSubjects),
              ],

              if (personalizedVideos.isNotEmpty) ...[
                _buildSectionTitle("Recent Videos", Icons.play_circle_fill_rounded, Colors.redAccent),
                _buildPersonalizedVideosList(personalizedVideos),
              ],

              if (personalizedQuizzes.isNotEmpty) ...[
                _buildSectionTitle("Practice Quizzes", Icons.quiz_rounded, Colors.teal),
                _buildPersonalizedQuizzesList(personalizedQuizzes),
              ],

              _buildSectionTitle("Categories", Icons.category_rounded, Colors.blue),
              _buildCategoriesList(categories),

              if (personalizedNotes.isNotEmpty) ...[
                _buildSectionTitle("Study Notes", Icons.description_rounded, Colors.amber[800]!),
                _buildPersonalizedNotesList(personalizedNotes),
              ],

              _buildSectionTitle("Featured Courses", Icons.star_rounded, Colors.orange),
              _buildFeaturedCoursesList(featuredCourses),
              const SizedBox(height: 40),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildPersonalizedSubjectsList(List<SubjectModel> subjects) {
    return SizedBox(
      height: 140,
      child: ListView.builder(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        scrollDirection: Axis.horizontal,
        itemCount: subjects.length,
        itemBuilder: (context, index) {
          final subject = subjects[index];
          return _buildSubjectCardPersonalized(subject);
        },
      ),
    );
  }

  Widget _buildSubjectCardPersonalized(SubjectModel subject) {
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
      borderRadius: BorderRadius.circular(24),
      child: Container(
        width: 120,
        margin: const EdgeInsets.only(right: 16),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: subject.color.withOpacity(0.15),
                borderRadius: BorderRadius.circular(24),
                border: Border.all(color: subject.color.withOpacity(0.2), width: 1.5),
              ),
              child: Icon(subject.icon, color: subject.color, size: 32),
            ),
            const SizedBox(height: 12),
            Text(
              subject.name,
              style: GoogleFonts.inter(fontWeight: FontWeight.w700, fontSize: 13, color: const Color(0xFF1A1A2E)),
              textAlign: TextAlign.center,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            Text(
              "Explore",
              style: GoogleFonts.inter(fontSize: 10, color: AppColors.grey, fontWeight: FontWeight.w500),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPersonalizedVideosList(List<dynamic> videos) {
    return SizedBox(
      height: 190,
      child: ListView.builder(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        scrollDirection: Axis.horizontal,
        itemCount: videos.length,
        itemBuilder: (context, index) {
          final video = videos[index];
          return _buildVideoCard(video);
        },
      ),
    );
  }

  Widget _buildVideoCard(dynamic video) {
    return InkWell(
      onTap: () {
        Navigator.pushNamed(context, AppRoutes.videoPlayer);
      },
      borderRadius: BorderRadius.circular(24),
      child: Container(
        width: 240,
        margin: const EdgeInsets.only(right: 16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(color: Colors.black.withOpacity(0.06), blurRadius: 15, offset: const Offset(0, 5)),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              height: 120,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [Colors.grey[300]!, Colors.grey[100]!],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
                image: video['thumbnail_url'] != null ? DecorationImage(
                  image: NetworkImage(video['thumbnail_url']),
                  fit: BoxFit.cover,
                ) : null,
              ),
              child: Center(
                child: Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.9),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.play_arrow_rounded, color: Colors.redAccent, size: 30),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    video['name'] ?? 'Video Lesson',
                    style: GoogleFonts.inter(fontWeight: FontWeight.w700, fontSize: 14, color: const Color(0xFF1A1A2E)),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  Text(
                    video['duration'] ?? '12:45 mins',
                    style: GoogleFonts.inter(fontSize: 11, color: AppColors.grey),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPersonalizedNotesList(List<dynamic> notes) {
    return SizedBox(
      height: 120,
      child: ListView.builder(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        scrollDirection: Axis.horizontal,
        itemCount: notes.length,
        itemBuilder: (context, index) {
          final note = notes[index];
          return _buildNoteCard(note);
        },
      ),
    );
  }

  Widget _buildNoteCard(dynamic note) {
    return InkWell(
      onTap: () {
        Navigator.pushNamed(context, AppRoutes.content);
      },
      borderRadius: BorderRadius.circular(20),
      child: Container(
        width: 160,
        margin: const EdgeInsets.only(right: 16),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: Colors.grey[200]!),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.amber[50],
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(Icons.description_rounded, color: Colors.amber[800], size: 24),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    note['name'] ?? 'Notes',
                    style: GoogleFonts.inter(fontWeight: FontWeight.w700, fontSize: 13, color: const Color(0xFF1A1A2E)),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  Text(
                    "PDF • 2.4 MB",
                    style: GoogleFonts.inter(fontSize: 10, color: AppColors.grey),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPersonalizedQuizzesList(List<dynamic> quizzes) {
    return SizedBox(
      height: 130,
      child: ListView.builder(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        scrollDirection: Axis.horizontal,
        itemCount: quizzes.length,
        itemBuilder: (context, index) {
          final quiz = quizzes[index];
          return _buildQuizCard(quiz);
        },
      ),
    );
  }

  Widget _buildQuizCard(dynamic quiz) {
    return InkWell(
      onTap: () {
        Navigator.pushNamed(
          context,
          AppRoutes.quizAttempt,
          arguments: quiz['id'],
        );
      },
      borderRadius: BorderRadius.circular(24),
      child: Container(
        width: 180,
        margin: const EdgeInsets.only(right: 16),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.teal[700]!, Colors.teal[500]!],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(color: Colors.teal.withOpacity(0.3), blurRadius: 10, offset: const Offset(0, 4)),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              quiz['title'] ?? 'Quiz',
              style: GoogleFonts.inter(color: Colors.white, fontWeight: FontWeight.w800, fontSize: 14),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 4),
            Text(
              "${quiz['questions_count'] ?? 0} Questions",
              style: TextStyle(color: Colors.white.withOpacity(0.8), fontSize: 11),
            ),
            const Spacer(),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                "Start Now",
                style: TextStyle(color: Colors.teal[700], fontWeight: FontWeight.bold, fontSize: 11),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return SliverPadding(
      padding: const EdgeInsets.fromLTRB(24, 60, 24, 20),
      sliver: SliverToBoxAdapter(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Hi Learner 👋",
                      style: GoogleFonts.inter(
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                        color: AppColors.darkGrey,
                      ),
                    ),
                    Text(
                      "EduStream Hub",
                      style: GoogleFonts.inter(
                        fontSize: 28,
                        fontWeight: FontWeight.w900,
                        color: const Color(0xFF1A1A2E),
                        letterSpacing: -0.5,
                      ),
                    ),
                  ],
                ),
                const Spacer(),
                const Icon(Icons.notifications_none_rounded, color: AppColors.primary),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title, IconData icon, Color color) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 24, 24, 16),
      child: Row(
        children: [
          Icon(icon, color: color, size: 22),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              title,
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          const SizedBox(width: 10),
          GestureDetector(
            onTap: () {
              if (title == "Categories") {
                Navigator.pushNamed(context, AppRoutes.explore);
              } else if (title.contains("Quizzes")) {
                Navigator.pushNamed(context, AppRoutes.quizList);
              } else {
                // Default to explore for subjects/courses
                Navigator.pushNamed(context, AppRoutes.explore);
              }
            },
            child: const Text("View All", style: TextStyle(color: AppColors.primary, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  Widget _buildBanners(List<BannerModel> banners) {
    if (banners.isEmpty) return const SliverToBoxAdapter(child: SizedBox.shrink());
    
    return SliverToBoxAdapter(
      child: Padding(
        padding: const EdgeInsets.only(bottom: 24.0),
        child: CarouselSlider(
          options: CarouselOptions(
            height: 180.0,
            autoPlay: banners.length > 1,
            enlargeCenterPage: true,
            autoPlayCurve: Curves.fastOutSlowIn,
            enableInfiniteScroll: banners.length > 1,
            autoPlayAnimationDuration: const Duration(milliseconds: 800),
            viewportFraction: 0.85,
          ),
          items: banners.map((banner) {
            final colorStart = _hexColor(banner.colorStart);
            final colorEnd = _hexColor(banner.colorEnd);
            return Builder(
              builder: (BuildContext context) {
                return Container(
                  width: MediaQuery.of(context).size.width,
                  margin: const EdgeInsets.symmetric(horizontal: 5.0),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [colorStart, colorEnd],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: colorStart.withOpacity(0.4),
                        blurRadius: 12,
                        offset: const Offset(0, 5),
                      ),
                    ],
                  ),
                  child: Stack(
                    children: [
                      Positioned(
                        right: -10,
                        bottom: -10,
                        child: Icon(
                          Icons.school_rounded,
                          size: 110,
                          color: Colors.white.withOpacity(0.1),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(20),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.local_fire_department_rounded, color: Colors.white.withOpacity(0.9), size: 28),
                            const SizedBox(height: 8),
                            Text(
                              banner.title,
                              style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
                            ),
                            if (banner.subtitle != null && banner.subtitle!.isNotEmpty)
                              Text(
                                banner.subtitle!,
                                style: TextStyle(color: Colors.white.withOpacity(0.85), fontSize: 13),
                              ),
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

  Color _hexColor(String hex) {
    try {
      return Color(int.parse('FF${hex.replaceAll('#', '')}', radix: 16));
    } catch (_) {
      return AppColors.primary;
    }
  }

  Widget _buildCategoriesList(List<CategoryModel> categories) {
    return SizedBox(
      height: 120,
      child: ListView.builder(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        scrollDirection: Axis.horizontal,
        itemCount: categories.length,
        itemBuilder: (context, index) {
          final category = categories[index];
          return _buildCategoryCard(category);
        },
      ),
    );
  }

  Widget _buildCategoryCard(CategoryModel category) {
    return InkWell(
      onTap: () {
        Navigator.pushNamed(
          context,
          AppRoutes.standardDetail,
          arguments: category,
        );
      },
      borderRadius: BorderRadius.circular(50),
      child: Container(
        width: 100,
        margin: const EdgeInsets.only(right: 16),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.primary.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.school, color: AppColors.primary),
            ),
            const SizedBox(height: 8),
            Text(
              category.name,
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
              textAlign: TextAlign.center,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFeaturedCoursesList(List<CourseModel> courses) {
    return SizedBox(
      height: 200,
      child: ListView.builder(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        scrollDirection: Axis.horizontal,
        itemCount: courses.length,
        itemBuilder: (context, index) {
          final course = courses[index];
          return _buildCourseCard(course);
        },
      ),
    );
  }

  Widget _buildCourseCard(CourseModel course) {
    return InkWell(
      onTap: () {
        Navigator.pushNamed(
          context,
          AppRoutes.coursePreview,
          arguments: course,
        );
      },
      borderRadius: BorderRadius.circular(20),
      child: Container(
        width: 200,
        margin: const EdgeInsets.only(right: 16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              height: 100,
              decoration: BoxDecoration(
                color: Colors.grey[200],
                borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
              ),
              child: const Center(child: Icon(Icons.image, color: Colors.grey)),
            ),
            Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(course.name, style: const TextStyle(fontWeight: FontWeight.bold), maxLines: 1, overflow: TextOverflow.ellipsis),
                  const SizedBox(height: 4),
                  Text("Price: ₹${course.price ?? '0'}", style: const TextStyle(color: AppColors.primary, fontWeight: FontWeight.bold)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
