import '../entities/search_result.dart';
import '../repositories/clinical_repository.dart';

class SearchClinicalDataUseCase {
  final ClinicalRepository repository;

  SearchClinicalDataUseCase(this.repository);

  Future<List<SearchResult>> execute(String query) async {
    return await repository.searchClinicalData(query);
  }
}
