import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:jbr_pharmica/utils/theme/app_theme.dart';
import '../controllers/clinical_controller.dart';

class StatusBannerWidget extends StatelessWidget {
  const StatusBannerWidget({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<ClinicalController>();

    return Obx(() {
      final isOnline = controller.isOnline.value;

      final bannerBgColor = isOnline ? AppColors.onlineColor : AppColors.offlineColor;
      final icon = isOnline ? Icons.cloud_done_rounded : Icons.wifi_off_rounded;
      final message = isOnline
          ? 'Online — Synchronized with clinical server'
          : 'Offline — Using downloaded clinical information';

      return InkWell(
        onTap: () => controller.toggleStatusBanner(),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          decoration: BoxDecoration(
            color: bannerBgColor.withOpacity(0.12),
            border: Border(
              bottom: BorderSide(
                color: bannerBgColor.withOpacity(0.3),
                width: 1,
              ),
            ),
          ),
          child: Row(
            children: [
              Icon(
                icon,
                size: 18,
                color: bannerBgColor,
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  message,
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: bannerBgColor,
                  ),
                ),
              ),
              Icon(
                Icons.swap_horiz_rounded,
                size: 16,
                color: bannerBgColor.withOpacity(0.7),
              ),
            ],
          ),
        ),
      );
    });
  }
}
