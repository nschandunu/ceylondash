import 'package:equatable/equatable.dart';

abstract class AuthEvent extends Equatable {
  const AuthEvent();

  @override
  List<Object?> get props => [];
}

/// Fired on app start to begin listening to auth state changes.
class AuthStarted extends AuthEvent {}

/// Fired when user logs in successfully (Firebase user detected).
class AuthLoggedIn extends AuthEvent {}

/// Fired when user explicitly logs out.
class AuthLoggedOut extends AuthEvent {}
