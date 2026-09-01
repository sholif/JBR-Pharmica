import '../../domain/entities/recommendation.dart';

class RecommendationModel extends Recommendation {
  const RecommendationModel({
    required super.id,
    required super.diseaseId,
    required super.antibioticId,
    required super.type,
    required super.dose,
    required super.frequency,
    required super.duration,
    super.diseaseName,
    super.antibioticName,
    super.genericName,
  });

  factory RecommendationModel.fromJson(Map<String, dynamic> json) {
    return RecommendationModel(
      id: json['id'] is int ? json['id'] : int.parse(json['id'].toString()),
      diseaseId: json['disease_id'] is int ? json['disease_id'] : int.parse(json['disease_id'].toString()),
      antibioticId: json['antibiotic_id'] is int ? json['antibiotic_id'] : int.parse(json['antibiotic_id'].toString()),
      type: json['type'] ?? '',
      dose: json['dose'] ?? '',
      frequency: json['frequency'] ?? '',
      duration: json['duration'] ?? '',
      diseaseName: json['disease_name'],
      antibioticName: json['antibiotic_name'],
      genericName: json['generic_name'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'disease_id': diseaseId,
      'antibiotic_id': antibioticId,
      'type': type,
      'dose': dose,
      'frequency': frequency,
      'duration': duration,
    };
  }

  factory RecommendationModel.fromEntity(Recommendation entity) {
    return RecommendationModel(
      id: entity.id,
      diseaseId: entity.diseaseId,
      antibioticId: entity.antibioticId,
      type: entity.type,
      dose: entity.dose,
      frequency: entity.frequency,
      duration: entity.duration,
      diseaseName: entity.diseaseName,
      antibioticName: entity.antibioticName,
      genericName: entity.genericName,
    );
  }
}
