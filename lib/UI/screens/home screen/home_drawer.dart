import 'package:flutter/material.dart';
import 'package:kotaby/UI/screens/home%20screen/azkar_screen.dart';
import 'package:kotaby/UI/screens/home%20screen/radio_screen.dart';
import 'package:kotaby/UI/screens/settings%20screen/screens/notfications_screen.dart';
import 'package:kotaby/UI/screens/settings%20screen/screens/storage_screen.dart';
import 'package:kotaby/UI/screens/settings%20screen/screens/top_10_screen.dart';
import 'package:kotaby/constants/azkar_elmassa.dart';
import 'package:kotaby/constants/azkar_elsabah.dart';
import 'package:kotaby/constants/constants.dart';
import 'package:kotaby/core/functions/navigate.dart';
import 'package:kotaby/core/ui_components/custom_text.dart';

class HomeDrawer extends StatelessWidget {
  const HomeDrawer({super.key});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: MediaQuery.of(context).size.width / 1.5,
      child: Drawer(
        backgroundColor: primaryColor,
        child: ListView(
          children: [
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: DrawerHeader(
                  child: Image.asset("assets/images/ic_launcher.png")),
            ),
            buildDrawerItem(
              context: context,
              title: "Radio",
              icon: Icons.radio_outlined,
              screen: const RadioScreen(),
            ),
            buildDrawerItem(
              context: context,
              title: "Notifications",
              icon: Icons.notifications_outlined,
              screen: const NotificationsScreen(),
            ),
            buildDrawerItem(
              context: context,
              title: "Storage",
              icon: Icons.sd_storage_outlined,
              screen: const StorageScreen(),
            ),
            buildDrawerItem(
              context: context,
              title: "Top 10",
              icon: Icons.leaderboard_outlined,
              screen: const Top10Screen(),
            ),
            buildDrawerItem(
              context: context,
              title: "Azkar ElSabah",
              icon: Icons.light_mode_outlined,
              screen: AzkarScreen(
                title: "Azkar ElSabah",
                azkarList: azkarElsabah,
              ),
            ),
            buildDrawerItem(
              context: context,
              title: "Azkar ElMasaa",
              icon: Icons.dark_mode_outlined,
              screen: AzkarScreen(
                title: "Azkar ElMasaa",
                azkarList: azkarElmassa,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

Widget buildDrawerItem(
    {required BuildContext context,
    required String title,
    required IconData icon,
    required Widget screen}) {
  return ListTile(
    leading: Icon(icon, color: Colors.white),
    title: CustomText(
      text: title,
      color: Colors.white,
      fontSize: 18,
    ),
    trailing: Icon(
      Icons.arrow_forward_ios,
      color: Colors.white,
    ),
    onTap: () => N.pushto(context: context, screen: screen),
  );
}
