import 'package:flutter/material.dart';

void customSnakeBar({
  required BuildContext context,
  required String tilte,
  required bool isSuccess,
}) {
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      content: Text(tilte),
      backgroundColor: isSuccess ? Colors.green : Colors.red,
      behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      duration: const Duration(seconds: 2),
    ),
  );
}
