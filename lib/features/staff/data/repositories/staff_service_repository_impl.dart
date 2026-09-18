import '../../domain/entities/staff_service.dart';
import '../../domain/repositories/staff_service_repository.dart';
import '../datasources/staff_service_datasource.dart';
import '../models/staff_service_model.dart';

class StaffServiceRepositoryImpl implements StaffServiceRepository {
  final StaffServiceDatasource datasource;

  StaffServiceRepositoryImpl({
    required this.datasource,
  });

  @override
  Future<void> addService({
    required String staffUid,
    required StaffService service,
  }) async {
    final model = StaffServiceModel(
      id: service.id,
      name: service.name,
      description: service.description,
    );

    await datasource.addService(
      staffUid: staffUid,
      serviceId: model.id,
      name: model.name,
      description: model.description,
    );
  }

  @override
  Future<List<StaffService>> getServices({
    required String staffUid,
  }) async {
    final maps = await datasource.getServices(staffUid: staffUid);
    return maps.map((m) => StaffServiceModel.fromMap(m)).toList();
  }
}