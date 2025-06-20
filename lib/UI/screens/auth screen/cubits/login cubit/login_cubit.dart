import 'dart:io';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';
import 'package:kotaby/UI/screens/auth%20screen/auth_screen.dart';
import 'package:kotaby/UI/screens/auth%20screen/cubits/login%20cubit/login_state.dart';
import 'package:kotaby/core/functions/navigate.dart';
import 'package:kotaby/core/functions/snake_bar.dart';
import 'package:kotaby/core/models/users_model.dart';
import 'package:kotaby/core/services/streak_service.dart';
import 'package:kotaby/core/services/tasks_service.dart';
import 'package:kotaby/core/services/user_auth_services.dart';
import 'package:kotaby/storage.dart';

class LoginCubit extends Cubit<LoginState> {
  final UserAuthServices _authServices;
  final GlobalKey<FormState> formKey = GlobalKey<FormState>();
  final GlobalKey<FormState> updateFormKey = GlobalKey<FormState>();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController updateEmailController = TextEditingController();
  final TextEditingController updatePasswordController =
      TextEditingController();
  final TextEditingController updateNameController = TextEditingController();

  final TextEditingController checkPasswordController = TextEditingController();

  UsersModel? _currentUser;
  bool isVisiblePassword = true;

  UsersModel? get currentUser => _currentUser;

  LoginCubit({UserAuthServices? authServices})
      : _authServices = authServices ?? UserAuthServices(),
        super(LoginInitial());

  void togglePasswordVisibility() {
    isVisiblePassword = !isVisiblePassword;
    emit(LoginPasswordVisibilityToggled(isVisiblePassword));
  }

  Future<void> loginUser({
    required BuildContext context,
  }) async {
    if (!formKey.currentState!.validate()) return;

    emit(LoginLoading());

    try {
      final connectivityResult = await Connectivity().checkConnectivity();
      if (connectivityResult[0] == ConnectivityResult.none) {
        emit(LoginFailure("لا يوجد اتصال بالإنترنت"));
        return;
      }

      final userData = await _authServices.login(
        email: emailController.text.trim(),
        password: passwordController.text.trim(),
      );

      if (userData != null) {
        _currentUser = UsersModel.fromJson(userData);

        await Future.wait([
          Storage.saveLoginState(true),
          Storage.cacheUserData(
            name: _currentUser!.userName,
            id: _currentUser!.id,
            email: _currentUser!.email,
            password: _currentUser!.password,
          ),
          Storage.saveUserImage(_currentUser!.image!),
          Storage.saveSurahAndVerse(
            _currentUser!.lastSurah == 0 ? 1 : _currentUser!.lastSurah,
            _currentUser!.lastAyah == 0 ? 1 : _currentUser!.lastAyah,
          ),
        ]);
        final streakService = StreakService();
        final taskspaln = TasksService();
        final r = await streakService.getStreak();
        await Storage.saveCurrentStreak(r.currentStreak);
        await Storage.saveLongestStreak(r.maxStreak);

        final t = await taskspaln.getTaskSummary();
        if (t.totalTasks != 0) {
          await Storage.saveTaskPlanState(1);
          await Storage.saveCompletionPercentage(t.completionPercentage);
        }
        emit(LoginSuccess("مرحبًا ${_currentUser!.userName}"));
        emit(LoginPasswordVisibilityToggled(true));

        emailController.clear();
        passwordController.clear();
      } else {
        emit(LoginFailure("البريد أو كلمة المرور غير صحيحة"));
      }
    } catch (e) {
      emit(LoginFailure("فشل تسجيل الدخول: ${e.toString()}"));
    }
  }

  Future<void> uploadProfilePicture(BuildContext context) async {
    try {
      final pickedImage = await ImagePicker().pickImage(
        source: ImageSource.gallery,
        imageQuality: 40,
        maxHeight: 800,
        maxWidth: 800,
      );

      if (pickedImage == null) return;

      emit(UploadLoading());

      customSnakeBar(
        context: context,
        tilte: "يتم تحديث الصورة...",
        isSuccess: true,
      );

      await _authServices.putProfilePic(
        userId: Storage.useridCached,
        imageFile: File(pickedImage.path),
      );

      final updatedUser =
          await _authServices.getUserById(userId: Storage.useridCached);

      if (updatedUser.image != null) {
        await Storage.saveUserImage(updatedUser.image!);
      }

      emit(UploadSuccess());

      customSnakeBar(
        context: context,
        tilte: 'تم تحديث الصورة بنجاح',
        isSuccess: true,
      );
    } catch (e) {
      emit(UploadFailure());
      debugPrint("Error uploading profile picture: $e");

      customSnakeBar(
        context: context,
        tilte: 'فشل في تحديث الصورة',
        isSuccess: false,
      );
    }
  }

  Future<void> logout(BuildContext context) async {
    emit(UserLoggingOut());
    try {
      await Storage.saveLoginState(false);
      await Storage.clearCachedUserData();
      _currentUser = null;

      emit(UserLoguted());
      N.pushAndRemoveUntil(context: context, screen: const AuthScreen());
    } catch (e) {
      emit(UserLogoutFailed());
    }
  }
}
