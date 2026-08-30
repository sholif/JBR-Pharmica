import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:jbr_pharmica/core/routes/app_routes.dart';
import 'package:jbr_pharmica/utils/theme/app_theme.dart';
import '../controllers/clinical_controller.dart';

class DiseaseDetailPage extends StatefulWidget {
  const DiseaseDetailPage({super.key});

  @override
  State<DiseaseDetailPage> createState() => _DiseaseDetailPageState();
}

class _DiseaseDetailPageState extends State<DiseaseDetailPage> {
  final ClinicalController controller = Get.find<ClinicalController>();

  @override
  void initState() {
    super.initState();
    final diseaseId = Get.arguments as int?;
    if (diseaseId != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        controller.fetchDiseaseDetail(diseaseId);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Condition Detail'),
      ),
      body: Obx(() {
        if (controller.isLoadingDetail.value) {
          return const Center(child: CircularProgressIndicator(color: AppColors.primaryColor));
        }

        final detail = controller.selectedDiseaseDetail.value;
        if (detail == null) {
          return const Center(child: Text('Condition detail not found.'));
        }

        final disease = detail.disease;
        final recommendations = detail.recommendations;

        return SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(10),
                            decoration: BoxDecoration(
                              color: AppColors.primaryColor.withOpacity(0.1),
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(Icons.coronavirus, color: AppColors.primaryColor, size: 28),
                          ),
                          const SizedBox(width: 14),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  disease.name,
                                  style: const TextStyle(
                                    fontSize: 20,
                                    fontWeight: FontWeight.bold,
                                    color: AppColors.textPrimary,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 2),
                                  decoration: BoxDecoration(
                                    color: AppColors.accentColor.withOpacity(0.12),
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: Text(
                                    disease.category,
                                    style: const TextStyle(
                                      color: AppColors.accentColor,
                                      fontWeight: FontWeight.w600,
                                      fontSize: 12,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      if (disease.keywords.isNotEmpty) ...[
                        const Divider(height: 24),
                        const Text(
                          'Keywords',
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            color: AppColors.textSecondary,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Wrap(
                          spacing: 6,
                          runSpacing: 6,
                          children: disease.keywords.map((kw) {
                            return Chip(
                              label: Text(kw, style: const TextStyle(fontSize: 12)),
                              backgroundColor: Colors.grey.shade100,
                              side: BorderSide(color: Colors.grey.shade300),
                              padding: EdgeInsets.zero,
                              materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                            );
                          }).toList(),
                        ),
                      ],
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),

              Text(
                'Treatment Recommendations (${recommendations.length})',
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: 12),

              if (recommendations.isEmpty)
                const Card(
                  child: Padding(
                    padding: EdgeInsets.all(16.0),
                    child: Text('No treatment recommendations listed for this condition.'),
                  ),
                )
              else
                ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: recommendations.length,
                  itemBuilder: (context, index) {
                    final rec = recommendations[index];
                    final isFirstLine = rec.type.toLowerCase().contains('first');
                    final typeColor = isFirstLine ? AppColors.onlineColor : AppColors.accentColor;

                    return Card(
                      margin: const EdgeInsets.only(bottom: 12),
                      child: InkWell(
                        onTap: () {
                          Get.toNamed(AppRoutes.antibioticDetail, arguments: rec.antibioticId);
                        },
                        child: Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                    decoration: BoxDecoration(
                                      color: typeColor.withOpacity(0.12),
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: Text(
                                      rec.type,
                                      style: TextStyle(
                                        color: typeColor,
                                        fontWeight: FontWeight.bold,
                                        fontSize: 12,
                                      ),
                                    ),
                                  ),
                                  const Spacer(),
                                  const Icon(Icons.chevron_right_rounded, color: AppColors.textSecondary),
                                ],
                              ),
                              const SizedBox(height: 12),
                              Text(
                                rec.antibioticName ?? 'Medicine #${rec.antibioticId}',
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: AppColors.primaryColor,
                                ),
                              ),
                              if (rec.genericName != null && rec.genericName!.isNotEmpty)
                                Text(
                                  'Generic: ${rec.genericName}',
                                  style: const TextStyle(
                                    fontSize: 13,
                                    color: AppColors.textSecondary,
                                    fontStyle: FontStyle.italic,
                                  ),
                                ),
                              const Divider(height: 20),
                              Row(
                                children: [
                                  _buildDetailItem(Icons.vaccines_outlined, 'Dose', rec.dose),
                                  _buildDetailItem(Icons.schedule_outlined, 'Frequency', rec.frequency),
                                  _buildDetailItem(Icons.timer_outlined, 'Duration', rec.duration),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                ),
            ],
          ),
        );
      }),
    );
  }

  Widget _buildDetailItem(IconData icon, String label, String value) {
    return Expanded(
      child: Column(
        children: [
          Icon(icon, size: 18, color: AppColors.primaryColor),
          const SizedBox(height: 4),
          Text(
            label,
            style: const TextStyle(fontSize: 11, color: AppColors.textSecondary),
          ),
          const SizedBox(height: 2),
          Text(
            value,
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
          ),
        ],
      ),
    );
  }
}
