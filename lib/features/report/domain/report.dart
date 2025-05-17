class Report {
  final String workOrderId;
  final String? beforePhoto;
  final String? afterPhoto;
  final String? note;
  final DateTime? createdAt;

  Report({
    required this.workOrderId,
    this.beforePhoto,
    this.afterPhoto,
    this.note,
    this.createdAt,
  });

  factory Report.fromJson(Map<String, dynamic> json) {
    return Report(
      workOrderId: json['id'] as String,
      beforePhoto: json['before_url'] as String?,
      afterPhoto: json['after_url'] as String?,
      note: json['note'] as String?,
      createdAt: json['report_created_at'] != null
          ? DateTime.parse(json['report_created_at'] as String)
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': workOrderId,
      'before_url': beforePhoto,
      'after_url': afterPhoto,
      'note': note,
      'report_created_at': createdAt?.toIso8601String(),
    };
  }
}