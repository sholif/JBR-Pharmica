import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../domain/entities/disease.dart';
import '../../domain/entities/antibiotic.dart';
import '../../domain/entities/recommendation.dart';
import '../../domain/entities/search_result.dart';

class ClinicalController extends GetxController {
  final searchTextController = TextEditingController();

  final searchQuery = ''.obs;
  final selectedFilter = 'All'.obs;
  final isOnline = true.obs;
  final isOfflineMode = false.obs;

  final allResults = <SearchResult>[].obs;
  final filteredResults = <SearchResult>[].obs;

  final selectedDiseaseDetail = Rxn<DiseaseDetailData>();
  final selectedAntibioticDetail = Rxn<AntibioticDetailData>();
  final isLoadingDetail = false.obs;

  // Mock Datasets
  final List<Disease> _mockDiseases = const [
    Disease(id: 1, name: 'Sample Respiratory Infection', category: 'Respiratory', keywords: ['respiratory', 'infection', 'cough']),
    Disease(id: 2, name: 'Pneumonia', category: 'Respiratory', keywords: ['fever', 'cough', 'lung', 'chest pain']),
    Disease(id: 3, name: 'Acute Bronchitis', category: 'Respiratory', keywords: ['cough', 'mucus', 'bronchial']),
    Disease(id: 4, name: 'Urinary Tract Infection (UTI)', category: 'Urology', keywords: ['dysuria', 'urine', 'bladder', 'burning']),
    Disease(id: 5, name: 'Pyelonephritis', category: 'Urology', keywords: ['kidney', 'fever', 'flank pain', 'uti']),
    Disease(id: 6, name: 'Streptococcal Pharyngitis', category: 'ENT', keywords: ['throat', 'sore throat', 'fever', 'strep']),
    Disease(id: 7, name: 'Acute Otitis Media', category: 'ENT', keywords: ['ear', 'ear pain', 'infection', 'hearing']),
    Disease(id: 8, name: 'Cellulitis', category: 'Dermatology', keywords: ['skin', 'redness', 'swelling', 'bacterial']),
    Disease(id: 9, name: 'Impetigo', category: 'Dermatology', keywords: ['skin', 'blisters', 'crust', 'contagious']),
    Disease(id: 10, name: 'Bacterial Gastroenteritis', category: 'Gastroenterology', keywords: ['diarrhea', 'stomach', 'cramps', 'vomiting']),
    Disease(id: 11, name: 'Typhoid Fever', category: 'Gastroenterology', keywords: ['salmonella', 'fever', 'abdominal pain']),
    Disease(id: 12, name: 'Sepsis', category: 'Critical Care', keywords: ['blood infection', 'fever', 'systemic', 'severe']),
    Disease(id: 13, name: 'Bacterial Meningitis', category: 'Neurology', keywords: ['brain', 'stiff neck', 'fever', 'headache']),
    Disease(id: 14, name: 'Sinusitis', category: 'ENT', keywords: ['sinus', 'headache', 'nasal congestion']),
    Disease(id: 15, name: 'Infective Endocarditis', category: 'Cardiology', keywords: ['heart', 'valve', 'fever', 'bacterial']),
  ];

  final List<Antibiotic> _mockAntibiotics = const [
    Antibiotic(id: 10, name: 'Medicine Alpha', genericName: 'Sample Generic A'),
    Antibiotic(id: 11, name: 'Amoxicillin', genericName: 'Amoxicillin Trihydrate'),
    Antibiotic(id: 12, name: 'Azithromycin', genericName: 'Azithromycin Dihydrate'),
    Antibiotic(id: 13, name: 'Ciprofloxacin', genericName: 'Ciprofloxacin Hydrochloride'),
    Antibiotic(id: 14, name: 'Ceftriaxone', genericName: 'Ceftriaxone Sodium'),
    Antibiotic(id: 15, name: 'Doxycycline', genericName: 'Doxycycline Hyclate'),
    Antibiotic(id: 16, name: 'Cephalexin', genericName: 'Cephalexin Monohydrate'),
    Antibiotic(id: 17, name: 'Metronidazole', genericName: 'Metronidazole'),
    Antibiotic(id: 18, name: 'Levofloxacin', genericName: 'Levofloxacin Hemihydrate'),
    Antibiotic(id: 19, name: 'Vancomycin', genericName: 'Vancomycin Hydrochloride'),
  ];

