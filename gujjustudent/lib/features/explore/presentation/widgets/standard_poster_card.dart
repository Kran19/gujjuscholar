import 'package:flutter/material.dart';
import 'package:edustream/core/constants/app_colors.dart';
import 'package:edustream/features/explore/data/models/explore_models.dart';
import 'package:edustream/features/explore/data/models/explore_subjects.dart';

class StandardPosterCard extends StatefulWidget {
  final CourseModel course;
  final VoidCallback onTap;

  const StandardPosterCard({
    super.key,
    required this.course,
    required this.onTap,
  });

  @override
  State<StandardPosterCard> createState() => _StandardPosterCardState();
}

class _StandardPosterCardState extends State<StandardPosterCard> {
  bool _isPressed = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => setState(() => _isPressed = true),
      onTapUp: (_) => setState(() => _isPressed = false),
      onTapCancel: () => setState(() => _isPressed = false),
      onTap: widget.onTap,
      child: AnimatedScale(
        scale: _isPressed ? 0.96 : 1.0,
        duration: const Duration(milliseconds: 100),
        child: Container(
          width: 170,
          margin: const EdgeInsets.only(right: 16),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(24),
            color: Colors.white,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.04),
                blurRadius: 12,
                offset: const Offset(0, 4),
              ),
            ],
            border: Border.all(
              color: AppColors.lightGrey.withValues(alpha: 0.5),
              width: 1,
            ),
          ),
          child: Padding(
            padding: const EdgeInsets.all(18.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Icon Header
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: SubjectModel.parseColor(widget.course.colorCode).withValues(alpha: 0.08),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Icon(
                    SubjectModel.getIconData(widget.course.iconUrl),
                    color: SubjectModel.parseColor(widget.course.colorCode),
                    size: 26,
                  ),
                ),
                const Spacer(),
                // Course Title
                Text(
                  widget.course.name,
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w800,
                    color: Color(0xFF1A1A2E),
                    height: 1.1,
                  ),
                ),
                const SizedBox(height: 6),
                // Subjects Count
                Text(
                  '${widget.course.subjectsCount ?? 5} Subjects Included',
                  style: TextStyle(
                    fontSize: 12,
                    color: AppColors.darkGrey.withValues(alpha: 0.8),
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Text(
                  'Full Curriculum',
                  style: TextStyle(
                    color: AppColors.darkGrey.withValues(alpha: 0.6),
                  ),
                ),
                const SizedBox(height: 14),
                // Price
                Row(
                  crossAxisAlignment: CrossAxisAlignment.baseline,
                  textBaseline: TextBaseline.alphabetic,
                  children: [
                    Flexible(
                      child: Text(
                        'Starting from ',
                        style: TextStyle(
                          fontSize: 10,
                          color: AppColors.darkGrey.withValues(alpha: 0.6),
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    Text(
                      '₹${widget.course.price ?? "499"}',
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                        color: AppColors.primary,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
