import 'package:flutter/material.dart';
import 'package:kotaby/constants/constants.dart';
import 'package:kotaby/core/ui_components/custom_text.dart';

class CustomButton extends StatelessWidget {
  final String buttonText;
  final VoidCallback onPressed;
  final bool isLoading;
  final Color color;
  final bool isWidth;

  const CustomButton({
    super.key,
    required this.buttonText,
    required this.onPressed,
    this.isLoading = false,
    this.color = bColor,
    this.isWidth = false,
  });

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      style: ElevatedButton.styleFrom(
        backgroundColor: color,
        minimumSize: const Size(double.infinity, 60),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
      ),
      onPressed: onPressed,
      child: isLoading
          ? const CircularProgressIndicator(
              color: Colors.white,
            )
          : CustomText(
              text: buttonText,
              color: Colors.white,
              fontSize: isWidth ? 15 : 20,
              fontWeight: FontWeight.bold,
            ),
    );
  }
}
