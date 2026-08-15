import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:edustream/core/constants/app_colors.dart';
import 'package:edustream/features/explore/presentation/providers/explore_providers.dart';
import 'package:edustream/features/quiz/presentation/screens/quiz_attempt_screen.dart';
import 'package:edustream/features/auth/presentation/providers/auth_providers.dart';

class QuizListScreen extends ConsumerStatefulWidget {
  const QuizListScreen({super.key});

  @override
  ConsumerState<QuizListScreen> createState() => _QuizListScreenState();
}

class _QuizListScreenState extends ConsumerState<QuizListScreen> {
  // 3-Step Navigation State
  // Step 1 = Standard Selection (Big Icons: Primary 5-8, Secondary 9-10)
  // Step 2 = Subject Selection (Big Subject Cards)
  // Step 3 = Chapter / Quiz Selection (Chapter Tests with Start Quiz)
  int _currentStep = 1;

  Map<String, dynamic>? _selectedCourse;
  Map<String, dynamic>? _selectedSubject;
  String _chapterSearchQuery = '';
  final TextEditingController _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final quizHubAsync = ref.watch(quizHubProvider);
    final profileAsync = ref.watch(profileProvider);

    return PopScope(
      canPop: _currentStep == 1,
      onPopInvokedWithResult: (didPop, result) {
        if (!didPop) {
          setState(() {
            if (_currentStep == 3) {
              _currentStep = 2;
            } else if (_currentStep == 2) {
              _currentStep = 1;
            }
          });
        }
      },
      child: Scaffold(
        backgroundColor: const Color(0xFFF6F8FB),
        body: quizHubAsync.when(
          data: (categoriesJson) {
            if (categoriesJson.isEmpty) {
              return _buildEmptyState("No quizzes available yet", "Please check back later for practice tests!");
            }

            final categories = categoriesJson.cast<Map<String, dynamic>>();

            // Flatten all courses from all categories
            List<Map<String, dynamic>> allCourses = [];
            for (final cat in categories) {
              final cList = (cat['courses'] as List? ?? []).cast<Map<String, dynamic>>();
              for (final c in cList) {
                final cCopy = Map<String, dynamic>.from(c);
                cCopy['category_name'] = cat['name'];
                allCourses.add(cCopy);
              }
            }

            if (_currentStep == 1) {
              return _buildStep1StandardSelection(allCourses, profileAsync);
            } else if (_currentStep == 2) {
              return _buildStep2SubjectSelection();
            } else {
              return _buildStep3ChapterQuizList();
            }
          },
          loading: () => const Center(
            child: CircularProgressIndicator(color: AppColors.primary),
          ),
          error: (err, stack) => Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.error_outline_rounded, size: 48, color: Colors.redAccent),
                const SizedBox(height: 16),
                Text("Error loading quizzes:\n$err", textAlign: TextAlign.center),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: () => ref.refresh(quizHubProvider),
                  child: const Text("Retry"),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // ==========================================
  // STEP 1: SELECT STANDARD (Big Icons Hub)
  // Primary (5-8) & Secondary (9-10)
  // ==========================================
  Widget _buildStep1StandardSelection(List<Map<String, dynamic>> courses, AsyncValue<dynamic> profileAsync) {
    // Group courses into:
    // 1. Primary (Standards 5, 6, 7, 8)
    // 2. Secondary (Standards 9, 10)
    // 3. Higher Secondary & Competitive
    List<Map<String, dynamic>> primaryCourses = [];
    List<Map<String, dynamic>> secondaryCourses = [];
    List<Map<String, dynamic>> otherCourses = [];

    for (final course in courses) {
      final name = (course['name'] ?? '').toString().toLowerCase();
      if (name.contains('10') || name.contains('૧૦') || name.contains(' 9') || name.contains(' ૯') || name.contains('secondary') || name.contains('std 9') || name.contains('std 10') || name.contains('ધોરણ ૯') || name.contains('ધોરણ ૧૦')) {
        secondaryCourses.add(course);
      } else if (name.contains(' 5') || name.contains(' 6') || name.contains(' 7') || name.contains(' 8') || name.contains(' ૫') || name.contains(' ૬') || name.contains(' ૭') || name.contains(' ૮') || name.contains('primary') || name.contains('ધોરણ ૫') || name.contains('ધોરણ ૬') || name.contains('ધોરણ ૭') || name.contains('ધોરણ ૮')) {
        primaryCourses.add(course);
      } else {
        otherCourses.add(course);
      }
    }

    // Sort Secondary: 9 first, then 10 (or vice versa)
    secondaryCourses.sort((a, b) => (a['name'] ?? '').toString().compareTo((b['name'] ?? '').toString()));
    primaryCourses.sort((a, b) => (a['name'] ?? '').toString().compareTo((b['name'] ?? '').toString()));

    return CustomScrollView(
      physics: const BouncingScrollPhysics(),
      slivers: [
        SliverToBoxAdapter(
          child: _buildHeaderBanner(
            title: "Quiz Hub • ક્વિઝ હબ",
            subtitle: "Select your Standard to practice chapter-wise MCQs",
            stepText: "Step 1 of 3: Select Standard",
          ),
        ),

        // SECTION 1: SECONDARY (Std 9 & 10)
        if (secondaryCourses.isNotEmpty) ...[
          SliverToBoxAdapter(
            child: _buildSectionHeader(
              "માધ્યમિક વિભાગ (Secondary • Std 9 & 10)",
              "Board & Secondary curriculum quizzes",
              Icons.school_rounded,
              const Color(0xFF1E3A8A),
            ),
          ),
          SliverPadding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            sliver: SliverGrid(
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                childAspectRatio: 1.15,
                crossAxisSpacing: 14,
                mainAxisSpacing: 14,
              ),
              delegate: SliverChildBuilderDelegate(
                (context, index) {
                  final course = secondaryCourses[index];
                  return _buildBigStandardCard(course, isSecondary: true);
                },
                childCount: secondaryCourses.length,
              ),
            ),
          ),
          const SliverToBoxAdapter(child: SizedBox(height: 24)),
        ],

        // SECTION 2: PRIMARY (Std 5 to 8)
        if (primaryCourses.isNotEmpty) ...[
          SliverToBoxAdapter(
            child: _buildSectionHeader(
              "પ્રાથમિક વિભાગ (Primary • Std 5 to 8)",
              "Primary standard daily tests & quizzes",
              Icons.child_care_rounded,
              const Color(0xFFD97706),
            ),
          ),
          SliverPadding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            sliver: SliverGrid(
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                childAspectRatio: 1.15,
                crossAxisSpacing: 14,
                mainAxisSpacing: 14,
              ),
              delegate: SliverChildBuilderDelegate(
                (context, index) {
                  final course = primaryCourses[index];
                  return _buildBigStandardCard(course, isSecondary: false);
                },
                childCount: primaryCourses.length,
              ),
            ),
          ),
          const SliverToBoxAdapter(child: SizedBox(height: 24)),
        ],

        // SECTION 3: OTHER / COMPETITIVE
        if (otherCourses.isNotEmpty) ...[
          SliverToBoxAdapter(
            child: _buildSectionHeader(
              "સ્પર્ધાત્મક & અન્ય કોર્સ (Competitive & Special)",
              "Scholarships, Entrance & Special exams",
              Icons.stars_rounded,
              const Color(0xFF059669),
            ),
          ),
          SliverPadding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            sliver: SliverGrid(
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                childAspectRatio: 1.15,
                crossAxisSpacing: 14,
                mainAxisSpacing: 14,
              ),
              delegate: SliverChildBuilderDelegate(
                (context, index) {
                  final course = otherCourses[index];
                  return _buildBigStandardCard(course, isSecondary: false);
                },
                childCount: otherCourses.length,
              ),
            ),
          ),
        ],

        const SliverToBoxAdapter(child: SizedBox(height: 40)),
      ],
    );
  }

  Widget _buildBigStandardCard(Map<String, dynamic> course, {required bool isSecondary}) {
    final name = (course['name'] ?? 'Standard').toString();
    final subjects = (course['subjects'] as List? ?? []).cast<Map<String, dynamic>>();

    int totalQuizzes = 0;
    for (final s in subjects) {
      final qList = (s['quizzes'] as List? ?? []);
      totalQuizzes += qList.length;
    }

    // Extract standard digit or initials
    String standardBadge = "Std";
    final RegExp digitRegex = RegExp(r'(\d+)');
    final match = digitRegex.firstMatch(name);
    if (match != null) {
      standardBadge = match.group(0)!;
    } else if (name.length > 3) {
      standardBadge = name.substring(0, 3).toUpperCase();
    }

    final gradientColors = isSecondary
        ? (standardBadge == "10" 
            ? [const Color(0xFF1E3A8A), const Color(0xFF3B82F6)] 
            : [const Color(0xFF4C1D95), const Color(0xFF8B5CF6)])
        : (int.tryParse(standardBadge) != null && int.parse(standardBadge) >= 7
            ? [const Color(0xFFB45309), const Color(0xFFF59E0B)]
            : [const Color(0xFF047857), const Color(0xFF10B981)]);

    return InkWell(
      onTap: () {
        setState(() {
          _selectedCourse = course;
          _selectedSubject = null;
          _currentStep = 2; // Move to Subject Selection
        });
      },
      borderRadius: BorderRadius.circular(20),
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: gradientColors[0].withValues(alpha: 0.25), width: 1.5),
          boxShadow: [
            BoxShadow(
              color: gradientColors[0].withValues(alpha: 0.08),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // Big Round Standard Numeral Badge
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: gradientColors,
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: gradientColors[0].withValues(alpha: 0.3),
                        blurRadius: 8,
                        offset: const Offset(0, 3),
                      ),
                    ],
                  ),
                  child: Center(
                    child: Text(
                      standardBadge,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: gradientColors[0].withValues(alpha: 0.08),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Text(
                    "${subjects.length} Sub",
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                      color: gradientColors[0],
                    ),
                  ),
                ),
              ],
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w800,
                    color: Color(0xFF1A1A2E),
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 2),
                Row(
                  children: [
                    Icon(Icons.quiz_outlined, size: 13, color: Colors.grey[600]),
                    const SizedBox(width: 4),
                    Text(
                      "$totalQuizzes Quizzes",
                      style: TextStyle(fontSize: 11, color: Colors.grey[600], fontWeight: FontWeight.w600),
                    ),
                    const Spacer(),
                    Icon(Icons.arrow_forward_ios_rounded, size: 13, color: gradientColors[0]),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  // ==========================================
  // STEP 2: SELECT SUBJECT (Big Subject Cards)
  // ==========================================
  Widget _buildStep2SubjectSelection() {
    final course = _selectedCourse ?? {};
    final courseName = (course['name'] ?? 'Standard').toString();
    final subjects = (course['subjects'] as List? ?? []).cast<Map<String, dynamic>>();

    return CustomScrollView(
      physics: const BouncingScrollPhysics(),
      slivers: [
        SliverToBoxAdapter(
          child: _buildNavigationHeader(
            title: courseName,
            subtitle: "Select Subject to view Chapter Quizzes",
            stepText: "Step 2 of 3: Select Subject",
            onBack: () {
              setState(() {
                _currentStep = 1;
              });
            },
          ),
        ),

        if (subjects.isEmpty)
          const SliverFillRemaining(
            hasScrollBody: false,
            child: Center(
              child: Text("No subjects found for this standard."),
            ),
          )
        else
          SliverPadding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            sliver: SliverGrid(
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                childAspectRatio: 1.1,
                crossAxisSpacing: 14,
                mainAxisSpacing: 14,
              ),
              delegate: SliverChildBuilderDelegate(
                (context, index) {
                  final subject = subjects[index];
                  return _buildBigSubjectCard(subject);
                },
                childCount: subjects.length,
              ),
            ),
          ),

        const SliverToBoxAdapter(child: SizedBox(height: 40)),
      ],
    );
  }

  Widget _buildBigSubjectCard(Map<String, dynamic> subject) {
    final subName = (subject['name'] ?? 'Subject').toString();
    final quizzes = (subject['quizzes'] as List? ?? []).cast<Map<String, dynamic>>();

    final colorHex = (subject['color_code'] ?? subject['color'] ?? '#1565C0').toString();
    Color subColor;
    try {
      subColor = Color(int.parse(colorHex.replaceAll('#', '0xFF')));
    } catch (_) {
      subColor = AppColors.primary;
    }

    return InkWell(
      onTap: () {
        setState(() {
          _selectedSubject = subject;
          _chapterSearchQuery = '';
          _searchController.clear();
          _currentStep = 3; // Move to Chapter Quiz List
        });
      },
      borderRadius: BorderRadius.circular(20),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: subColor.withValues(alpha: 0.25), width: 1.5),
          boxShadow: [
            BoxShadow(
              color: subColor.withValues(alpha: 0.08),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  width: 46,
                  height: 46,
                  decoration: BoxDecoration(
                    color: subColor.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Center(
                    child: Icon(
                      _getSubjectIcon(subName),
                      color: subColor,
                      size: 26,
                    ),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: subColor.withValues(alpha: 0.08),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    "${quizzes.length} Tests",
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                      color: subColor,
                    ),
                  ),
                ),
              ],
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  subName,
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w800,
                    color: Color(0xFF1A1A2E),
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 2),
                Row(
                  children: [
                    Text(
                      "Explore Chapters",
                      style: TextStyle(fontSize: 11, color: Colors.grey[600], fontWeight: FontWeight.w500),
                    ),
                    const Spacer(),
                    Icon(Icons.arrow_forward_ios_rounded, size: 12, color: subColor),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  // ==========================================
  // STEP 3: CHAPTER / QUIZ TESTS LIST
  // ==========================================
  Widget _buildStep3ChapterQuizList() {
    final course = _selectedCourse ?? {};
    final subject = _selectedSubject ?? {};
    final courseName = (course['name'] ?? 'Standard').toString();
    final subName = (subject['name'] ?? 'Subject').toString();
    final quizzes = (subject['quizzes'] as List? ?? []).cast<Map<String, dynamic>>();

    final colorHex = (subject['color_code'] ?? subject['color'] ?? '#1565C0').toString();
    Color subColor;
    try {
      subColor = Color(int.parse(colorHex.replaceAll('#', '0xFF')));
    } catch (_) {
      subColor = AppColors.primary;
    }

    final filteredQuizzes = quizzes.where((q) {
      if (_chapterSearchQuery.trim().isEmpty) return true;
      final title = (q['title'] ?? q['name'] ?? '').toString().toLowerCase();
      return title.contains(_chapterSearchQuery.toLowerCase());
    }).toList();

    return CustomScrollView(
      physics: const BouncingScrollPhysics(),
      slivers: [
        SliverToBoxAdapter(
          child: _buildNavigationHeader(
            title: "$subName Tests",
            subtitle: "$courseName • ${quizzes.length} Chapter Quizzes",
            stepText: "Step 3 of 3: Select Chapter Test",
            onBack: () {
              setState(() {
                _currentStep = 2;
              });
            },
          ),
        ),

        // Search Bar for Chapters
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
            child: TextField(
              controller: _searchController,
              onChanged: (val) => setState(() => _chapterSearchQuery = val),
              decoration: InputDecoration(
                hintText: "Search Chapter / Test name...",
                prefixIcon: const Icon(Icons.search, color: AppColors.primary),
                suffixIcon: _chapterSearchQuery.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear),
                        onPressed: () {
                          _searchController.clear();
                          setState(() => _chapterSearchQuery = '');
                        },
                      )
                    : null,
                filled: true,
                fillColor: Colors.white,
                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: BorderSide(color: Colors.grey[200]!),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: BorderSide(color: Colors.grey[200]!),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: const BorderSide(color: AppColors.primary, width: 1.5),
                ),
              ),
            ),
          ),
        ),

        if (filteredQuizzes.isEmpty)
          SliverFillRemaining(
            hasScrollBody: false,
            child: _buildEmptyState("No chapter tests found", "Try searching with different keywords!"),
          )
        else
          SliverPadding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            sliver: SliverList(
              delegate: SliverChildBuilderDelegate(
                (context, index) {
                  final quiz = filteredQuizzes[index];
                  return _buildChapterQuizCard(quiz, index + 1, subColor);
                },
                childCount: filteredQuizzes.length,
              ),
            ),
          ),

        const SliverToBoxAdapter(child: SizedBox(height: 40)),
      ],
    );
  }

  Widget _buildChapterQuizCard(Map<String, dynamic> quiz, int index, Color themeColor) {
    final title = (quiz['title'] ?? quiz['name'] ?? 'Chapter Test').toString();
    final questionCount = quiz['questions_count'] ?? (quiz['questions'] as List? ?? []).length;
    final duration = quiz['duration_minutes'] ?? quiz['duration'] ?? 20;
    final marks = quiz['total_marks'] ?? (questionCount > 0 ? questionCount : 25);
    final quizId = quiz['id'] is int ? quiz['id'] : (int.tryParse(quiz['id'].toString()) ?? 1);

    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: Colors.grey[200]!),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: themeColor.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    "Chapter $index",
                    style: TextStyle(
                      color: themeColor,
                      fontWeight: FontWeight.w800,
                      fontSize: 11,
                    ),
                  ),
                ),
                const Spacer(),
                Row(
                  children: [
                    Icon(Icons.timer_outlined, size: 14, color: Colors.grey[600]),
                    const SizedBox(width: 4),
                    Text(
                      "$duration Mins",
                      style: TextStyle(fontSize: 12, color: Colors.grey[600], fontWeight: FontWeight.w600),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 10),
            Text(
              title,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w800,
                color: Color(0xFF1A1A2E),
              ),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                _buildQuizInfoPill(Icons.help_outline_rounded, "$questionCount MCQs"),
                const SizedBox(width: 10),
                _buildQuizInfoPill(Icons.emoji_events_outlined, "$marks Marks"),
                const Spacer(),
                ElevatedButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => QuizAttemptScreen(quizId: quizId),
                      ),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: themeColor,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    elevation: 2,
                  ),
                  child: const Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text("Start Quiz", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                      SizedBox(width: 4),
                      Icon(Icons.play_arrow_rounded, size: 18),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildQuizInfoPill(IconData icon, String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.grey[100],
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 13, color: Colors.grey[700]),
          const SizedBox(width: 4),
          Text(
            text,
            style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Colors.grey[700]),
          ),
        ],
      ),
    );
  }

  // ==========================================
  // SHARED HEADER HELPERS
  // ==========================================
  Widget _buildHeaderBanner({required String title, required String subtitle, required String stepText}) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.fromLTRB(16, 16, 16, 16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF1E3A8A), Color(0xFF2563EB)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF1E3A8A).withValues(alpha: 0.3),
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              stepText,
              style: const TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.bold),
            ),
          ),
          const SizedBox(height: 12),
          Text(
            title,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 22,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            subtitle,
            style: TextStyle(
              color: Colors.white.withValues(alpha: 0.85),
              fontSize: 13,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNavigationHeader({
    required String title,
    required String subtitle,
    required String stepText,
    required VoidCallback onBack,
  }) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.fromLTRB(16, 16, 16, 16),
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF1E3A8A), Color(0xFF2563EB)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF1E3A8A).withValues(alpha: 0.3),
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              InkWell(
                onTap: onBack,
                borderRadius: BorderRadius.circular(12),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.arrow_back_ios_new_rounded, color: Colors.white, size: 14),
                      SizedBox(width: 6),
                      Text(
                        "Back",
                        style: TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                ),
              ),
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  stepText,
                  style: const TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.bold),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Text(
            title,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            subtitle,
            style: TextStyle(
              color: Colors.white.withValues(alpha: 0.85),
              fontSize: 13,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title, String subtitle, IconData icon, Color color) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(18, 12, 18, 12),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: color, size: 20),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: Color(0xFF1A1A2E)),
                ),
                Text(
                  subtitle,
                  style: TextStyle(fontSize: 11, color: Colors.grey[600]),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState(String title, String subtitle) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.quiz_outlined, size: 64, color: Colors.grey),
            const SizedBox(height: 16),
            Text(
              title,
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF1A1A2E)),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 6),
            Text(
              subtitle,
              style: TextStyle(fontSize: 13, color: Colors.grey[600]),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  IconData _getSubjectIcon(String name) {
    final lower = name.toLowerCase();
    if (lower.contains('math') || lower.contains('ગણિત')) {
      return Icons.calculate_rounded;
    } else if (lower.contains('sci') || lower.contains('વિજ્ઞાન')) {
      return Icons.biotech_rounded;
    } else if (lower.contains('eng') || lower.contains('અંગ્રેજી')) {
      return Icons.translate_rounded;
    } else if (lower.contains('soc') || lower.contains('સમાજ') || lower.contains('સામાજિક')) {
      return Icons.public_rounded;
    } else if (lower.contains('guj') || lower.contains('ગુજરાતી')) {
      return Icons.menu_book_rounded;
    } else if (lower.contains('san') || lower.contains('સંસ્કૃત')) {
      return Icons.auto_stories_rounded;
    } else if (lower.contains('hindi') || lower.contains('હિન્દી')) {
      return Icons.history_edu_rounded;
    }
    return Icons.school_rounded;
  }
}
