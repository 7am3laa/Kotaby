import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:kotaby/UI/screens/tafsir%20screen/tafsir_screen.dart';
import 'package:kotaby/constants/constants.dart';
import 'package:kotaby/core/functions/navigate.dart';
import 'package:kotaby/core/ui_components/custom_app_bar.dart';
import 'package:kotaby/core/ui_components/custom_text.dart';
import 'package:kotaby/storage.dart';
import 'package:quran/quran.dart';
import 'package:quran/surah_data.dart';

class AllSurahTafsir extends StatelessWidget {
  const AllSurahTafsir({super.key});

  @override
  Widget build(BuildContext context) {
    bool isWidth = MediaQuery.of(context).size.width > 500;
    return Scaffold(
      backgroundColor: Storage.themeState == 1 ? primaryColor : Colors.white,
      appBar: CustomAppBar(
        title: "التفسير",
        islead: false,
      ),
      body: ListView.builder(
        shrinkWrap: true,
        itemCount: surah.length,
        itemBuilder: (context, index) {
          final surahFiltered = surah[index];
          final int surahNumber = surahFiltered["id"];
          final String surahName = surahFiltered["name"];
          final int ayahCount = getVerseCount(surahNumber);
          final bool isMadinah = surahFiltered["place"] == "Madinah";
          final String suraArabicName = surahFiltered["arabic"];
          final String s =
              "${surahNumber <= 9 ? "00$surahNumber" : surahNumber <= 99 ? "0$surahNumber" : surahNumber}";

          return Card(
            color: Storage.themeState == 1
                ? const Color(0xff121931)
                : Colors.white,
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            child: ListTile(
              leading: Image.asset(
                isMadinah
                    ? "assets/images/madinah.png"
                    : "assets/images/makkah.png",
                width: isWidth ? 35.w : 50.w,
                height: 45.h,
                fit: BoxFit.cover,
              ),
              title: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  CustomText(
                    text: surahName,
                    color: Storage.themeState == 1 ? Colors.white : bColor,
                    fontSize: isWidth ? 10 : 18,
                  ),
                  CustomText(
                    text: s,
                    color: Storage.themeState == 1 ? Colors.white : bColor,
                    fontFamily: "SurahName",
                    fontSize: isWidth ? 15 : 30,
                  ),
                ],
              ),
              subtitle: CustomText(
                text: "عدد آياتها $ayahCount",
                color: Storage.themeState == 1
                    ? Colors.white.withOpacity(.6)
                    : Colors.black,
                fontFamily: "Hafs",
                fontWeight: FontWeight.w500,
                textAlign: TextAlign.right,
                fontSize: isWidth ? 9 : 14,
              ),
              trailing: CustomText(
                text: "$surahNumber",
                color: Storage.themeState == 1 ? Colors.white : bColor,
                fontSize: isWidth ? 10 : 20,
              ),
              onTap: () {
                N.pushto(
                  context: context,
                  screen: TafsirScreen(
                    suranumber: surahNumber,
                  ),
                );
              },
            ),
          );
        },
      ),
    );
  }
}
