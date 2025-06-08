import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:kotaby/core/functions/navigate.dart';
import 'package:kotaby/core/services/user_auth_services.dart';
import 'package:kotaby/storage.dart';

class UpdateInfoCubit extends Cubit<UpdateInfoState> {
  final UserAuthServices _authServices = UserAuthServices();
  final TextEditingController updateNameController = TextEditingController();
  final TextEditingController updateEmailController = TextEditingController();
  final TextEditingController updatePasswordController =
      TextEditingController();

  final GlobalKey<FormState> formKey = GlobalKey<FormState>();

  bool isPasswordVisible = true;

  UpdateInfoCubit() : super(UpdateInfoInitial());

  void togglePasswordVisibility() {
    isPasswordVisible = !isPasswordVisible;
    emit(UserUpdatePasswordVisibilityToggled(isPasswordVisible));
  }

  Future<void> updateUser({
    required int id,
    required BuildContext context,
  }) async {
    emit(UserUpdateLoading());

    try {
      final userName = (updateNameController.text.trim().isEmpty)
          ? Storage.usernameCached
          : updateNameController.text.trim();

      final email = (updateEmailController.text.trim().isEmpty)
          ? Storage.userEmailCached
          : updateEmailController.text.trim();

      final password = (updatePasswordController.text.trim().isEmpty)
          ? Storage.userPasswordCached
          : updatePasswordController.text.trim();

      final bool nothingChanged = userName == Storage.usernameCached &&
          email == Storage.userEmailCached &&
          password == Storage.userPasswordCached;

      if (nothingChanged) {
        emit(UserUpdateNothing());

        return;
      }

      final response = await _authServices.update(
        userId: id,
        userName: userName,
        email: email,
        password: password,
      );

      if (response != null) {
        final updatedUser =
            await _authServices.getUserById(userId: Storage.useridCached);

        await Storage.cacheUserData(
          name: updatedUser.userName,
          id: updatedUser.id,
          email: updatedUser.email,
          password: updatedUser.password,
        );
        await Storage.saveUserImage(updatedUser.image!);

        emit(UserUpdateSuccess());
        N.pop(context: context);
        updateEmailController.clear();
        updatePasswordController.clear();
        updateNameController.clear();
        emit(UserUpdatePasswordVisibilityToggled(true));
      } else {
        emit(UserUpdateFailed());
      }
    } catch (e) {
      emit(UserUpdateError(e.toString()));
    }
  }
}

abstract class UpdateInfoState {}

class UpdateInfoInitial extends UpdateInfoState {}

class UserUpdateLoading extends UpdateInfoState {}

class UserUpdateNothing extends UpdateInfoState {}

class UserUpdateSuccess extends UpdateInfoState {}

class UserUpdateFailed extends UpdateInfoState {}

class UserUpdateNoInternet extends UpdateInfoState {}

class UserUpdateError extends UpdateInfoState {
  final String error;
  UserUpdateError(this.error);
}

class UserUpdatePasswordVisibilityToggled extends UpdateInfoState {
  final bool isVisible;
  UserUpdatePasswordVisibilityToggled(this.isVisible);
}
