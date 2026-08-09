import 'explore_subjects.dart';

class CategoryModel {
  final int id;
  final String name;
  final String? iconUrl;
  final int? coursesCount;

  CategoryModel({
    required this.id,
    required this.name,
    this.iconUrl,
    this.coursesCount,
  });

  factory CategoryModel.fromJson(Map<String, dynamic> json) {
    return CategoryModel(
      id: json['id'],
      name: json['name'] ?? 'Untitled Category',
      iconUrl: json['icon_url'],
      coursesCount: json['courses_count'],
    );
  }
}

class CourseModel {
  final int id;
  final String name;
  final String? description;
  final String? price;
  final String? mrp;
  final String? save;
  final List<dynamic>? subjects;
  final String? thumbnailUrl;
  final int? subjectsCount;
  final String? iconUrl;
  final String? colorCode;

  CourseModel({
    required this.id,
    required this.name,
    this.description,
    this.price,
    this.mrp,
    this.save,
    this.subjects,
    this.thumbnailUrl,
    this.subjectsCount,
    this.iconUrl,
    this.colorCode,
  });

  factory CourseModel.fromJson(Map<String, dynamic> json) {
    return CourseModel(
      id: json['id'],
      name: json['name'] ?? 'Untitled Course',
      description: json['description'],
      price: json['price']?.toString(),
      mrp: json['mrp']?.toString(),
      save: json['save']?.toString(),
      subjects: json['subjects'] as List?,
      thumbnailUrl: json['thumbnail_url'],
      subjectsCount: json['subjects_count'],
      iconUrl: json['icon_url'],
      colorCode: json['color_code'],
    );
  }
}

class BannerModel {
  final int id;
  final String title;
  final String? subtitle;
  final String icon;
  final String colorStart;
  final String colorEnd;
  final String? link;

  BannerModel({
    required this.id,
    required this.title,
    this.subtitle,
    required this.icon,
    required this.colorStart,
    required this.colorEnd,
    this.link,
  });

  factory BannerModel.fromJson(Map<String, dynamic> json) {
    return BannerModel(
      id: json['id'],
      title: json['title'] ?? '',
      subtitle: json['subtitle'],
      icon: json['icon'] ?? 'fa-graduation-cap',
      colorStart: json['color_start'] ?? '#1565C0',
      colorEnd: json['color_end'] ?? '#7B1FA2',
      link: json['link'],
    );
  }
}

class CartItemModel {
  final int id;
  final String itemType;
  final int itemId;
  final String price;
  final List<int>? bundleSubjects;
  final dynamic item; // Can be CourseModel or SubjectModel

  CartItemModel({
    required this.id,
    required this.itemType,
    required this.itemId,
    required this.price,
    this.bundleSubjects,
    this.item,
  });

  factory CartItemModel.fromJson(Map<String, dynamic> json) {
    return CartItemModel(
      id: json['id'],
      itemType: json['item_type'],
      itemId: json['item_id'],
      price: json['price']?.toString() ?? '0',
      bundleSubjects: json['bundle_subjects'] != null 
          ? List<int>.from(json['bundle_subjects']) 
          : null,
      item: json['item'] != null 
          ? (json['item_type'].contains('Course') 
              ? CourseModel.fromJson(json['item']) 
              : SubjectModel.fromJson(json['item']))
          : null,
    );
  }
}
