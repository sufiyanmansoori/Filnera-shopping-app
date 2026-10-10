import 'package:flutter/foundation.dart';

import '../../domain/entities/home_entity.dart';
import '../../domain/usecases/get_home_data_usecase.dart';
import '../../domain/usecases/get_personalized_deals_usecase.dart';

class HomeController extends ChangeNotifier {
  HomeController({required this._getHomeData, this._getPersonalizedDeals});

  final GetHomeDataUseCase _getHomeData;
  final GetPersonalizedDealsUseCase? _getPersonalizedDeals;

  bool _isLoading = false;
  String? _error;
  HomePageEntity? _homePage;
  List<HomeDealEntity> _personalizedDeals = const <HomeDealEntity>[];

  bool get isLoading => _isLoading;
  String? get error => _error;
  HomePageEntity? get homePage => _homePage;
  List<HomeDealEntity> get personalizedDeals => _personalizedDeals;

  Future<void> loadHomePage() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _homePage = await _getHomeData();
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> loadPersonalizedDeals({required String customerId}) async {
    if (_getPersonalizedDeals == null) return;
    try {
      _personalizedDeals = await _getPersonalizedDeals(customerId: customerId);
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      notifyListeners();
    }
  }
}
