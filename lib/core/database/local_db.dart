import 'package:flutter/foundation.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../services/sync_service.dart';

class LocalDb {
  static const String patientsBoxName = 'patients';
  static const String visitsBoxName = 'visits';
  static const String alertsBoxName = 'alerts';
  static const String medicinesBoxName = 'medicines';
  static const String syncQueueBoxName = 'sync_queue';
  static const String prefsBoxName = 'prefs';

  static Future<void> init() async {
    await Hive.initFlutter();
    
    await Hive.openBox(patientsBoxName);
    await Hive.openBox(visitsBoxName);
    await Hive.openBox(alertsBoxName);
    await Hive.openBox(medicinesBoxName);
    await Hive.openBox(syncQueueBoxName);
    await Hive.openBox(prefsBoxName);

    debugPrint('Hive Local Database initialized with 6 storage boxes.');
  }

  static Box get patientsBox => Hive.box(patientsBoxName);
  static Box get visitsBox => Hive.box(visitsBoxName);
  static Box get alertsBox => Hive.box(alertsBoxName);
  static Box get medicinesBox => Hive.box(medicinesBoxName);
  static Box get syncQueueBox => Hive.box(syncQueueBoxName);
  static Box get prefsBox => Hive.box(prefsBoxName);

  /// Outbox helper: Queues a local mutation to be synced to the remote backend
  static Future<void> enqueueSync({
    required String table,
    required String action, // 'insert', 'update', 'delete'
    required Map<String, dynamic> payload,
  }) async {
    final item = {
      'id': DateTime.now().millisecondsSinceEpoch.toString(),
      'table': table,
      'action': action,
      'payload': payload,
      'enqueued_at': DateTime.now().toIso8601String(),
    };
    await syncQueueBox.add(item);
    SyncService.instance.triggerSync();
  }

  /// Get pending sync items
  static List<Map<String, dynamic>> getPendingSyncItems() {
    return syncQueueBox.values.map((e) => Map<String, dynamic>.from(e as Map)).toList();
  }

  /// Clear synced item from outbox
  static Future<void> removeSyncItem(int key) async {
    await syncQueueBox.delete(key);
  }
}
