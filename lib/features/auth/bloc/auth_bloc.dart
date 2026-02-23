import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:firebase_auth/firebase_auth.dart';

import 'auth_event.dart';
import 'auth_state.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  AuthBloc({FirebaseAuth? firebaseAuth})
      : _firebaseAuth = firebaseAuth ?? FirebaseAuth.instance,
        super(AuthInitial()) {
    on<AuthStarted>(_onAuthStarted);
    on<AuthUserChanged>(_onAuthUserChanged);
    on<AuthLoggedOut>(_onAuthLoggedOut);
  }

  final FirebaseAuth _firebaseAuth;
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

  /// Pure state mapper — no side effects, so no loop.
  void _onAuthUserChanged(AuthUserChanged event, Emitter<AuthState> emit) {
    final user = event.user;
    if (user != null) {
      emit(Authenticated(user));
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
