import 'package:flutter/material.dart';
import 'package:kotaby/UI/screens/home%20screen/completion.dart';
import 'package:kotaby/UI/screens/home%20screen/completion_list.dart';
import 'package:kotaby/UI/screens/home%20screen/home_drawer.dart';
import 'package:kotaby/UI/screens/home%20screen/widgets/bookmark_container.dart';
import 'package:kotaby/UI/screens/home%20screen/widgets/progress_container.dart';
import 'package:kotaby/UI/screens/home%20screen/widgets/streak_container.dart';
import 'package:kotaby/constants/constants.dart';
import 'package:kotaby/core/functions/navigate.dart';
import 'package:kotaby/core/ui_components/custom_app_bar.dart';
import 'package:kotaby/core/ui_components/custom_text.dart';
import 'package:kotaby/storage.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final width = size.width;
    final height = size.height;

    return Scaffold(
      backgroundColor: primaryColor,
      appBar: const CustomAppBar(
        title: "Kotaby - كُتّابي",
        islead: false,
        isDrawer: true,
      ),
      drawer: const HomeDrawer(),
      body: ListView(
        padding: const EdgeInsets.all(16.0),
        children: [
          _buildWelcomeSection(width),
          const SizedBox(height: 20),
          BookmarkContainer(width: width, height: height),
          const SizedBox(height: 20),
          Row(
            spacing: 10,
            children: [
              StreakContainer(
                title: "Current Streak",
                numOfDays: 10,
                width: width,
              ),
              StreakContainer(
                title: "Longest Streak",
                numOfDays: 10,
                width: width,
              ),
            ],
          ),
          const SizedBox(height: 20),
          _buildProgressSection(width, height),
        ],
      ),
    );
  }

  Widget _buildWelcomeSection(double width) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        CustomText(
          text: "Asslamualaikum",
          fontSize: (width > 500 && width < 750)
              ? 10
              : width >= 750
                  ? 9
                  : 12,
        ),
        CustomText(
          text: Storage.usernameCached.toString(),
          color: Colors.white.withOpacity(.8),
          fontSize: (width > 500 && width < 750)
              ? 13
              : width >= 750
                  ? 12
                  : 20,
        ),
      ],
    );
  }

  Widget _buildProgressSection(double width, double height) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        CustomText(
          text: "Progress",
          color: Colors.white,
          fontSize: (width > 500 && width < 750)
              ? 14
              : width >= 750
                  ? 10
                  : 18,
        ),
        const SizedBox(height: 20),
        ProgressContainer(
          icon: "assets/images/icons/icon4.png",
          title: "Completion",
          percentage:
              "${((Storage.completionPageForPercentage / 604) * 100).toStringAsFixed(0)}%",
          width: width,
          height: height,
          onTap: () async {
            if (Storage.completionDays == 0) {
              await N.pushto(context: context, screen: const Completion());
            } else {
              await N.pushto(context: context, screen: const CompletionList());
            }
            setState(() {});
          },
        ),
        const SizedBox(height: 10),
        ProgressContainer(
          icon: "assets/images/icons/icon2.png",
          title: "Memorization",
          percentage: "40%",
          width: width,
          height: height,
          onTap: () {},
        ),
      ],
    );
  }
}
