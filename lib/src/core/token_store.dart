import 'package:flutter_secure_storage/flutter_secure_storage.dart';

/// Where the bearer token lives between launches.
///
/// The Keychain on iOS and EncryptedSharedPreferences on Android, rather than
/// plain preferences: the token is the customer's entire identity here — there
/// is no password behind it — so it is stored the way a password would be.
class TokenStore {
  TokenStore(this._storage);

  static const _key = 'saints_link.customer_token';

  final FlutterSecureStorage _storage;

  Future<String?> read() async {
    try {
      return await _storage.read(key: _key);
    } catch (_) {
      /*
       * Secure storage can fail to open — a restored backup on Android leaves
       * entries that cannot be decrypted with the new device's key. Losing the
       * token means signing in again, which is a minor inconvenience; throwing
       * here would mean an app that cannot start at all.
       */
      return null;
    }
  }

  Future<void> write(String token) async {
    try {
      await _storage.write(key: _key, value: token);
    } catch (_) {
      // The session still works for this launch; only persistence is lost.
    }
  }

  Future<void> clear() async {
    try {
      await _storage.delete(key: _key);
    } catch (_) {
      // Nothing to recover from: the caller is signing out regardless.
    }
  }
}
