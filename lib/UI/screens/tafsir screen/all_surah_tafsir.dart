import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:kotaby/UI/screens/tafsir%20screen/tafsir_screen.dart';
import 'package:kotaby/constants/constants.dart';
import 'package:kotaby/core/ui_components/custom_app_bar.dart';
import 'package:kotaby/core/ui_components/custom_search_icon.dart';
import 'package:kotaby/core/ui_components/custom_text.dart';
import 'package:quran/quran.dart';
import 'package:quran/surah_data.dart';

class AllSurahTafsir extends StatelessWidget {
  const AllSurahTafsir({super.key});

  @override
  Widget build(BuildContext context) {
    bool isWidth = MediaQuery.of(context).size.width > 500;
    return Scaffold(
      backgroundColor: primaryColor,
      appBar: CustomAppBar(
        title: "التفسير",
        islead: false,
        actions: [
          CustomSearchIcon(
            onPressed: () => print("Search button tafisr Screen pressed"),
          ),
        ],
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
            color: const Color(0xff121931),
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
                    color: Colors.white,
                    fontSize: isWidth ? 10 : 18,
                  ),
                  CustomText(
                    text: s,
                    color: Colors.white,
                    fontFamily: "SurahName",
                    fontSize: isWidth ? 15 : 30,
                  ),
                ],
              ),
              subtitle: CustomText(
                text: "عدد آياتها $ayahCount",
                color: Colors.white.withOpacity(.6),
                fontFamily: "Hafs",
                textAlign: TextAlign.right,
                fontSize: isWidth ? 9 : 14,
              ),
              trailing: CustomText(
                text: "$surahNumber",
                color: Colors.white,
                fontSize: isWidth ? 10 : 20,
              ),
              onTap: () {
                Get.to(
                  () => TafsirScreen(
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
