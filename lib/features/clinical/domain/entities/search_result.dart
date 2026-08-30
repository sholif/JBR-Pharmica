import 'disease.dart';
import 'antibiotic.dart';
import 'recommendation.dart';

enum SearchResultType { disease, antibiotic }

class SearchResult {
  final SearchResultType type;
  final Disease? disease;
  final Antibiotic? antibiotic;
  final List<Recommendation> recommendations;
  final String matchedField;
  final int relevanceScore;

  const SearchResult({
    required this.type,
    this.disease,
    this.antibiotic,
    this.recommendations = const [],
    required this.matchedField,
    required this.relevanceScore,
  });
}
