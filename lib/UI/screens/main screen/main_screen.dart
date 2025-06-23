import 'package:flutter/material.dart';
import 'package:kotaby/UI/screens/hadith%20screen/hadith_screen.dart';
import 'package:kotaby/UI/screens/home%20screen/home_screen.dart';
import 'package:kotaby/UI/screens/settings%20screen/settings_screen.dart';
import 'package:kotaby/UI/screens/surah%20screen/all_surah_quran_screen.dart';
import 'package:kotaby/UI/screens/tafsir%20screen/all_surah_tafsir.dart';
import 'package:kotaby/constants/constants.dart';
import 'package:kotaby/core/services/tafseer_api.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _currentIndex = 0;
  ApiServices apiServices = ApiServices();

  void _updateIndex(int index) {
    setState(() {
      _currentIndex = index;
    });
  }

  final List<Widget> _pages = [
    const HomeScreen(),
    const AllSurahQuranScreen(),
    const AllSurahTafsir(),
    const HadithScreen(),
    const SettingsScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _pages[_currentIndex],
      bottomNavigationBar: BottomNavigationBar(
        backgroundColor: primaryColor,
        currentIndex: _currentIndex,
        useLegacyColorScheme: false,
        onTap: _updateIndex,
        showSelectedLabels: true,
        showUnselectedLabels: false,
        selectedItemColor: activeIconColor,
        type: BottomNavigationBarType.fixed,
        items: [
          BottomNavigationBarItem(
            tooltip: "Home",
            icon: Image.asset(
              "assets/images/icons/icon1.png",
              width: 25,
              height: 30,
              color: inactiveIconColor,
            ),
            activeIcon: Image.asset(
              "assets/images/icons/icon1.png",
              width: 30,
              height: 30,
              color: activeIconColor,
            ),
            label: "Home",
          ),
          BottomNavigationBarItem(
            tooltip: "quran",
            icon: Image.asset(
              "assets/images/icons/icon2.png",
              width: 25,
              height: 30,
              color: inactiveIconColor,
            ),
            activeIcon: Image.asset(
              "assets/images/icons/icon2.png",
              width: 30,
              height: 30,
              color: activeIconColor.withOpacity(.8),
            ),
            label: "quran",
          ),
          BottomNavigationBarItem(
            tooltip: "tafsir",
            icon: Image.asset(
              "assets/images/icons/icon3.png",
              width: 25,
              height: 30,
              color: inactiveIconColor,
            ),
            activeIcon: Image.asset(
              "assets/images/icons/icon3.png",
              width: 30,
              height: 30,
              color: activeIconColor,
            ),
            label: "Tafsir",
          ),
          BottomNavigationBarItem(
            tooltip: "hadith",
            icon: Image.asset(
              "assets/images/icons/icon4.png",
              width: 25,
              height: 30,
              color: inactiveIconColor,
            ),
            activeIcon: Image.asset(
              "assets/images/icons/icon4.png",
              width: 30,
              height: 30,
              color: activeIconColor,
            ),
            label: "hadith",
          ),
          BottomNavigationBarItem(
            tooltip: "settings",
            icon: Image.asset(
              "assets/images/icons/icon5.png",
              width: 25,
              height: 30,
              color: inactiveIconColor,
            ),
            activeIcon: Image.asset(
              "assets/images/icons/icon5.png",
              width: 25,
              height: 30,
              color: activeIconColor,
            ),
            label: "settings",
          ),
        ],
      ),
    );
  }
}
