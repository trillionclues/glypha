import 'package:glypha/core/failure/failure.dart';
import 'package:glypha/features/auth/domain/entities/user_entity.dart';

enum LoginProvider { none, google, apple }

sealed class AuthState {
  const AuthState();

  UserEntity? get user => null;

  bool get isLoading => this is AuthLoading;

  bool isLoadingProvider(LoginProvider provider) {
    if (this is AuthLoading) {
      return (this as AuthLoading).provider == provider;
    }
    return false;
  }
}

class AuthInitial extends AuthState {
  const AuthInitial();
}

class AuthLoading extends AuthState {
  final LoginProvider provider;
  const AuthLoading({this.provider = LoginProvider.none});
}

class AuthAuthenticated extends AuthState {
  final UserEntity user;
  const AuthAuthenticated(this.user);
}

class AuthUnauthenticated extends AuthState {
  const AuthUnauthenticated();
}

class AuthError extends AuthState {
  final AuthFailure failure;
  const AuthError(this.failure);
}
