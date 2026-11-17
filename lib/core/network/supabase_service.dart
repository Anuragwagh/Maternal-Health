import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class SupabaseService {
  SupabaseService._();
  static final SupabaseService instance = SupabaseService._();

  // Supabase credentials (can be configured via environment or updated by the developer)
  // When empty or placeholder, the app runs in resilient offline/cache-first demo mode.
  static const String supabaseUrl = String.fromEnvironment(
    'SUPABASE_URL',
    defaultValue: 'https://demo-maternal-health.supabase.co',
  );
  static const String supabaseAnonKey = String.fromEnvironment(
    'SUPABASE_ANON_KEY',
    defaultValue: 'demo-anon-key-placeholder',
  );

  bool _isInitialized = false;
  bool get isInitialized => _isInitialized;

  bool get isConfigured =>
      supabaseUrl.isNotEmpty &&
      !supabaseUrl.contains('demo-maternal-health') &&
      supabaseAnonKey.isNotEmpty &&
      !supabaseAnonKey.contains('demo-anon-key');

  SupabaseClient? get client {
    if (!_isInitialized || !isConfigured) return null;
    return Supabase.instance.client;
  }

  Future<void> init() async {
    try {
      if (isConfigured) {
        await Supabase.initialize(
          url: supabaseUrl,
          publishableKey: supabaseAnonKey,
        );
        _isInitialized = true;
        debugPrint('Supabase successfully initialized with URL: $supabaseUrl');
      } else {
        debugPrint('Supabase is running in local offline/cache-first mock mode (No valid remote keys provided yet).');
      }
    } catch (e) {
      debugPrint('Supabase initialization failed, falling back to local cache mode: $e');
      _isInitialized = false;
    }
  }
}
