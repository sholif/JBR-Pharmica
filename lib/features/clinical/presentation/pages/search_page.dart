import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:jbr_pharmica/utils/theme/app_theme.dart';
import '../controllers/clinical_controller.dart';
import '../widgets/search_result_tile.dart';
import '../widgets/status_banner_widget.dart';

class ClinicalRefScr extends GetView<ClinicalController> {
  const ClinicalRefScr({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Clinical Reference'),
        actions: [
          IconButton(
            icon: const Icon(Icons.info_outline_rounded),
            onPressed: () {
              Get.defaultDialog(
                title: 'About JBR Pharmica',
                middleText:
                    'Mobile UI Prototype for Clinical Reference System with multi-field search and details view.',
                confirmTextColor: Colors.white,
                textConfirm: 'Close',
                buttonColor: AppColors.primaryColor,
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
                    prefixIcon: const Icon(Icons.search_rounded, color: AppColors.primaryColor),
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
                            selectedColor: AppColors.primaryColor.withOpacity(0.2),
                            checkmarkColor: AppColors.primaryColor,
                            labelStyle: TextStyle(
                              color: isSelected ? AppColors.primaryColor : AppColors.textPrimary,
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
          Expanded(
            child: Obx(() {
              final results = controller.filteredResults;

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
                          style: TextStyle(color: AppColors.textSecondary, fontSize: 13),
                        ),
                      ],
                    ),
                  ),
                );
              }

              return ListView.builder(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                itemCount: results.length,
                itemBuilder: (context, index) {
                  final item = results[index];
                  return SearchResultTile(result: item);
                },
              );
            }),
          ),
        ],
      ),
    );
  }
}
