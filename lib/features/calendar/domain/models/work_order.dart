class WorkOrder {
  final String id;
  final String title;
  final String description;
  final DateTime startTime;
  final DateTime endTime;
  final DateTime createdAt;
  final DateTime? updatedAt;
  final String status; // "selesai", "belum", "terkendala"
  final String technicianId;
  final String adminId;
  final String categoryId;

  WorkOrder({
    required this.id,
    required this.title,
    required this.description,
    required this.startTime,
    required this.endTime,
    required this.createdAt,
    this.updatedAt,
    required this.status,
    required this.technicianId,
    required this.adminId,
    required this.categoryId,
  });

  factory WorkOrder.fromJson(Map<String, dynamic> json) {
    return WorkOrder(
      id: json['id'],
      title: json['title'],
      description: json['description'],
      startTime: DateTime.parse(json['start_time']),
      endTime: DateTime.parse(json['end_time']),
      createdAt: DateTime.parse(json['created_at']),
      updatedAt: json['updated_at'] != null ? DateTime.parse(json['updated_at']) : null,
      status: json['status'] ?? 'belum',
      technicianId: json['technician_id'],
      adminId: json['admin_id'],
      categoryId: json['category_id'],
    );
  }
}