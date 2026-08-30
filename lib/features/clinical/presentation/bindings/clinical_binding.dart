import 'package:get/get.dart';
import '../controllers/clinical_controller.dart';

class ClinicalBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<ClinicalController>(() => ClinicalController());
  }
}
