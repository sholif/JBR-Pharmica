import '../entities/disease.dart';
import '../entities/antibiotic.dart';
import '../entities/recommendation.dart';
import '../entities/search_result.dart';

abstract class ClinicalRepository {
  Future<void> syncClinicalData();
  Future<bool> isLocalDataAvailable();

  Future<List<SearchResult>> searchClinicalData(String query);

  Future<Disease?> getDiseaseDetail(int diseaseId);
  Future<List<Recommendation>> getDiseaseRecommendations(int diseaseId);

  Future<Antibiotic?> getAntibioticDetail(int antibioticId);
  Future<List<Recommendation>> getAntibioticRecommendations(int antibioticId);
}
