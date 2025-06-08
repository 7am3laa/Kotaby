import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:kotaby/UI/screens/surah%20screen/surah_page_screen.dart';
import 'package:kotaby/constants/constants.dart';
import 'package:kotaby/core/functions/navigate.dart';
import 'package:kotaby/core/ui_components/custom_text.dart';
import 'package:kotaby/storage.dart';
import 'package:quran/quran.dart';

class BookmarkContainer extends StatelessWidget {
  final double width;
  final double height;

  const BookmarkContainer({
    super.key,
    required this.width,
    required this.height,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () async {
        await N.pushto(
          context: context,
          screen: SurahPageScreen(
            shouldHighlightText: true,
            highlightVerse: "${Storage.surahNumber}:${Storage.verseNumber}",
            pageNumber: getPageNumber(Storage.surahNumber, Storage.verseNumber),
          ),
        );
      },
      child: Container(
        height: (width > 500 && height > 750) ? 100.w : 150.w,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [sColor, bColor],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Row(
          children: [
            Expanded(
              child: Padding(
                padding: EdgeInsets.symmetric(vertical: 8.h, horizontal: 15.w),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      spacing: 5,
                      children: [
                        Icon(
                          Icons.menu_book_rounded,
                          color: Colors.white,
                          size: width > 500 ? 20.w : 24.w,
                        ),
                        CustomText(
                          text: "Last Read",
                          color: Colors.white,
                          fontSize: (width > 500 && width < 750)
                              ? 14
                              : width >= 750
                                  ? 10
                                  : 18,
                        ),
                      ],
                    ),
                    SizedBox(height: 10),
                    CustomText(
                      text: getSurahName(Storage.surahNumber),
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: (width > 500 && width < 750)
                          ? 14
                          : width >= 750
                              ? 10
                              : 18,
                    ),
                    SizedBox(height: 5),
                    CustomText(
                      text: "Ayah No : ${Storage.verseNumber}",
                      color: Colors.white.withOpacity(.8),
                      fontSize: (width > 500 && width < 750)
                          ? 14
                          : width >= 750
                              ? 10
                              : 18,
                    ),
                  ],
                ),
              ),
            ),
            Expanded(
              child: Align(
                alignment: Alignment.bottomRight,
                child: Image.asset(
                  "assets/images/quran.png",
                  width: (width > 500 && width < 750)
                      ? 150.w
                      : width >= 750
                          ? 100.w
                          : 200.w,
                  fit: BoxFit.fitHeight,
                ),
              ),
            )
          ],
        ),
      ),
    );
  }
}
