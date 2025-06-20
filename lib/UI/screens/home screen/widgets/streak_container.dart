import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:kotaby/constants/constants.dart';
import 'package:kotaby/core/ui_components/custom_text.dart';

class StreakContainer extends StatefulWidget {
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
  State<StreakContainer> createState() => _StreakContainerState();
}

class _StreakContainerState extends State<StreakContainer> {
  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        height: (widget.width > 500 && widget.width < 750)
            ? 70.w
            : widget.width > 750
                ? 50.w
                : 100.w,
        decoration: BoxDecoration(
          color: bColor,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Padding(
          padding: EdgeInsets.all(8.w),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CustomText(
                text: widget.title,
                color: Colors.white,
                fontSize: (widget.width > 500 && widget.width < 750)
                    ? 14
                    : widget.width >= 750
                        ? 9
                        : 18,
              ),
              CustomText(
                text: "${widget.numOfDays} Days",
                color: Colors.green,
                fontSize: (widget.width > 500 && widget.width < 750)
                    ? 14
                    : widget.width >= 750
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
