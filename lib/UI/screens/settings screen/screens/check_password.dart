import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:kotaby/UI/screens/settings%20screen/screens/update_screen.dart';
import 'package:kotaby/constants/constants.dart';
import 'package:kotaby/core/functions/animation.dart';
import 'package:kotaby/core/functions/customs_fields.dart';
import 'package:kotaby/core/functions/navigate.dart';
import 'package:kotaby/core/functions/snake_bar.dart';
import 'package:kotaby/core/functions/validation.dart';
import 'package:kotaby/core/ui_components/custom_app_bar.dart';
import 'package:kotaby/storage.dart';
import '../cubits/check_password_cubit.dart'; // Adjust path as necessary

class CheckPassword extends StatelessWidget {
  const CheckPassword({super.key});

  @override
  Widget build(BuildContext context) {
    bool isWidth = MediaQuery.of(context).size.width >= 500;

    return BlocProvider(
      create: (_) => CheckPasswordCubit(),
      child: BlocConsumer<CheckPasswordCubit, CheckPasswordState>(
        listener: (context, state) {
          if (state is CheckPasswordSuccess) {
            N.pushReplacementto(context: context, screen: const UpdateScreen());
          }
          if (state is CheckPasswordFailure) {
            customSnakeBar(
              context: context,
              tilte: "Invalid password",
              isSuccess: false,
            );
          }
          if (state is CheckPasswordNoInternet) {
            customSnakeBar(
              context: context,
              tilte: "No internet connection",
              isSuccess: false,
            );
          }
          if (state is CheckPasswordError) {
            customSnakeBar(
              context: context,
              tilte: "Error, try again",
              isSuccess: false,
            );
          }
        },
        builder: (context, state) {
          final cubit = context.read<CheckPasswordCubit>();

          return Scaffold(
            appBar: const CustomAppBar(title: "Check Password"),
            backgroundColor:
                Storage.themeState == 1 ? primaryColor : Colors.white,
            body: Center(
              child: CustomAnimation(
                child: Padding(
                  padding: const EdgeInsets.all(10.0),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      BlocBuilder<CheckPasswordCubit, CheckPasswordState>(
                        buildWhen: (previous, current) =>
                            current is CheckPasswordVisible ||
                            current is CheckPasswordInputChanged,
                        builder: (context, state) {
                          final isVisible = (state is CheckPasswordVisible)
                              ? state.isPasswordVisible
                              : true;

                          return customPassword(
                            label: "Enter your password",
                            controller: cubit.checkpasswordcontroller,
                            isVisible: isVisible,
                            validator: (value) =>
                                passwordValidation(value: value),
                            toggleVisibility: cubit.togglePasswordVisibility,
                            isWidth: isWidth,
                          );
                        },
                      ),
                      const SizedBox(height: 30),
                      BlocBuilder<CheckPasswordCubit, CheckPasswordState>(
                        builder: (context, state) {
                          final isFilled =
                              cubit.checkpasswordcontroller.text.isNotEmpty;
                          final isLoading = state is CheckPasswordLoading;

                          return FloatingActionButton(
                            backgroundColor: isFilled
                                ? const Color.fromARGB(255, 95, 50, 130)
                                : Colors.grey,
                            onPressed: isFilled
                                ? () async => await cubit.checkPassword()
                                : null,
                            child: isLoading
                                ? const SizedBox(
                                    width: 24,
                                    height: 24,
                                    child: CircularProgressIndicator(
                                      color: Colors.white,
                                      strokeWidth: 2,
                                    ),
                                  )
                                : const Icon(Icons.arrow_forward_ios),
                          );
                        },
                      ),
                    ],
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
