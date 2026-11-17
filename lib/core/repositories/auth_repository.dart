import 'package:flutter/foundation.dart';
import '../database/local_db.dart';
import '../models/app_user.dart';
import '../network/supabase_service.dart';

class AuthRepository {
  AuthRepository._();
  static final AuthRepository instance = AuthRepository._();

  static const String _currentUserKey = 'current_app_user';

  AppUser? _currentUser;
  AppUser? get currentUser => _currentUser;

  bool get isAuthenticated => _currentUser != null;

  /// Load persisted session from local cache on startup
  Future<AppUser?> loadSession() async {
    try {
      final cached = LocalDb.prefsBox.get(_currentUserKey);
      if (cached != null) {
        _currentUser = AppUser.fromMap(Map<String, dynamic>.from(cached as Map));
        debugPrint('Loaded user session: ${_currentUser?.name} (${_currentUser?.role.name})');
        return _currentUser;
      }
    } catch (e) {
      debugPrint('Error loading cached session: $e');
    }
    return null;
  }

  /// Sign in using predefined role accounts (Ideal for competition demo & testing)
  Future<AppUser> loginAsDemoRole(UserRole role) async {
    AppUser user;
    switch (role) {
      case UserRole.patient:
        user = const AppUser(
          id: '33333333-3333-3333-3333-333333333301',
          name: 'Priyanka More (Mother)',
          phone: '9811111101',
          role: UserRole.patient,
          language: 'mr',
          phcId: '11111111-1111-1111-1111-111111111111',
        );
        break;
      case UserRole.asha:
        user = const AppUser(
          id: '22222222-2222-2222-2222-222222222241',
          name: 'Savita Tai (ASHA)',
          phone: '9800000021',
          role: UserRole.asha,
          language: 'mr',
          phcId: '11111111-1111-1111-1111-111111111111',
          pinHash: '1234',
        );
        break;
      case UserRole.anm:
        user = const AppUser(
          id: '22222222-2222-2222-2222-222222222231',
          name: 'ANM Sunita Gaikwad',
          phone: '9800000011',
          role: UserRole.anm,
          language: 'mr',
          phcId: '11111111-1111-1111-1111-111111111111',
          pinHash: '1234',
        );
        break;
      case UserRole.supervisor:
        user = const AppUser(
          id: '22222222-2222-2222-2222-222222222221',
          name: 'Dr. Rajesh Patil (PHC Supervisor)',
          phone: '9800000001',
          role: UserRole.supervisor,
          language: 'mr',
          phcId: '11111111-1111-1111-1111-111111111111',
        );
        break;
      case UserRole.caregiver:
        user = const AppUser(
          id: '44444444-4444-4444-4444-444444444401',
          name: 'Sachin More (Caregiver)',
          phone: '9822222201',
          role: UserRole.caregiver,
          language: 'mr',
          phcId: '11111111-1111-1111-1111-111111111111',
        );
        break;
    }

    _currentUser = user;
    await LocalDb.prefsBox.put(_currentUserKey, user.toMap());
    return user;
  }

  /// Non-OTP offline PIN authentication for ASHA & ANM (Field-resilient)
  Future<AppUser?> loginWithPin({required String phone, required String pin}) async {
    // If Supabase is online, verify against profiles
    if (SupabaseService.instance.isConfigured) {
      try {
        final client = SupabaseService.instance.client;
        final res = await client
            ?.from('profiles')
            .select()
            .eq('phone', phone)
            .maybeSingle();

        if (res != null && res['pin_hash'] == pin) {
          final user = AppUser.fromMap(res);
          _currentUser = user;
          await LocalDb.prefsBox.put(_currentUserKey, user.toMap());
          return user;
        }
      } catch (e) {
        debugPrint('Supabase PIN login failed, falling back to cached PIN: $e');
      }
    }

    // Offline / Demo fallback
    if (pin == '1234') {
      return loginAsDemoRole(UserRole.asha);
    }
    return null;
  }

  /// Phone + OTP login for Patients
  Future<AppUser?> verifyOtp({required String phone, required String otp}) async {
    if (otp == '1234' || otp == '123456') {
      return loginAsDemoRole(UserRole.patient);
    }
    return null;
  }

  /// Sign out
  Future<void> logout() async {
    _currentUser = null;
    await LocalDb.prefsBox.delete(_currentUserKey);
    try {
      if (SupabaseService.instance.isConfigured) {
        await SupabaseService.instance.client?.auth.signOut();
      }
    } catch (_) {}
  }
}
