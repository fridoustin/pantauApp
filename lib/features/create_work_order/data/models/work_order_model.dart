import 'package:pantau_app/features/create_work_order/domain/entities/work_order.dart';

class WorkOrderModel extends WorkOrder {
  WorkOrderModel({
    required super.id,
    required super.title,
    required super.description,
    super.startTime,
    super.endTime,
    required super.createdAt,
    super.updatedAt,
    required super.status,
    required super.technicianId,
    super.adminId,
    super.categoryId
  });

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{
      'id': id,
      'title': title,
      'description': description,
      'created_at': createdAt.toIso8601String(),
      'status': status,
      'technician_id': technicianId,
    };
    if (startTime != null) map['start_time'] = startTime!.toIso8601String();
    if (endTime != null) map['end_time'] = endTime!.toIso8601String();
    if (updatedAt != null) map['updated_at'] = updatedAt!.toIso8601String();
    if (adminId != null) map['admin_id'] = adminId;
    if (categoryId != null) map['category_id'] = categoryId;
    return map;
  }

  factory WorkOrderModel.fromJson(Map<String, dynamic> json) => WorkOrderModel(
        id: json['id'] as String,
        title: json['title'] as String,
        description: json['description'] as String,
        startTime: json['start_time'] != null
            ? DateTime.parse(json['start_time'] as String)
            : null,
        endTime: json['end_time'] != null
            ? DateTime.parse(json['end_time'] as String)
            : null,
        createdAt: DateTime.parse(json['created_at'] as String),
        updatedAt: json['updated_at'] != null
            ? DateTime.parse(json['updated_at'] as String)
            : null,
        status: json['status'] as String,
        technicianId: json['technician_id'] as String,
        adminId: json['admin_id'] as String?,
        categoryId: json['category_id'] as String?,
      );
}