import '../database/local_db.dart';
import '../models/alert_model.dart';

class AlertRepository {
  AlertRepository._();
  static final AlertRepository instance = AlertRepository._();

  static final List<AlertModel> defaultSeedAlerts = [
    AlertModel(
      id: 'alert-seed-01',
      patientId: '55555555-5555-5555-5555-555555555501',
      patientName: 'Priyanka More (Demo Mother)',
      type: 'missed_dose_3_days',
      severity: 'urgent',
      status: AlertStatus.open,
      assignedTo: '22222222-2222-2222-2222-222222222241',
      message: '🚨 Medicine Alert: Priyanka More has missed Iron & Calcium for 4 consecutive days!',
      createdAt: DateTime.now().subtract(const Duration(hours: 4)),
    ),
    AlertModel(
      id: 'alert-seed-02',
      patientId: '55555555-5555-5555-5555-555555555502',
      patientName: 'Sita Devi',
      type: 'high_bp',
      severity: 'urgent',
      status: AlertStatus.escalated,
      assignedTo: '22222222-2222-2222-2222-222222222241',
      message: 'High BP Alert: Sita Devi systolic BP reached 146 mmHg.',
      createdAt: DateTime.now().subtract(const Duration(days: 1)),
    ),
  ];

  Future<void> ensureCachePopulated() async {
    final box = LocalDb.alertsBox;
    if (box.isEmpty) {
      for (final a in defaultSeedAlerts) {
        await box.put(a.id, a.toMap());
      }
    }
  }

  /// Get alerts assigned to ASHA
  Future<List<AlertModel>> getAlertsForAsha(String ashaId) async {
    await ensureCachePopulated();
    final box = LocalDb.alertsBox;
    final list = box.values
        .map((e) => AlertModel.fromMap(Map<String, dynamic>.from(e as Map)))
        .toList();

    list.sort((a, b) => b.createdAt.compareTo(a.createdAt));
    return list;
  }

  /// Check if there is an active medicine-missed alert
  Future<bool> hasActiveMedicineAlert() async {
    await ensureCachePopulated();
    final box = LocalDb.alertsBox;
    return box.values.any((e) {
      final map = Map<String, dynamic>.from(e as Map);
      return map['type'] == 'missed_dose_3_days' && map['status'] == 'open';
    });
  }

  /// ASHA acknowledges an alert
  Future<void> acknowledgeAlert(String alertId) async {
    final box = LocalDb.alertsBox;
    final raw = box.get(alertId);
    if (raw != null) {
      final map = Map<String, dynamic>.from(raw as Map);
      map['status'] = 'acknowledged';
      map['acknowledged_at'] = DateTime.now().toIso8601String();
      await box.put(alertId, map);
    }
  }

  /// ASHA escalates alert to ANM
  Future<void> escalateToAnm({
    required String alertId,
    required String ashaId,
    required String anmId,
    required String notes,
  }) async {
    final box = LocalDb.alertsBox;
    final raw = box.get(alertId);
    if (raw != null) {
      final map = Map<String, dynamic>.from(raw as Map);
      map['status'] = 'escalated';
      await box.put(alertId, map);
    }

    final escalation = EscalationModel(
      id: 'esc-${DateTime.now().millisecondsSinceEpoch}',
      alertId: alertId,
      escalatedBy: ashaId,
      escalatedTo: anmId,
      decisionNotes: notes,
      createdAt: DateTime.now(),
    );

    await LocalDb.enqueueSync(
      table: 'escalations',
      action: 'insert',
      payload: escalation.toMap(),
    );
  }

  /// Close alert
  Future<void> closeAlert(String alertId, String resolutionNotes) async {
    final box = LocalDb.alertsBox;
    final raw = box.get(alertId);
    if (raw != null) {
      final map = Map<String, dynamic>.from(raw as Map);
      map['status'] = 'closed';
      map['closed_at'] = DateTime.now().toIso8601String();
      map['resolution_notes'] = resolutionNotes;
      await box.put(alertId, map);
    }
  }
}
