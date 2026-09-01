import '../entities/antibiotic.dart';
import '../entities/recommendation.dart';
import '../repositories/clinical_repository.dart';

class AntibioticDetailData {
  final Antibiotic antibiotic;
  final List<Recommendation> recommendations;

  AntibioticDetailData({
    required this.antibiotic,
    required this.recommendations,
  });
}

class GetAntibioticDetailUseCase {
  final ClinicalRepository repository;

  GetAntibioticDetailUseCase(this.repository);

  Future<AntibioticDetailData?> execute(int antibioticId) async {
    final antibiotic = await repository.getAntibioticDetail(antibioticId);
    if (antibiotic == null) return null;
    final recs = await repository.getAntibioticRecommendations(antibioticId);
    return AntibioticDetailData(antibiotic: antibiotic, recommendations: recs);
  }
}
