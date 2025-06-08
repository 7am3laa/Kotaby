import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:kotaby/UI/screens/auth%20screen/cubits/signup%20cubit/signup_cubit.dart';
import 'package:kotaby/UI/screens/auth%20screen/cubits/signup%20cubit/signup_state.dart';
import 'package:kotaby/core/functions/customs_fields.dart';
import 'package:kotaby/core/functions/snake_bar.dart';
import 'package:kotaby/core/functions/validation.dart';
import 'package:kotaby/core/ui_components/custom_button.dart';
import 'package:kotaby/core/ui_components/custom_text.dart';

class SignupScreen extends StatelessWidget {
  final VoidCallback toggleScreen;
  const SignupScreen({super.key, required this.toggleScreen});

  @override
  Widget build(BuildContext context) {
    bool isWidth = MediaQuery.of(context).size.width >= 500;
    return BlocConsumer<SignupCubit, SignupState>(
      listener: (context, state) {
        if (state is SignupSuccess) {
          customSnakeBar(
            context: context,
            tilte: state.success,
            isSuccess: true,
          );
        } else if (state is SignupFailure) {
          customSnakeBar(
            context: context,
            tilte: state.error,
            isSuccess: false,
          );
          print(state.error);
        }
      },
      builder: (context, state) {
        final signupCubit = context.read<SignupCubit>();

        return Form(
          key: signupCubit.formKey,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const SizedBox(height: 30),
              CustomText(
                text: "Create An Account",
                fontSize: isWidth ? 20 : 25,
              ),
              const SizedBox(height: 30),
              customField(
                  label: "Name",
                  controller: signupCubit.nameController,
                  icon: Icons.person,
                  validator: (value) => nameValidation(value: value),
                  keyboardType: TextInputType.name,
                  isWidth: isWidth),
              const SizedBox(height: 5),
              customField(
                  label: "Email",
                  controller: signupCubit.emailController,
                  icon: Icons.email_outlined,
                  validator: (value) => emailValidation(value: value),
                  keyboardType: TextInputType.emailAddress,
                  isWidth: isWidth),
              const SizedBox(height: 5),
              customPassword(
                  label: "Password",
                  controller: signupCubit.passwordController,
                  isVisible: signupCubit.isPasswordVisible,
                  validator: (value) => passwordValidation(value: value),
                  toggleVisibility: signupCubit.togglePasswordVisibility,
                  isWidth: isWidth),
              const SizedBox(height: 5),
              customPassword(
                  label: "Confirm Password",
                  controller: signupCubit.confirmPasswordController,
                  isVisible: signupCubit.isConfirmPasswordVisible,
                  validator: (value) => passwordValidation(
                        value: value,
                        isConfirm: true,
                        originalPassword: signupCubit.passwordController.text,
                      ),
                  toggleVisibility: signupCubit.toggleConfirmPasswordVisibility,
                  isWidth: isWidth),
              const SizedBox(height: 30),
              CustomButton(
                buttonText: "SIGN UP",
                isWidth: isWidth,
                onPressed: () {
                  signupCubit.signup(context: context);
                },
                isLoading: state is SignupLoading,
              ),
              const SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CustomText(
                    text: "Already have an account? ",
                    fontSize: isWidth ? 10 : 15,
                  ),
                  InkWell(
                    onTap: toggleScreen,
                    child: CustomText(
                      text: "Log In",
                      color: Colors.white,
                      fontSize: isWidth ? 10 : 15,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
            ],
          ),
        );
      },
    );
  }
}
