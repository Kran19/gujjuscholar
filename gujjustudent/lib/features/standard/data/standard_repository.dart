import 'package:flutter/material.dart';
import 'package:edustream/features/standard/data/models/standard_model.dart';

class StandardRepository {
  static final List<Standard> availableStandards = [
    Standard(
      label: "Standard 5th",
      tag: "5",
      icon: Icons.school_rounded,
      colors: [Colors.blue, Colors.blueAccent],
    ),
    Standard(
      label: "Standard 6th",
      tag: "6",
      icon: Icons.school_rounded,
      colors: [Colors.teal, Colors.tealAccent],
    ),
    Standard(
      label: "Standard 7th",
      tag: "7",
      icon: Icons.school_rounded,
      colors: [Colors.orange, Colors.orangeAccent],
    ),
    Standard(
      label: "Standard 8th",
      tag: "8",
      icon: Icons.school_rounded,
      colors: [Colors.red, Colors.redAccent],
    ),
    Standard(
      label: "Standard 9th",
      tag: "9",
      icon: Icons.school_rounded,
      colors: [Colors.indigo, Colors.indigoAccent],
    ),
    Standard(
      label: "Standard 10th",
      tag: "10",
      icon: Icons.school_rounded,
      colors: [Colors.deepPurple, Colors.deepPurpleAccent],
    ),
  ];

  static Standard getByTag(String tag) {
    return availableStandards.firstWhere(
      (s) => s.tag == tag,
      orElse: () => availableStandards.last,
    );
  }
}
