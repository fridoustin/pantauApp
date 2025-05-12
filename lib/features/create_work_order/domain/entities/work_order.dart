class WorkOrder {
  final String title;
  final String description;
  final DateTime? endTime;
  final DateTime createdAt;
  final String status;
  final String technicianId;
  final String? categoryId;

  WorkOrder({
    required this.title,
    required this.description,
    this.endTime,
    required this.createdAt,
    required this.status,
    required this.technicianId,
    this.categoryId,
  });
}