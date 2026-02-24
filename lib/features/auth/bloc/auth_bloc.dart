import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:firebase_auth/firebase_auth.dart';

import 'auth_event.dart';
import 'auth_state.dart';
import '../data/auth_service.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  AuthBloc({FirebaseAuth? firebaseAuth, AuthService? authService})
      : _firebaseAuth = firebaseAuth ?? FirebaseAuth.instance,
        _authService = authService ?? AuthService(),
        super(AuthInitial()) {
    on<AuthStarted>(_onAuthStarted);
    on<AuthUserChanged>(_onAuthUserChanged);
    on<AuthLoggedOut>(_onAuthLoggedOut);
  }

  final FirebaseAuth _firebaseAuth;
  final AuthService _authService;
  StreamSubscription<User?>? _authSubscription;

  void _onAuthStarted(AuthStarted event, Emitter<AuthState> emit) {
    emit(AuthLoading());

    // Listen to Firebase auth state changes.
    // This only *observes* — it never calls signOut().
    _authSubscription?.cancel();
    _authSubscription = _firebaseAuth.authStateChanges().listen((user) {
      add(AuthUserChanged(user));
    });
  }

  /// Fetches MongoDB profile before emitting Authenticated
  Future<void> _onAuthUserChanged(
    AuthUserChanged event,
    Emitter<AuthState> emit,
  ) async {
    final user = event.user;
    if (user != null) {
      emit(AuthLoading());
      try {
        final response = await _authService.syncUser();
        final mongoUser = response['data']?['user'] as Map<String, dynamic>? ?? {};
        emit(Authenticated(user, mongoUser));
      } catch (e) {
        // If sync fails, force a logout to prevent broken state
        await _firebaseAuth.signOut();
        emit(Unauthenticated());
      }
    } else {
      emit(Unauthenticated());
    }
  }

  /// User-initiated logout — calls signOut() once.
  /// The authStateChanges stream will then fire AuthUserChanged(null),
  /// which emits Unauthenticated without calling signOut again.
  Future<void> _onAuthLoggedOut(
    AuthLoggedOut event,
    Emitter<AuthState> emit,
  ) async {
    await _firebaseAuth.signOut();
    // No need to emit — authStateChanges will handle it.
  }

  @override
  Future<void> close() {
    _authSubscription?.cancel();
    return super.close();
  }
}
