import 'package:flutter/material.dart';

@immutable
abstract class LoginState {}

class LoginInitial extends LoginState {}

class LoginLoading extends LoginState {}

class LoginSuccess extends LoginState {
  final String message;

  LoginSuccess(this.message);

  @override
  String toString() => 'LoginSuccess: $message';
}

class LoginFailure extends LoginState {
  final String error;

  LoginFailure(this.error);

  @override
  String toString() => 'LoginFailure: $error';
}

class ProfileUpdated extends LoginState {
  @override
  String toString() => 'ProfileUpdated';
}

class UserLoggingOut extends LoginState {}

class UserLoguted extends LoginState {
  @override
  String toString() => 'UserLoguted';
}

class UserLogoutFailed extends LoginState {}

class UploadLoading extends LoginState {}

class UploadSuccess extends LoginState {}

class UploadFailure extends LoginState {}

class LoginPasswordVisibilityToggled extends LoginState {
  final bool isVisible;
  LoginPasswordVisibilityToggled(this.isVisible);
}
class LoginPasswordVisibilityToggledForget extends LoginState {
  final bool isVisible;
  LoginPasswordVisibilityToggledForget(this.isVisible);
}

class ForgetPasswordSuccess extends LoginState {}

class ForgetPasswordError extends LoginState {
  final String error;

  ForgetPasswordError(this.error);

  @override
  String toString() => 'ForgetPasswordError: $error';
}

class ForgetPasswordEmailNotFound extends LoginState {}

class ForgetPasswordEmailFound extends LoginState {}

class ForgetPasswordLoading extends LoginState {}
