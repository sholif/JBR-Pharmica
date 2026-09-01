

import 'package:jbr_pharmica/features/clinical/domain/entities/antibiotic.dart';

class AntibioticModel extends Antibiotic {
  const AntibioticModel({
    required super.id,
    required super.name,
    required super.genericName,
  });

  factory AntibioticModel.fromJson(Map<String, dynamic> json) {
    return AntibioticModel(
      id: json['id'] is int ? json['id'] : int.parse(json['id'].toString()),
      name: json['name'] ?? '',
      genericName: json['generic_name'] ?? json['genericName'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'generic_name': genericName,
    };
  }

  factory AntibioticModel.fromEntity(Antibiotic entity) {
    return AntibioticModel(
      id: entity.id,
      name: entity.name,
      genericName: entity.genericName,
    );
  }
}
