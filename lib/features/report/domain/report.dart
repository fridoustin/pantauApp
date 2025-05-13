class Report {
  final String id;
  final String workOrderId;
  final String? beforePhoto;
  final String? afterPhoto;
  final String? note;
  final DateTime createdAt;

  Report({
    required this.id,
    required this.workOrderId,
    this.beforePhoto,
    this.afterPhoto,
    this.note,
    required this.createdAt,
  });

  factory Report.fromJson(Map<String, dynamic> json) {
    return Report(
      id: json['id'] as String,
      workOrderId: json['wo_id'] as String,
      beforePhoto: json['before_photo'] as String?,
      afterPhoto: json['after_photo'] as String?,
      note: json['note'] as String?,
      createdAt: DateTime.parse(json['created_at'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'wo_id': workOrderId,
      'before_photo': beforePhoto,
      'after_photo': afterPhoto,
      'note': note,
      'created_at': createdAt.toIso8601String(),
    };
  }
}