
import 'package:edustream/core/services/api_service.dart';
import 'package:edustream/features/subject/data/models/subject_models.dart';

class SubjectRepository {
  final ApiService _apiService = ApiService();

  Future<SubjectDetailModel> fetchSubjectDetails(int subjectId) async {
    try {
      final response = await _apiService.get('content/subjects/$subjectId');
      return SubjectDetailModel.fromJson(response.data);
    } catch (e) {
      rethrow;
    }
  }

  Future<FolderContentModel> fetchSubjectNotes(int subjectId, {int? folderId}) async {
    try {
      final response = await _apiService.get(
        'content/subjects/$subjectId/notes',
        queryParameters: folderId != null ? {'folder_id': folderId} : null,
      );
      return FolderContentModel.fromJson(response.data, 'note');
    } catch (e) {
      rethrow;
    }
  }

  Future<FolderContentModel> fetchSubjectVideos(int subjectId, {int? folderId}) async {
    try {
      final response = await _apiService.get(
        'content/subjects/$subjectId/videos',
        queryParameters: folderId != null ? {'folder_id': folderId} : null,
      );
      return FolderContentModel.fromJson(response.data, 'video');
    } catch (e) {
      rethrow;
    }
  }

  Future<FolderContentModel> fetchSubjectPapers(int subjectId, {int? folderId}) async {
    try {
      final response = await _apiService.get(
        'content/subjects/$subjectId/papers',
        queryParameters: folderId != null ? {'folder_id': folderId} : null,
      );
      return FolderContentModel.fromJson(response.data, 'paper');
    } catch (e) {
      rethrow;
    }
  }

  // Similar methods for papers and quizzes
}
