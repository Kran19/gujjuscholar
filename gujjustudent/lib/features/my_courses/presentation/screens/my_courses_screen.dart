import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:edustream/core/constants/app_colors.dart';
import 'package:edustream/features/my_courses/presentation/providers/my_courses_providers.dart';
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
                  
                  return Card(
                    margin: const EdgeInsets.only(bottom: 12),
                    child: ListTile(
                      leading: const Icon(Icons.book, color: AppColors.primary),
                      title: Text(name, style: const TextStyle(fontWeight: FontWeight.bold)),
                      subtitle: Text(course != null ? "Full Course" : "Single Subject"),
                      trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                      onTap: () {
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
