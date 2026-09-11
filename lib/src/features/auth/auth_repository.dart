import '../../core/api_client.dart';
import '../../core/token_store.dart';
import 'customer.dart';

class AuthRepository {
  AuthRepository({required ApiClient api, required TokenStore tokens})
      : _api = api, // ignore: prefer_initializing_formals
        _tokens = tokens; // ignore: prefer_initializing_formals

  final ApiClient _api;
  final TokenStore _tokens;

  Future<SignInCodeRequest> requestCode(String phone) async {
    final response = await _api.post('/auth/request-code', body: {'phone': phone});

    return SignInCodeRequest.fromJson(response);
  }

  /// Verifies the code, stores the returned token and returns the customer.
  ///
  /// The token is written before the customer is returned so that the very next
  /// request — usually loading their trips — is already authenticated.
  Future<Customer> verifyCode({
    required String phone,
    required String code,
    String? name,
    String deviceName = 'mobile',
  }) async {
    final response = await _api.post('/auth/verify-code', body: {
      'phone': phone,
      'code': code,
      if (name != null && name.trim().isNotEmpty) 'name': name.trim(),
      'device_name': deviceName,
    });

    await _tokens.write(response['token'] as String);

    return Customer.fromJson(response['customer'] as Map<String, dynamic>);
  }

  Future<Customer> me() async {
    final response = await _api.get('/me');

    return Customer.fromJson(response['customer'] as Map<String, dynamic>);
  }

  Future<Customer> updateProfile({
    String? firstName,
    String? lastName,
    String? email,
    bool? marketingConsent,
  }) async {
    final response = await _api.patch('/me', body: {
      'first_name': ?firstName,
      'last_name': ?lastName,
      'email': ?email,
      'marketing_consent': ?marketingConsent,
    });

    return Customer.fromJson(response['customer'] as Map<String, dynamic>);
  }

  /// Revokes the token server-side, then forgets it locally.
  ///
  /// The local token is cleared even if the call fails: a customer who taps
  /// sign out while offline must still end up signed out on this device.
  Future<void> signOut() async {
    try {
      await _api.post('/auth/sign-out');
    } catch (_) {
      // Deliberately ignored — see above.
    } finally {
      await _tokens.clear();
    }
  }

  Future<bool> hasStoredSession() async {
    final token = await _tokens.read();

    return token != null && token.isNotEmpty;
  }
}
