import '../../../../core/constants/api_endpoints.dart';
import '../../../../core/network/dio_client.dart';
import '../../../../core/network/network_exceptions.dart';
import '../models/clinical_data_response_model.dart';

abstract class ClinicalRemoteDataSource {
  Future<ClinicalDataResponseModel> fetchClinicalData();
}

class ClinicalRemoteDataSourceImpl implements ClinicalRemoteDataSource {
  final DioClient dioClient;

  ClinicalRemoteDataSourceImpl(this.dioClient);

  @override
  Future<ClinicalDataResponseModel> fetchClinicalData() async {
    try {
      final response = await dioClient.get(ApiEndpoints.clinicalData);
      if (response.data == null) {
        throw const InvalidDataException('Received empty payload from clinical API.');
      }
      return ClinicalDataResponseModel.fromJson(response.data);
    } catch (e) {
      if (e is NetworkException) {
        rethrow;
      }
      throw InvalidDataException('Failed to parse clinical API response: $e');
    }
  }
}
