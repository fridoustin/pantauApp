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
  final String? afterPhoto;

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
    this.afterPhoto
  });

  factory WorkOrder.fromJson(Map<String, dynamic> json) {
    final rawStart = json['start_time'];
    final rawEnd   = json['end_time'];

    DateTime? parseNullable(dynamic raw) {
      if (raw == null) return null;
      final str = raw.toString();
      return DateTime.tryParse(str);
    }

    return WorkOrder(
      id: json['id'],
      title: json['title'],
      description: json['description'],
      startTime: parseNullable(rawStart),
      endTime:   parseNullable(rawEnd),
      createdAt: DateTime.parse(json['created_at']),
      updatedAt: json['updated_at'] != null 
          ? DateTime.parse(json['updated_at']) 
          : null,
      status: json['status'] ?? 'belum',
      technicianId: json['technician_id'],
      adminId: json['admin_id'],
      categoryId: json['category_id'],
      afterPhoto: json['after_url'],
    );
  }
}