import 'package:equatable/equatable.dart';
import 'package:firebase_auth/firebase_auth.dart';

abstract class AuthEvent extends Equatable {
  const AuthEvent();

  @override
  List<Object?> get props => [];
}

/// Fired on app start to begin listening to auth state changes.
class AuthStarted extends AuthEvent {}

/// Internal event: fired by the authStateChanges stream when auth state changes.
class AuthUserChanged extends AuthEvent {
  const AuthUserChanged(this.user);

  final User? user;

  @override
  List<Object?> get props => [user?.uid];
}

/// Fired when user explicitly taps the logout button.
class AuthLoggedOut extends AuthEvent {}
