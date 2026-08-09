enum ContentNodeType { folder, video, material, test, qaPaper }

class ContentNode {
  final String id;
  final String title;
  final ContentNodeType type;
  final List<ContentNode>? children;
  final bool isFree;   // Only relevant for videos
  final bool isLocked;
  final String? duration;     // For videos and tests
  final int? questionCount;   // For tests only

  const ContentNode({
    required this.id,
    required this.title,
    required this.type,
    this.children,
    this.isFree = false,
    this.isLocked = true,
    this.duration,
    this.questionCount,
  });

  bool get isFolder => type == ContentNodeType.folder;
  bool get isLeaf => children == null || children!.isEmpty;
}
