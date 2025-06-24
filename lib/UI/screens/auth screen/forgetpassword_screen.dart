import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:kotaby/UI/screens/auth%20screen/cubits/login%20cubit/login_cubit.dart';
import 'package:kotaby/UI/screens/auth%20screen/cubits/login%20cubit/login_state.dart';
import 'package:kotaby/constants/constants.dart';
import 'package:kotaby/core/functions/customs_fields.dart';
import 'package:kotaby/core/functions/validation.dart';
import 'package:kotaby/core/ui_components/custom_app_bar.dart';
import 'package:kotaby/core/ui_components/custom_button.dart';
import 'package:kotaby/core/ui_components/custom_text.dart';

class ForgetpasswordScreen extends StatelessWidget {
  const ForgetpasswordScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final loginCubit = context.read<LoginCubit>();
    final isWide = MediaQuery.of(context).size.width >= 500;

    return Form(
      key: loginCubit.formForgetKey,
      child: Scaffold(
        appBar: CustomAppBar(title: "Forget Password"),
        backgroundColor: primaryColor,
        body: Center(
          child: SingleChildScrollView(
            child: SizedBox(
              width: MediaQuery.of(context).size.width * .8,
              child: BlocConsumer<LoginCubit, LoginState>(
                listener: (context, state) {
                  if (state is ForgetPasswordSuccess) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text("Password reset successfully"),
                        backgroundColor: Colors.green,
                      ),
                    );
                  } else if (state is ForgetPasswordError) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(state.error),
                        backgroundColor: Colors.red,
                      ),
                    );
                  } else if (state is ForgetPasswordEmailNotFound) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text("Email not found"),
                        backgroundColor: Colors.red,
                      ),
                    );
                  }
                },
                builder: (context, state) {
                  final showPasswordField =
                      context.watch<LoginCubit>().isEmailFound;
                  final isLoading = state is ForgetPasswordLoading;

                  return Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const CustomText(
                        text: "Enter your email to reset password",
                        color: Colors.white,
                        fontSize: 18,
                      ),
                      const SizedBox(height: 20),
                      customField(
                        label: "Email",
                        controller: loginCubit.emailForgetPassword,
                        icon: Icons.email,
                        validator: (value) => emailValidation(value: value),
                        keyboardType: TextInputType.emailAddress,
                        isWidth: isWide,
                      ),
                      const SizedBox(height: 20),
                      if (showPasswordField)
                        Column(
                          children: [
                            customPassword(
                              label: "New Password",
                              controller: loginCubit.passworForget,
                              isVisible: context.watch<LoginCubit>().isVForget,
                              validator: (value) =>
                                  passwordValidation(value: value),
                              toggleVisibility: () => context
                                  .read<LoginCubit>()
                                  .togglePasswordVisibilityForget(),
                              isWidth: isWide,
                            ),
                            const SizedBox(height: 20),
                          ],
                        ),
                      isLoading
                          ? const CircularProgressIndicator(color: Colors.red)
                          : CustomButton(
                              color: Colors.red,
                              buttonText: showPasswordField
                                  ? "Confirm Reset"
                                  : "Check Email",
                              onPressed: () {
                                if (showPasswordField) {
                                  loginCubit.resetPassword(context);
                                } else {
                                  loginCubit.forgetPassword(context);
                                }
                              },
                            ),
                    ],
                  );
                },
              ),
            ),
          ),
        ),
      ),
    );
  }
}
