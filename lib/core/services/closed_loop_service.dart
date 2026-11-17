import 'package:flutter/foundation.dart';
import '../database/local_db.dart';
import '../models/alert_model.dart';
import '../models/medicine_log_model.dart';
import '../models/patient_model.dart';
import '../network/supabase_service.dart';
import '../repositories/alert_repository.dart';
import '../repositories/patient_repository.dart';

class ClosedLoopService extends ChangeNotifier {
  ClosedLoopService._();
  static final ClosedLoopService instance = ClosedLoopService._();

  static const String demoPatientId = '55555555-5555-5555-5555-555555555501';
  static const String demoAshaId = '22222222-2222-2222-2222-222222222241';
  static const String demoAnmId = '22222222-2222-2222-2222-222222222231';

  /// Step 1: Simulate 4 consecutive missed days for Priyanka More
  Future<void> simulateConsecutiveMissedDays() async {
    final now = DateTime.now();
    for (int i = 1; i <= 4; i++) {
      final date = now.subtract(Duration(days: i));
      for (final med in ['Iron', 'Calcium', 'Folic Acid']) {
        final id = '$demoPatientId-${_formatDate(date)}-$med';
        final log = MedicineLogModel(
          id: id,
          patientId: demoPatientId,
          medicine: med,
          logDate: date,
          taken: false,
          loggedAt: date,
        );
        await LocalDb.medicinesBox.put(id, log.toMap());
      }
    }

    // Step 2: Auto-trigger alert for ASHA Savita Tai
    final alert = AlertModel(
      id: 'alert-loop-01',
      patientId: demoPatientId,
      patientName: 'Priyanka More (Demo Mother)',
      type: 'missed_dose_3_days',
      severity: 'urgent',
      status: AlertStatus.open,
      assignedTo: demoAshaId,
      message: '🚨 Automated Detection: Priyanka More has missed Iron & Calcium for 4 consecutive days!',
      createdAt: DateTime.now(),
    );

    await LocalDb.alertsBox.put(alert.id, alert.toMap());
    await LocalDb.enqueueSync(
      table: 'alerts',
      action: 'insert',
      payload: alert.toMap(),
    );

    notifyListeners();
    debugPrint('Closed Loop Step 1 & 2: Missed doses simulated -> Alert created for ASHA.');
  }

  /// Step 3: ASHA calls/visits and escalates alert to ANM
  Future<void> ashaEscalateAlert({required String alertId, required String notes}) async {
    await AlertRepository.instance.escalateToAnm(
      alertId: alertId,
      ashaId: demoAshaId,
      anmId: demoAnmId,
      notes: notes,
    );

    // If online, call Supabase function
    if (SupabaseService.instance.isConfigured) {
      try {
        final client = SupabaseService.instance.client;
        await client?.rpc('escalate_alert_to_anm', params: {
          'p_alert_id': alertId,
          'p_asha_id': demoAshaId,
          'p_notes': notes,
        });
      } catch (e) {
        debugPrint('Supabase escalate_alert_to_anm failed: $e');
      }
    }

    notifyListeners();
    debugPrint('Closed Loop Step 3: ASHA escalated alert to ANM Sunita.');
  }

  /// Step 4: ANM confirms HRP status, clearing alert and updating supervisor counts
  Future<void> anmConfirmHrp({
    required String alertId,
    required String patientId,
    required String notes,
  }) async {
    // 1. Confirm patient as High-Risk Pregnancy
    await PatientRepository.instance.confirmHrp(
      patientId,
      'Confirmed by ANM Sunita: $notes',
    );

    // 2. Close alert
    await AlertRepository.instance.closeAlert(
      alertId,
      'Confirmed as High-Risk Pregnancy by ANM Sunita: $notes',
    );

    // 3. If online, call Supabase function
    if (SupabaseService.instance.isConfigured) {
      try {
        final client = SupabaseService.instance.client;
        await client?.rpc('decide_anm_escalation', params: {
          'p_alert_id': alertId,
          'p_anm_id': demoAnmId,
          'p_decision': 'confirm_hrp',
          'p_decision_notes': notes,
        });
      } catch (e) {
        debugPrint('Supabase decide_anm_escalation failed: $e');
      }
    }

    notifyListeners();
    debugPrint('Closed Loop Step 4 & 5: ANM confirmed HRP -> Supervisor count updated.');
  }

  /// Reset the closed-loop demo scenario back to default state
  Future<void> resetDemoLoop() async {
    // Reset patient HRP flag
    final patient = await PatientRepository.instance.getPatientById(demoPatientId);
    if (patient != null) {
      final resetPatient = PatientModel(
        id: patient.id,
        profileId: patient.profileId,
        name: patient.name,
        phone: patient.phone,
        dateOfBirth: patient.dateOfBirth,
        lmp: patient.lmp,
        edd: patient.edd,
        heightCm: patient.heightCm,
        bloodGroup: patient.bloodGroup,
        rhNegative: patient.rhNegative,
        isConfirmedHrp: false,
        hrpCategory: null,
        assignedAshaId: patient.assignedAshaId,
        assignedAnmId: patient.assignedAnmId,
      );
      await LocalDb.patientsBox.put(patient.id, resetPatient.toMap());
    }

    // Reset default seed alerts
    await LocalDb.alertsBox.clear();
    await AlertRepository.instance.ensureCachePopulated();

    notifyListeners();
    debugPrint('Closed Loop scenario reset to baseline.');
  }

  String _formatDate(DateTime d) =>
      "${d.year.toString().padLeft(4, '0')}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}";
}
