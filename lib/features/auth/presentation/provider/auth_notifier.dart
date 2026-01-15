import 'package:glypha/core/failure/failure.dart';
import 'package:glypha/core/services/auth_service.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'auth_state.dart';

part 'auth_notifier.g.dart';

@riverpod
class AuthNotifier extends _$AuthNotifier {
  @override
  AuthState build() {
    _listenToAuthChanges();
    return const AuthInitial();
  }

  void _listenToAuthChanges() {
    final authService = ref.watch(authServiceProvider);

    final subscription = authService.authChanges.listen(
      (user) {
        if (user != null) {
          state = AuthAuthenticated(user);
        } else {
          state = const AuthUnauthenticated();
        }
      },
      onError: (error) {
        if (error is AuthFailure) {
          state = AuthError(error);
        } else {
          state = const AuthError(AuthFailure.serverError());
        }
      },
    );

    ref.onDispose(subscription.cancel);
  }

  Future<void> signInWithGoogle() async {
    state = const AuthLoading(provider: LoginProvider.google);

    try {
      final authService = ref.read(authServiceProvider);
      final user = await authService.signInWithGoogle();

      if (user != null) {
        state = AuthAuthenticated(user);
      } else {
        state = const AuthUnauthenticated();
      }
    } on AuthFailure catch (failure) {
      state = AuthError(failure);
    } catch (e) {
      state = const AuthError(AuthFailure.serverError());
    }
  }

  Future<void> signInWithApple() async {
    state = const AuthLoading(provider: LoginProvider.apple);

    try {
      final authService = ref.read(authServiceProvider);
      final user = await authService.signInWithApple();

      state = AuthAuthenticated(user);
    } on AuthFailure catch (failure) {
      state = AuthError(failure);
    } catch (e) {
      state = const AuthError(AuthFailure.serverError());
    }
  }

  Future<void> signOut() async {
    state = const AuthLoading();

    try {
      final authService = ref.read(authServiceProvider);
      await authService.signOut();
      state = const AuthUnauthenticated();
    } on AuthFailure catch (failure) {
      state = AuthError(failure);
    } catch (e) {
      state = const AuthError(AuthFailure.serverError());
    }
  }

  void clearError() {
    if (state is AuthError) {
      state = const AuthUnauthenticated();
    }
  }
}
