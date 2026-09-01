import 'package:sqflite/sqflite.dart';
import '../../../../core/database/database_helper.dart';
import '../models/disease_model.dart';
import '../models/antibiotic_model.dart';
import '../models/recommendation_model.dart';
import '../../domain/entities/search_result.dart';

abstract class ClinicalLocalDataSource {
  Future<void> saveClinicalData({
    required List<DiseaseModel> diseases,
    required List<AntibioticModel> antibiotics,
    required List<RecommendationModel> recommendations,
  });

  Future<bool> hasData();

  Future<List<DiseaseModel>> getAllDiseases();
  Future<List<AntibioticModel>> getAllAntibiotics();

  Future<DiseaseModel?> getDiseaseById(int id);
  Future<AntibioticModel?> getAntibioticById(int id);

  Future<List<RecommendationModel>> getRecommendationsForDisease(int diseaseId);
  Future<List<RecommendationModel>> getRecommendationsForAntibiotic(int antibioticId);

  Future<List<SearchResult>> searchClinicalData(String query);
}

class ClinicalLocalDataSourceImpl implements ClinicalLocalDataSource {
  final DatabaseHelper dbHelper;

  ClinicalLocalDataSourceImpl(this.dbHelper);

  @override
  Future<void> saveClinicalData({
    required List<DiseaseModel> diseases,
    required List<AntibioticModel> antibiotics,
    required List<RecommendationModel> recommendations,
  }) async {
    final diseasesJson = diseases.map((e) => e.toJson()).toList();
    final antibioticsJson = antibiotics.map((e) => e.toJson()).toList();
    final recommendationsJson = recommendations.map((e) => e.toJson()).toList();

    await dbHelper.saveClinicalData(
      diseases: diseasesJson,
      antibiotics: antibioticsJson,
      recommendations: recommendationsJson,
    );
  }

  @override
  Future<bool> hasData() async {
    final db = await dbHelper.database;
    final count = Sqflite.firstIntValue(
      await db.rawQuery('SELECT COUNT(*) FROM ${DatabaseHelper.tableDiseases}'),
    );
    return (count ?? 0) > 0;
  }

  @override
  Future<List<DiseaseModel>> getAllDiseases() async {
    final db = await dbHelper.database;
    final maps = await db.query(DatabaseHelper.tableDiseases);
    return maps.map((e) => DiseaseModel.fromJson(e)).toList();
  }

  @override
  Future<List<AntibioticModel>> getAllAntibiotics() async {
    final db = await dbHelper.database;
    final maps = await db.query(DatabaseHelper.tableAntibiotics);
    return maps.map((e) => AntibioticModel.fromJson(e)).toList();
  }

  @override
  Future<DiseaseModel?> getDiseaseById(int id) async {
    final db = await dbHelper.database;
    final maps = await db.query(
      DatabaseHelper.tableDiseases,
      where: 'id = ?',
      whereArgs: [id],
    );
    if (maps.isNotEmpty) {
      return DiseaseModel.fromJson(maps.first);
    }
    return null;
  }

  @override
  Future<AntibioticModel?> getAntibioticById(int id) async {
    final db = await dbHelper.database;
    final maps = await db.query(
      DatabaseHelper.tableAntibiotics,
      where: 'id = ?',
      whereArgs: [id],
    );
    if (maps.isNotEmpty) {
      return AntibioticModel.fromJson(maps.first);
    }
    return null;
  }

  @override
  Future<List<RecommendationModel>> getRecommendationsForDisease(int diseaseId) async {
    final db = await dbHelper.database;
    final maps = await db.rawQuery('''
      SELECT r.*, a.name AS antibiotic_name, a.generic_name AS generic_name
      FROM ${DatabaseHelper.tableRecommendations} r
      JOIN ${DatabaseHelper.tableAntibiotics} a ON r.antibiotic_id = a.id
      WHERE r.disease_id = ?
    ''', [diseaseId]);

    return maps.map((e) => RecommendationModel.fromJson(e)).toList();
  }

  @override
  Future<List<RecommendationModel>> getRecommendationsForAntibiotic(int antibioticId) async {
    final db = await dbHelper.database;
    final maps = await db.rawQuery('''
      SELECT r.*, d.name AS disease_name
      FROM ${DatabaseHelper.tableRecommendations} r
      JOIN ${DatabaseHelper.tableDiseases} d ON r.disease_id = d.id
      WHERE r.antibiotic_id = ?
    ''', [antibioticId]);

    return maps.map((e) => RecommendationModel.fromJson(e)).toList();
  }

