import 'package:flutter/foundation.dart';
import '../database/local_db.dart';
import '../models/visit_model.dart';
import '../network/supabase_service.dart';

class VisitRepository {
  VisitRepository._();
  static final VisitRepository instance = VisitRepository._();

  static final List<VisitModel> defaultSeedVisits = [
    VisitModel(
      id: 'visit-seed-01',
      patientId: '55555555-5555-5555-5555-555555555501',
      recordedBy: '22222222-2222-2222-2222-222222222241',
      recordedByRole: 'asha',
      visitDate: DateTime.now().subtract(const Duration(days: 14)),
      systolic: 118,
      diastolic: 76,
      hemoglobin: 11.2,
      weightKg: 54.5,
      notes: 'Regular home checkup. Patient feeling healthy.',
      recordedAt: DateTime.now().subtract(const Duration(days: 14)),
    ),
    VisitModel(
      id: 'visit-seed-02',
      patientId: '55555555-5555-5555-5555-555555555502',
      recordedBy: '22222222-2222-2222-2222-222222222231',
      recordedByRole: 'anm',
      visitDate: DateTime.now().subtract(const Duration(days: 5)),
      systolic: 146,
      diastolic: 94,
      hemoglobin: 10.4,
      weightKg: 49.0,
      dangerSigns: ['severe_headache'],
      notes: 'Stage 1 gestational hypertension detected. Referred for ANM review.',
      recordedAt: DateTime.now().subtract(const Duration(days: 5)),
    ),
  ];

  Future<void> ensureCachePopulated() async {
    final box = LocalDb.visitsBox;
    if (box.isEmpty) {
      for (final v in defaultSeedVisits) {
        await box.put(v.id, v.toMap());
      }
    }
  }

  /// Get visits for a specific patient
  Future<List<VisitModel>> getVisitsForPatient(String patientId) async {
    await ensureCachePopulated();
    final box = LocalDb.visitsBox;
    final all = box.values
        .map((e) => VisitModel.fromMap(Map<String, dynamic>.from(e as Map)))
        .where((v) => v.patientId == patientId)
        .toList();

    all.sort((a, b) => b.visitDate.compareTo(a.visitDate));
    return all;
  }

  /// Record a new visit
  Future<VisitModel> logVisit({
    required String patientId,
    required String recordedBy,
    required String recordedByRole,
    required DateTime visitDate,
    int? systolic,
    int? diastolic,
    double? hemoglobin,
    double? weightKg,
    List<String> dangerSigns = const [],
    String? notes,
  }) async {
    final newVisit = VisitModel(
      id: 'visit-${DateTime.now().millisecondsSinceEpoch}',
      patientId: patientId,
      recordedBy: recordedBy,
      recordedByRole: recordedByRole,
      visitDate: visitDate,
      systolic: systolic,
      diastolic: diastolic,
      hemoglobin: hemoglobin,
      weightKg: weightKg,
      dangerSigns: dangerSigns,
      notes: notes,
      recordedAt: DateTime.now(),
    );

    // 1. Write to local Hive cache
    await LocalDb.visitsBox.put(newVisit.id, newVisit.toMap());

    // 2. Queue in outbox
    await LocalDb.enqueueSync(
      table: 'visits',
      action: 'insert',
      payload: newVisit.toMap(),
    );

    // 3. Sync to Supabase if connected
    if (SupabaseService.instance.isConfigured) {
      try {
        final client = SupabaseService.instance.client;
        await client?.from('visits').insert(newVisit.toMap());
      } catch (e) {
        debugPrint('Supabase visit insert error: $e');
      }
    }

    return newVisit;
  }
}
