import 'package:flutter/material.dart';
import 'package:kotaby/UI/screens/surah%20screen/surah_page_screen.dart';
import 'package:kotaby/core/functions/navigate.dart';
import 'package:kotaby/core/ui_components/custom_text.dart';
import 'package:quran/juz_data.dart';
import 'package:quran/quran.dart';

class JuzScreen extends StatelessWidget {
  const JuzScreen({super.key});

  @override
  Widget build(BuildContext context) {
    bool isWidth = MediaQuery.of(context).size.width >= 500;
    return ListView.builder(
      itemCount: juz.length,
      itemBuilder: (context, index) {
        var currentJuz = juz[index];
        List<int> surahNumbers = List<int>.from(currentJuz["surahs"]);
        Map<int, List<int>> verses =
            Map<int, List<int>>.from(currentJuz["verses"]);

        String surahNames = surahNumbers
            .map((s) => "سورة ${getSurahNameArabicFull(s)}")
            .join("\n");
        String sf =
            surahNumbers.map((s) => "سورة ${getSurahNameArabic(s)}").first;
        String sl =
            surahNumbers.map((s) => "سورة ${getSurahNameArabic(s)}").last;

        int startfVerse = verses.entries.first.value.first;
        int endfVerse = verses.entries.first.value.last;
        int startlVerse = verses.entries.last.value.first;
        int endlVerse = verses.entries.last.value.last;

        return Card(
          color: const Color(0xff121931),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
          child: ListTile(
            trailing: CustomText(
              text: "الجزء ${currentJuz['id']}",
              color: Colors.white,
              fontFamily: "Hafs",
              fontSize: isWidth ? 15 : 20,
            ),
            title: Align(
              alignment: Alignment.center,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                mainAxisAlignment: MainAxisAlignment.center,
                spacing: 5,
                children: [
                  CustomText(
                    text: "$sf الي $sl",
                    color: Colors.white,
                    fontFamily: "Hafs",
                    fontSize: isWidth ? 12 : 18,
                  ),
                  CustomText(
                    text:
                        "عدد الصفحات : ${getPageNumber(surahNumbers.last, endlVerse) - getPageNumber(surahNumbers.first, startfVerse)}",
                    color: Colors.white,
                    fontFamily: "Hafs",
                    fontSize: isWidth ? 10 : 18,
                  ),
                ],
              ),
            ),
            onTap: () {
              N.pushto(
                context: context,
                screen: SurahPageScreen(
                  pageNumber: getPageNumber(surahNumbers.first, startfVerse),
                  shouldHighlightText: true,
                  highlightVerse: "${surahNumbers.first}:$startfVerse",
                  lastp: getPageNumber(surahNumbers.last, endlVerse) + 1,
                ),
              );
            },
          ),
        );
      },
    );
  }
}