  final List<Recommendation> _mockRecommendations = const [
    Recommendation(id: 100, diseaseId: 1, antibioticId: 10, type: 'First Line', dose: '500 mg', frequency: 'Twice daily', duration: '5 days', diseaseName: 'Sample Respiratory Infection', antibioticName: 'Medicine Alpha', genericName: 'Sample Generic A'),
    Recommendation(id: 101, diseaseId: 1, antibioticId: 12, type: 'Alternative', dose: '250 mg', frequency: 'Once daily', duration: '3 days', diseaseName: 'Sample Respiratory Infection', antibioticName: 'Azithromycin', genericName: 'Azithromycin Dihydrate'),
    Recommendation(id: 102, diseaseId: 2, antibioticId: 11, type: 'First Line', dose: '1000 mg', frequency: 'Three times daily', duration: '7 days', diseaseName: 'Pneumonia', antibioticName: 'Amoxicillin', genericName: 'Amoxicillin Trihydrate'),
    Recommendation(id: 103, diseaseId: 2, antibioticId: 18, type: 'Alternative', dose: '500 mg', frequency: 'Once daily', duration: '7 days', diseaseName: 'Pneumonia', antibioticName: 'Levofloxacin', genericName: 'Levofloxacin Hemihydrate'),
    Recommendation(id: 104, diseaseId: 3, antibioticId: 12, type: 'First Line', dose: '500 mg', frequency: 'Once daily', duration: '5 days', diseaseName: 'Acute Bronchitis', antibioticName: 'Azithromycin', genericName: 'Azithromycin Dihydrate'),
    Recommendation(id: 105, diseaseId: 4, antibioticId: 13, type: 'First Line', dose: '250 mg', frequency: 'Twice daily', duration: '3 days', diseaseName: 'Urinary Tract Infection (UTI)', antibioticName: 'Ciprofloxacin', genericName: 'Ciprofloxacin Hydrochloride'),
    Recommendation(id: 106, diseaseId: 4, antibioticId: 15, type: 'Alternative', dose: '100 mg', frequency: 'Twice daily', duration: '7 days', diseaseName: 'Urinary Tract Infection (UTI)', antibioticName: 'Doxycycline', genericName: 'Doxycycline Hyclate'),
    Recommendation(id: 107, diseaseId: 5, antibioticId: 14, type: 'First Line', dose: '1 g', frequency: 'Once daily', duration: '10 days', diseaseName: 'Pyelonephritis', antibioticName: 'Ceftriaxone', genericName: 'Ceftriaxone Sodium'),
    Recommendation(id: 108, diseaseId: 6, antibioticId: 11, type: 'First Line', dose: '500 mg', frequency: 'Twice daily', duration: '10 days', diseaseName: 'Streptococcal Pharyngitis', antibioticName: 'Amoxicillin', genericName: 'Amoxicillin Trihydrate'),
    Recommendation(id: 109, diseaseId: 7, antibioticId: 11, type: 'First Line', dose: '875 mg', frequency: 'Twice daily', duration: '10 days', diseaseName: 'Acute Otitis Media', antibioticName: 'Amoxicillin', genericName: 'Amoxicillin Trihydrate'),
    Recommendation(id: 110, diseaseId: 8, antibioticId: 16, type: 'First Line', dose: '500 mg', frequency: 'Four times daily', duration: '7 days', diseaseName: 'Cellulitis', antibioticName: 'Cephalexin', genericName: 'Cephalexin Monohydrate'),
    Recommendation(id: 111, diseaseId: 9, antibioticId: 16, type: 'First Line', dose: '250 mg', frequency: 'Four times daily', duration: '7 days', diseaseName: 'Impetigo', antibioticName: 'Cephalexin', genericName: 'Cephalexin Monohydrate'),
    Recommendation(id: 112, diseaseId: 10, antibioticId: 17, type: 'First Line', dose: '500 mg', frequency: 'Three times daily', duration: '5 days', diseaseName: 'Bacterial Gastroenteritis', antibioticName: 'Metronidazole', genericName: 'Metronidazole'),
    Recommendation(id: 113, diseaseId: 11, antibioticId: 14, type: 'First Line', dose: '2 g', frequency: 'Once daily', duration: '7 days', diseaseName: 'Typhoid Fever', antibioticName: 'Ceftriaxone', genericName: 'Ceftriaxone Sodium'),
    Recommendation(id: 114, diseaseId: 12, antibioticId: 19, type: 'First Line', dose: '15 mg/kg', frequency: 'Every 12 hours', duration: '14 days', diseaseName: 'Sepsis', antibioticName: 'Vancomycin', genericName: 'Vancomycin Hydrochloride'),
    Recommendation(id: 115, diseaseId: 13, antibioticId: 14, type: 'First Line', dose: '2 g', frequency: 'Every 12 hours', duration: '14 days', diseaseName: 'Bacterial Meningitis', antibioticName: 'Ceftriaxone', genericName: 'Ceftriaxone Sodium'),
    Recommendation(id: 116, diseaseId: 14, antibioticId: 11, type: 'First Line', dose: '875 mg', frequency: 'Twice daily', duration: '5 days', diseaseName: 'Sinusitis', antibioticName: 'Amoxicillin', genericName: 'Amoxicillin Trihydrate'),
    Recommendation(id: 117, diseaseId: 15, antibioticId: 19, type: 'First Line', dose: '30 mg/kg', frequency: 'Continuous', duration: '6 weeks', diseaseName: 'Infective Endocarditis', antibioticName: 'Vancomycin', genericName: 'Vancomycin Hydrochloride'),
    Recommendation(id: 118, diseaseId: 8, antibioticId: 15, type: 'Alternative', dose: '100 mg', frequency: 'Twice daily', duration: '10 days', diseaseName: 'Cellulitis', antibioticName: 'Doxycycline', genericName: 'Doxycycline Hyclate'),
    Recommendation(id: 119, diseaseId: 10, antibioticId: 13, type: 'Alternative', dose: '500 mg', frequency: 'Twice daily', duration: '3 days', diseaseName: 'Bacterial Gastroenteritis', antibioticName: 'Ciprofloxacin', genericName: 'Ciprofloxacin Hydrochloride'),
  ];

