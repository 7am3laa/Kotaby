import 'package:flutter/material.dart';
import 'package:kotaby/core/ui_components/custom_text.dart';

class NumberShape extends StatelessWidget {
  final dynamic text;
  const NumberShape({super.key, this.text});

  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment: Alignment.center,
      children: [
        Transform.rotate(
          angle: -0.4,
          child: Container(
            width: 35,
            height: 35,
            color: Colors.black,
          ),
        ),
        Transform.rotate(
          angle: 0.4,
          child: Container(
            width: 35,
            height: 35,
            color: const Color(0xff006783),
          ),
        ),
        CustomText(
          text: text,
          fontFamily: "Hafs",
          color: Colors.white,
        ),
      ],
    );
  }
}
