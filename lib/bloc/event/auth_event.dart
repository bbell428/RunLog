abstract class AuthEvent {}

class AppStarted extends AuthEvent {}

class GoogleSignInRequested extends AuthEvent {}

class SignOutRequested extends AuthEvent {}