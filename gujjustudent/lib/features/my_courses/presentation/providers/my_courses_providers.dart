import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:edustream/core/services/api_service.dart';

final myCoursesProvider = FutureProvider<List<dynamic>>((ref) async {
  final api = ApiService();
  final response = await api.get('learning/my-courses');
  return response.data as List<dynamic>;
});
