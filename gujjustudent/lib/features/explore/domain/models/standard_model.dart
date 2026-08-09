import 'package:flutter/material.dart';

class ExploreStandard {
  final int id;
  final String name;
  final String category;
  final IconData icon;

  const ExploreStandard({
    required this.id,
    required this.name,
    required this.category,
    required this.icon,
  });
}

class StandardCategory {
  final String name;
  final List<ExploreStandard> standards;

  const StandardCategory({required this.name, required this.standards});
}

final List<StandardCategory> allStandardCategories = [
  StandardCategory(
    name: 'Primary',
    standards: [
      ExploreStandard(id: 0, name: 'Nursery', category: 'Primary', icon: Icons.child_care_rounded),
      ExploreStandard(id: 1, name: 'LKG', category: 'Primary', icon: Icons.emoji_nature_rounded),
      ExploreStandard(id: 2, name: 'UKG', category: 'Primary', icon: Icons.star_rounded),
    ],
  ),
  StandardCategory(
    name: 'Middle School',
    standards: [
      ExploreStandard(id: 5, name: 'Std 5', category: 'Middle School', icon: Icons.school_rounded),
      ExploreStandard(id: 6, name: 'Std 6', category: 'Middle School', icon: Icons.school_rounded),
      ExploreStandard(id: 7, name: 'Std 7', category: 'Middle School', icon: Icons.school_rounded),
    ],
  ),
  StandardCategory(
    name: 'High School',
    standards: [
      ExploreStandard(id: 8, name: 'Std 8', category: 'High School', icon: Icons.school_rounded),
      ExploreStandard(id: 9, name: 'Std 9', category: 'High School', icon: Icons.school_rounded),
      ExploreStandard(id: 10, name: 'Std 10', category: 'High School', icon: Icons.school_rounded),
    ],
  ),
];
