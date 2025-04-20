
import 'package:drive_notes/auth/auth_service.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final authServiceProvider = Provider<AuthService>((ref){
  return AuthService();
},);

final authStateProvider = StateNotifierProvider<AuthStateNotifier,bool>((ref) {
  return AuthStateNotifier(ref);
},);

class AuthStateNotifier extends StateNotifier<bool>{
  
  final Ref ref;
  AuthStateNotifier(this.ref): super(false){
    _initializeAuthState();
  }

/// First checks if there is a current user, then falls back to silent sign in.
  Future<void> _initializeAuthState() async {
    final authService = ref.read(authServiceProvider);
    // Check if an interactive sign in has already set a user.
    if (authService.currentUser != null) {
      state = true;
      return;
    }
    // Otherwise attempt silent sign in.
    try {
      final account = await authService.signInSilently();
      state = account != null;
    } catch (error) {
      // If error, assume user is not authenticated.
      state = false;
    }
  }
  Future<void> login() async{
    final authService = ref.read(authServiceProvider);
    final account = await authService.signInWithGoogle();
    state = account !=null;
  }

  Future<void> logout() async{
     final authService = ref.read(authServiceProvider);
    await authService.signOut();
     state = false; 
  }
}