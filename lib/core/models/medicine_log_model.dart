class MedicineLogModel {
  final String id;
  final String patientId;
  final String medicine; // 'Iron', 'Calcium', 'Folic Acid'
  final DateTime logDate;
  final bool taken;
  final DateTime loggedAt;
  final bool isSynced;

  const MedicineLogModel({
    required this.id,
    required this.patientId,
    required this.medicine,
    required this.logDate,
    required this.taken,
    required this.loggedAt,
    this.isSynced = true,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'patient_id': patientId,
      'medicine': medicine,
      'log_date': "${logDate.year.toString().padLeft(4, '0')}-${logDate.month.toString().padLeft(2, '0')}-${logDate.day.toString().padLeft(2, '0')}",
      'taken': taken,
      'logged_at': loggedAt.toIso8601String(),
      'is_synced': isSynced,
    };
  }

  factory MedicineLogModel.fromMap(Map<String, dynamic> map) {
    return MedicineLogModel(
      id: map['id']?.toString() ?? '',
      patientId: map['patient_id']?.toString() ?? '',
      medicine: map['medicine']?.toString() ?? 'Iron',
      logDate: DateTime.tryParse(map['log_date']?.toString() ?? '') ?? DateTime.now(),
      taken: map['taken'] == true,
      loggedAt: DateTime.tryParse(map['logged_at']?.toString() ?? '') ?? DateTime.now(),
      isSynced: map['is_synced'] ?? true,
    );
  }
}