  @override
  void onInit() {
    super.onInit();
    performSearch('');
  }

  void onSearchTextChanged(String val) {
    searchQuery.value = val;
    performSearch(val);
  }

  void clearSearch() {
    searchTextController.clear();
    searchQuery.value = '';
    performSearch('');
  }

  void setFilter(String filter) {
    selectedFilter.value = filter;
    _applyFilter();
  }

  void performSearch(String query) {
    final q = query.trim().toLowerCase();
    final List<SearchResult> results = [];

    ///>>>>>>>>>>>>>>>>> Search Diseases >>>>>>>>>>>>>>>>>>>>>>> ///
    for (var d in _mockDiseases) {
      final recs = _mockRecommendations.where((r) => r.diseaseId == d.id).toList();
      if (q.isEmpty) {
        results.add(SearchResult(
          type: SearchResultType.disease,
          disease: d,
          recommendations: recs,
          matchedField: 'Condition Name',
          relevanceScore: 100,
        ));
      } else {
        final dName = d.name.toLowerCase();
        final dCat = d.category.toLowerCase();
        final kwMatch = d.keywords.any((k) => k.toLowerCase().contains(q));

        if (dName == q) {
          results.add(SearchResult(type: SearchResultType.disease, disease: d, recommendations: recs, matchedField: 'Exact Name Match', relevanceScore: 100));
        } else if (dName.startsWith(q)) {
          results.add(SearchResult(type: SearchResultType.disease, disease: d, recommendations: recs, matchedField: 'Starts With Name', relevanceScore: 85));
        } else if (dName.contains(q)) {
          results.add(SearchResult(type: SearchResultType.disease, disease: d, recommendations: recs, matchedField: 'Condition Name', relevanceScore: 75));
        } else if (dCat.contains(q)) {
          results.add(SearchResult(type: SearchResultType.disease, disease: d, recommendations: recs, matchedField: 'Category Match', relevanceScore: 70));
        } else if (kwMatch) {
          results.add(SearchResult(type: SearchResultType.disease, disease: d, recommendations: recs, matchedField: 'Keyword Match', relevanceScore: 65));
        }
      }
    }

    ///>>>>>>>>>>>>>>>> Search Antibiotics  >>>>>>>>>>>>>>>>>>///
    for (var a in _mockAntibiotics) {
      final recs = _mockRecommendations.where((r) => r.antibioticId == a.id).toList();
      if (q.isEmpty) {
        results.add(SearchResult(
          type: SearchResultType.antibiotic,
          antibiotic: a,
          recommendations: recs,
          matchedField: 'Medicine Name',
          relevanceScore: 100,
        ));
      } else {
        final aName = a.name.toLowerCase();
        final gName = a.genericName.toLowerCase();

        if (aName == q) {
          results.add(SearchResult(type: SearchResultType.antibiotic, antibiotic: a, recommendations: recs, matchedField: 'Exact Medicine Match', relevanceScore: 100));
        } else if (aName.startsWith(q)) {
          results.add(SearchResult(type: SearchResultType.antibiotic, antibiotic: a, recommendations: recs, matchedField: 'Starts With Medicine', relevanceScore: 85));
        } else if (aName.contains(q) || gName.contains(q)) {
          results.add(SearchResult(type: SearchResultType.antibiotic, antibiotic: a, recommendations: recs, matchedField: 'Medicine / Generic Name', relevanceScore: 75));
        }
      }
    }

    results.sort((a, b) => b.relevanceScore.compareTo(a.relevanceScore));
    allResults.value = results;
    _applyFilter();
  }