  @override
  Future<List<SearchResult>> searchClinicalData(String rawQuery) async {
    final trimmedQuery = rawQuery.trim().toLowerCase();
    if (trimmedQuery.isEmpty) return [];

    final diseases = await getAllDiseases();
    final antibiotics = await getAllAntibiotics();
    final db = await dbHelper.database;

    final allRecsMap = await db.rawQuery('''
      SELECT r.*, d.name AS disease_name, a.name AS antibiotic_name, a.generic_name AS generic_name
      FROM ${DatabaseHelper.tableRecommendations} r
      JOIN ${DatabaseHelper.tableDiseases} d ON r.disease_id = d.id
      JOIN ${DatabaseHelper.tableAntibiotics} a ON r.antibiotic_id = a.id
    ''');
    final allRecs = allRecsMap.map((e) => RecommendationModel.fromJson(e)).toList();

    final List<SearchResult> results = [];
    final queryWords = trimmedQuery.split(RegExp(r'\s+')).where((w) => w.isNotEmpty).toList();

    // 1. Search Diseases
    for (var disease in diseases) {
      final diseaseNameLower = disease.name.toLowerCase();
      final categoryLower = disease.category.toLowerCase();
      final keywordsLower = disease.keywords.map((k) => k.toLowerCase()).toList();

      int score = 0;
      String matchReason = '';

      if (diseaseNameLower == trimmedQuery) {
        score = 100;
        matchReason = 'Exact condition name match';
      } else if (diseaseNameLower.startsWith(trimmedQuery)) {
        score = 85;
        matchReason = 'Condition name starts with "$rawQuery"';
      } else if (diseaseNameLower.contains(trimmedQuery)) {
        score = 75;
        matchReason = 'Condition name contains "$rawQuery"';
      } else if (categoryLower.contains(trimmedQuery)) {
        score = 70;
        matchReason = 'Category match ($rawQuery)';
      } else {
        bool keywordMatch = keywordsLower.any((k) => k.contains(trimmedQuery) || trimmedQuery.contains(k));
        if (!keywordMatch && queryWords.length > 1) {
          keywordMatch = queryWords.any((qw) => keywordsLower.any((k) => k.contains(qw)));
        }
        if (keywordMatch) {
          score = 65;
          matchReason = 'Keyword match in condition';
        } else {
          // Check associated recommendations
          final associatedRecs = allRecs.where((r) => r.diseaseId == disease.id);
          final recMatch = associatedRecs.any((r) =>
              r.antibioticName?.toLowerCase().contains(trimmedQuery) == true ||
              r.genericName?.toLowerCase().contains(trimmedQuery) == true ||
              r.type.toLowerCase().contains(trimmedQuery) ||
              r.dose.toLowerCase().contains(trimmedQuery));
          if (recMatch) {
            score = 45;
            matchReason = 'Treatment recommendation match';
          }
        }
      }

      if (score > 0) {
        final recsForDisease = allRecs.where((r) => r.diseaseId == disease.id).toList();
        final recSummary = recsForDisease.map((r) => '${r.type}: ${r.antibioticName ?? "Medicine"} (${r.dose})').join(' • ');

        results.add(
          SearchResult(
            id: 'disease_${disease.id}',
            type: SearchResultType.disease,
            title: disease.name,
            subtitle: 'Category: ${disease.category}${recSummary.isNotEmpty ? " | $recSummary" : ""}',
            tags: [disease.category, ...disease.keywords],
            matchReason: matchReason,
            relevanceScore: score,
            entity: disease,
          ),
        );
      }
    }

    // 2. Search Antibiotics
    for (var antibiotic in antibiotics) {
      final nameLower = antibiotic.name.toLowerCase();
      final genericLower = antibiotic.genericName.toLowerCase();

      int score = 0;
      String matchReason = '';

      if (nameLower == trimmedQuery || genericLower == trimmedQuery) {
        score = 100;
        matchReason = 'Exact medicine / generic name match';
      } else if (nameLower.startsWith(trimmedQuery) || genericLower.startsWith(trimmedQuery)) {
        score = 85;
        matchReason = 'Medicine / generic name starts with "$rawQuery"';
      } else if (nameLower.contains(trimmedQuery) || genericLower.contains(trimmedQuery)) {
        score = 75;
        matchReason = 'Medicine / generic name contains "$rawQuery"';
      } else {
        final associatedRecs = allRecs.where((r) => r.antibioticId == antibiotic.id);
        final diseaseMatch = associatedRecs.any((r) =>
            r.diseaseName?.toLowerCase().contains(trimmedQuery) == true ||
            r.type.toLowerCase().contains(trimmedQuery));
        if (diseaseMatch) {
          score = 50;
          matchReason = 'Associated condition / treatment match';
        }
      }

      if (score > 0) {
        final recsForAntibiotic = allRecs.where((r) => r.antibioticId == antibiotic.id).toList();
        final diseaseSummary = recsForAntibiotic.map((r) => '${r.diseaseName ?? "Condition"} (${r.type})').join(' • ');

        results.add(
          SearchResult(
            id: 'antibiotic_${antibiotic.id}',
            type: SearchResultType.antibiotic,
            title: antibiotic.name,
            subtitle: 'Generic: ${antibiotic.genericName}${diseaseSummary.isNotEmpty ? " | Treats: $diseaseSummary" : ""}',
            tags: ['Antibiotic', antibiotic.genericName],
            matchReason: matchReason,
            relevanceScore: score,
            entity: antibiotic,
          ),
        );
      }
    }

    // Sort by relevance score
    results.sort((a, b) => b.relevanceScore.compareTo(a.relevanceScore));
    return results;
  }
}
