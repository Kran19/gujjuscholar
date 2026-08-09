import 'package:edustream/features/quiz/data/models/quiz_model.dart';

class SubjectDetailModel {
  final int id;
  final String name;
  final String? courseName;
  final String? description;
  final String? price;
  final String? iconUrl;
  final String? colorCode;
  final bool isEnrolled;
  final Map<String, int> contentSummary;
  final List<FolderModel> videoFolders;
  final List<FolderModel> noteFolders;
  final List<FolderModel> paperFolders;
  final List<VideoModel> rootVideos;
  final List<NoteModel> rootNotes;
  final List<NoteModel> rootPapers;
  final List<QuizModel> quizzes;

  SubjectDetailModel({
    required this.id,
    required this.name,
    this.courseName,
    this.description,
    this.price,
    this.iconUrl,
    this.colorCode,
    this.isEnrolled = false,
    this.contentSummary = const {},
    this.videoFolders = const [],
    this.noteFolders = const [],
    this.paperFolders = const [],
    this.rootVideos = const [],
    this.rootNotes = const [],
    this.rootPapers = const [],
    this.quizzes = const [],
  });

  factory SubjectDetailModel.fromJson(Map<String, dynamic> json) {
    final subjectJson = json['subject'] ?? {};
    final sections = json['sections'] as Map<String, dynamic>? ?? {};
    
    return SubjectDetailModel(
      id: subjectJson['id'] ?? 0,
      name: subjectJson['name'] ?? 'Unknown Subject',
      courseName: subjectJson['course']?['name'],
      description: subjectJson['description'],
      price: subjectJson['price']?.toString(),
      iconUrl: subjectJson['icon_url'],
      colorCode: subjectJson['color_code'],
      isEnrolled: json['is_enrolled'] ?? false,
      contentSummary: Map<String, int>.from(json['content_summary'] ?? {}),
      videoFolders: (sections['video_folders'] as List?)?.map((f) => FolderModel.fromJson(f, 'videos_count')).toList() ?? [],
      noteFolders: (sections['note_folders'] as List?)?.map((f) => FolderModel.fromJson(f, 'notes_count')).toList() ?? [],
      paperFolders: (sections['paper_folders'] as List?)?.map((f) => FolderModel.fromJson(f, 'qa_papers_count')).toList() ?? [],
      rootVideos: (sections['root_videos'] as List?)?.map((v) => VideoModel.fromJson(v)).toList() ?? [],
      rootNotes: (sections['root_notes'] as List?)?.map((n) => NoteModel.fromJson(n)).toList() ?? [],
      rootPapers: (sections['root_papers'] as List?)?.map((p) => NoteModel.fromJson(p)).toList() ?? [],
      quizzes: (sections['quizzes'] as List?)?.map((q) => QuizModel.fromJson(q)).toList() ?? [],
    );
  }
}

class FolderModel {
  final int id;
  final String name;
  final int itemCount;
  final bool isFree;

  FolderModel({
    required this.id,
    required this.name,
    required this.itemCount,
    required this.isFree,
  });

  factory FolderModel.fromJson(Map<String, dynamic> json, String countKey) {
    return FolderModel(
      id: json['id'] ?? 0,
      name: json['name'] ?? 'Folder',
      itemCount: json[countKey] ?? 0,
      isFree: json['is_free'] ?? false,
    );
  }
}


class NoteModel {
  final int id;
  final String name;
  final String? filePath;
  final bool isFree;
  final bool isLocked;

  NoteModel({
    required this.id,
    required this.name,
    this.filePath,
    required this.isFree,
    required this.isLocked,
  });

  factory NoteModel.fromJson(Map<String, dynamic> json) {
    return NoteModel(
      id: json['id'] ?? 0,
      name: json['name'] ?? 'Note',
      filePath: json['file_path'],
      isFree: json['is_free'] ?? false,
      isLocked: json['is_locked'] ?? true,
    );
  }
}

class VideoModel {
  final int id;
  final String name;
  final String? videoUrl;
  final String? duration;
  final bool isFree;
  final bool isLocked;
  final String processingStatus;

  VideoModel({
    required this.id,
    required this.name,
    this.videoUrl,
    this.duration,
    required this.isFree,
    required this.isLocked,
    this.processingStatus = 'completed',
  });

  factory VideoModel.fromJson(Map<String, dynamic> json) {
    return VideoModel(
      id: json['id'] ?? 0,
      name: json['name'] ?? 'Video',
      videoUrl: json['video_url'],
      duration: json['duration'],
      isFree: json['is_free'] ?? false,
      isLocked: json['is_locked'] ?? true,
      processingStatus: json['processing_status'] ?? 'completed',
    );
  }
}

class FolderContentModel {
  final List<FolderModel> folders;
  final List<dynamic> items;

  FolderContentModel({required this.folders, required this.items});

  factory FolderContentModel.fromJson(Map<String, dynamic> json, String type) {
    final folders = (json['folders'] as List?)?.map((f) {
      String countKey = 'notes_count';
      if (type == 'video') countKey = 'videos_count';
      if (type == 'paper') countKey = 'qa_papers_count';
      return FolderModel.fromJson(f, countKey);
    }).toList() ?? [];

    final itemsList = json['files'] as List?;
    List<dynamic> items = [];
    if (itemsList != null) {
      if (type == 'video') {
        items = itemsList.map((i) => VideoModel.fromJson(i)).toList();
      } else {
        items = itemsList.map((i) => NoteModel.fromJson(i)).toList();
      }
    }

    return FolderContentModel(folders: folders, items: items);
  }
}
