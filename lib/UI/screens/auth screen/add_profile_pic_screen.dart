import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:image_picker/image_picker.dart';
import 'package:kotaby/UI/screens/auth%20screen/cubits/signup%20cubit/signup_cubit.dart';
import 'package:kotaby/constants/constants.dart';
import 'package:kotaby/core/ui_components/custom_text.dart';

class AddProfilePicScreen extends StatefulWidget {
  const AddProfilePicScreen({super.key});

  @override
  State<AddProfilePicScreen> createState() => _AddProfilePicScreenState();
}

class _AddProfilePicScreenState extends State<AddProfilePicScreen> {
  XFile? pickedFile;

  Future<void> _pickImage() async {
    final selectedFile =
        await ImagePicker().pickImage(source: ImageSource.gallery);
    if (selectedFile != null) {
      setState(() {
        pickedFile = selectedFile;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final signupCubit = context.read<SignupCubit>();
    return Scaffold(
      backgroundColor: primaryColor,
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 15.0.w, vertical: 10.h),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  InkWell(
                    onTap: () {
                      signupCubit.signup(
                        context: context,
                      );
                    },
                    child: CustomText(
                      text: "Skip",
                      fontSize: 15,
                      color: Colors.white.withOpacity(0.7),
                    ),
                  )
                ],
              ),
            ),
            Spacer(flex: 2),
            AnimatedSwitcher(
              duration: Duration(milliseconds: 500),
              child: pickedFile == null
                  ? CircleAvatar(
                      key: ValueKey('default'),
                      radius: 100.w,
                      backgroundColor: Colors.white,
                      child: Icon(
                        Icons.person,
                        color: bColor,
                        size: 150,
                      ),
                    )
                  : CircleAvatar(
                      key: ValueKey('image'),
                      radius: 100.w,
                      backgroundImage: FileImage(File(pickedFile!.path)),
                    ),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _pickImage,
              style: ElevatedButton.styleFrom(
                backgroundColor: bColor,
                minimumSize: Size(160.w, 50.h),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: const CustomText(
                text: "Choose Photo",
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 25),
            if (pickedFile != null)
              ElevatedButton(
                onPressed: () {
                  signupCubit.signup(context: context);
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green,
                  minimumSize: Size(160.w, 50.h),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const CustomText(
                  text: "Continue",
                  color: Colors.white,
                ),
              ),
            Spacer(flex: 3),
          ],
        ),
      ),
    );
  }
}
