import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:edustream/core/constants/app_colors.dart';
import 'package:edustream/features/my_courses/presentation/providers/my_courses_providers.dart';
import 'package:edustream/features/explore/presentation/providers/explore_providers.dart';
import 'package:edustream/features/auth/presentation/providers/auth_providers.dart';
import 'package:edustream/features/explore/data/models/explore_models.dart';
import 'package:edustream/routes/app_routes.dart';
import 'package:edustream/features/home/presentation/screens/main_entry_screen.dart';

class MyCoursesScreen extends ConsumerWidget {
  // Enrolled courses view
  const MyCoursesScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final myCoursesAsync = ref.watch(myCoursesProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      body: myCoursesAsync.when(
        data: (enrollments) => enrollments.isEmpty 
            ? _buildEmptyState(context, ref)
            : ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: enrollments.length,
                itemBuilder: (context, index) {
                  final enrollment = enrollments[index];
                  final course = enrollment['course'];
                  final subject = enrollment['subject'];
                  final name = course != null ? course['name'] : (subject != null ? subject['name'] : 'Unknown Course');
                  final isActive = enrollment['is_active'] == true;
                  final courseId = course != null ? course['id'] : null;

                  return Card(
                    margin: const EdgeInsets.only(bottom: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                      side: BorderSide(
                        color: isActive ? AppColors.primary : Colors.grey[200]!,
                        width: isActive ? 2 : 1,
                      ),
                    ),
                    elevation: isActive ? 3 : 1,
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.all(10),
                                decoration: BoxDecoration(
                                  color: isActive ? AppColors.primary : AppColors.primary.withValues(alpha: 0.1),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Icon(
                                  Icons.book_rounded,
                                  color: isActive ? Colors.white : AppColors.primary,
                                  size: 24,
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      name,
                                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                                    ),
                                    const SizedBox(height: 2),
                                    Text(
                                      course != null ? "Full Course / Standard" : "Single Subject",
                                      style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                                    ),
                                  ],
                                ),
                              ),
                              if (isActive)
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                  decoration: BoxDecoration(
                                    color: Colors.green[600],
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: const Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Icon(Icons.check_circle, color: Colors.white, size: 12),
                                      SizedBox(width: 4),
                                      Text(
                                        "ACTIVE",
                                        style: TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold),
                                      ),
                                    ],
                                  ),
                                ),
                            ],
                          ),
                          const SizedBox(height: 14),
                          const Divider(height: 1),
                          const SizedBox(height: 12),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              if (!isActive && courseId != null)
                                TextButton.icon(
                                  onPressed: () async {
                                    try {
                                      ScaffoldMessenger.of(context).showSnackBar(
                                        SnackBar(content: Text("Setting $name as active..."), duration: const Duration(seconds: 1)),
                                      );
                                      final authRepo = ref.read(authRepositoryProvider);
                                      await authRepo.switchCourse(courseId);
                                      ref.invalidate(homeDataProvider);
                                      ref.invalidate(myCoursesProvider);
                                      ref.invalidate(categoriesProvider);
                                      ref.invalidate(quizHubProvider);
                                      
                                      if (!context.mounted) return;
                                      ScaffoldMessenger.of(context).showSnackBar(
                                        SnackBar(content: Text("Active standard updated to $name!"), backgroundColor: Colors.green[700]),
                                      );
                                    } catch (e) {
                                      if (!context.mounted) return;
                                      ScaffoldMessenger.of(context).showSnackBar(
                                        SnackBar(content: Text("Failed to switch: $e"), backgroundColor: Colors.red),
                                      );
                                    }
                                  },
                                  icon: const Icon(Icons.swap_horiz_rounded, size: 18),
                                  label: const Text("Set as Active Standard"),
                                  style: TextButton.styleFrom(
                                    foregroundColor: AppColors.primary,
                                    textStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                                  ),
                                )
                              else
                                const SizedBox.shrink(),
                              ElevatedButton(
                                onPressed: () {
                                  if (course != null) {
                                    Navigator.pushNamed(
                                      context,
                                      AppRoutes.coursePreview,
                                      arguments: CourseModel.fromJson(course),
                                    );
                                  } else if (subject != null) {
                                    Navigator.pushNamed(
                                      context,
                                      AppRoutes.subjectDetail,
                                      arguments: {
                                        'subjectId': subject['id'],
                                        'subjectName': subject['name'],
                                      },
                                    );
                                  }
                                },
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: isActive ? AppColors.primary : Colors.grey[800],
                                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                                ),
                                child: const Text("View Content", style: TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.bold)),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, stack) => Center(child: Text("Error: $err")),
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context, WidgetRef ref) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.school_outlined, size: 80, color: Colors.grey),
          const SizedBox(height: 24),
          const Text("No enrolled courses", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
          const SizedBox(height: 12),
          const Text("Explore the standards to get started"),
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: () {
              // Switch to Explore tab (index 2)
              ref.read(bottomNavIndexProvider.notifier).state = 2;
            },
            child: const Text("Explore Now"),
          ),
        ],
      ),
    );
  }
}
