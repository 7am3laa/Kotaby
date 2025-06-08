import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:kotaby/UI/screens/settings%20screen/cubits/update_info_cubit.dart';
import 'package:kotaby/constants/constants.dart';
import 'package:kotaby/core/functions/animation.dart';
import 'package:kotaby/core/functions/customs_fields.dart';
import 'package:kotaby/core/functions/snake_bar.dart';
import 'package:kotaby/core/functions/validation.dart';
import 'package:kotaby/core/ui_components/custom_app_bar.dart';
import 'package:kotaby/core/ui_components/custom_button.dart';
import 'package:kotaby/core/ui_components/custom_text.dart';
import 'package:kotaby/core/ui_components/custom_text_field.dart';
import 'package:kotaby/storage.dart';

class UpdateScreen extends StatelessWidget {
  const UpdateScreen({super.key});

  @override
  Widget build(BuildContext context) {
    bool isWidth = MediaQuery.of(context).size.width >= 500;
    double width = MediaQuery.of(context).size.width;
    final updateCubit = context.read<UpdateInfoCubit>();

    return BlocConsumer<UpdateInfoCubit, UpdateInfoState>(
      listener: (context, state) {
        if (state is UserUpdateSuccess) {
          customSnakeBar(
            context: context,
            tilte: "Updated successfully",
            isSuccess: true,
          );
        }
        if (state is UserUpdateFailed) {
          customSnakeBar(
            context: context,
            tilte: "Failed to update",
            isSuccess: false,
          );
        }
        if (state is UserUpdateNothing) {
          customSnakeBar(
            context: context,
            tilte: "Nothing changed",
            isSuccess: false,
          );
        }
        if (state is UserUpdateNoInternet) {
          customSnakeBar(
            context: context,
            tilte: "No internet connection",
            isSuccess: false,
          );
        }
        if (state is UserUpdateError) {
          customSnakeBar(
            context: context,
            tilte: state.error,
            isSuccess: false,
          );
        }
      },
      builder: (context, state) {
        return Form(
          key: updateCubit.formKey,
          child: Scaffold(
            backgroundColor: primaryColor,
            appBar: CustomAppBar(
              title: "Account",
              iscenterTitle: false,
            ),
            body: Padding(
              padding: const EdgeInsets.all(10.0),
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Center(
                      child: SizedBox(
                        width: isWidth ? width / 1.5 : width,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            CustomAnimation(
                              duration: const Duration(milliseconds: 300),
                              child: CustomText(
                                text: "New Name",
                                fontSize: isWidth ? 12 : 20,
                              ),
                            ),
                            const SizedBox(height: 8),
                            CustomAnimation(
                              duration: const Duration(milliseconds: 400),
                              child: CustomTextField(
                                controller: updateCubit.updateNameController,
                                keyboardType: TextInputType.name,
                                hintText: Storage.usernameCached,
                                validator: (value) =>
                                    nameValidation(value: value),
                                prefixIcon: const Icon(Icons.person_outline),
                              ),
                            ),
                            const SizedBox(height: 15),
                            CustomAnimation(
                              duration: const Duration(milliseconds: 500),
                              child: CustomText(
                                text: "Email",
                                fontSize: isWidth ? 12 : 20,
                              ),
                            ),
                            const SizedBox(height: 8),
                            CustomAnimation(
                              duration: const Duration(milliseconds: 600),
                              child: CustomTextField(
                                readOnly: true,
                                controller: updateCubit.updateEmailController,
                                keyboardType: TextInputType.emailAddress,
                                hintText: Storage.userEmailCached,
                                prefixIcon: const Icon(Icons.email),
                              ),
                            ),
                            const SizedBox(height: 15),
                            CustomAnimation(
                              duration: const Duration(milliseconds: 700),
                              child:
                                  BlocBuilder<UpdateInfoCubit, UpdateInfoState>(
                                builder: (context, state) {
                                  return customPassword(
                                    label: "New Password",
                                    controller:
                                        updateCubit.updatePasswordController,
                                    isWidth: isWidth,
                                    validator: (value) =>
                                        passwordValidation(value: value),
                                    isVisible: updateCubit.isPasswordVisible,
                                    toggleVisibility: () =>
                                        updateCubit.togglePasswordVisibility(),
                                  );
                                },
                              ),
                            ),
                            const SizedBox(height: 20),
                            CustomAnimation(
                              duration: const Duration(milliseconds: 800),
                              child:
                                  BlocBuilder<UpdateInfoCubit, UpdateInfoState>(
                                builder: (context, state) {
                                  return CustomButton(
                                    isWidth: isWidth,
                                    isLoading: state is UserUpdateLoading,
                                    buttonText: "Update",
                                    onPressed: () {
                                      updateCubit.updateUser(
                                        id: Storage.useridCached,
                                        context: context,
                                      );
                                    },
                                  );
                                },
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
