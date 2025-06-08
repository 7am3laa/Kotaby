import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:kotaby/constants/constants.dart';
import 'package:kotaby/core/ui_components/custom_text.dart';

class StreakContainer extends StatelessWidget {
  final String title;
  final int numOfDays;
  final double width;

  const StreakContainer({
    super.key,
    required this.title,
    required this.numOfDays,
    required this.width,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        height: (width > 500 && width < 750)
            ? 70.w
            : width > 750
                ? 50.w
                : 100.w,
        decoration: BoxDecoration(
          color: bColor,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CustomText(
                text: title,
                color: Colors.white,
                fontSize: (width > 500 && width < 750)
                    ? 14
                    : width >= 750
                        ? 9
                        : 18,
              ),
              CustomText(
                text: "$numOfDays Days",
                color: Colors.green,
                fontSize: (width > 500 && width < 750)
                    ? 14
                    : width >= 750
                        ? 9
                        : 18,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
