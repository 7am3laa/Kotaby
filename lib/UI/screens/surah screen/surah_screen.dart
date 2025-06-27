import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:kotaby/UI/screens/surah%20screen/surah_page_screen.dart';
import 'package:kotaby/constants/constants.dart';
import 'package:kotaby/core/functions/navigate.dart';
import 'package:kotaby/core/ui_components/custom_text.dart';
import 'package:kotaby/storage.dart';
import 'package:quran/quran.dart';

class SurahScreen extends StatelessWidget {
  final bool isSearch;
  final TextEditingController searchController;
  final Function searchLogic;
  final VoidCallback onClose;
  final List pageNumbers;
  var ayatFiltered;
  var filteredData;

  SurahScreen({
    super.key,
    required this.isSearch,
    required this.searchController,
    required this.searchLogic,
    required this.onClose,
    required this.pageNumbers,
    required this.ayatFiltered,
    required this.filteredData,
  });

  @override
  Widget build(BuildContext context) {
    bool isWidth = MediaQuery.of(context).size.width > 500;
    bool isHeight = MediaQuery.of(context).size.height > 850;

    return Column(
      children: [
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 10.0.w, vertical: 8.h),
          child: SizedBox(
            height: 50,
            child: Center(
              child: TextField(
                controller: searchController,
                onChanged: (value) => searchLogic(value),
                cursorColor:
                    Storage.themeState == 1 ? Colors.white : Colors.black,
                textAlign: TextAlign.right,
                style: TextStyle(
                  color: Storage.themeState == 1 ? Colors.white : Colors.black,
                  fontSize: 16.sp,
                  fontWeight: FontWeight.w500,
                ),
                decoration: InputDecoration(
                  hintText: 'ابحث عن سورة أو صفحة أو آية',
                  hintStyle: TextStyle(
                    color:
                        Storage.themeState == 1 ? Colors.white54 : Colors.black,
                    fontSize: 16.sp,
                    fontWeight: FontWeight.w400,
                    fontFamily: "Poppins",
                  ),
                  suffixIcon: Icon(
                    Icons.search,
                    color: Storage.themeState == 1 ? Colors.white : bColor,
                    size: 24.w,
                  ),
                  prefixIcon: searchController.text.isNotEmpty
                      ? IconButton(
                          icon: Icon(
                            Icons.clear,
                            color:
                                Storage.themeState == 1 ? Colors.white : bColor,
                            size: 24.w,
                          ),
                          onPressed: () {
                            onClose();
                          },
                        )
                      : null,
                  filled: true,
                  fillColor: Colors.white.withOpacity(0.1),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(15),
                    borderSide: BorderSide(
                      color: Storage.themeState == 1 ? Colors.white : bColor,
                    ),
                  ),
                  contentPadding: EdgeInsets.symmetric(horizontal: 16.w),
                ),
              ),
            ),
          ),
        ),
        Expanded(
          child: _buildSearchResults(context, isWidth, isHeight),
        ),
      ],
    );
  }

  Widget _buildSearchResults(
      BuildContext context, bool isWidth, bool isHeight) {
    if (searchController.text.isEmpty) {
      return _buildSurahList(context, isWidth, filteredData[0] ?? []);
    }

    if (filteredData.length > 1 &&
        filteredData[1] != null &&
        filteredData[1].isNotEmpty) {
      return _buildPageNumbersList(context, filteredData[1]);
    }

    if (filteredData.length > 2 &&
        filteredData[2] != null &&
        filteredData[2]["occurences"] > 0) {
      return _buildAyatSearchResults(context, isWidth, filteredData[2]);
    }

    if (filteredData.length > 0 &&
        filteredData[0] != null &&
        filteredData[0].isNotEmpty) {
      return _buildSurahList(context, isWidth, filteredData[0]);
    }

    return _buildNoResults();
  }

  Widget _buildPageNumbersList(BuildContext context, List pageNumbers) {
    return ListView.builder(
      itemCount: pageNumbers.length,
      itemBuilder: (context, index) {
        final pageNumber = pageNumbers[index];
        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 30.0, vertical: 4.0),
          child: Card(
            color: Storage.themeState == 1 ? const Color(0xff121931) : bColor,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
            child: ListTile(
              title: CustomText(
                text: "صفحة $pageNumber",
                color: Colors.white,
                textAlign: TextAlign.center,
                fontSize: 16,
                fontWeight: FontWeight.w500,
              ),
              subtitle: CustomText(
                text:
                    "سورة ${getSurahNameArabic(getPageData(pageNumber)[0]["surah"])}",
                color: Colors.white.withOpacity(0.7),
                textAlign: TextAlign.center,
                fontSize: 14,
                fontFamily: "Hafs",
              ),
              onTap: () {
                N.pushto(
                  context: context,
                  screen: SurahPageScreen(
                    pageNumber: pageNumber,
                    shouldHighlightText: true,
                    highlightVerse:
                        "${getPageData(pageNumber)[0]["surah"]}:${getPageData(pageNumber)[0]["start"]}",
                  ),
                );
              },
            ),
          ),
        );
      },
    );
  }

  Widget _buildAyatSearchResults(
      BuildContext context, bool isWidth, Map ayatResults) {
    final int itemCount =
        ayatResults["occurences"] > 10 ? 10 : ayatResults["occurences"];

    return ListView.builder(
      itemCount: itemCount,
      itemBuilder: (context, index) {
        final result = ayatResults["result"][index];
        final int surahNumber = result["surah"];
        final int verseNumber = result["verse"];
        final int pageNumber = getPageNumber(surahNumber, verseNumber);
        final String s =
            "${surahNumber <= 9 ? "00$surahNumber" : surahNumber <= 99 ? "0$surahNumber" : surahNumber}";

        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 4.0),
          child: Card(
            color: Storage.themeState == 1 ? const Color(0xff121931) : bColor,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
            child: ListTile(
              title: CustomText(
                text: getVerseQCF(surahNumber, verseNumber),
                fontFamily: 'QCF_P${pageNumber.toString().padLeft(3, "0")}',
                color: Colors.white,
                textAlign: TextAlign.right,
                fontSize: isWidth ? 14 : 16,
              ),
              subtitle: CustomText(
                text: s,
                color: Colors.white,
                textAlign: TextAlign.center,
                fontSize: 30,
                fontFamily: "SurahName",
              ),
              onTap: () {
                N.pushto(
                  context: context,
                  screen: SurahPageScreen(
                    pageNumber: pageNumber,
                    shouldHighlightText: true,
                    highlightVerse: "$surahNumber:$verseNumber",
                  ),
                );
              },
            ),
          ),
        );
      },
    );
  }

  Widget _buildSurahList(BuildContext context, bool isWidth, List surahList) {
    return ListView.builder(
      itemCount: surahList.length,
      itemBuilder: (context, index) {
        final surahFiltered = surahList[index];
        final int surahNumber = surahFiltered["id"];
        final String surahName = surahFiltered["name"];
        final int ayahCount = getVerseCount(surahNumber);
        final bool isMadinah = surahFiltered["place"] == "Madinah";
        final String suraArabicName = surahFiltered["arabic"];
        final String s =
            "${surahNumber <= 9 ? "00$surahNumber" : surahNumber <= 99 ? "0$surahNumber" : surahNumber}";

        return Card(
          color:
              Storage.themeState == 1 ? const Color(0xff121931) : Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
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
                  fontWeight: FontWeight.w500,
                  fontSize: isWidth ? 10 : 18,
                ),
                CustomText(
                  text: s,
                  color: Storage.themeState == 1 ? Colors.white : bColor,
                  fontWeight: FontWeight.bold,
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
              fontWeight: FontWeight.w500,
              fontSize: isWidth ? 10 : 20,
            ),
            onTap: () {
              N.pushto(
                context: context,
                screen: SurahPageScreen(
                  highlightVerse: "$surahNumber:1",
                  shouldHighlightText: true,
                  pageNumber: getPageNumber(surahNumber, 1),
                ),
              );
            },
          ),
        );
      },
    );
  }

  Widget _buildNoResults() {
    return Center(
      child: CustomText(
        text: "لم يتم العثور على نتائج",
        color: Colors.white.withOpacity(0.7),
        fontSize: 16,
        fontFamily: "Hafs",
      ),
    );
  }
}
