import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:edustream/features/explore/data/models/explore_models.dart';
import 'package:edustream/features/explore/data/models/explore_subjects.dart';
import 'package:edustream/features/explore/presentation/widgets/subject_card.dart';
import 'package:edustream/features/cart/presentation/providers/cart_controller.dart';
import 'package:edustream/routes/app_routes.dart';
import 'package:edustream/features/explore/presentation/providers/explore_providers.dart';

class CourseSubjectsScreen extends ConsumerStatefulWidget {
  final CourseModel course;

  const CourseSubjectsScreen({super.key, required this.course});

  @override
  ConsumerState<CourseSubjectsScreen> createState() => _CourseSubjectsScreenState();
}

class _CourseSubjectsScreenState extends ConsumerState<CourseSubjectsScreen> {
  final Set<int> _selectedBundleSubjects = {};
  bool _isSelectionMode = false;

  @override
  Widget build(BuildContext context) {
    final courseDetailsAsync = ref.watch(courseSubjectsProvider(widget.course.id));

    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FE),
      appBar: AppBar(
        title: Text(
          widget.course.name, 
          style: const TextStyle(color: Color(0xFF1A1A2E), fontWeight: FontWeight.w800)
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Color(0xFF1A1A2E)),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          Stack(
            children: [
              IconButton(
                icon: const Icon(Icons.shopping_cart_outlined, color: Color(0xFF1A1A2E)),
                onPressed: () => Navigator.pushNamed(context, AppRoutes.cart),
              ),
              Consumer(
                builder: (context, ref, child) {
                  final cartState = ref.watch(cartControllerProvider);
                  if (cartState.items.isEmpty) return const SizedBox.shrink();
                  return Positioned(
                    right: 8,
                    top: 8,
                    child: Container(
                      padding: const EdgeInsets.all(4),
                      decoration: const BoxDecoration(color: Colors.red, shape: BoxShape.circle),
                      child: Text('${cartState.items.length}', style: const TextStyle(color: Colors.white, fontSize: 10)),
                    ),
                  );
                },
              ),
            ],
          ),
        ],
      ),
      body: courseDetailsAsync.when(
        data: (data) {
          final course = CourseModel.fromJson(data['course']);
          final isEnrolled = data['is_enrolled'] as bool? ?? false;
          // List of individually purchased subject IDs (not full course)
          final enrolledSubjectIds = (data['enrolled_subject_ids'] as List?)?.map((e) => e as int).toSet() ?? <int>{};
          final List<SubjectModel> subjects = (data['subjects'] as List)
              .map((s) => SubjectModel.fromJson(s as Map<String, dynamic>))
              .toList();

          final cartState = ref.watch(cartControllerProvider);
          final bool inCart = cartState.items.any((item) => 
              item['item_id'].toString() == course.id.toString() && 
              item['item_type'].toString().toLowerCase().contains('course'));

          return CustomScrollView(
            physics: const BouncingScrollPhysics(),
            slivers: [
              // 1. Course Header Card
              SliverToBoxAdapter(
                child: Container(
                  margin: const EdgeInsets.all(20),
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        SubjectModel.parseColor(course.colorCode),
                        SubjectModel.parseColor(course.colorCode).withValues(alpha: 0.8),
                      ],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(32),
                    boxShadow: [
                      BoxShadow(
                        color: SubjectModel.parseColor(course.colorCode).withValues(alpha: 0.3),
                        blurRadius: 20,
                        offset: const Offset(0, 10),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: Colors.white.withValues(alpha: 0.2),
                              borderRadius: BorderRadius.circular(16),
                            ),
                            child: Icon(
                              SubjectModel.getIconData(course.iconUrl),
                              color: Colors.white,
                              size: 32,
                            ),
                          ),
                          const Spacer(),
                          Flexible(
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                              decoration: BoxDecoration(
                                color: isEnrolled ? Colors.green : Colors.white.withValues(alpha: 0.2),
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Text(
                                isEnrolled ? 'ENROLLED' : '${course.subjectsCount ?? subjects.length} Subjects',
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 12,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 24),
                      Text(
                        course.name,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 28,
                          fontWeight: FontWeight.w900,
                          letterSpacing: -0.5,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        course.description ?? 'Complete access to all subjects and study materials.',
                        style: TextStyle(
                          color: Colors.white.withValues(alpha: 0.9),
                          fontSize: 14,
                          height: 1.4,
                        ),
                      ),
                      const SizedBox(height: 24),
                      if (!isEnrolled)
                        Row(
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Full Course Price',
                                    style: TextStyle(
                                      color: Colors.white.withValues(alpha: 0.7),
                                      fontSize: 12,
                                    ),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  Text(
                                    '₹${course.price}',
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 24,
                                      fontWeight: FontWeight.bold,
                                    ),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(width: 8),
                            ElevatedButton(
                              onPressed: inCart || cartState.isLoading ? null : () async {
                                try {
                                  await ref.read(cartControllerProvider).addItem(
                                    type: 'course', 
                                    itemId: course.id,
                                  );
                                  if (context.mounted) {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(
                                        content: Text('Added to cart successfully!'),
                                        backgroundColor: Colors.green,
                                      ),
                                    );
                                  }
                                } catch (e) {
                                  if (context.mounted) {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                        content: Text('Failed to add: $e'),
                                        backgroundColor: Colors.red,
                                      ),
                                    );
                                  }
                                }
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.white,
                                foregroundColor: SubjectModel.parseColor(course.colorCode),
                                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(16),
                                ),
                                elevation: 0,
                              ),
                              child: cartState.isLoading 
                                ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(strokeWidth: 2))
                                : Text(
                                    inCart ? 'In Cart' : 'Buy Full Course',
                                    style: const TextStyle(fontWeight: FontWeight.bold),
                                  ),
                            ),
                          ],
                        ),
                      if (isEnrolled)
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.2),
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Icon(Icons.check_circle_outline, color: Colors.white),
                              const SizedBox(width: 8),
                              const Flexible(
                                child: Text(
                                  'You have full access to this course',
                                  style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                                  overflow: TextOverflow.ellipsis,
                                  maxLines: 2,
                                ),
                              ),
                            ],
                          ),
                        ),
                    ],
                  ),
                ),
              ),

              // 2. Subjects Grid Header
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(24, 8, 24, 16),
                  child: Row(
                    children: [
                      const Text(
                        'Included Subjects',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w800,
                          color: Color(0xFF1A1A2E),
                        ),
                      ),
                      const Spacer(),
                      if (!isEnrolled)
                        TextButton(
                          onPressed: () {
                            setState(() {
                              _isSelectionMode = !_isSelectionMode;
                              if (!_isSelectionMode) _selectedBundleSubjects.clear();
                            });
                          },
                          child: Text(_isSelectionMode ? 'Cancel' : 'Custom Bundle'),
                        ),
                    ],
                  ),
                ),
              ),

              // 3. Flexible Subjects 2-Column Layout
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
                              Expanded(child: _buildSubjectItem(
                                subjects[firstIndex], 
                                isEnrolled,
                                enrolledSubjectIds.contains(subjects[firstIndex].id),
                              )),
                              const SizedBox(width: 16),
                              Expanded(
                                child: secondIndex < subjects.length
                                    ? _buildSubjectItem(
                                        subjects[secondIndex], 
                                        isEnrolled,
                                        enrolledSubjectIds.contains(subjects[secondIndex].id),
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
              if (_isSelectionMode)
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.all(24),
                    child: ElevatedButton(
                      onPressed: _selectedBundleSubjects.isEmpty ? null : () async {
                        double total = 0;
                        for (var id in _selectedBundleSubjects) {
                          total += subjects.firstWhere((s) => s.id == id).price;
                        }
                        double bundlePrice = total * 0.9;
                        
                        await ref.read(cartControllerProvider).addItem(
                          type: 'bundle',
                          bundleSubjects: _selectedBundleSubjects.toList(),
                          price: bundlePrice,
                        );
                        
                        if (context.mounted) {
                          setState(() {
                            _isSelectionMode = false;
                            _selectedBundleSubjects.clear();
                          });
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Bundle added to cart!')),
                          );
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blue,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.all(16),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                      ),
                      child: Text('Add Bundle to Cart (₹${(_selectedBundleSubjects.fold(0, (sum, id) => sum + subjects.firstWhere((s) => s.id == id).price) * 0.9).toStringAsFixed(0)})'),
                    ),
                  ),
                ),
                  SliverToBoxAdapter(child: const SizedBox(height: 40)),
            ],
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, stack) => Center(child: Text("Error: $err")),
      ),
    );
  }

  Widget _buildSubjectItem(SubjectModel subject, bool isCourseEnrolled, bool isSubjectEnrolled) {
    // A subject is accessible if the full course is purchased OR the individual subject is purchased
    final bool hasAccess = isCourseEnrolled || isSubjectEnrolled;
    bool isSelected = _selectedBundleSubjects.contains(subject.id);

    return Stack(
      children: [
        SubjectCard(
          subject: subject,
          onViewDetails: () {
            if (_isSelectionMode && !hasAccess) {
              setState(() {
                if (isSelected) {
                  _selectedBundleSubjects.remove(subject.id);
                } else {
                  _selectedBundleSubjects.add(subject.id);
                }
              });
            } else {
              Navigator.pushNamed(
                context,
                AppRoutes.subjectDetail,
                arguments: {
                  'subjectId': subject.id,
                  'subjectName': subject.name,
                },
              );
            }
          },
        ),

        // --- Bundle selection checkbox (only non-enrolled subjects) ---
        if (_isSelectionMode && !hasAccess)
          Positioned(
            right: 8,
            top: 8,
            child: Container(
              decoration: BoxDecoration(
                color: isSelected ? Colors.blue : Colors.white.withValues(alpha: 0.8),
                shape: BoxShape.circle,
                border: Border.all(color: Colors.blue, width: 2),
              ),
              child: Icon(
                Icons.check,
                size: 20,
                color: isSelected ? Colors.white : Colors.transparent,
              ),
            ),
          ),

        // --- Enrolled badge (individually purchased subject) ---
        if (!_isSelectionMode && isSubjectEnrolled && !isCourseEnrolled)
          Positioned(
            right: 6,
            top: 6,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: Colors.green,
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.check_circle, color: Colors.white, size: 12),
                  SizedBox(width: 3),
                  Text('Enrolled', style: TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold)),
                ],
              ),
            ),
          ),

        // --- Add to Cart button (only for unenrolled subjects when course is not enrolled) ---
        if (!_isSelectionMode && !hasAccess)
          Positioned(
            right: 8,
            top: 8,
            child: IconButton(
              icon: const Icon(Icons.add_shopping_cart, size: 20, color: Color(0xFF1A1A2E)),
              onPressed: () => ref.read(cartControllerProvider).addItem(
                type: 'subject',
                itemId: subject.id,
              ),
            ),
          ),
      ],
    );
  }
}
