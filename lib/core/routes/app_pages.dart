import 'package:get/get.dart';
import '../../features/clinical/presentation/bindings/clinical_binding.dart';
import '../../features/clinical/presentation/pages/antibiotic_detail_page.dart';
import '../../features/clinical/presentation/pages/disease_detail_page.dart';
import '../../features/clinical/presentation/pages/search_page.dart';
import 'app_routes.dart';

class AppPages {
  static const initial = AppRoutes.search;

  static final routes = [
    GetPage(
      name: AppRoutes.search,
      page: () => const SearchPage(),
      binding: ClinicalBinding(),
    ),
    GetPage(
      name: AppRoutes.diseaseDetail,
      page: () => const DiseaseDetailPage(),
      binding: ClinicalBinding(),
      transition: Transition.rightToLeft,
    ),
    GetPage(
      name: AppRoutes.antibioticDetail,
      page: () => const AntibioticDetailPage(),
      binding: ClinicalBinding(),
      transition: Transition.rightToLeft,
    ),
  ];
}
