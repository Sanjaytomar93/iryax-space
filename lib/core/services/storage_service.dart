import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';

class StorageService {
  StorageService._();

  static final GetStorage _box = GetStorage();

  // ============================================================
  // LOGIN SESSION
  // ============================================================

  static const String _isLoggedInKey =
      'is_logged_in';

  static const String _tokenKey =
      'auth_token';

  static const String _userIdKey =
      'user_id';

  static const String _userNameKey =
      'user_name';

  static const String _userEmailKey =
      'user_email';

  static const String _userMobileKey =
      'user_mobile';

  static const String _userAddressKey =
      'user_address';

  static const String _userRoleKey =
      'user_role';

  static const String _isDoctorKey =
      'is_doctor';

  static const String _readNotificationIdsPrefix =
      'read_notification_ids_';

  // ============================================================
  // REGISTRATION
  // ============================================================

  static const String _registrationCompletedKey =
      'registration_completed';

  static const String _registrationInProgressKey =
      'registration_in_progress';

  static const String _registrationStepKey =
      'registration_step';

  static const String _accountTypeKey =
      'account_type';

  static const String _fullNameKey =
      'full_name';

  static const String _emailKey =
      'registration_email';

  static const String _mobileKey =
      'mobile';

  static const String _addressKey =
      'address';

  static const String _organizationKey =
      'organization_name';

  static const String _gstKey =
      'gst_number';

  static const String _panKey =
      'pan_number';

  static const String _dmhoKey =
      'dmho_number';

  // ============================================================
  // SESSION GETTERS
  // ============================================================

  /// True only when login flag is set AND a non-empty auth token exists.
  /// Prevents stale `is_logged_in` from treating the user as logged in
  /// after cache/data clears or incomplete restores.
  static bool get isLoggedIn {
    final loggedIn =
        _box.read<bool>(_isLoggedInKey) ?? false;
    final authToken =
        _box.read<String>(_tokenKey) ?? '';
    return loggedIn && authToken.trim().isNotEmpty;
  }

  static String get token =>
      _box.read<String>(_tokenKey) ?? '';

  static String get userId =>
      _box.read<String>(_userIdKey) ?? '';

  static String get userName =>
      _box.read<String>(_userNameKey) ?? '';

  static String get userEmail =>
      _box.read<String>(_userEmailKey) ?? '';

  static String get userMobile =>
      _box.read<String>(_userMobileKey) ?? '';

  static String get userAddress =>
      _box.read<String>(_userAddressKey) ?? '';

  static String get userRole =>
      _box.read<String>(_userRoleKey) ?? '';

  static bool get isDoctor =>
      _box.read<bool>(_isDoctorKey) ??
          false;

  // ============================================================
  // REGISTRATION GETTERS
  // ============================================================

  static bool get registrationCompleted =>
      _box.read<bool>(
        _registrationCompletedKey,
      ) ??
          false;

  static bool get registrationInProgress =>
      _box.read<bool>(
        _registrationInProgressKey,
      ) ??
          false;

  static int get registrationStep =>
      _box.read<int>(
        _registrationStepKey,
      ) ??
          1;

  static String? get accountType =>
      _box.read<String>(
        _accountTypeKey,
      );

  static String get fullName =>
      _box.read<String>(
        _fullNameKey,
      ) ??
          '';

  static String get registrationEmail =>
      _box.read<String>(
        _emailKey,
      ) ??
          '';

  static String get mobile =>
      _box.read<String>(
        _mobileKey,
      ) ??
          '';

  static String get address =>
      _box.read<String>(
        _addressKey,
      ) ??
          '';

  static String get organizationName =>
      _box.read<String>(
        _organizationKey,
      ) ??
          '';

  static String get gst =>
      _box.read<String>(
        _gstKey,
      ) ??
          '';

  static String get pan =>
      _box.read<String>(
        _panKey,
      ) ??
          '';

  static String get dmho =>
      _box.read<String>(
        _dmhoKey,
      ) ??
          '';

  // ============================================================
  // SAVE LOGIN
  // ============================================================

  static Future<void> saveLoginSession({
    required String token,
    required String userId,
    required String name,
    required String email,
    required String mobile,
    required String address,
    required String role,
    required bool isDoctor,
  }) async {
    await _box.write(
      _tokenKey,
      token,
    );

    await _box.write(
      _userIdKey,
      userId,
    );

    await _box.write(
      _userNameKey,
      name,
    );

    await _box.write(
      _userEmailKey,
      email,
    );

    await _box.write(
      _userMobileKey,
      mobile,
    );

    await _box.write(
      _userAddressKey,
      address,
    );

    await _box.write(
      _userRoleKey,
      role,
    );

    await _box.write(
      _isDoctorKey,
      isDoctor,
    );

    await _box.write(
      _isLoggedInKey,
      true,
    );
  }

