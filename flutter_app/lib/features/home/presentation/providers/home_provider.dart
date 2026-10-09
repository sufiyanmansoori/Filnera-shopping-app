import 'package:flutter/foundation.dart';

import '../../data/repositories/home_repository.dart';
import '../../domain/entities/banner_entity.dart';
import '../../domain/entities/home_entity.dart';

class HomeProvider extends ChangeNotifier {
  HomeProvider({required this._repository});

  final HomeRepository _repository;

  bool _isLoading = false;
  String? _errorMessage;
  HomePageEntity? _homePage;

  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  HomePageEntity? get homePage => _homePage;

  List<BannerEntity> get banners =>
      _homePage?.banners ?? const <BannerEntity>[];
  List<HomeCategoryEntity> get categories =>
      _homePage?.categories ?? const <HomeCategoryEntity>[];
  List<HomeDealEntity> get deals =>
      _homePage?.deals ?? const <HomeDealEntity>[];
  List<HomeProductEntity> get featuredProducts =>
      _homePage?.products ?? const <HomeProductEntity>[];

  Future<void> fetchHome() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _homePage = await _repository.getHomePage();
    } catch (e) {
      _errorMessage = e.toString();
      if (kDebugMode) {
        print('HomeProvider error: $e');
      }
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> loadPersonalizedDeals({required String customerId}) async {
    try {
      final deals = await _repository.getPersonalizedDeals(
        customerId: customerId,
      );
      if (_homePage != null) {
        _homePage = HomePageEntity(
          banners: _homePage!.banners,
          categories: _homePage!.categories,
          deals: deals,
          products: _homePage!.products,
          updatedAt: _homePage!.updatedAt,
        );
      }
      notifyListeners();
    } catch (e) {
      _errorMessage = e.toString();
      notifyListeners();
    }
  }

  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }
}
