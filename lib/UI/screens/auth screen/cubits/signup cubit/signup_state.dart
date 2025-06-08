import 'package:flutter/material.dart';

@immutable
abstract class SignupState {}

class SignupInitial extends SignupState {}

class SignupLoading extends SignupState {}

class SignupSuccess extends SignupState {
  final String success;
  SignupSuccess(this.success);

  @override
  String toString() => 'SignupSuccess: $success';
}

class SignupFailure extends SignupState {
  final String error;
  SignupFailure(this.error);

  @override
  String toString() => 'SignupFailure: $error';
}

class SignupPasswordVisibilityToggled extends SignupState {
  final bool isVisible;
  SignupPasswordVisibilityToggled(this.isVisible);

  @override
  String toString() => 'SignupPasswordVisibilityToggled: $isVisible';
}

class SignupConfirmPasswordVisibilityToggled extends SignupState {
  final bool isVisible;
  SignupConfirmPasswordVisibilityToggled(this.isVisible);

  @override
  String toString() => 'SignupConfirmPasswordVisibilityToggled: $isVisible';
}
