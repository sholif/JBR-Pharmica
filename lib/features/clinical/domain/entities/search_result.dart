enum SearchResultType { disease, antibiotic }

class SearchResult {
  final String id;
  final SearchResultType type;
  final String title;
  final String subtitle;
  final List<String> tags;
  final String matchReason;
  final int relevanceScore;
  final dynamic entity; // Disease or Antibiotic

  const SearchResult({
    required this.id,
    required this.type,
    required this.title,
    required this.subtitle,
    required this.tags,
    required this.matchReason,
    required this.relevanceScore,
    required this.entity,
  });
}
