import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:runlog/model/user_model.dart';
import 'package:runlog/bloc/event/auth_event.dart';
import 'package:runlog/bloc/state/auth_state.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn();
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  AuthBloc() : super(AuthInitial()) {
    on<AppStarted>(_onAppStarted);
    on<GoogleSignInRequested>(_onGoogleSignInRequested);
    on<SignOutRequested>(_onSignOutRequested);
  }

  Future<void> _onAppStarted(AppStarted event, Emitter<AuthState> emit) async {
    final user = _auth.currentUser;
    if (user != null) {
      try {
        final userModel = await _fetchUser(user.uid);
        emit(Authenticated(userModel));
      } catch (e) {
        emit(AuthError("유저 데이터 로드 실패: $e"));
        emit(Unauthenticated());
      }
    } else {
      emit(Unauthenticated());
    }
  }

  Future<void> _onGoogleSignInRequested(
    GoogleSignInRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(AuthLoading());
    try {
      final googleUser = await _googleSignIn.signIn();
      if (googleUser == null) {
        emit(Unauthenticated());
        return;
      }

      final googleAuth = await googleUser.authentication;
      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      final userCredential = await _auth.signInWithCredential(credential);
      final user = userCredential.user!;

      await _firestore.collection('users').doc(user.uid).set({
        'name': user.displayName,
        'email': user.email,
      }, SetOptions(merge: true));

      final userModel = await _fetchUser(user.uid);
      emit(Authenticated(userModel));
    } catch (e) {
      emit(AuthError("로그인 실패: $e"));
      emit(Unauthenticated());
    }
  }

  Future<void> _onSignOutRequested(
    SignOutRequested event,
    Emitter<AuthState> emit,
  ) async {
    await _auth.signOut();
    await _googleSignIn.signOut();
    emit(Unauthenticated());
  }

  Future<UserModel> _fetchUser(String uid) async {
    final doc = await _firestore.collection('users').doc(uid).get();

    if (!doc.exists || doc.data() == null) {
      throw Exception("사용자 데이터가 존재하지 않습니다.");
    }

    return UserModel.fromMap(doc.data()!, uid);
  }
}
