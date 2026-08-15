import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:edustream/core/constants/app_colors.dart';
import 'package:edustream/features/explore/presentation/providers/explore_providers.dart';
import 'package:edustream/features/quiz/presentation/widgets/quiz_card.dart';
import 'package:edustream/features/quiz/data/models/quiz_model.dart';
import 'package:edustream/features/quiz/presentation/screens/quiz_attempt_screen.dart';
import 'package:edustream/features/auth/presentation/providers/auth_providers.dart';

class QuizListScreen extends ConsumerStatefulWidget {
  const QuizListScreen({super.key});

  @override
  ConsumerState<QuizListScreen> createState() => _QuizListScreenState();
}

class _QuizListScreenState extends ConsumerState<QuizListScreen> {
  int? _selectedCategoryId;
  int? _selectedCourseId;
  int? _selectedSubjectId;
  String _searchQuery = '';
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
    final recommendedCourseAsync = ref.watch(recommendedCourseProvider);

    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      body: quizHubAsync.when(
        data: (categoriesJson) {
          if (categoriesJson.isEmpty) {
            return _buildEmptyState("No quizzes available yet", "Check back later for new tests!");
          }

          final categories = categoriesJson.cast<Map<String, dynamic>>();

          // Auto-select initial Category and Course (Standard)
          _initializeSelection(categories, profileAsync, recommendedCourseAsync);

          // Find current selected Category
          final currentCategory = categories.firstWhere(
            (c) => c['id'] == _selectedCategoryId,
            orElse: () => categories.first,
          );

          final courses = (currentCategory['courses'] as List? ?? []).cast<Map<String, dynamic>>();

          // Find current selected Course / Standard
          final currentCourse = courses.firstWhere(
            (c) => c['id'] == _selectedCourseId,
            orElse: () => courses.isNotEmpty ? courses.first : <String, dynamic>{},
          );

          final subjects = (currentCourse['subjects'] as List? ?? []).cast<Map<String, dynamic>>();

          // Collect quizzes for the selected Course (Standard)
          List<Map<String, dynamic>> filteredQuizzes = [];
          for (final sub in subjects) {
            if (_selectedSubjectId != null && sub['id'] != _selectedSubjectId) {
              continue;
            }
            final qList = (sub['quizzes'] as List? ?? []).cast<Map<String, dynamic>>();
            for (final q in qList) {
              final Map<String, dynamic> qCopy = Map<String, dynamic>.from(q);
              qCopy['subject_name'] = sub['name'];
              qCopy['standard_name'] = currentCourse['name'];
              
              if (_searchQuery.trim().isNotEmpty) {
                final qTitle = (qCopy['title'] ?? qCopy['name'] ?? '').toString().toLowerCase();
                final subName = (sub['name'] ?? '').toString().toLowerCase();
                if (!qTitle.contains(_searchQuery.toLowerCase()) && !subName.contains(_searchQuery.toLowerCase())) {
                  continue;
                }
              }
              filteredQuizzes.add(qCopy);
            }
          }

          return CustomScrollView(
            physics: const BouncingScrollPhysics(),
            slivers: [
              // Hero Banner
              SliverToBoxAdapter(
                child: _buildHeroBanner(),
              ),

              // Category Selector (if multiple boards/categories exist)
              if (categories.length > 1)
                SliverToBoxAdapter(
                  child: _buildCategorySelector(categories),
                ),

              // Standard Selector Bar (Direct 1-Tap Access)
              if (courses.isNotEmpty)
                SliverToBoxAdapter(
                  child: _buildStandardSelector(courses),
                ),

              // Subject Filter Pills & Search
              if (subjects.isNotEmpty)
                SliverToBoxAdapter(
                  child: _buildSubjectSelector(subjects, currentCourse['name'] ?? 'Standard'),
                ),

              // Quizzes Count Header
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(20, 16, 20, 12),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        "${currentCourse['name'] ?? 'Selected Standard'} Tests",
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w800,
                          color: Color(0xFF1A1A2E),
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: AppColors.primary.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          "${filteredQuizzes.length} Available",
                          style: const TextStyle(
                            color: AppColors.primary,
                            fontSize: 12,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              // Quiz Cards List
              if (filteredQuizzes.isEmpty)
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.all(40.0),
                    child: Center(
                      child: Column(
                        children: [
                          Icon(Icons.assignment_outlined, size: 56, color: Colors.grey[400]),
                          const SizedBox(height: 12),
                          Text(
                            _searchQuery.isNotEmpty ? "No matching quizzes found" : "No quizzes for this standard yet",
                            style: const TextStyle(color: Colors.grey, fontSize: 16, fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(height: 6),
                          const Text(
                            "Select another subject or standard from the top bar.",
                            style: TextStyle(color: Colors.grey, fontSize: 13),
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
                    ),
                  ),
                )
              else
                SliverPadding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  sliver: SliverList(
                    delegate: SliverChildBuilderDelegate(
                      (context, index) {
                        final qJson = filteredQuizzes[index];
                        final quiz = QuizModel.fromJson(qJson);
                        return QuizCard(
                          quiz: quiz,
                          onStart: () => Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => QuizAttemptScreen(quizId: int.tryParse(quiz.id) ?? 0),
                            ),
                          ),
                        );
                      },
                      childCount: filteredQuizzes.length,
                    ),
                  ),
                ),

              const SliverToBoxAdapter(
                child: SizedBox(height: 40),
              ),
            ],
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, stack) => Center(
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.error_outline, color: Colors.red, size: 48),
                const SizedBox(height: 12),
                Text("Failed to load quizzes: $err", textAlign: TextAlign.center),
                const SizedBox(height: 12),
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

  void _initializeSelection(
    List<Map<String, dynamic>> categories, 
    AsyncValue<Map<String, dynamic>> profileAsync,
    AsyncValue<dynamic> recommendedCourseAsync,
  ) {
    if (_selectedCategoryId != null && _selectedCourseId != null) return;

    int? userCourseId;
    final profileData = profileAsync.value;
    if (profileData != null) {
      userCourseId = profileData['course_id'] ?? profileData['student']?['course_id'];
    }
    userCourseId ??= recommendedCourseAsync.value?.id;

    // Try to match student's enrolled course across categories
    if (userCourseId != null) {
      for (final cat in categories) {
        final courses = (cat['courses'] as List? ?? []).cast<Map<String, dynamic>>();
        for (final c in courses) {
          if (c['id'] == userCourseId) {
            _selectedCategoryId = cat['id'];
            _selectedCourseId = c['id'];
            return;
          }
        }
      }
    }

    // Default to first available category and course
    if (_selectedCategoryId == null && categories.isNotEmpty) {
      _selectedCategoryId = categories.first['id'];
      final courses = (categories.first['courses'] as List? ?? []).cast<Map<String, dynamic>>();
      if (courses.isNotEmpty) {
        _selectedCourseId = courses.first['id'];
      }
    }
  }

  Widget _buildHeroBanner() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
      decoration: const BoxDecoration(
        color: AppColors.primary,
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(24),
          bottomRight: Radius.circular(24),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                "Quiz Hub 🎯",
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 26,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.15),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.leaderboard_rounded, color: Colors.white, size: 20),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            "Select your standard and test your knowledge!",
            style: TextStyle(
              color: Colors.white.withValues(alpha: 0.85),
              fontSize: 13,
            ),
          ),
          const SizedBox(height: 16),
          // Search Input
          Container(
            height: 44,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.08),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: TextField(
              controller: _searchController,
              onChanged: (val) {
                setState(() {
                  _searchQuery = val;
                });
              },
              decoration: InputDecoration(
                hintText: "Search topics, subjects, quizzes...",
                hintStyle: TextStyle(fontSize: 13, color: Colors.grey[400]),
                prefixIcon: const Icon(Icons.search, size: 20, color: AppColors.primary),
                suffixIcon: _searchQuery.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear, size: 18),
                        onPressed: () {
                          _searchController.clear();
                          setState(() {
                            _searchQuery = '';
                          });
                        },
                      )
                    : null,
                border: InputBorder.none,
                contentPadding: const EdgeInsets.symmetric(vertical: 12),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCategorySelector(List<Map<String, dynamic>> categories) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 4),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: categories.map((cat) {
            final isSelected = cat['id'] == _selectedCategoryId;
            return Padding(
              padding: const EdgeInsets.only(right: 8),
              child: ChoiceChip(
                label: Text(
                  cat['name'] ?? '',
                  style: TextStyle(
                    color: isSelected ? Colors.white : const Color(0xFF1A1A2E),
                    fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                    fontSize: 13,
                  ),
                ),
                selected: isSelected,
                selectedColor: AppColors.primary,
                backgroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                  side: BorderSide(
                    color: isSelected ? AppColors.primary : Colors.grey[300]!,
                  ),
                ),
                onSelected: (selected) {
                  if (selected) {
                    setState(() {
                      _selectedCategoryId = cat['id'];
                      final courses = (cat['courses'] as List? ?? []).cast<Map<String, dynamic>>();
                      _selectedCourseId = courses.isNotEmpty ? courses.first['id'] : null;
                      _selectedSubjectId = null;
                    });
                  }
                },
              ),
            );
          }).toList(),
        ),
      ),
    );
  }

  Widget _buildStandardSelector(List<Map<String, dynamic>> courses) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.fromLTRB(20, 16, 20, 8),
          child: Text(
            "Select Standard",
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w700,
              color: Color(0xFF666666),
              letterSpacing: 0.5,
            ),
          ),
        ),
        SizedBox(
          height: 44,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 20),
            itemCount: courses.length,
            itemBuilder: (context, index) {
              final course = courses[index];
              final isSelected = course['id'] == _selectedCourseId;
              final courseName = course['name'] ?? 'Standard';

              return Padding(
                padding: const EdgeInsets.only(right: 10),
                child: GestureDetector(
                  onTap: () {
                    setState(() {
                      _selectedCourseId = course['id'];
                      _selectedSubjectId = null; // Reset subject on standard change
                    });
                  },
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
                    decoration: BoxDecoration(
                      color: isSelected ? AppColors.primary : Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: isSelected ? AppColors.primary : const Color(0xFFE2E8F0),
                        width: 1.5,
                      ),
                      boxShadow: isSelected
                          ? [
                              BoxShadow(
                                color: AppColors.primary.withValues(alpha: 0.3),
                                blurRadius: 8,
                                offset: const Offset(0, 3),
                              )
                            ]
                          : [
                              BoxShadow(
                                color: Colors.black.withValues(alpha: 0.03),
                                blurRadius: 4,
                                offset: const Offset(0, 1),
                              )
                            ],
                    ),
                    child: Center(
                      child: Text(
                        courseName,
                        style: TextStyle(
                          color: isSelected ? Colors.white : const Color(0xFF1A1A2E),
                          fontWeight: isSelected ? FontWeight.w800 : FontWeight.w600,
                          fontSize: 14,
                        ),
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildSubjectSelector(List<Map<String, dynamic>> subjects, String standardName) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 14),
        SizedBox(
          height: 38,
          child: ListView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 20),
            children: [
              // "All Subjects" Pill
              Padding(
                padding: const EdgeInsets.only(right: 8),
                child: ChoiceChip(
                  label: const Text("All Subjects"),
                  selected: _selectedSubjectId == null,
                  selectedColor: const Color(0xFF1A1A2E),
                  backgroundColor: Colors.white,
                  labelStyle: TextStyle(
                    color: _selectedSubjectId == null ? Colors.white : Colors.black87,
                    fontWeight: _selectedSubjectId == null ? FontWeight.bold : FontWeight.w500,
                    fontSize: 12,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                    side: BorderSide(
                      color: _selectedSubjectId == null ? const Color(0xFF1A1A2E) : Colors.grey[300]!,
                    ),
                  ),
                  onSelected: (selected) {
                    if (selected) {
                      setState(() {
                        _selectedSubjectId = null;
                      });
                    }
                  },
                ),
              ),
              // Individual Subject Pills
              ...subjects.map((sub) {
                final isSelected = sub['id'] == _selectedSubjectId;
                final quizzesCount = (sub['quizzes'] as List? ?? []).length;
                return Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: ChoiceChip(
                    label: Text("${sub['name']} ($quizzesCount)"),
                    selected: isSelected,
                    selectedColor: AppColors.primary,
                    backgroundColor: Colors.white,
                    labelStyle: TextStyle(
                      color: isSelected ? Colors.white : Colors.black87,
                      fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                      fontSize: 12,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                      side: BorderSide(
                        color: isSelected ? AppColors.primary : Colors.grey[300]!,
                      ),
                    ),
                    onSelected: (selected) {
                      setState(() {
                        _selectedSubjectId = selected ? sub['id'] : null;
                      });
                    },
                  ),
                );
              }),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildEmptyState(String title, String subtitle) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(40.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.quiz_outlined, size: 64, color: Colors.grey),
            const SizedBox(height: 16),
            Text(
              title,
              style: const TextStyle(color: Colors.grey, fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(
              subtitle,
              style: const TextStyle(color: Colors.grey),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
