import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../core/routes/app_routes.dart';
import '../../../../core/theme/app_theme.dart';
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
          return const Center(child: CircularProgressIndicator(color: AppTheme.primaryColor));
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
              // Antibiotic Header Card
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: AppTheme.accentColor.withOpacity(0.12),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(Icons.medication, color: AppTheme.accentColor, size: 30),
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
                                color: AppTheme.textPrimary,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'Generic Name: ${antibiotic.genericName}',
                              style: const TextStyle(
                                fontSize: 13,
                                color: AppTheme.textSecondary,
                                fontStyle: FontStyle.italic,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),

              // Related Conditions Section
              Text(
                'Related Conditions & Indications (${recommendations.length})',
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: AppTheme.textPrimary,
                ),
              ),
              const SizedBox(height: 12),

              if (recommendations.isEmpty)
                const Card(
                  child: Padding(
                    padding: EdgeInsets.all(16.0),
                    child: Text('No related conditions found for this medicine.'),
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
                    final typeColor = isFirstLine ? AppTheme.onlineColor : AppTheme.accentColor;

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
                                  Expanded(
                                    child: Text(
                                      rec.diseaseName ?? 'Condition #${rec.diseaseId}',
                                      style: const TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                        color: AppTheme.primaryColor,
                                      ),
                                    ),
                                  ),
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
                                  const SizedBox(width: 6),
                                  const Icon(Icons.chevron_right_rounded, color: AppTheme.textSecondary),
                                ],
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
          Icon(icon, size: 18, color: AppTheme.primaryColor),
          const SizedBox(height: 4),
          Text(
            label,
            style: const TextStyle(fontSize: 11, color: AppTheme.textSecondary),
          ),
          const SizedBox(height: 2),
          Text(
            value,
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: AppTheme.textPrimary),
          ),
        ],
      ),
    );
  }
}
