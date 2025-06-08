import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:kotaby/constants/constants.dart';
import 'package:kotaby/core/ui_components/custom_text.dart';

class ProgressContainer extends StatelessWidget {
  final String icon;
  final String title;
  final String percentage;
  final VoidCallback onTap;
  final double width;
  final double height;

  const ProgressContainer({
    super.key,
    required this.icon,
    required this.title,
    required this.percentage,
    required this.onTap,
    required this.width,
    required this.height,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: (width > 500 && width < 750)
          ? 50.w
          : width >= 750
              ? 40.w
              : 70.w,
      decoration: BoxDecoration(
        color: bColor,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Center(
        child: ListTile(
          leading: Image.asset(
            icon,
            color: Colors.green,
            width: (width > 500 && width < 750)
                ? 25.w
                : width >= 750
                    ? 30.w
                    : 35.w,
            height: height > 850 ? 40.h : 40.h,
          ),
          title: CustomText(
            text: title,
            color: Colors.white,
            fontSize: (width > 500 && width < 750)
                ? 14
                : width >= 750
                    ? 9
                    : 18,
          ),
          trailing: CustomText(
            text: percentage,
            color: Colors.green,
            fontSize: (width > 500 && width < 750)
                ? 14
                : width >= 750
                    ? 9
                    : 18,
          ),
          onTap: onTap,
        ),
      ),
    );
  }
}
