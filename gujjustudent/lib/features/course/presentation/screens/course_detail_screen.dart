import 'package:flutter/material.dart';
import 'package:edustream/core/constants/app_colors.dart';
import 'package:edustream/routes/app_routes.dart';
import 'package:edustream/core/widgets/custom_button.dart';
import 'package:edustream/features/course/data/models/course_model.dart';

class CourseDetailScreen extends StatelessWidget {
  const CourseDetailScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // For now using static dummy data. 
    final course = CourseModel.dummy;

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          // App Bar with Image
          SliverAppBar(
            expandedHeight: 240,
            pinned: true,
            flexibleSpace: FlexibleSpaceBar(
              background: Image.network(
                course.thumbnail,
                fit: BoxFit.cover,
              ),
            ),
            leading: Padding(
              padding: const EdgeInsets.all(8.0),
              child: CircleAvatar(
                backgroundColor: Colors.white,
                child: IconButton(
                  icon: const Icon(Icons.arrow_back, color: Colors.black),
                  onPressed: () => Navigator.pop(context),
                ),
              ),
            ),
            actions: [
               Padding(
                 padding: const EdgeInsets.all(8.0),
                 child: CircleAvatar(
                   backgroundColor: Colors.white,
                   child: IconButton(
                     icon: const Icon(Icons.share, color: Colors.black),
                     onPressed: () {},
                   ),
                 ),
               ),
               Padding(
                 padding: const EdgeInsets.all(8.0),
                 child: CircleAvatar(
                   backgroundColor: Colors.white,
                   child: IconButton(
                     icon: const Icon(Icons.bookmark_border, color: Colors.black),
                     onPressed: () {},
                   ),
                 ),
               ),
            ],
          ),

          // Content
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Title & Price
                  Text(
                    course.title,
                    style: Theme.of(context).textTheme.displaySmall,
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      const Icon(Icons.person, size: 18, color: AppColors.grey),
                      const SizedBox(width: 4),
                      Text(course.instructor, style: const TextStyle(color: AppColors.darkGrey)),
                      const Spacer(),
                      const Icon(Icons.star, size: 18, color: AppColors.accent),
                      const SizedBox(width: 4),
                      Text("${course.rating} (120+ reviews)", style: const TextStyle(fontWeight: FontWeight.bold)),
                    ],
                  ),
                  
                  const SizedBox(height: 16),
                  
                  // Description
                  Text(
                    "About This Course",
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    course.description,
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),

                  const SizedBox(height: 24),

                  // Curriculum
                  Text(
                    "Curriculum",
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  const SizedBox(height: 12),
                  
                  ListView.separated(
                    padding: EdgeInsets.zero,
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: course.lessons.length,
                    separatorBuilder: (context, index) => const Divider(),
                    itemBuilder: (context, index) {
                      final lesson = course.lessons[index];
                      return ListTile(
                        leading: Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: AppColors.lightGrey,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Icon(
                            _getIconForType(lesson.type),
                            color: AppColors.primary,
                          ),
                        ),
                        title: Text(lesson.title, style: const TextStyle(fontWeight: FontWeight.bold)),
                        subtitle: Text(lesson.duration),
                        trailing: lesson.isLocked 
                          ? const Icon(Icons.lock, color: AppColors.grey, size: 20)
                          : const Icon(Icons.play_circle_fill, color: AppColors.primary, size: 28),
                        onTap: () {
                          if (!lesson.isLocked) {
                             if (lesson.type == 'notes') {
                               Navigator.pushNamed(context, AppRoutes.content, arguments: {'type': 'notes'});
                             } else if (lesson.type == 'quiz') {
                               Navigator.pushNamed(context, AppRoutes.quizList);
                             } else {
                               Navigator.pushNamed(
                                 context,
                                 AppRoutes.videoPlayer,
                                 arguments: {
                                   'videoId': int.tryParse(lesson.id) ?? 1,
                                   'videoName': lesson.title,
                                 },
                               );
                             }
                          }
                        },
                      );
                    },
                  ),

                  const SizedBox(height: 100), // Spacing for bottom button
                ],
              ),
            ),
          ),
        ],
      ),
      bottomSheet: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 10,
              offset: const Offset(0, -5),
            )
          ],
        ),
        child: Row(
          children: [
            Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text("Total Price", style: TextStyle(color: AppColors.grey)),
                Text(course.price, style: Theme.of(context).textTheme.headlineMedium?.copyWith(color: AppColors.primary)),
              ],
            ),
            const Spacer(),
            SizedBox(
              width: 200,
              child: CustomButton(
                text: "Buy Now",
                onPressed: () {},
              ),
            ),
          ],
        ),
      ),
    );
  }

  IconData _getIconForType(String type) {
    switch (type) {
      case 'video': return Icons.play_lesson;
      case 'notes': return Icons.description;
      case 'quiz': return Icons.quiz;
      default: return Icons.circle;
    }
  }
}
