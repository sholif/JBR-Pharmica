import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:jbr_pharmica/utils/theme/app_theme.dart';
import 'core/routes/app_pages.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const JbrPharmicaApp());
}

class JbrPharmicaApp extends StatelessWidget {
  const JbrPharmicaApp({super.key});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      title: 'JBR Pharmica',
      debugShowCheckedModeBanner: false,
      theme: AppColors.lightTheme,
      initialRoute: AppPages.initial,
      getPages: AppPages.routes,
    );
  }
}
