import '../../../../core/network/network_exceptions.dart';
import '../../domain/entities/disease.dart';
import '../../domain/entities/antibiotic.dart';
import '../../domain/entities/recommendation.dart';
import '../../domain/entities/search_result.dart';
import '../../domain/repositories/clinical_repository.dart';
import '../datasources/clinical_remote_data_source.dart';
import '../datasources/clinical_local_data_source.dart';

class ClinicalRepositoryImpl implements ClinicalRepository {
  final ClinicalRemoteDataSource remoteDataSource;
  final ClinicalLocalDataSource localDataSource;

  ClinicalRepositoryImpl({
    required this.remoteDataSource,
    required this.localDataSource,
  });

  @override
  Future<void> syncClinicalData() async {
    try {
      final remoteData = await remoteDataSource.fetchClinicalData();
      await localDataSource.saveClinicalData(
        diseases: remoteData.diseases,
        antibiotics: remoteData.antibiotics,
        recommendations: remoteData.recommendations,
      );
    } catch (e) {
      final hasLocal = await localDataSource.hasData();
      if (hasLocal) {
        // Fallback to local cached data silently or log warning
        return;
      }
      if (e is NetworkException) {
        rethrow;
      }
      throw ServerException('Failed to synchronize clinical data: $e');
    }
  }

  @override
  Future<bool> isLocalDataAvailable() async {
    return await localDataSource.hasData();
  }

  @override
  Future<List<SearchResult>> searchClinicalData(String query) async {
    return await localDataSource.searchClinicalData(query);
  }

  @override
  Future<Disease?> getDiseaseDetail(int diseaseId) async {
    return await localDataSource.getDiseaseById(diseaseId);
  }

  @override
  Future<List<Recommendation>> getDiseaseRecommendations(int diseaseId) async {
    return await localDataSource.getRecommendationsForDisease(diseaseId);
  }

  @override
  Future<Antibiotic?> getAntibioticDetail(int antibioticId) async {
    return await localDataSource.getAntibioticById(antibioticId);
  }

  @override
  Future<List<Recommendation>> getAntibioticRecommendations(int antibioticId) async {
    return await localDataSource.getRecommendationsForAntibiotic(antibioticId);
  }
}
