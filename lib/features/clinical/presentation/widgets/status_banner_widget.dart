import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../core/theme/app_theme.dart';
import '../controllers/clinical_controller.dart';

class StatusBannerWidget extends StatelessWidget {
  const StatusBannerWidget({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<ClinicalController>();

    return Obx(() {
      final isOnline = controller.isOnline.value;
      final isOfflineMode = controller.isOfflineMode.value;
      final isSyncing = controller.isSyncing.value;

      final isOffline = !isOnline || isOfflineMode;

      final bannerBgColor = isOffline ? AppTheme.offlineColor : AppTheme.onlineColor;
      final icon = isOffline ? Icons.wifi_off_rounded : Icons.cloud_done_rounded;

      return Container(
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
              size: 20,
              color: bannerBgColor,
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                controller.statusMessage.value,
                style: TextStyle(
                  color: bannerBgColor.withOpacity(0.95),
                  fontWeight: FontWeight.w600,
                  fontSize: 13,
                ),
              ),
            ),
            if (isSyncing)
              SizedBox(
                width: 16,
                height: 16,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation<Color>(bannerBgColor),
                ),
              )
            else
              IconButton(
                icon: const Icon(Icons.refresh_rounded, size: 18),
                color: bannerBgColor,
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(),
                tooltip: 'Sync clinical data',
                onPressed: () => controller.syncData(),
              ),
          ],
        ),
      );
    });
  }
}
