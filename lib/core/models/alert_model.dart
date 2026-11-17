enum AlertStatus {
  open,
  acknowledged,
  escalated,
  closed;

  static AlertStatus fromString(String status) {
    switch (status.toLowerCase()) {
      case 'acknowledged':
        return AlertStatus.acknowledged;
      case 'escalated':
        return AlertStatus.escalated;
      case 'closed':
        return AlertStatus.closed;
      case 'open':
      default:
        return AlertStatus.open;
    }
  }
}

class AlertModel {
  final String id;
  final String patientId;
  final String patientName;
  final String type; // 'missed_dose_3_days', 'high_bp', 'severe_anemia', 'danger_sign_reported'
  final String severity; // 'urgent', 'warning', 'info'
  final AlertStatus status;
  final String? assignedTo;
  final String message;
  final DateTime createdAt;
  final DateTime? acknowledgedAt;
  final DateTime? closedAt;
  final String? resolutionNotes;

  const AlertModel({
    required this.id,
    required this.patientId,
    this.patientName = 'Mother',
    required this.type,
    this.severity = 'urgent',
    this.status = AlertStatus.open,
    this.assignedTo,
    required this.message,
    required this.createdAt,
    this.acknowledgedAt,
    this.closedAt,
    this.resolutionNotes,
  });

  bool get isUrgent => severity == 'urgent';

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'patient_id': patientId,
      'patient_name': patientName,
      'type': type,
      'severity': severity,
      'status': status.name,
      'assigned_to': assignedTo,
      'message': message,
      'created_at': createdAt.toIso8601String(),
      'acknowledged_at': acknowledgedAt?.toIso8601String(),
      'closed_at': closedAt?.toIso8601String(),
      'resolution_notes': resolutionNotes,
    };
  }

  factory AlertModel.fromMap(Map<String, dynamic> map) {
    return AlertModel(
      id: map['id']?.toString() ?? '',
      patientId: map['patient_id']?.toString() ?? '',
      patientName: map['patient_name']?.toString() ?? 'Mother',
      type: map['type']?.toString() ?? 'missed_dose_3_days',
      severity: map['severity']?.toString() ?? 'urgent',
      status: AlertStatus.fromString(map['status']?.toString() ?? 'open'),
      assignedTo: map['assigned_to']?.toString(),
      message: map['message']?.toString() ?? 'Alert',
      createdAt: DateTime.tryParse(map['created_at']?.toString() ?? '') ?? DateTime.now(),
      acknowledgedAt: map['acknowledged_at'] != null ? DateTime.tryParse(map['acknowledged_at']) : null,
      closedAt: map['closed_at'] != null ? DateTime.tryParse(map['closed_at']) : null,
      resolutionNotes: map['resolution_notes']?.toString(),
    );
  }
}

class EscalationModel {
  final String id;
  final String alertId;
  final String escalatedBy;
  final String escalatedTo;
  final String? decision; // 'confirm_hrp', 'clear', 'refer_to_phc'
  final String? decisionNotes;
  final String? decidedBy;
  final DateTime? decidedAt;
  final DateTime createdAt;

  const EscalationModel({
    required this.id,
    required this.alertId,
    required this.escalatedBy,
    required this.escalatedTo,
    this.decision,
    this.decisionNotes,
    this.decidedBy,
    this.decidedAt,
    required this.createdAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'alert_id': alertId,
      'escalated_by': escalatedBy,
      'escalated_to': escalatedTo,
      'decision': decision,
      'decision_notes': decisionNotes,
      'decided_by': decidedBy,
      'decided_at': decidedAt?.toIso8601String(),
      'created_at': createdAt.toIso8601String(),
    };
  }

  factory EscalationModel.fromMap(Map<String, dynamic> map) {
    return EscalationModel(
      id: map['id']?.toString() ?? '',
      alertId: map['alert_id']?.toString() ?? '',
      escalatedBy: map['escalated_by']?.toString() ?? '',
      escalatedTo: map['escalated_to']?.toString() ?? '',
      decision: map['decision']?.toString(),
      decisionNotes: map['decision_notes']?.toString(),
      decidedBy: map['decided_by']?.toString(),
      decidedAt: map['decided_at'] != null ? DateTime.tryParse(map['decided_at']) : null,
      createdAt: DateTime.tryParse(map['created_at']?.toString() ?? '') ?? DateTime.now(),
    );
  }
}
