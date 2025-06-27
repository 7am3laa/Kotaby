import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:kotaby/constants/constants.dart';
import 'package:kotaby/core/functions/navigate.dart';
import 'package:kotaby/core/ui_components/custom_app_bar.dart';
import 'package:kotaby/core/ui_components/custom_text.dart';
import 'package:kotaby/storage.dart';

class ThemeColorScreen extends StatefulWidget {
  const ThemeColorScreen({super.key});

  @override
  State<ThemeColorScreen> createState() => _ThemeColorScreenState();
}

class _ThemeColorScreenState extends State<ThemeColorScreen> {
  void changeTheme() async {
    if (Storage.themeState == 1) {
      await Storage.saveTheme(0);
      setState(() {});
    } else {
      await Storage.saveTheme(1);
      setState(() {});
    }
  }

  @override
  void initState() {
    Storage.getTheme();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Storage.themeState == 1 ? primaryColor : Colors.white,
      appBar: AppBar(
        bottomOpacity: 0,
        elevation: 0,
        backgroundColor: Storage.themeState == 1 ? primaryColor : Colors.white,
        title: CustomText(
          text: "Theme Color",
          color: Storage.themeState == 1 ? Colors.white : bColor,
        ),
        automaticallyImplyLeading: false,
        leading: IconButton(
          onPressed: () async {
            Navigator.pop(context, true);
            await Storage.getTheme();
          },
          icon: Icon(
            Icons.arrow_back_ios_new_outlined,
            color: Storage.themeState == 1 ? Colors.white : bColor,
          ),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 10),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Storage.themeState == 1
                    ? Colors.white.withOpacity(0.1)
                    : Colors.black.withOpacity(0.3),
                borderRadius: BorderRadius.circular(12),
              ),
              child: ListTile(
                title: CustomText(
                  text: "change theme",
                  color: Storage.themeState == 1 ? Colors.white : Colors.black,
                ),
                trailing: IconButton(
                  onPressed: () async {
                    changeTheme();
                    await Storage.getTheme();
                  },
                  icon: Icon(
                    Storage.themeState == 1
                        ? Icons.light_mode
                        : Icons.dark_mode,
                    size: 35.w,
                    color:
                        Storage.themeState == 1 ? Colors.white : Colors.black,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
