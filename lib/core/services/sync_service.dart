import 'dart:async';
import 'dart:io';
import 'package:flutter/foundation.dart';
import '../database/local_db.dart';
import '../network/supabase_service.dart';
import '../../app_state.dart';

class SyncResult {
  final bool success;
  final int syncedCount;
  final String message;

  const SyncResult({
    required this.success,
    this.syncedCount = 0,
    required this.message,
  });
}

/// Offline Sync Manager
///
/// Implements the cache-first, outbox pattern for the Maternal Health App.
/// Handles network connectivity monitoring, live demo offline simulation,
/// queue draining, and synchronization with Supabase backend.
class SyncService extends ChangeNotifier {
  SyncService._();
  static final SyncService instance = SyncService._();

  bool _isOnline = true;
  bool _isSimulatedOffline = false;
  bool _isSyncing = false;
  DateTime? _lastSyncedAt;
  String? _lastError;
  Timer? _periodicTimer;
  Timer? _debounceTimer;

  bool get isOnline => !_isSimulatedOffline && _isOnline;
  bool get isSimulatedOffline => _isSimulatedOffline;
  bool get isSyncing => _isSyncing;
  DateTime? get lastSyncedAt => _lastSyncedAt;
  String? get lastError => _lastError;
  int get pendingCount => LocalDb.syncQueueBox.length;

  /// Initialize sync manager and start background heartbeat
  Future<void> init() async {
    final count = pendingCount;
    AppState.instance.setPendingSyncCount(count);
    AppState.instance.setOnlineStatus(isOnline);

    await checkConnectivity();

    // Start background sync heartbeat (every 20 seconds)
    _periodicTimer?.cancel();
    _periodicTimer = Timer.periodic(const Duration(seconds: 20), (_) async {
      await checkConnectivity();
      if (isOnline && pendingCount > 0 && !_isSyncing) {
        await syncNow();
      }
    });

    _setupRealtimeSubscriptions();
    debugPrint('SyncService initialized. Pending queue items: $pendingCount');
  }

  /// Toggle simulated offline mode (for Avishkar live demo)
  void setSimulatedOffline(bool simulated) {
    _isSimulatedOffline = simulated;
    AppState.instance.setOnlineStatus(isOnline);
    notifyListeners();
  }

  /// Test network connectivity
  Future<bool> checkConnectivity() async {
    if (_isSimulatedOffline) {
      _isOnline = false;
      AppState.instance.setOnlineStatus(false);
      notifyListeners();
      return false;
    }

    try {
      // Fast DNS lookup to verify real internet connectivity
      final result = await InternetAddress.lookup('google.com')
          .timeout(const Duration(seconds: 3));
      final connected = result.isNotEmpty && result[0].rawAddress.isNotEmpty;
      _isOnline = connected;
      AppState.instance.setOnlineStatus(connected);
      notifyListeners();
      return connected;
    } catch (_) {
      _isOnline = false;
      AppState.instance.setOnlineStatus(false);
      notifyListeners();
      return false;
    }
  }

  /// Trigger debounced sync (called after local data mutations)
  void triggerSync() {
    AppState.instance.setPendingSyncCount(pendingCount);
    notifyListeners();

    if (!isOnline) return;

    _debounceTimer?.cancel();
    _debounceTimer = Timer(const Duration(milliseconds: 1500), () {
      if (isOnline && pendingCount > 0 && !_isSyncing) {
        syncNow();
      }
    });
  }

  /// Drain the outbox queue and push items to Supabase
  Future<SyncResult> syncNow() async {
    if (_isSimulatedOffline) {
      return const SyncResult(
        success: false,
        message: 'Offline mode is currently active (Airplane simulation)',
      );
    }

    if (_isSyncing) {
      return const SyncResult(
        success: false,
        message: 'Sync is already in progress',
      );
    }

    _isSyncing = true;
    _lastError = null;
    notifyListeners();

    int successCount = 0;

    try {
      final queueBox = LocalDb.syncQueueBox;
      final keys = queueBox.keys.toList();

      if (keys.isEmpty) {
        _isSyncing = false;
        _lastSyncedAt = DateTime.now();
        AppState.instance.setPendingSyncCount(0);
        notifyListeners();
        return const SyncResult(
          success: true,
          syncedCount: 0,
          message: 'Outbox is clean. Everything is up to date.',
        );
      }

      final isRemoteReady = SupabaseService.instance.isConfigured;
      final client = SupabaseService.instance.client;

      for (final key in keys) {
        final rawItem = queueBox.get(key);
        if (rawItem == null) continue;

        final item = Map<String, dynamic>.from(rawItem as Map);
        final table = item['table'] as String;
        final action = item['action'] as String? ?? 'upsert';
        final payload = Map<String, dynamic>.from(item['payload'] as Map);

        bool pushed = false;

        if (isRemoteReady && client != null) {
          try {
            if (action == 'delete' && payload.containsKey('id')) {
              await client.from(table).delete().eq('id', payload['id']);
            } else {
              await client.from(table).upsert(payload);
            }
            pushed = true;
          } catch (e) {
            debugPrint('Failed to sync item $key to Supabase table $table: $e');
            _lastError = e.toString();
            pushed = false;
          }
        } else {
          // In local/mock mode: treat queue drainage as successful local commit
          pushed = true;
        }

        if (pushed) {
          await queueBox.delete(key);
          successCount++;
        }
      }

      _lastSyncedAt = DateTime.now();
      final remaining = queueBox.length;
      AppState.instance.setPendingSyncCount(remaining);

      _isSyncing = false;
      notifyListeners();

      return SyncResult(
        success: true,
        syncedCount: successCount,
        message: 'Successfully synced $successCount items. $remaining remaining.',
      );
    } catch (e) {
      _isSyncing = false;
      _lastError = e.toString();
      notifyListeners();
      return SyncResult(
        success: false,
        syncedCount: successCount,
        message: 'Sync error: $e',
      );
    }
  }

  /// Supabase Realtime subscriptions for multi-device synchronization
  void _setupRealtimeSubscriptions() {
    if (!SupabaseService.instance.isConfigured) return;

    try {
      final client = SupabaseService.instance.client;
      if (client == null) return;

      client.channel('public:alerts').subscribe();
      debugPrint('Supabase Realtime subscriptions established.');
    } catch (e) {
      debugPrint('Error setting up Supabase Realtime: $e');
    }
  }

  @override
  void dispose() {
    _periodicTimer?.cancel();
    _debounceTimer?.cancel();
    super.dispose();
  }
}
