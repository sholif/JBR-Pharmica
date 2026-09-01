import 'dart:async';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../core/network/network_info.dart';
import '../../domain/entities/search_result.dart';
import '../../domain/usecases/sync_clinical_data_usecase.dart';
import '../../domain/usecases/search_clinical_data_usecase.dart';
import '../../domain/usecases/get_disease_detail_usecase.dart';
import '../../domain/usecases/get_antibiotic_detail_usecase.dart';
import '../../domain/repositories/clinical_repository.dart';

class ClinicalController extends GetxController {
  final SyncClinicalDataUseCase syncUseCase;
  final SearchClinicalDataUseCase searchUseCase;
  final GetDiseaseDetailUseCase diseaseDetailUseCase;
  final GetAntibioticDetailUseCase antibioticDetailUseCase;
  final ClinicalRepository repository;
  final NetworkInfo networkInfo;

  StreamSubscription<List<ConnectivityResult>>? _connectivitySubscription;

  ClinicalController({
    required this.syncUseCase,
    required this.searchUseCase,
    required this.diseaseDetailUseCase,
    required this.antibioticDetailUseCase,
    required this.repository,
    required this.networkInfo,
  });

  // Connection & Sync state
  final RxBool isOnline = true.obs;
  final RxBool isSyncing = false.obs;
  final RxBool isOfflineMode = false.obs;
  final RxString statusMessage = ''.obs;
  final RxString errorMessage = ''.obs;

  // Search state
  final TextEditingController searchTextController = TextEditingController();
  final RxString searchQuery = ''.obs;
  final RxList<SearchResult> searchResults = <SearchResult>[].obs;
  final RxList<SearchResult> filteredResults = <SearchResult>[].obs;
  final RxString selectedFilter = 'All'.obs; // All, Diseases, Antibiotics
  final RxBool isSearching = false.obs;

  // Detail view state
  final Rx<DiseaseDetailData?> selectedDiseaseDetail = Rx<DiseaseDetailData?>(null);
  final Rx<AntibioticDetailData?> selectedAntibioticDetail = Rx<AntibioticDetailData?>(null);
  final RxBool isLoadingDetail = false.obs;

  @override
  void onInit() {
    super.onInit();
    _checkConnectivity();
    _listenConnectivityChanges();
    syncData();

    // Debounce search query
    debounce(
      searchQuery,
      (String query) => performSearch(query),
      time: const Duration(milliseconds: 300),
    );

    ever(selectedFilter, (_) => _applyCategoryFilter());
  }

  Future<void> _checkConnectivity() async {
    final connected = await networkInfo.isConnected;
    isOnline.value = connected;
    _updateStatusMessage();
  }

  void _listenConnectivityChanges() {
    _connectivitySubscription = Connectivity().onConnectivityChanged.listen((List<ConnectivityResult> results) {
      final connected = !results.contains(ConnectivityResult.none);
      isOnline.value = connected;
      _updateStatusMessage();
      if (connected) {
        syncData();
      }
    });
  }

  void _updateStatusMessage() {
    if (isOnline.value && !isOfflineMode.value) {
      statusMessage.value = 'Online — Synchronized with clinical server';
    } else {
      statusMessage.value = 'Offline — Using downloaded clinical information';
    }
  }

  Future<void> syncData() async {
    isSyncing.value = true;
    errorMessage.value = '';

    try {
      await syncUseCase.execute();
      isOfflineMode.value = false;
      _updateStatusMessage();
      // Re-trigger search to update dataset view
      await performSearch(searchQuery.value);
    } catch (e) {
      final hasLocal = await repository.isLocalDataAvailable();
      if (hasLocal) {
        isOfflineMode.value = true;
        _updateStatusMessage();
        await performSearch(searchQuery.value);
      } else {
        errorMessage.value = e.toString();
      }
    } finally {
      isSyncing.value = false;
    }
  }

  Future<void> performSearch(String query) async {
    isSearching.value = true;
    try {
      if (query.trim().isEmpty) {
        // If empty query, show all records default list
        final allDiseases = await searchUseCase.execute('a'); 
        // fallback to query with empty or space, get full list
        final fullResults = await searchUseCase.execute('');
        searchResults.assignAll(fullResults.isEmpty ? allDiseases : fullResults);
      } else {
        final results = await searchUseCase.execute(query);
        searchResults.assignAll(results);
      }
      _applyCategoryFilter();
    } catch (e) {
      errorMessage.value = 'Search failed: $e';
    } finally {
      isSearching.value = false;
    }
  }

  void _applyCategoryFilter() {
    if (selectedFilter.value == 'Diseases') {
      filteredResults.assignAll(searchResults.where((r) => r.type == SearchResultType.disease));
    } else if (selectedFilter.value == 'Antibiotics') {
      filteredResults.assignAll(searchResults.where((r) => r.type == SearchResultType.antibiotic));
    } else {
      filteredResults.assignAll(searchResults);
    }
  }

  void onSearchTextChanged(String text) {
    searchQuery.value = text;
  }

  void clearSearch() {
    searchTextController.clear();
    searchQuery.value = '';
  }

  void setFilter(String filter) {
    selectedFilter.value = filter;
  }

  Future<void> fetchDiseaseDetail(int id) async {
    isLoadingDetail.value = true;
    selectedDiseaseDetail.value = null;
    try {
      final detail = await diseaseDetailUseCase.execute(id);
      selectedDiseaseDetail.value = detail;
    } catch (e) {
      errorMessage.value = 'Failed to load disease details: $e';
    } finally {
      isLoadingDetail.value = false;
    }
  }

  Future<void> fetchAntibioticDetail(int id) async {
    isLoadingDetail.value = true;
    selectedAntibioticDetail.value = null;
    try {
      final detail = await antibioticDetailUseCase.execute(id);
      selectedAntibioticDetail.value = detail;
    } catch (e) {
      errorMessage.value = 'Failed to load medicine details: $e';
    } finally {
      isLoadingDetail.value = false;
    }
  }

  @override
  void onClose() {
    _connectivitySubscription?.cancel();
    searchTextController.dispose();
    super.onClose();
  }
}
