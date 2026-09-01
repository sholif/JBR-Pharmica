import 'package:get/get.dart';
import '../../../../core/database/database_helper.dart';
import '../../../../core/network/dio_client.dart';
import '../../../../core/network/network_info.dart';
import '../../data/datasources/clinical_local_data_source.dart';
import '../../data/datasources/clinical_remote_data_source.dart';
import '../../data/repositories/clinical_repository_impl.dart';
import '../../domain/repositories/clinical_repository.dart';
import '../../domain/usecases/get_antibiotic_detail_usecase.dart';
import '../../domain/usecases/get_disease_detail_usecase.dart';
import '../../domain/usecases/search_clinical_data_usecase.dart';
import '../../domain/usecases/sync_clinical_data_usecase.dart';
import '../controllers/clinical_controller.dart';

class ClinicalBinding extends Bindings {
  @override
  void dependencies() {
    // Data Sources
    Get.lazyPut<ClinicalRemoteDataSource>(
      () => ClinicalRemoteDataSourceImpl(Get.find<DioClient>()),
      fenix: true,
    );
    Get.lazyPut<ClinicalLocalDataSource>(
      () => ClinicalLocalDataSourceImpl(Get.find<DatabaseHelper>()),
      fenix: true,
    );

    // Repository
    Get.lazyPut<ClinicalRepository>(
      () => ClinicalRepositoryImpl(
        remoteDataSource: Get.find<ClinicalRemoteDataSource>(),
        localDataSource: Get.find<ClinicalLocalDataSource>(),
      ),
      fenix: true,
    );

    // Use Cases
    Get.lazyPut<SyncClinicalDataUseCase>(
      () => SyncClinicalDataUseCase(Get.find<ClinicalRepository>()),
      fenix: true,
    );
    Get.lazyPut<SearchClinicalDataUseCase>(
      () => SearchClinicalDataUseCase(Get.find<ClinicalRepository>()),
      fenix: true,
    );
    Get.lazyPut<GetDiseaseDetailUseCase>(
      () => GetDiseaseDetailUseCase(Get.find<ClinicalRepository>()),
      fenix: true,
    );
    Get.lazyPut<GetAntibioticDetailUseCase>(
      () => GetAntibioticDetailUseCase(Get.find<ClinicalRepository>()),
      fenix: true,
    );

    // Controller
    Get.lazyPut<ClinicalController>(
      () => ClinicalController(
        syncUseCase: Get.find<SyncClinicalDataUseCase>(),
        searchUseCase: Get.find<SearchClinicalDataUseCase>(),
        diseaseDetailUseCase: Get.find<GetDiseaseDetailUseCase>(),
        antibioticDetailUseCase: Get.find<GetAntibioticDetailUseCase>(),
        repository: Get.find<ClinicalRepository>(),
        networkInfo: Get.find<NetworkInfo>(),
      ),
      fenix: true,
    );
  }
}
