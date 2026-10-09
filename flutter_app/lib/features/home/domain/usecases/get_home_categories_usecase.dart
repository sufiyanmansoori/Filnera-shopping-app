import '../entities/home_data_entity.dart';

/// Retrieves searchable and paginated categories for home navigation.
class GetHomeCategoriesUseCase {
  const GetHomeCategoriesUseCase(this._repository);

  final HomeCategoriesRepository _repository;

  Future<List<HomeCategoryEntity>> call({
    bool forceRefresh = false,
    bool activeOnly = true,
    String? searchQuery,
    String? parentId,
    int page = 1,
    int pageSize = 50,
    String? locale,
    String? country,
  }) {
    return _repository.getCategories(
      forceRefresh: forceRefresh,
      activeOnly: activeOnly,
      searchQuery: searchQuery,
      parentId: parentId,
      page: page,
      pageSize: pageSize,
      locale: locale,
      country: country,
    );
  }
}

abstract class HomeCategoriesRepository {
  Future<List<HomeCategoryEntity>> getCategories({
    bool forceRefresh = false,
    bool activeOnly = true,
    String? searchQuery,
    String? parentId,
    int page = 1,
    int pageSize = 50,
    String? locale,
    String? country,
  });
}
