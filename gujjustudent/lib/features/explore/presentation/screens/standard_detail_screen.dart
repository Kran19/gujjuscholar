import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:edustream/core/constants/app_colors.dart';
import 'package:edustream/features/explore/data/models/explore_models.dart';
import 'package:edustream/features/explore/presentation/providers/explore_providers.dart';
import 'package:edustream/features/cart/presentation/providers/cart_controller.dart';
import 'package:edustream/routes/app_routes.dart';

class StandardDetailScreen extends ConsumerStatefulWidget {
  final CategoryModel standard; // Using CategoryModel as 'Standard'

  const StandardDetailScreen({super.key, required this.standard});

  @override
  ConsumerState<StandardDetailScreen> createState() => _StandardDetailScreenState();
}

class _StandardDetailScreenState extends ConsumerState<StandardDetailScreen> {


  void _navigateToPreview(CourseModel course) {
    Navigator.pushNamed(
      context,
      AppRoutes.coursePreview,
      arguments: course,
    );
  }

  @override
  Widget build(BuildContext context) {
    final coursesAsync = ref.watch(categoryCoursesProvider(widget.standard.id));
    final cartState = ref.watch(cartControllerProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(widget.standard.name, style: const TextStyle(color: AppColors.primary, fontWeight: FontWeight.bold)),
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, color: AppColors.primary),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: coursesAsync.when(
        data: (courses) => _buildContent(context, courses, cartState),
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, stack) => Center(child: Text("Error: $err")),
      ),
    );
  }

  Widget _buildContent(BuildContext context, List<CourseModel> courses, CartNotifier cartState) {
    return CustomScrollView(
      slivers: [
        SliverPadding(
          padding: const EdgeInsets.all(16),
          sliver: SliverList(
            delegate: SliverChildBuilderDelegate(
              (context, index) {
                final course = courses[index];
                final inCart = cartState.items.any((item) => 
                    item['item_id'].toString() == course.id.toString() && 
                    item['item_type'].toString().contains('Course'));
                
                return Card(
                  margin: const EdgeInsets.only(bottom: 16),
                  child: ListTile(
                    title: Text(course.name, style: const TextStyle(fontWeight: FontWeight.bold)),
                    subtitle: Text("Price: ₹${course.price}"),
                    trailing: ElevatedButton(
                      onPressed: inCart || cartState.isLoading ? null : () async {
                        try {
                          await ref.read(cartControllerProvider).addItem(type: 'course', itemId: course.id);
                        } catch (e) {
                          if (context.mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text('Failed to add: $e')),
                            );
                          }
                        }
                      },
                      child: cartState.isLoading 
                        ? const SizedBox(height: 16, width: 16, child: CircularProgressIndicator(strokeWidth: 2))
                        : Text(inCart ? "In Cart" : "Buy Course"),
                    ),
                    onTap: () => _navigateToPreview(course),
                  ),
                );
              },
              childCount: courses.length,
            ),
          ),
        ),
      ],
    );
  }
}
