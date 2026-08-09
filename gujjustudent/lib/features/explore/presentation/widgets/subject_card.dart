import 'package:flutter/material.dart';
import 'package:edustream/core/constants/app_colors.dart';
import 'package:edustream/features/explore/data/models/explore_subjects.dart';

class SubjectCard extends StatelessWidget {
  final SubjectModel subject;
  final VoidCallback onViewDetails;

  const SubjectCard({
    super.key,
    required this.subject,
    required this.onViewDetails,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
        border: Border.all(
          color: AppColors.lightGrey.withValues(alpha: 0.5),
          width: 1,
        ),
      ),
      child: InkWell(
        onTap: onViewDetails,
        borderRadius: BorderRadius.circular(24),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min, // Use min size to wrap content
            children: [
              // Icon
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: subject.color.withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(subject.icon, color: subject.color, size: 26),
              ),
              const SizedBox(height: 16),
              // Title
              Text(
                subject.name,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                  color: Color(0xFF1A1A2E),
                  height: 1.2,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 8),
              // Description
              Text(
                subject.description,
                style: TextStyle(
                  fontSize: 11,
                  color: AppColors.darkGrey.withValues(alpha: 0.7),
                  height: 1.4,
                ),
                maxLines: 3, // Increased lines for better fit
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 20),
              // Button
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 10),
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.08),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Text(
                  'View Details',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 12,
                    color: AppColors.primary,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
