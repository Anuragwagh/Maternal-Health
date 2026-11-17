class VisitModel {
  final String id;
  final String patientId;
  final String recordedBy;
  final String recordedByRole; // 'asha', 'anm', 'supervisor'
  final DateTime visitDate;
  final int? systolic;
  final int? diastolic;
  final double? hemoglobin;
  final double? weightKg;
  final double? fundalHeightCm;
  final int? fetalHeartRate;
  final List<String> dangerSigns;
  final String? notes;
  final DateTime recordedAt;

  const VisitModel({
    required this.id,
    required this.patientId,
    required this.recordedBy,
    required this.recordedByRole,
    required this.visitDate,
    this.systolic,
    this.diastolic,
    this.hemoglobin,
    this.weightKg,
    this.fundalHeightCm,
    this.fetalHeartRate,
    this.dangerSigns = const [],
    this.notes,
    required this.recordedAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'patient_id': patientId,
      'recorded_by': recordedBy,
      'recorded_by_role': recordedByRole,
      'visit_date': "${visitDate.year.toString().padLeft(4, '0')}-${visitDate.month.toString().padLeft(2, '0')}-${visitDate.day.toString().padLeft(2, '0')}",
      'systolic': systolic,
      'diastolic': diastolic,
      'hemoglobin': hemoglobin,
      'weight_kg': weightKg,
      'fundal_height_cm': fundalHeightCm,
      'fetal_heart_rate': fetalHeartRate,
      'danger_signs': dangerSigns,
      'notes': notes,
      'recorded_at': recordedAt.toIso8601String(),
    };
  }

  factory VisitModel.fromMap(Map<String, dynamic> map) {
    return VisitModel(
      id: map['id']?.toString() ?? '',
      patientId: map['patient_id']?.toString() ?? '',
      recordedBy: map['recorded_by']?.toString() ?? '',
      recordedByRole: map['recorded_by_role']?.toString() ?? 'asha',
      visitDate: DateTime.tryParse(map['visit_date']?.toString() ?? '') ?? DateTime.now(),
      systolic: (map['systolic'] as num?)?.toInt(),
      diastolic: (map['diastolic'] as num?)?.toInt(),
      hemoglobin: (map['hemoglobin'] as num?)?.toDouble(),
      weightKg: (map['weight_kg'] as num?)?.toDouble(),
      fundalHeightCm: (map['fundal_height_cm'] as num?)?.toDouble(),
      fetalHeartRate: (map['fetal_heart_rate'] as num?)?.toInt(),
      dangerSigns: (map['danger_signs'] as List<dynamic>?)?.map((e) => e.toString()).toList() ?? [],
      notes: map['notes']?.toString(),
      recordedAt: DateTime.tryParse(map['recorded_at']?.toString() ?? '') ?? DateTime.now(),
    );
  }
}
