import 'package:flutter/material.dart';

class Standard {
  final String label;
  final String tag;
  final IconData icon;
  final List<Color> colors;
  final bool isPro;
  final List<Subject> subjects;

  Standard({
    required this.label,
    required this.tag,
    required this.icon,
    required this.colors,
    this.isPro = false,
    this.subjects = const [],
  });
}

class Subject {
  final String name;
  final IconData icon;
  final Color color;
  final double progress;
  final bool isPurchased;

  Subject({
    required this.name,
    required this.icon,
    required this.color,
    this.progress = 0.0,
    this.isPurchased = false,
  });
}
