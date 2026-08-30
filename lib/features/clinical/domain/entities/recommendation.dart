class Recommendation {
  final int id;
  final int diseaseId;
  final int antibioticId;
  final String type;
  final String dose;
  final String frequency;
  final String duration;
  final String? diseaseName;
  final String? antibioticName;
  final String? genericName;

  const Recommendation({
    required this.id,
    required this.diseaseId,
    required this.antibioticId,
    required this.type,
    required this.dose,
    required this.frequency,
    required this.duration,
    this.diseaseName,
    this.antibioticName,
    this.genericName,
  });
}
