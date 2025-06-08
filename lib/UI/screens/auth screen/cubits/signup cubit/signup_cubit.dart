import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:kotaby/UI/screens/auth%20screen/add_profile_pic_screen.dart';
import 'package:kotaby/UI/screens/auth%20screen/auth_screen.dart';
import 'package:kotaby/UI/screens/auth%20screen/cubits/signup%20cubit/signup_state.dart';
import 'package:kotaby/core/functions/navigate.dart';
import 'package:kotaby/core/services/user_auth_services.dart';

class SignupCubit extends Cubit<SignupState> {
  SignupCubit() : super(SignupInitial());

  final TextEditingController nameController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController confirmPasswordController =
      TextEditingController();
  final GlobalKey<FormState> formKey = GlobalKey<FormState>();

  final UserAuthServices userAuthServices = UserAuthServices();

  bool isPasswordVisible = true;
  bool isConfirmPasswordVisible = true;

  void togglePasswordVisibility() {
    isPasswordVisible = !isPasswordVisible;
    emit(SignupPasswordVisibilityToggled(isPasswordVisible));
  }

  void toggleConfirmPasswordVisibility() {
    isConfirmPasswordVisible = !isConfirmPasswordVisible;
    emit(SignupConfirmPasswordVisibilityToggled(isConfirmPasswordVisible));
  }

  Future<void> signup({required BuildContext context}) async {
    if (!formKey.currentState!.validate()) return;

    // Check if passwords match
    if (passwordController.text.trim() !=
        confirmPasswordController.text.trim()) {
      emit(SignupFailure("Passwords do not match"));
      return;
    }

    emit(SignupLoading());

    try {
      final users = await userAuthServices.getUsers();
      for (var user in users) {
        if (user.email == emailController.text.trim()) {
          emit(SignupFailure("Email already exists"));
          return;
        }
      }

      final user = await userAuthServices.register(
        userName: nameController.text.trim(),
        email: emailController.text.trim(),
        password: confirmPasswordController.text.trim(),
      );

      if (user == null) {
        emit(SignupFailure("Failed to signup"));
      } else {
        emit(SignupSuccess("Signup Successful!"));

        nameController.clear();
        emailController.clear();
        passwordController.clear();
        confirmPasswordController.clear();

        N.pushReplacementto(context: context, screen: AuthScreen());
      }
    } catch (e) {
      emit(SignupFailure("Signup error: $e"));
    }
  }

  void nextStep({required BuildContext context}) {
    if (formKey.currentState!.validate()) {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => AddProfilePicScreen()),
      );
    }
  }

  @override
  Future<void> close() {
    nameController.dispose();
    emailController.dispose();
    passwordController.dispose();
    confirmPasswordController.dispose();
    return super.close();
  }
}
