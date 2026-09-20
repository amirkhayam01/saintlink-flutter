import 'package:flutter_secure_storage/flutter_secure_storage.dart';

/// The bearer token, in secure storage: it is the customer's only credential.
class TokenStore {
  TokenStore(this._storage);

  static const _key = 'saints_link.customer_token';

  final FlutterSecureStorage _storage;

  Future<String?> read() async {
    try {
      return await _storage.read(key: _key);
    } catch (_) {
      // A restored Android backup can leave entries the new device cannot decrypt.
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
