import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:edustream/features/subject/data/subject_repository.dart';
import 'package:edustream/features/subject/data/models/subject_models.dart';

final subjectRepositoryProvider = Provider((ref) => SubjectRepository());

final subjectDetailsProvider = FutureProvider.family<SubjectDetailModel, int>((ref, subjectId) async {
  final repo = ref.watch(subjectRepositoryProvider);
  return repo.fetchSubjectDetails(subjectId);
});

class FolderContentParam {
  final int subjectId;
  final int? folderId;
  final String type; // 'note', 'video', 'paper'

  FolderContentParam({required this.subjectId, this.folderId, required this.type});

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is FolderContentParam &&
          runtimeType == other.runtimeType &&
          subjectId == other.subjectId &&
          folderId == other.folderId &&
          type == other.type;

  @override
  int get hashCode => subjectId.hashCode ^ folderId.hashCode ^ type.hashCode;
}

final folderContentProvider = FutureProvider.family<FolderContentModel, FolderContentParam>((ref, param) async {
  final repo = ref.watch(subjectRepositoryProvider);
  if (param.type == 'video') {
    return repo.fetchSubjectVideos(param.subjectId, folderId: param.folderId);
  } else if (param.type == 'paper') {
    return repo.fetchSubjectPapers(param.subjectId, folderId: param.folderId);
  } else {
    return repo.fetchSubjectNotes(param.subjectId, folderId: param.folderId);
  }
});

final subjectNotesProvider = FutureProvider.family<FolderContentModel, int>((ref, subjectId) async {
  final repo = ref.watch(subjectRepositoryProvider);
  return repo.fetchSubjectNotes(subjectId);
});

final subjectVideosProvider = FutureProvider.family<FolderContentModel, int>((ref, subjectId) async {
  final repo = ref.watch(subjectRepositoryProvider);
  return repo.fetchSubjectVideos(subjectId);
});
