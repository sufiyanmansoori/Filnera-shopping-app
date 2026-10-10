import '../entities/home_entity.dart';
import '../../data/repositories/home_repository.dart';

class GetHomeDataUseCase {
  const GetHomeDataUseCase(this.repository);

  final HomeRepository repository;

  Future<HomePageEntity> call() {
    return repository.getHomePage();
  }
}