  static Future<void> setLoggedIn(
      bool value,
      ) async {
    await _box.write(
      _isLoggedInKey,
      value,
    );
  }

  // ============================================================
  // REGISTRATION PROGRESS
  // ============================================================

  static Future<void> startRegistration({
    required String accountType,
  }) async {
    await _box.write(
      _registrationCompletedKey,
      false,
    );

    await _box.write(
      _registrationInProgressKey,
      true,
    );

    await _box.write(
      _accountTypeKey,
      accountType,
    );

    await _box.write(
      _registrationStepKey,
      1,
    );
  }

  static Future<void> saveRegistrationStep(
      int step,
      ) async {
    await _box.write(
      _registrationStepKey,
      step,
    );
  }

  static Future<void> savePersonalDetails({
    required String fullName,
    required String email,
    required String mobile,
    required String address,
  }) async {
    await _box.write(
      _fullNameKey,
      fullName,
    );

    await _box.write(
      _emailKey,
      email,
    );

    await _box.write(
      _mobileKey,
      mobile,
    );

    await _box.write(
      _addressKey,
      address,
    );
  }

  static Future<void> saveOrganization({
    required String name,
    required String gst,
    required String pan,
    required String dmho,
  }) async {
    await _box.write(
      _organizationKey,
      name,
    );

    await _box.write(
      _gstKey,
      gst,
    );

    await _box.write(
      _panKey,
      pan,
    );

    await _box.write(
      _dmhoKey,
      dmho,
    );
  }

  static Future<void> completeRegistration() async {
    await _box.write(
      _registrationCompletedKey,
      true,
    );

    await _box.write(
      _registrationInProgressKey,
      false,
    );

    await _clearRegistrationFields();
  }

  static Future<void> clearRegistration() async {
    await _box.write(
      _registrationInProgressKey,
      false,
    );

    await _clearRegistrationFields();
  }

  static Future<void> _clearRegistrationFields() async {
    await _box.remove(
      _registrationStepKey,
    );

    await _box.remove(
      _accountTypeKey,
    );

    await _box.remove(
      _fullNameKey,
    );

    await _box.remove(
      _emailKey,
    );

    await _box.remove(
      _mobileKey,
    );

    await _box.remove(
      _addressKey,
    );

    await _box.remove(
      _organizationKey,
    );

    await _box.remove(
      _gstKey,
    );

    await _box.remove(
      _panKey,
    );

    await _box.remove(
      _dmhoKey,
    );
  }

  // ============================================================
  // NOTIFICATIONS (local mark-read — per user, survives logout)
  // ============================================================

  static String _readNotificationIdsKeyFor([String? uid]) {
    final id = (uid ?? userId).trim();
    return '$_readNotificationIdsPrefix${id.isEmpty ? 'guest' : id}';
  }

  static Set<String> getReadNotificationIds() {
    final key = _readNotificationIdsKeyFor();
    var raw = _box.read(key);
    // Migrate legacy global key → per-user key
    if (raw is! List) {
      raw = _box.read('read_notification_ids');
      if (raw is List) {
        _box.write(key, raw);
        _box.remove('read_notification_ids');
      }
    }
    if (raw is! List) return <String>{};
    return raw.map((e) => e.toString()).where((e) => e.isNotEmpty).toSet();
  }

  static Future<void> saveReadNotificationIds(Set<String> ids) async {
    await _box.write(_readNotificationIdsKeyFor(), ids.toList());
  }

  // ============================================================
  // LOGOUT / CLEAR CACHE
  // ============================================================

  /// Clears session when `is_logged_in` is true but token is missing.
  static Future<void> clearStaleSessionIfNeeded() async {
    final loggedInFlag =
        _box.read<bool>(_isLoggedInKey) ?? false;
    final authToken =
        (_box.read<String>(_tokenKey) ?? '').trim();

    if (loggedInFlag && authToken.isEmpty) {
      await logout();
    }
  }

  /// Full local wipe of session + registration cache.
  static Future<void> clearAll() async {
    await _box.erase();

    try {
      Get.deleteAll(force: true);
    } catch (_) {}
  }

  static Future<void> logout() async {
    await _box.remove(
      _tokenKey,
    );

    await _box.remove(
      _userIdKey,
    );

    await _box.remove(
      _userNameKey,
    );

    await _box.remove(
      _userEmailKey,
    );

    await _box.remove(
      _userMobileKey,
    );

    await _box.remove(
      _userAddressKey,
    );

    await _box.remove(
      _userRoleKey,
    );

    await _box.remove(
      _isDoctorKey,
    );

    // Keep per-user read notification ids so Mark-all-read survives re-login.

    await _box.write(
      _isLoggedInKey,
      false,
    );

    try {
      Get.deleteAll(force: true);
    } catch (_) {}
  }
}
