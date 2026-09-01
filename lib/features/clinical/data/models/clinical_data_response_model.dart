import 'disease_model.dart';
import 'antibiotic_model.dart';
import 'recommendation_model.dart';

class ClinicalDataResponseModel {
  final List<DiseaseModel> diseases;
  final List<AntibioticModel> antibiotics;
  final List<RecommendationModel> recommendations;

  ClinicalDataResponseModel({
    required this.diseases,
    required this.antibiotics,
    required this.recommendations,
  });

  factory ClinicalDataResponseModel.fromJson(dynamic json) {
    Map<String, dynamic> dataMap = {};

    if (json is List) {
      if (json.isNotEmpty && json.first is Map<String, dynamic>) {
        dataMap = json.first as Map<String, dynamic>;
      }
    } else if (json is Map<String, dynamic>) {
      dataMap = json;
    }

    final rawDiseases = dataMap['diseases'] as List? ?? [];
    final rawAntibiotics = dataMap['antibiotics'] as List? ?? [];
    final rawRecommendations = dataMap['recommendations'] as List? ?? [];

    return ClinicalDataResponseModel(
      diseases: rawDiseases.map((e) => DiseaseModel.fromJson(e as Map<String, dynamic>)).toList(),
      antibiotics: rawAntibiotics.map((e) => AntibioticModel.fromJson(e as Map<String, dynamic>)).toList(),
      recommendations: rawRecommendations.map((e) => RecommendationModel.fromJson(e as Map<String, dynamic>)).toList(),
    );
  }
}
