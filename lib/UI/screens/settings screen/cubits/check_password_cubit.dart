import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:kotaby/core/services/user_auth_services.dart';
import 'package:kotaby/storage.dart';

class CheckPasswordCubit extends Cubit<CheckPasswordState> {
  final TextEditingController checkpasswordcontroller = TextEditingController();
  final UserAuthServices _authServices = UserAuthServices();

  bool isPasswordVisible = true;

  CheckPasswordCubit() : super(CheckPasswordInitial()) {
    checkpasswordcontroller.addListener(_onTextChanged);
  }

  void _onTextChanged() {
    final isFilled = checkpasswordcontroller.text.trim().isNotEmpty;
    emit(CheckPasswordInputChanged(isButtonEnabled: isFilled));
  }

  void togglePasswordVisibility() {
    isPasswordVisible = !isPasswordVisible;
    emit(CheckPasswordVisible(isPasswordVisible: isPasswordVisible));
  }

  Future<void> checkPassword() async {
    emit(CheckPasswordLoading());
    try {
      final connectivityResult = await Connectivity().checkConnectivity();
      if (connectivityResult[0] == ConnectivityResult.none) {
        emit(CheckPasswordNoInternet());
        return;
      }

      final user =
          await _authServices.getUserById(userId: Storage.useridCached);
      final enteredPassword = checkpasswordcontroller.text.trim();

      if (user.password == enteredPassword) {
        emit(CheckPasswordSuccess());
        checkpasswordcontroller.clear();
      } else {
        emit(CheckPasswordFailure());
      }
    } catch (e) {
      print(e);
      emit(CheckPasswordError());
    }
  }

  @override
  Future<void> close() {
    checkpasswordcontroller.dispose();
    return super.close();
  }
}

abstract class CheckPasswordState {}

class CheckPasswordInitial extends CheckPasswordState {}

class CheckPasswordLoading extends CheckPasswordState {}

class CheckPasswordSuccess extends CheckPasswordState {}

class CheckPasswordError extends CheckPasswordState {}

class CheckPasswordFailure extends CheckPasswordState {}

class CheckPasswordNoInternet extends CheckPasswordState {}

class CheckPasswordVisible extends CheckPasswordState {
  final bool isPasswordVisible;
  CheckPasswordVisible({
    required this.isPasswordVisible,
  });
}

class CheckPasswordInputChanged extends CheckPasswordState {
  final bool isButtonEnabled;
  CheckPasswordInputChanged({
    required this.isButtonEnabled,
  });
}
