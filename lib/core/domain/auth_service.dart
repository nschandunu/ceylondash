import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class AuthService {
  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;
  final FlutterSecureStorage _secureStorage = const FlutterSecureStorage();

  static const String _tokenKey = 'firebase_id_token';

  /// Login with email and password.
  /// On success, stores the Firebase ID token securely for future API requests.
  Future<User> login(String email, String password) async {
    final credential = await _firebaseAuth.signInWithEmailAndPassword(
      email: email,
      password: password,
    );

    final user = credential.user;
    if (user == null) {
      throw Exception('Login failed: no user returned.');
    }

    final idToken = await user.getIdToken();
    await _secureStorage.write(key: _tokenKey, value: idToken);

    return user;
  }

  /// Retrieve the stored ID token for API request headers.
  Future<String?> getStoredToken() async {
    return _secureStorage.read(key: _tokenKey);
  }

  /// Logout: sign out of Firebase and delete the stored token.
  Future<void> logout() async {
    await _firebaseAuth.signOut();
    await _secureStorage.delete(key: _tokenKey);
  }
}
