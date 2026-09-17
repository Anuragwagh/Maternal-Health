import 'package:hive_flutter/hive_flutter.dart';

class LocalDb {
  static const String patientsBoxName = 'patients';
  static const String visitsBoxName = 'visits';
  static const String alertsBoxName = 'alerts';
  static const String syncQueueBoxName = 'sync_queue';
  static const String prefsBoxName = 'prefs';

  static Future<void> init() async {
    await Hive.initFlutter();
    
    // Register adapters here if we have custom model classes in the future.
    // Hive.registerAdapter(PatientAdapter());

    // Open boxes
    await Hive.openBox(patientsBoxName);
    await Hive.openBox(visitsBoxName);
    await Hive.openBox(alertsBoxName);
    await Hive.openBox(syncQueueBoxName);
    await Hive.openBox(prefsBoxName);
  }

  static Box get patientsBox => Hive.box(patientsBoxName);
  static Box get visitsBox => Hive.box(visitsBoxName);
  static Box get alertsBox => Hive.box(alertsBoxName);
  static Box get syncQueueBox => Hive.box(syncQueueBoxName);
  static Box get prefsBox => Hive.box(prefsBoxName);
}
