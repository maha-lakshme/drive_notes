import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:google_sign_in/google_sign_in.dart';

class AuthService {
  final GoogleSignIn _googleSignIn = GoogleSignIn(
    scopes: ['https://www.googleapis.com/auth/drive.file'],
  );

  final FlutterSecureStorage _flutterSecureStorage = FlutterSecureStorage();

  GoogleSignInAccount? get currentUser => _googleSignIn.currentUser;

  Future<GoogleSignInAccount?> signInWithGoogle() async {
    try {
      final account = await _googleSignIn.signIn();
      if (account != null) {
        final auth = await account.authentication;
        print("Interactive sign-in token: ${auth.accessToken}");
        await _flutterSecureStorage.write(
          key: 'accessToken',
          value: auth.accessToken,
        );
      } else {
        print("Interactive sign-in returned null account.");
      }
      return account;
    } catch (error) {
      print("Interactive sign-in error: $error");
      rethrow;
    }
  }

  /// Attempt a silent sign-in and store the new access token if available.
  Future<GoogleSignInAccount?> signInSilently() async {
    try {
      // Try returning the current user immediately if available.
      if (_googleSignIn.currentUser != null) {
        print("Silent sign-in: currentUser exists.");
        return _googleSignIn.currentUser;
      }
      final account = await _googleSignIn.signInSilently();
      if (account != null) {
        final auth = await account.authentication;
        print("Silent sign-in token: ${auth.accessToken}");
        await _flutterSecureStorage.write(
          key: 'accessToken',
          value: auth.accessToken,
        );
      } else {
        print("Silent sign-in returned null account.");
      }
      return account;
    } catch (error) {
      print("Silent sign-in error: $error");
      return null;
    }
  }

  /// Sign out and remove the stored token.
  Future<void> signOut() async {
    await _googleSignIn.signOut();
    await _flutterSecureStorage.delete(key: 'accessToken');
  }

  /// Get the current access token.
  /// This method attempts a silent sign in to make sure to have a fresh token. or return stored token
  Future<String?> getAccessToken() async {
    final account = await signInSilently();
    if (account != null) {
      final auth = await account.authentication;
      // Store the fresh token.
      await _flutterSecureStorage.write(
        key: 'accessToken',
        value: auth.accessToken,
      );
      return auth.accessToken;
    }
    // If silent sign-in fails, return the stored token (if any).
    return await _flutterSecureStorage.read(key: 'accessToken');
  }
}
