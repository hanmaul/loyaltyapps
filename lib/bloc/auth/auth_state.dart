part of 'auth_bloc.dart';

@immutable
sealed class AuthState {}

final class AuthInitial extends AuthState {}

final class SignedIn extends AuthState {
  final String message;

  SignedIn({
    required this.message,
  });
}

final class InRegister extends AuthState {
  final String message;

  InRegister({
    required this.message,
  });
}

final class UnRegistered extends AuthState {
  final String message;

  UnRegistered({
    required this.message,
  });
}

class UserLoggedOut extends AuthState {}

final class FailureLoadState extends AuthState {
  final String message;

  FailureLoadState({
    required this.message,
  });
}
