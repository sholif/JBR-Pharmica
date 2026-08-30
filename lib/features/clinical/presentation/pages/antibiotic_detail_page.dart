import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:jbr_pharmica/utils/theme/app_theme.dart';
import '../../../../core/routes/app_routes.dart';
import '../controllers/clinical_controller.dart';

class AntibioticDetailPage extends StatefulWidget {
  const AntibioticDetailPage({super.key});

  @override
  State<AntibioticDetailPage> createState() => _AntibioticDetailPageState();
}

class _AntibioticDetailPageState extends State<AntibioticDetailPage> {
  final ClinicalController controller = Get.find<ClinicalController>();

  @override
  void initState() {
    super.initState();
    final antibioticId = Get.arguments as int?;
    if (antibioticId != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        controller.fetchAntibioticDetail(antibioticId);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Medicine Detail'),
      ),
      body: Obx(() {
        if (controller.isLoadingDetail.value) {
          return const Center(child: CircularProgressIndicator(color: AppColors.primaryColor));
        }

        final detail = controller.selectedAntibioticDetail.value;
        if (detail == null) {
          return const Center(child: Text('Medicine detail not found.'));
        }

        final antibiotic = detail.antibiotic;
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
                              color: AppColors.accentColor.withOpacity(0.1),
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(Icons.medication_rounded, color: AppColors.accentColor, size: 28),
                          ),
                          const SizedBox(width: 14),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  antibiotic.name,
                                  style: const TextStyle(
                                    fontSize: 20,
                                    fontWeight: FontWeight.bold,
                                    color: AppColors.textPrimary,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  'Generic: ${antibiotic.genericName}',
                                  style: const TextStyle(
                                    fontSize: 14,
                                    color: AppColors.textSecondary,
                                    fontStyle: FontStyle.italic,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),

              Text(
                'Associated Conditions & Guidelines (${recommendations.length})',
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
                    child: Text('No associated medical conditions listed for this antibiotic.'),
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
                          Get.toNamed(AppRoutes.diseaseDetail, arguments: rec.diseaseId);
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
                                rec.diseaseName ?? 'Condition #${rec.diseaseId}',
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: AppColors.primaryColor,
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
