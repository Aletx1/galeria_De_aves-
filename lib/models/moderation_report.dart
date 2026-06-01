enum ReportStatus { pending, blocked, resolved, dismissed }

class ModerationReport {
  final String id;
  final String? postId;
  final String reportedUser;
  final String reason;
  final String detail;
  final String reporter;
  final DateTime createdAt;
  final ReportStatus status;
  final bool automaticFlag;

  const ModerationReport({
    required this.id,
    required this.postId,
    required this.reportedUser,
    required this.reason,
    required this.detail,
    required this.reporter,
    required this.createdAt,
    required this.status,
    required this.automaticFlag,
  });

  ModerationReport copyWith({ReportStatus? status}) {
    return ModerationReport(
      id: id,
      postId: postId,
      reportedUser: reportedUser,
      reason: reason,
      detail: detail,
      reporter: reporter,
      createdAt: createdAt,
      status: status ?? this.status,
      automaticFlag: automaticFlag,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'postId': postId,
      'reportedUser': reportedUser,
      'reason': reason,
      'detail': detail,
      'reporter': reporter,
      'createdAt': createdAt.toIso8601String(),
      'status': status.name,
      'automaticFlag': automaticFlag,
    };
  }

  factory ModerationReport.fromJson(Map<String, dynamic> json) {
    return ModerationReport(
      id: json['id'] as String,
      postId: json['postId'] as String?,
      reportedUser: json['reportedUser'] as String? ?? 'Usuario desconocido',
      reason: json['reason'] as String? ?? 'Sin motivo',
      detail: json['detail'] as String? ?? '',
      reporter: json['reporter'] as String? ?? 'Comunidad',
      createdAt:
          DateTime.tryParse(json['createdAt'] as String? ?? '') ??
          DateTime.now(),
      status: ReportStatus.values.firstWhere(
        (value) => value.name == json['status'],
        orElse: () => ReportStatus.pending,
      ),
      automaticFlag: json['automaticFlag'] as bool? ?? false,
    );
  }
}
