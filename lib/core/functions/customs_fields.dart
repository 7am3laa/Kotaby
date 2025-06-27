import 'package:flutter/material.dart';
import 'package:kotaby/constants/constants.dart';
import 'package:kotaby/core/ui_components/custom_text.dart';
import 'package:kotaby/core/ui_components/custom_text_field.dart';
import 'package:kotaby/storage.dart';

Widget customPassword({
  required String label,
  required TextEditingController controller,
  required bool isVisible,
  required String? Function(String?)? validator,
  required VoidCallback? toggleVisibility,
  bool isLogin = false,
  VoidCallback? onTap,
  required bool isWidth,
}) {
  return SizedBox(
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        CustomText(
          text: label,
          color: Storage.themeState == 1 ? sColor : bColor,
          fontSize: isWidth ? 12 : 20,
        ),
        CustomTextField(
          controller: controller,
          validator: validator,
          keyboardType: TextInputType.visiblePassword,
          hintText: "Enter your password",
          obscureText: isVisible,
          prefixIcon: const Icon(Icons.lock_outlined),
          suffixIcon: IconButton(
            onPressed: toggleVisibility,
            icon: Icon(
              isVisible
                  ? Icons.visibility_off_outlined
                  : Icons.visibility_outlined,
            ),
          ),
        ),
        const SizedBox(height: 5),
        Align(
          alignment: Alignment.centerRight,
          child: isLogin
              ? InkWell(
                  onTap: onTap,
                  child: CustomText(
                    text: "Forgot Password?",
                    fontSize: isWidth ? 10 : 15,
                    color: Storage.themeState == 1 ? sColor : bColor,
                  ),
                )
              : null,
        ),
      ],
    ),
  );
}

Widget customField({
  required String label,
  required TextEditingController controller,
  required IconData icon,
  required String? Function(String?)? validator,
  required TextInputType keyboardType,
  required isWidth,
}) {
  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      CustomText(
        text: label,
        fontSize: isWidth ? 12 : 20,
        color: Storage.themeState == 1 ? sColor : bColor,
      ),
      CustomTextField(
        controller: controller,
        validator: validator,
        keyboardType: keyboardType,
        hintText: "Enter your $label",
        prefixIcon: Icon(icon),
      ),
    ],
  );
}
