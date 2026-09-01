import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../core/theme/app_theme.dart';
import '../controllers/clinical_controller.dart';
import '../widgets/search_result_tile.dart';
import '../widgets/status_banner_widget.dart';

class SearchPage extends GetView<ClinicalController> {
  const SearchPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('JBR Pharmica'),
        actions: [
          IconButton(
            icon: const Icon(Icons.info_outline_rounded),
            onPressed: () {
              Get.defaultDialog(
                title: 'About JBR Pharmica',
                middleText:
                    'JBR Pharmica system for medical guidelines, diseases, and antibiotic recommendations.',
                confirmTextColor: Colors.white,
                textConfirm: 'Close',
                buttonColor: AppTheme.primaryColor,
                onConfirm: () => Get.back(),
              );
            },
          ),
        ],
      ),
      body: Column(
        children: [
          const StatusBannerWidget(),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                TextField(
                  controller: controller.searchTextController,
                  onChanged: controller.onSearchTextChanged,
                  decoration: InputDecoration(
                    hintText: 'Search disease, antibiotic or recommendation...',
                    prefixIcon: const Icon(Icons.search_rounded, color: AppTheme.primaryColor),
                    suffixIcon: Obx(() {
                      if (controller.searchQuery.value.isNotEmpty) {
                        return IconButton(
                          icon: const Icon(Icons.clear_rounded),
                          onPressed: controller.clearSearch,
                        );
                      }
                      return const SizedBox.shrink();
                    }),
                  ),
                ),
                const SizedBox(height: 12),
                // Filter Choice Chips
                Obx(() {
                  final filters = ['All', 'Diseases', 'Antibiotics'];
                  return SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: filters.map((filter) {
                        final isSelected = controller.selectedFilter.value == filter;
                        return Padding(
                          padding: const EdgeInsets.only(right: 8.0),
                          child: FilterChip(
                            label: Text(filter),
                            selected: isSelected,
                            selectedColor: AppTheme.primaryColor.withOpacity(0.2),
                            checkmarkColor: AppTheme.primaryColor,
                            labelStyle: TextStyle(
                              color: isSelected ? AppTheme.primaryColor : AppTheme.textPrimary,
                              fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                            ),
                            onSelected: (_) => controller.setFilter(filter),
                          ),
                        );
                      }).toList(),
                    ),
                  );
                }),
              ],
            ),
          ),
          // Main Body: Error state, loading state, empty state, or list
          Expanded(
            child: Obx(() {
              final error = controller.errorMessage.value;
              final isSyncing = controller.isSyncing.value;
              final results = controller.filteredResults;

              if (error.isNotEmpty && results.isEmpty) {
                return Center(
                  child: Padding(
                    padding: const EdgeInsets.all(24.0),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.cloud_off_rounded, size: 64, color: AppTheme.offlineColor),
                        const SizedBox(height: 16),
                        const Text(
                          'Unable to Download Clinical Data',
                          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          error,
                          textAlign: TextAlign.center,
                          style: const TextStyle(color: AppTheme.textSecondary),
                        ),
                        const SizedBox(height: 24),
                        ElevatedButton.icon(
                          onPressed: () => controller.syncData(),
                          icon: const Icon(Icons.refresh_rounded),
                          label: const Text('Retry Download'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppTheme.primaryColor,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              }

              if (isSyncing && results.isEmpty) {
                return const Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      CircularProgressIndicator(color: AppTheme.primaryColor),
                      SizedBox(height: 16),
                      Text('Downloading clinical database...'),
                    ],
                  ),
                );
              }

              if (results.isEmpty) {
                return Center(
                  child: Padding(
                    padding: const EdgeInsets.all(24.0),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.search_off_rounded, size: 56, color: Colors.grey.shade400),
                        const SizedBox(height: 16),
                        Text(
                          controller.searchQuery.value.isEmpty
                              ? 'No clinical records found'
                              : 'No match for "${controller.searchQuery.value}"',
                          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                        ),
                        const SizedBox(height: 8),
                        const Text(
                          'Try searching for disease names, keywords, generic medicine, or treatment type.',
                          textAlign: TextAlign.center,
                          style: TextStyle(color: AppTheme.textSecondary, fontSize: 13),
                        ),
                      ],
                    ),
                  ),
                );
              }

              return RefreshIndicator(
                onRefresh: () => controller.syncData(),
                color: AppTheme.primaryColor,
                child: ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  itemCount: results.length,
                  itemBuilder: (context, index) {
                    final item = results[index];
                    return SearchResultTile(result: item);
                  },
                ),
              );
            }),
          ),
        ],
      ),
    );
  }
}
