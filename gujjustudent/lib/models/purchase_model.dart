enum PurchaseType { fullStandard, singleSubject }

class Purchase {
  final String id;
  final String standardName;
  final String? subjectName;
  final PurchaseType type;
  final double progress;
  final String image;

  Purchase({
    required this.id,
    required this.standardName,
    this.subjectName,
    required this.type,
    required this.progress,
    required this.image,
  });
}
