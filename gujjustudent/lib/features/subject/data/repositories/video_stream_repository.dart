import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/services/api_service.dart';

class VideoStreamRepository {
  final ApiService _apiService;

  VideoStreamRepository(this._apiService);

  Future<Map<String, dynamic>> fetchStreamUrl(int videoId) async {
    try {
      final response = await _apiService.get('video/$videoId/stream');
      
      if (response.data['success'] == true) {
        return response.data['data'];
      } else {
        throw Exception(response.data['message'] ?? 'Failed to fetch stream details');
      }
    } on DioException catch (e) {
      if (e.response != null && e.response?.data != null) {
         throw Exception(e.response?.data['message'] ?? 'Failed to fetch stream details');
      }
      throw Exception('Network error occurred');
    } catch (e) {
      throw Exception(e.toString());
    }
  }
}

final videoStreamRepositoryProvider = Provider<VideoStreamRepository>((ref) {
  return VideoStreamRepository(ApiService());
});
