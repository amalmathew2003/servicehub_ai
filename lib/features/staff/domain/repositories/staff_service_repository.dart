import '../entities/staff_service.dart';

abstract class StaffServiceRepository {
  Future<void> addService({
    required String staffUid,
    required StaffService service,
  });

  Future<List<StaffService>> getServices({
    required String staffUid,
  });
}