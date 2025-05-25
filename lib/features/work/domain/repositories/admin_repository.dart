import 'package:pantau_app/features/work/domain/models/admin.dart';

abstract class AdminRepository {
  Future<Admin?> getAdminById(String id);
}