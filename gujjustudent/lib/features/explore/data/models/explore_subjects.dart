import 'package:flutter/material.dart';

class SubjectModel {
  final int id;
  final String name;
  final String description;
  final int price;
  final IconData icon;
  final Color color;

  const SubjectModel({
    required this.id,
    required this.name,
    required this.description,
    required this.price,
    required this.icon,
    required this.color,
  });

  factory SubjectModel.fromJson(Map<String, dynamic> json) {
    return SubjectModel(
      id: json['id'] ?? 0,
      name: json['name'] ?? '',
      description: json['description'] ?? '',
      price: int.tryParse(json['price']?.toString() ?? '0') ?? 0,
      icon: getIconData(json['icon']),
      color: parseColor(json['color']),
    );
  }

  static IconData getIconData(String? iconName) {
    if (iconName == null) return Icons.school_rounded;
    final name = iconName.toLowerCase();
    
    // Core variations
    if (name.contains('flask')) return Icons.science_rounded;
    if (name.contains('calculator')) return Icons.calculate_rounded;
    if (name.contains('atom')) return Icons.science_outlined;
    if (name.contains('microscope')) return Icons.biotech_rounded;
    if (name.contains('code')) return Icons.code_rounded;
    if (name.contains('chart')) return Icons.bar_chart_rounded;
    if (name.contains('book')) return Icons.menu_book_rounded;
    if (name.contains('globe')) return Icons.public_rounded;
    if (name.contains('dna')) return Icons.health_and_safety_rounded;
    if (name.contains('briefcase')) return Icons.work_rounded;
    if (name.contains('language')) return Icons.language_rounded;
    if (name.contains('landmark')) return Icons.account_balance_rounded;
    if (name.contains('map')) return Icons.map_rounded;
    if (name.contains('brain')) return Icons.psychology_rounded;
    if (name.contains('om')) return Icons.self_improvement_rounded;
    if (name.contains('computer')) return Icons.computer_rounded;
    if (name.contains('graduation')) return Icons.school_rounded;
    if (name.contains('school')) return Icons.school_rounded;
    if (name.contains('cap')) return Icons.school_rounded;
    if (name.contains('pencil')) return Icons.edit_note_rounded;
    if (name.contains('pen')) return Icons.edit_note_rounded;
    if (name.contains('edit')) return Icons.edit_note_rounded;
    if (name.contains('video')) return Icons.video_library_rounded;
    if (name.contains('play')) return Icons.play_arrow_rounded;
    if (name.contains('quiz')) return Icons.quiz_rounded;
    if (name.contains('test')) return Icons.quiz_rounded;
    if (name.contains('star')) return Icons.star_rounded;
    if (name.contains('heart')) return Icons.favorite_rounded;
    
    return Icons.school_rounded;
  }

