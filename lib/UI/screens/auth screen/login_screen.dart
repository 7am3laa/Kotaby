import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:kotaby/UI/screens/auth%20screen/cubits/login%20cubit/login_cubit.dart';
import 'package:kotaby/UI/screens/auth%20screen/cubits/login%20cubit/login_state.dart';
import 'package:kotaby/UI/screens/auth%20screen/forgetpassword_screen.dart';
import 'package:kotaby/UI/screens/main%20screen/main_screen.dart';
import 'package:kotaby/core/functions/customs_fields.dart';
import 'package:kotaby/core/functions/navigate.dart';
import 'package:kotaby/core/functions/snake_bar.dart';
import 'package:kotaby/core/functions/validation.dart';
import 'package:kotaby/core/ui_components/custom_button.dart';
import 'package:kotaby/core/ui_components/custom_text.dart';

class LoginScreen extends StatelessWidget {
  final VoidCallback toggleScreen;
  const LoginScreen({super.key, required this.toggleScreen});

  @override
  Widget build(BuildContext context) {
    bool isWidth = MediaQuery.of(context).size.width >= 500;
    return BlocConsumer<LoginCubit, LoginState>(
      listener: (context, state) {
        if (state is LoginSuccess) {
          customSnakeBar(
            context: context,
            tilte: state.message,
            isSuccess: true,
          );

          if (context.mounted) {
            Navigator.pushReplacement(
              context,
              PageRouteBuilder(
                pageBuilder: (_, __, ___) => const MainScreen(),
                transitionsBuilder: (_, a, __, c) =>
                    FadeTransition(opacity: a, child: c),
                maintainState: true,
              ),
            );
          }
        } else if (state is LoginFailure) {
          customSnakeBar(
            context: context,
            tilte: state.error,
            isSuccess: false,
          );
        }
      },
      builder: (context, state) {
        final loginCubit = context.read<LoginCubit>();
        return Form(
          key: loginCubit.formKey,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const SizedBox(height: 30),
              CustomText(
                text: "Welcome Back",
                fontWeight: FontWeight.bold,
                fontSize: isWidth ? 15 : 25,
              ),
              CustomText(
                text: "Login to continue",
                fontWeight: FontWeight.bold,
                fontSize: isWidth ? 13 : 21,
              ),
              const SizedBox(height: 30),
              customField(
                  label: "Email",
                  controller: loginCubit.emailController,
                  icon: Icons.email_outlined,
                  validator: (value) => emailValidation(value: value),
                  keyboardType: TextInputType.emailAddress,
                  isWidth: isWidth),
              const SizedBox(height: 20),
              customPassword(
                label: "Password",
                controller: loginCubit.passwordController,
                isVisible: loginCubit.isVisiblePassword,
                validator: (value) => passwordValidation(value: value),
                toggleVisibility: loginCubit.togglePasswordVisibility,
                isLogin: true,
                onTap: () =>
                    N.pushto(context: context, screen: ForgetpasswordScreen()),
                isWidth: isWidth,
              ),
              const SizedBox(height: 30),
              CustomButton(
                buttonText: "LOG IN",
                onPressed: () {
                  loginCubit.loginUser(
                    context: context,
                  );
                },
                isWidth: isWidth,
                isLoading: state is LoginLoading,
              ),
              const SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CustomText(
                    text: "Don't have an account? ",
                    fontSize: isWidth ? 10 : 15,
                  ),
                  InkWell(
                    onTap: toggleScreen,
                    child: CustomText(
                      text: "Sign Up",
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
