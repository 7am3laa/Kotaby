import 'package:flutter/material.dart';
import 'package:kotaby/core/ui_components/custom_text.dart';
import 'package:quran/quran.dart';

class Basmallah extends StatelessWidget {
  final int index;
  final bool isStart;
  final Color textColor;
  const Basmallah({
    super.key,
    required this.index,
    this.isStart = false,
    required this.textColor,
  });

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;
    bool isWidth = screenSize.width >= 500;

    return Container(
      width: screenSize.width,
      color: isStart ? Color(0xffFAF1E2) : null,
      child: Center(
        child: CustomText(
          text: basmala,
          textAlign: TextAlign.center,
          color: textColor,
          fontWeight: FontWeight.w600,
          fontFamily: "uthmanic",
        ),
      ),
    );
  }
}
