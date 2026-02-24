import 'package:equatable/equatable.dart';
import 'package:firebase_auth/firebase_auth.dart';

abstract class AuthState extends Equatable {
  const AuthState();

  @override
  List<Object?> get props => [];
}

/// Initial state before auth check has been performed.
class AuthInitial extends AuthState {}

/// Auth check is in progress.
class AuthLoading extends AuthState {}

/// User is authenticated.
class Authenticated extends AuthState {
  const Authenticated(this.user, this.mongoUser);

  final User user;
  final Map<String, dynamic> mongoUser;

  @override
  List<Object?> get props => [user.uid, mongoUser];
}

/// User is not authenticated.
class Unauthenticated extends AuthState {}
