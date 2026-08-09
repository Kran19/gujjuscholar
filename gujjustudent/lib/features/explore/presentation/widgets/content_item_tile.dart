import 'package:flutter/material.dart';
import 'package:edustream/core/constants/app_colors.dart';
import 'package:edustream/features/explore/domain/models/content_node_model.dart';

class ContentItemTile extends StatelessWidget {
  final ContentNode node;
  final VoidCallback onTap;

  const ContentItemTile({
    super.key,
    required this.node,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 5),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: node.isFree
              ? AppColors.success.withValues(alpha: 0.3)
              : AppColors.lightGrey,
          width: node.isFree ? 1.5 : 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(14),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(14),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            child: Row(
              children: [
                // Type icon
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: _iconBgColor,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(_icon, color: _iconColor, size: 20),
                ),
                const SizedBox(width: 14),
                // Title + metadata
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        node.title,
                        style: const TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: 14,
                          color: Color(0xFF1A1A2E),
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          if (node.duration != null) ...[
                            Icon(Icons.timer_outlined, size: 13, color: AppColors.darkGrey.withValues(alpha: 0.7)),
                            const SizedBox(width: 4),
                            Text(
                              node.duration!,
                              style: TextStyle(fontSize: 12, color: AppColors.darkGrey.withValues(alpha: 0.7)),
                            ),
                            const SizedBox(width: 12),
                          ],
                          if (node.questionCount != null) ...[
                            Icon(Icons.quiz_outlined, size: 13, color: AppColors.darkGrey.withValues(alpha: 0.7)),
                            const SizedBox(width: 4),
                            Text(
                              '${node.questionCount} questions',
                              style: TextStyle(fontSize: 12, color: AppColors.darkGrey.withValues(alpha: 0.7)),
                            ),
                          ],
                        ],
                      ),
                    ],
                  ),
                ),
                // Free / Locked tag
                _buildStatusTag(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildStatusTag() {
    if (node.isFree && node.type == ContentNodeType.video) {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
        decoration: BoxDecoration(
          color: AppColors.success.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(8),
        ),
        child: const Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.play_circle_rounded, size: 14, color: AppColors.success),
            SizedBox(width: 4),
            Text(
              'Free',
              style: TextStyle(
                fontSize: 11,
                color: AppColors.success,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      );
    }

    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: const Color(0xFFFFF3E0),
        borderRadius: BorderRadius.circular(8),
      ),
      child: const Icon(
        Icons.lock_rounded,
        size: 16,
        color: Color(0xFFE65100),
      ),
    );
  }

  IconData get _icon {
    switch (node.type) {
      case ContentNodeType.video:
        return Icons.play_circle_filled_rounded;
      case ContentNodeType.material:
        return Icons.description_rounded;
      case ContentNodeType.test:
        return Icons.assignment_rounded;
      case ContentNodeType.qaPaper:
        return Icons.history_edu_rounded;
      case ContentNodeType.folder:
        return Icons.folder_rounded;
    }
  }

  Color get _iconColor {
    switch (node.type) {
      case ContentNodeType.video:
        return const Color(0xFF1565C0);
      case ContentNodeType.material:
        return const Color(0xFF6A1B9A);
      case ContentNodeType.test:
        return const Color(0xFFE65100);
      case ContentNodeType.qaPaper:
        return const Color(0xFF2E7D32);
      case ContentNodeType.folder:
        return AppColors.primary;
    }
  }

  Color get _iconBgColor {
    switch (node.type) {
      case ContentNodeType.video:
        return const Color(0xFF1565C0).withValues(alpha: 0.1);
      case ContentNodeType.material:
        return const Color(0xFF6A1B9A).withValues(alpha: 0.1);
      case ContentNodeType.test:
        return const Color(0xFFE65100).withValues(alpha: 0.1);
      case ContentNodeType.qaPaper:
        return const Color(0xFF2E7D32).withValues(alpha: 0.1);
      case ContentNodeType.folder:
        return AppColors.primary.withValues(alpha: 0.1);
    }
  }
}
