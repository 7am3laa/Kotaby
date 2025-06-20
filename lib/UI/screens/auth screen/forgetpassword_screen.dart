import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:kotaby/UI/screens/auth%20screen/cubits/login%20cubit/login_cubit.dart';
import 'package:kotaby/UI/screens/auth%20screen/cubits/login%20cubit/login_state.dart';
import 'package:kotaby/constants/constants.dart';
import 'package:kotaby/core/ui_components/custom_app_bar.dart';
import 'package:kotaby/core/ui_components/custom_button.dart';
import 'package:kotaby/core/ui_components/custom_text.dart';

class ForgetpasswordScreen extends StatelessWidget {
  const ForgetpasswordScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final loginCubit = context.read<LoginCubit>();

    return Scaffold(
      appBar: CustomAppBar(title: "Forget Password"),
      backgroundColor: primaryColor,
      body: Center(
        child: SizedBox(
          width: MediaQuery.of(context).size.width * .8,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CustomText(
                text: "Enter your email to reset password",
                color: Colors.white,
                fontSize: 18,
              ),
              const SizedBox(height: 20),
              // CustomTextField(
              //   hintText: "Your Email",
              //   controller: loginCubit
              //       .emailResetController, // ✅ استخدم emailResetController
              // ),
              const SizedBox(height: 20),
              BlocConsumer<LoginCubit, LoginState>(
                listener: (context, state) {
                  if (state is ForgetPasswordSuccess) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text("Password reset link sent to your email"),
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
                  }
                },
                builder: (context, state) {
                  if (state is LoginLoading) {
                    return const CircularProgressIndicator(color: Colors.white);
                  }
                  return CustomButton(
                    color: Colors.red,
                    buttonText: "Reset Password",
                    onPressed: () {
                    //  loginCubit.resetPassword(context);
                    },
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
