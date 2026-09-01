import '../entities/disease.dart';
import '../entities/recommendation.dart';
import '../repositories/clinical_repository.dart';

class DiseaseDetailData {
  final Disease disease;
  final List<Recommendation> recommendations;

  DiseaseDetailData({
    required this.disease,
    required this.recommendations,
  });
}

class GetDiseaseDetailUseCase {
  final ClinicalRepository repository;

  GetDiseaseDetailUseCase(this.repository);

  Future<DiseaseDetailData?> execute(int diseaseId) async {
    final disease = await repository.getDiseaseDetail(diseaseId);
    if (disease == null) return null;
    final recs = await repository.getDiseaseRecommendations(diseaseId);
    return DiseaseDetailData(disease: disease, recommendations: recs);
  }
}
