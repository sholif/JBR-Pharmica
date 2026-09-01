import 'dart:convert';
import '../../domain/entities/disease.dart';

class DiseaseModel extends Disease {
  const DiseaseModel({
    required super.id,
    required super.name,
    required super.category,
    required super.keywords,
  });

  factory DiseaseModel.fromJson(Map<String, dynamic> json) {
    List<String> parsedKeywords = [];
    if (json['keywords'] != null) {
      if (json['keywords'] is List) {
        parsedKeywords = List<String>.from(json['keywords'].map((x) => x.toString()));
      } else if (json['keywords'] is String) {
        final kwStr = json['keywords'] as String;
        try {
          final decoded = jsonDecode(kwStr);
          if (decoded is List) {
            parsedKeywords = List<String>.from(decoded.map((x) => x.toString()));
          } else {
            parsedKeywords = kwStr.split(',').map((e) => e.trim()).toList();
          }
        } catch (_) {
          parsedKeywords = kwStr.split(',').map((e) => e.trim()).toList();
        }
      }
    }

    return DiseaseModel(
      id: json['id'] is int ? json['id'] : int.parse(json['id'].toString()),
      name: json['name'] ?? '',
      category: json['category'] ?? '',
      keywords: parsedKeywords,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'category': category,
      'keywords': jsonEncode(keywords),
    };
  }

  factory DiseaseModel.fromEntity(Disease entity) {
    return DiseaseModel(
      id: entity.id,
      name: entity.name,
      category: entity.category,
      keywords: entity.keywords,
    );
  }
}
