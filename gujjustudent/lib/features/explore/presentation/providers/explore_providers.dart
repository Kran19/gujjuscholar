import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:edustream/features/explore/data/explore_repository.dart';
import 'package:edustream/features/explore/data/models/explore_models.dart';

final exploreRepositoryProvider = Provider((ref) => ExploreRepository());

final categoriesProvider = FutureProvider<List<CategoryModel>>((ref) async {
  final repo = ref.watch(exploreRepositoryProvider);
  return repo.fetchCategories();
});

final categoryCoursesProvider = FutureProvider.family<List<CourseModel>, int>((ref, categoryId) async {
  final repo = ref.watch(exploreRepositoryProvider);
  return repo.fetchCategoryCourses(categoryId);
});

final allCoursesProvider = FutureProvider<List<CourseModel>>((ref) async {
  final repo = ref.watch(exploreRepositoryProvider);
  return repo.fetchAllCourses();
});

final homeDataProvider = FutureProvider<Map<String, dynamic>>((ref) async {
  final repo = ref.watch(exploreRepositoryProvider);
  return repo.fetchHomeData();
});

final exploreBannersProvider = FutureProvider<List<BannerModel>>((ref) async {
  final homeData = await ref.watch(homeDataProvider.future);
  final rawBanners = homeData['banners'] as List? ?? [];
  return rawBanners.map((e) => BannerModel.fromJson(e)).toList();
});

final recommendedCourseProvider = FutureProvider<CourseModel?>((ref) async {
  final homeData = await ref.watch(homeDataProvider.future);
  if (homeData['recommended_course'] == null) return null;
  return CourseModel.fromJson(homeData['recommended_course']);
});
final courseSubjectsProvider = FutureProvider.family<Map<String, dynamic>, int>((ref, courseId) async {
  final repo = ref.watch(exploreRepositoryProvider);
  return repo.fetchCourseSubjects(courseId);
});

final quizHubProvider = FutureProvider<List<dynamic>>((ref) async {
  final repo = ref.watch(exploreRepositoryProvider);
  return repo.fetchQuizHub();
});
