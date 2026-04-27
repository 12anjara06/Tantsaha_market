import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/user_model.dart';
import '../services/auth_service.dart';

final authServiceProvider = Provider<AuthService>((ref) => AuthService());

class AuthState {
  final bool isLoading;
  final UserModel? user;
  final String? error;

  AuthState({this.isLoading = false, this.user, this.error});

  AuthState copyWith({bool? isLoading, UserModel? user, String? error, bool clearError = false}) {
    return AuthState(
      isLoading: isLoading ?? this.isLoading,
      user: user ?? this.user,
      error: clearError ? null : (error ?? this.error),
    );
  }
}

class AuthNotifier extends Notifier<AuthState> {
  @override
  AuthState build() {
    return AuthState();
  }

  Future<void> login(String credentials, String password) async {
    state = state.copyWith(isLoading: true, clearError: true);
    try {
      final authService = ref.read(authServiceProvider);
      final user = await authService.login(credentials, password);
      // Connexion réussie
      state = state.copyWith(isLoading: false, user: user);
    } catch (e) {
      // Nettoyer le mot Exception: du message pour affichage
      state = state.copyWith(isLoading: false, error: e.toString().replaceAll('Exception: ', ''));
    }
  }

  void logout() {
    state = state.copyWith(user: null, clearError: true);
  }
}

final authProvider = NotifierProvider<AuthNotifier, AuthState>(() {
  return AuthNotifier();
});
