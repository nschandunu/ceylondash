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
    on<AuthLoggedIn>(_onAuthLoggedIn);
    on<AuthLoggedOut>(_onAuthLoggedOut);
  }

  final FirebaseAuth _firebaseAuth;
  StreamSubscription<User?>? _authSubscription;

  void _onAuthStarted(AuthStarted event, Emitter<AuthState> emit) {
    emit(AuthLoading());

    // Listen to Firebase auth state changes and map to bloc events.
    _authSubscription?.cancel();
    _authSubscription = _firebaseAuth.authStateChanges().listen((user) {
      if (user != null) {
        add(AuthLoggedIn());
      } else {
        add(AuthLoggedOut());
      }
    });
  }

  void _onAuthLoggedIn(AuthLoggedIn event, Emitter<AuthState> emit) {
    final user = _firebaseAuth.currentUser;
    if (user != null) {
      emit(Authenticated(user));
    } else {
      emit(Unauthenticated());
    }
  }

  Future<void> _onAuthLoggedOut(
    AuthLoggedOut event,
    Emitter<AuthState> emit,
  ) async {
    await _firebaseAuth.signOut();
    emit(Unauthenticated());
  }

  @override
  Future<void> close() {
    _authSubscription?.cancel();
    return super.close();
  }
}
