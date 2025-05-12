import 'package:pantau_app/features/create_work_order/domain/entities/work_order.dart';

class WorkOrderModel extends WorkOrder {
  WorkOrderModel({
    required super.title,
    required super.description,
    super.endTime,
    required super.createdAt,
    required super.status,
    required super.technicianId,
    super.categoryId
  });

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{
      'title': title,
      'description': description,
      'created_at': createdAt.toIso8601String(),
      'status': status,
      'technician_id': technicianId,
    };
    if (endTime != null) map['end_time'] = endTime!.toIso8601String();
    if (categoryId != null) map['category_id'] = categoryId;
    return map;
  }

  factory WorkOrderModel.fromJson(Map<String, dynamic> json) => WorkOrderModel(
        title: json['title'] as String,
        description: json['description'] as String,
        endTime: json['end_time'] != null
            ? DateTime.parse(json['end_time'] as String)
            : null,
        createdAt: DateTime.parse(json['created_at'] as String),
        status: json['status'] as String,
        technicianId: json['technician_id'] as String,
        categoryId: json['category_id'] as String?,
      );
}