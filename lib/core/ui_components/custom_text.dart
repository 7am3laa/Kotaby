import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:kotaby/constants/constants.dart';

class CustomText extends StatelessWidget {
  final String text;
  final double fontSize;
  final FontWeight fontWeight;
  final Color color;
  final TextAlign? textAlign;
  final int? maxLines;
  final TextOverflow? overflow;
  final String fontFamily;
  final TextDirection textDirection;

  const CustomText({
    super.key,
    required this.text,
    this.fontWeight = FontWeight.w600,
    this.color = sColor,
    this.textAlign,
    this.maxLines,
    this.overflow,
    this.fontSize = 20,
    this.fontFamily = "Poppins",
    this.textDirection = TextDirection.ltr,
  });

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: TextStyle(
        fontSize: fontSize.sp,
        fontWeight: fontWeight,
        color: color,
        fontFamily: fontFamily,
      ),
      textAlign: textAlign,
      maxLines: maxLines,
      overflow: overflow,
    );
  }
}
