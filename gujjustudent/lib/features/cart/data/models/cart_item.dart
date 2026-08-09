enum CartItemType {
  fullCourse,
  individualSubject,
  customBundle,
}

class CartItem {
  final String id;
  final int std;
  final CartItemType type;
  final List<String> subjects; // For individualSubject (length 1) and customBundle
  final int price;

  CartItem({
    required this.id,
    required this.std,
    required this.type,
    required this.subjects,
    required this.price,
  });

  String get title {
    switch (type) {
      case CartItemType.fullCourse:
        return 'Standard $std – Full Course';
      case CartItemType.individualSubject:
        return 'Std $std – ${subjects.first}';
      case CartItemType.customBundle:
        return 'Standard $std – Custom Bundle';
    }
  }

  String get subtitle {
    switch (type) {
      case CartItemType.fullCourse:
        return 'Includes: ${subjects.join(', ')}';
      case CartItemType.individualSubject:
        return 'Subject Course';
      case CartItemType.customBundle:
        return 'Selected:\n• ${subjects.join('\n• ')}';
    }
  }

  CartItem copyWith({
    String? id,
    int? std,
    CartItemType? type,
    List<String>? subjects,
    int? price,
  }) {
    return CartItem(
      id: id ?? this.id,
      std: std ?? this.std,
      type: type ?? this.type,
      subjects: subjects ?? this.subjects,
      price: price ?? this.price,
    );
  }
}
