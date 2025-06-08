import 'package:flutter/material.dart';
import 'package:kotaby/constants/constants.dart';

class CustomSearchIcon extends StatelessWidget {
  final VoidCallback onPressed;
  const CustomSearchIcon({super.key, required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return IconButton(
      onPressed: onPressed,
      icon: SizedBox(
        child: Image.asset(
          "assets/images/icons/search.png",
          width: 24,
          height: 24,
          color: sColor.withOpacity(.8),
        ),
      ),
    );
  }
}
