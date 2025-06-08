import 'package:flutter/material.dart';
import 'package:kotaby/UI/screens/surah%20screen/juz_screen.dart';
import 'package:kotaby/UI/screens/surah%20screen/surah_screen.dart';
import 'package:kotaby/constants/constants.dart';
import 'package:kotaby/core/ui_components/custom_app_bar.dart';
import 'package:kotaby/core/ui_components/custom_text.dart';
import 'package:quran/quran.dart';
import 'package:quran/surah_data.dart';
import 'package:string_validator/string_validator.dart';

class AllSurahQuranScreen extends StatefulWidget {
  const AllSurahQuranScreen({super.key});

  @override
  State<AllSurahQuranScreen> createState() => _AllSurahQuranScreenState();
}

class _AllSurahQuranScreenState extends State<AllSurahQuranScreen>
    with SingleTickerProviderStateMixin {
  bool isLoading = true;
  bool isSearch = false;
  var searchQuery = "";
  var filteredData;
  var ayatFiltered;
  var filteredDataSurah = [];

  List pageNumbers = [];
  TextEditingController searchController = TextEditingController();
  late TabController tabController;
  void init() {
    setState(() {
      isLoading = false;
      filteredDataSurah = [surah];
    });
  }

  void searchLogic(String value) {
    setState(() {
      value = searchController.text.trim();
    });

    filteredData = [];
    ayatFiltered = null;
    pageNumbers = [];

    if (value == "") {
      filteredDataSurah = [surah, null, null];
      setState(() {});
      return;
    }

    List tempFilteredSurah = [];
    List tempPageNumbers = [];
    Map? tempAyatFiltered;

    if (isInt(value) && toInt(value) >= 1 && toInt(value) <= 604) {
      tempPageNumbers.add(toInt(value));
    }

    if (value.length > 3 || value.contains(" ")) {
      tempAyatFiltered = searchWords(value);
    }

    tempFilteredSurah = surah.where((sura) {
      final suraName = sura['name'].toString().toLowerCase();
      final suraNameArabic = getSurahNameArabic(sura["id"]).toLowerCase();
      final searchLower = value.toLowerCase();

      return suraName.contains(searchLower) ||
          suraNameArabic.contains(searchLower);
    }).toList();

    setState(() {
      filteredData = tempFilteredSurah;
      pageNumbers = tempPageNumbers;
      ayatFiltered = tempAyatFiltered;
      filteredDataSurah = [
        tempFilteredSurah,
        tempPageNumbers,
        tempAyatFiltered
      ];
    });
  }

  void onClose() {
    setState(() {
      searchController.text = "";
      ayatFiltered = null;
      pageNumbers = [];
      filteredData = [];
      filteredDataSurah = [surah];
    });
  }

  @override
  void initState() {
    init();
    tabController = TabController(length: 2, vsync: this);
    tabController == 2;
    tabController.addListener(() {
      setState(() {});
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    bool isWidth = MediaQuery.of(context).size.width > 500;
    return Scaffold(
      backgroundColor: primaryColor,
      appBar: CustomAppBar(
        title: "القرآن الكريم",
        islead: false,
        issearch: false,
        bottom: TabBar(
          controller: tabController,
          tabs: [
            Tab(
              child: Center(
                child: CustomText(
                  text: "السور",
                  fontWeight: FontWeight.w500,
                  color: Colors.white,
                  fontSize: isWidth ? 10 : 25,
                ),
              ),
            ),
            Tab(
              child: Center(
                child: CustomText(
                  text: "الاجزء",
                  fontWeight: FontWeight.w500,
                  color: Colors.white,
                  fontSize: isWidth ? 10 : 25,
                ),
              ),
            ),
          ],
        ),
      ),
      body: TabBarView(
        controller: tabController,
        children: [
          SurahScreen(
            ayatFiltered: ayatFiltered,
            filteredData: filteredDataSurah,
            pageNumbers: pageNumbers,
            searchLogic: searchLogic,
            onClose: onClose,
            isSearch: isSearch,
            searchController: searchController,
          ),
          JuzScreen(),
        ],
      ),
    );
  }
}