  static Color parseColor(String? colorStr) {
    if (colorStr == null) return const Color(0xFF1565C0);
    try {
      return Color(int.parse('FF${colorStr.replaceAll('#', '')}', radix: 16));
    } catch (_) {
      return const Color(0xFF1565C0);
    }
  }
}

const Map<int, List<SubjectModel>> subjectsByStd = {
  5: [
    SubjectModel(id: 1, name: 'Maths',          description: 'Numbers, shapes & patterns',    price: 999,  icon: Icons.calculate_rounded,    color: Color(0xFF1565C0)),
    SubjectModel(id: 2, name: 'Science',        description: 'Experiments & discoveries',      price: 899,  icon: Icons.science_rounded,      color: Color(0xFF00838F)),
    SubjectModel(id: 3, name: 'English',        description: 'Grammar, reading & writing',     price: 799,  icon: Icons.menu_book_rounded,    color: Color(0xFF6A1B9A)),
    SubjectModel(id: 4, name: 'Social Studies', description: 'History, civics & geography',    price: 799,  icon: Icons.public_rounded,       color: Color(0xFFBF360C)),
  ],
  6: [
    SubjectModel(id: 5, name: 'Maths',          description: 'Algebra, geometry & statistics', price: 1099, icon: Icons.calculate_rounded,    color: Color(0xFF1565C0)),
    SubjectModel(id: 6, name: 'Science',        description: 'Physics, chemistry & biology',   price: 999,  icon: Icons.science_rounded,      color: Color(0xFF00838F)),
    SubjectModel(id: 7, name: 'English',        description: 'Literature & language skills',   price: 899,  icon: Icons.menu_book_rounded,    color: Color(0xFF6A1B9A)),
    SubjectModel(id: 8, name: 'Social Studies', description: 'Ancient history & civics',       price: 899,  icon: Icons.public_rounded,       color: Color(0xFFBF360C)),
  ],
  7: [
    SubjectModel(id: 9, name: 'Maths',          description: 'Rational numbers & equations',   price: 1199, icon: Icons.calculate_rounded,    color: Color(0xFF1565C0)),
    SubjectModel(id: 10, name: 'Science',        description: 'Motion, cells & materials',      price: 1099, icon: Icons.science_rounded,      color: Color(0xFF00838F)),
    SubjectModel(id: 11, name: 'English',        description: 'Advanced prose & poetry',        price: 999,  icon: Icons.menu_book_rounded,    color: Color(0xFF6A1B9A)),
    SubjectModel(id: 12, name: 'Social Studies', description: 'Medieval history & resources',   price: 999,  icon: Icons.public_rounded,       color: Color(0xFFBF360C)),
  ],
  8: [
    SubjectModel(id: 13, name: 'Maths',          description: 'Linear equations & data',        price: 1299, icon: Icons.calculate_rounded,    color: Color(0xFF1565C0)),
    SubjectModel(id: 14, name: 'Science',        description: 'Chemical reactions & forces',    price: 1199, icon: Icons.science_rounded,      color: Color(0xFF00838F)),
    SubjectModel(id: 15, name: 'English',        description: 'Creative writing & grammar',     price: 1099, icon: Icons.menu_book_rounded,    color: Color(0xFF6A1B9A)),
    SubjectModel(id: 16, name: 'Social Studies', description: 'Modern history & economics',     price: 1099, icon: Icons.public_rounded,       color: Color(0xFFBF360C)),
  ],
  9: [
    SubjectModel(id: 17, name: 'Maths',          description: 'Polynomials, triangles & more',  price: 1499, icon: Icons.calculate_rounded,    color: Color(0xFF1565C0)),
    SubjectModel(id: 18, name: 'Science',        description: 'Gravitation, atoms & tissues',   price: 1299, icon: Icons.science_rounded,      color: Color(0xFF00838F)),
    SubjectModel(id: 19, name: 'English',        description: 'Prose, poetry & grammar',        price: 1199, icon: Icons.menu_book_rounded,    color: Color(0xFF6A1B9A)),
    SubjectModel(id: 20, name: 'Social Studies', description: 'Contemporary India & economy',   price: 1199, icon: Icons.public_rounded,       color: Color(0xFFBF360C)),
  ],
  10: [
    SubjectModel(id: 21, name: 'Maths',          description: 'Quadratics, circles & stats',    price: 1699, icon: Icons.calculate_rounded,    color: Color(0xFF1565C0)),
    SubjectModel(id: 22, name: 'Science',        description: 'Electricity, heredity & optics', price: 1499, icon: Icons.science_rounded,      color: Color(0xFF00838F)),
    SubjectModel(id: 23, name: 'English',        description: 'First flight & footprints',      price: 1299, icon: Icons.menu_book_rounded,    color: Color(0xFF6A1B9A)),
    SubjectModel(id: 24, name: 'Social Studies', description: 'Nationalism, resources & eco',   price: 1299, icon: Icons.public_rounded,       color: Color(0xFFBF360C)),
  ],
};

const Map<int, int> fullCoursePrices = {
  5: 2999, 6: 3299, 7: 3599, 8: 3799, 9: 3999, 10: 4499,
};
