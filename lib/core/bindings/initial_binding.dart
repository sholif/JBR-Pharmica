import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:dio/dio.dart';
import 'package:get/get.dart';
import '../database/database_helper.dart';
import '../network/dio_client.dart';
import '../network/network_info.dart';

class InitialBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<Connectivity>(() => Connectivity(), fenix: true);
    Get.lazyPut<NetworkInfo>(() => NetworkInfoImpl(Get.find<Connectivity>()), fenix: true);
    Get.lazyPut<Dio>(() => Dio(), fenix: true);
    Get.lazyPut<DioClient>(() => DioClient(Get.find<Dio>(), Get.find<NetworkInfo>()), fenix: true);
    Get.lazyPut<DatabaseHelper>(() => DatabaseHelper(), fenix: true);
  }
}