  void _applyFilter() {
    final filter = selectedFilter.value;
    if (filter == 'Diseases') {
      filteredResults.value = allResults.where((r) => r.type == SearchResultType.disease).toList();
    } else if (filter == 'Antibiotics') {
      filteredResults.value = allResults.where((r) => r.type == SearchResultType.antibiotic).toList();
    } else {
      filteredResults.value = List.from(allResults);
    }
  }

  void fetchDiseaseDetail(int diseaseId) {
    isLoadingDetail.value = true;
    final disease = _mockDiseases.firstWhereOrNull((d) => d.id == diseaseId);
    if (disease != null) {
      final recs = _mockRecommendations.where((r) => r.diseaseId == diseaseId).toList();
      selectedDiseaseDetail.value = DiseaseDetailData(disease: disease, recommendations: recs);
    } else {
      selectedDiseaseDetail.value = null;
    }
    isLoadingDetail.value = false;
  }

  void fetchAntibioticDetail(int antibioticId) {
    isLoadingDetail.value = true;
    final antibiotic = _mockAntibiotics.firstWhereOrNull((a) => a.id == antibioticId);
    if (antibiotic != null) {
      final recs = _mockRecommendations.where((r) => r.antibioticId == antibioticId).toList();
      selectedAntibioticDetail.value = AntibioticDetailData(antibiotic: antibiotic, recommendations: recs);
    } else {
      selectedAntibioticDetail.value = null;
    }
    isLoadingDetail.value = false;
  }

  void toggleStatusBanner() {
    isOnline.value = !isOnline.value;
  }

  @override
  void onClose() {
    searchTextController.dispose();
    super.onClose();
  }
}

class DiseaseDetailData {
  final Disease disease;
  final List<Recommendation> recommendations;
  DiseaseDetailData({required this.disease, required this.recommendations});
}

class AntibioticDetailData {
  final Antibiotic antibiotic;
  final List<Recommendation> recommendations;
  AntibioticDetailData({required this.antibiotic, required this.recommendations});
}
