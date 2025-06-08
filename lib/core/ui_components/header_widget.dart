import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:kotaby/core/ui_components/custom_text.dart';

import 'package:quran/quran.dart';

class HeaderWidget extends StatelessWidget {
  var e;
  final Color textColor;
  HeaderWidget({
    super.key,
    required this.e,
    required this.textColor,
  });

  @override
  Widget build(BuildContext context) {
    bool isWidth = MediaQuery.of(context).size.width >= 500;
    double width = MediaQuery.of(context).size.width;

    int i = e["start"];
    return SizedBox(
      width: width,
      height: isWidth ? 100.h : 40.h,
      child: Stack(
        alignment: Alignment.center,
        children: [
          Image.asset(
            "assets/images/888-02.png",
            width: width,
            color: Color.fromARGB(255, 230, 143, 11),
            fit: BoxFit.cover,
          ),
          CustomText(
            text: e['surah'] <= 9
                ? "00${e['surah']}"
                : e['surah'] <= 99
                    ? "0${e['surah']}"
                    : "${e['surah']}",
            fontSize: isWidth ? 25 : 35,
            fontFamily: "surahName",
            fontWeight: FontWeight.w500,
            textAlign: TextAlign.center,
            color: textColor.withOpacity(.9),
          ),
        ],
      ),
    );
  }
}
