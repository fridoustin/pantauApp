class WorkOrder {
  final String id;
  final String title;
  final String description;
  final DateTime? startTime;
  final DateTime? endTime;
  final DateTime createdAt;
  final DateTime? updatedAt;
  final String status;
  final String technicianId;
  final String? adminId;
  final String? categoryId;

  WorkOrder({
    required this.id,
    required this.title,
    required this.description,
    this.startTime,
    this.endTime,
    required this.createdAt,
    this.updatedAt,
    required this.status,
    required this.technicianId,
    this.adminId,
    this.categoryId,
  });
}