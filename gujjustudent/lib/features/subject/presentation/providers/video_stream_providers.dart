import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/repositories/video_stream_repository.dart';

final videoStreamUrlProvider = FutureProvider.autoDispose.family<Map<String, dynamic>, int>((ref, videoId) async {
  final repository = ref.watch(videoStreamRepositoryProvider);
  return repository.fetchStreamUrl(videoId);
});
