import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pantau_app/features/report/data/report_repository_impl.dart';
import 'package:pantau_app/features/report/domain/report.dart';

final reportRepositoryProvider = Provider<ReportRepository>((ref) {
  return ReportRepository();
});

final workOrderReportsProvider = FutureProvider.family<List<Report>, String>((ref, workOrderId) async {
  final repository = ref.watch(reportRepositoryProvider);
  return repository.getReportsByWorkOrderId(workOrderId);
});