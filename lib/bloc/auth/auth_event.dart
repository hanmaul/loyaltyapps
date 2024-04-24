part of 'auth_bloc.dart';

@immutable
sealed class AuthEvent {}

class SessionCheck extends AuthEvent {}
