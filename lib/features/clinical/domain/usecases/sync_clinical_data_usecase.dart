import '../repositories/clinical_repository.dart';

class SyncClinicalDataUseCase {
  final ClinicalRepository repository;

  SyncClinicalDataUseCase(this.repository);

  Future<void> execute() async {
    return await repository.syncClinicalData();
  }
}
