import 'package:flutter/material.dart';
import 'package:kotaby/UI/screens/home%20screen/completion_list.dart';
import 'package:kotaby/constants/constants.dart';
import 'package:kotaby/core/functions/navigate.dart';
import 'package:kotaby/core/services/tasks_service.dart';
import 'package:kotaby/core/ui_components/custom_app_bar.dart';
import 'package:kotaby/core/ui_components/custom_text.dart';
import 'package:kotaby/notfications_service.dart';
import 'package:kotaby/storage.dart';

class Completion extends StatefulWidget {
  const Completion({super.key});

  @override
  _CompletionState createState() => _CompletionState();
}

class _CompletionState extends State<Completion> {
  final int totalQuranPages = 604;
  int selectedDays = 30;

  bool isLoading = false;
  final tasksService = TasksService();

  @override
  void initState() {
    super.initState();
  }

  Future<void> saveCompletionPlan({required int days}) async {
    if (isLoading) return;

    setState(() {
      isLoading = true;
    });

    try {
      final tasks = await tasksService.createTasks(days: days);
      await Storage.saveTaskPlanState(1);
      await N.pushReplacementto(context: context, screen: CompletionList());
      await NotificationsService.scheduleWerdDailyNotification();
      await Storage.saveWerdDaily(true);
      for (var task in tasks) {
        print('Task ${task.dayNumber}: ${task.surahRange}');
      }
    } catch (e) {
      print('Failed to create tasks');
    }
    setState(() {
      isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Storage.themeState == 1 ? primaryColor : Colors.white,
      appBar: CustomAppBar(title: "Completion"),
      body: Stack(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                CustomText(
                  text: 'Create Your Quran Reading Plan',
                  fontSize: 22,
                  color: Storage.themeState == 1
                      ? Colors.white.withOpacity(.8)
                      : bColor,
                  fontWeight: FontWeight.bold,
                ),
                const SizedBox(height: 20),
                const Spacer(),
                Card(
                  elevation: 4,
                  color: Storage.themeState == 1
                      ? Colors.white.withOpacity(.1)
                      : Colors.white,
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        CustomText(
                          text: 'Your Reading Plan',
                          fontSize: 18,
                          color: Storage.themeState == 1
                              ? Colors.white.withOpacity(.8)
                              : bColor,
                          fontWeight: FontWeight.bold,
                        ),
                        const SizedBox(height: 10),
                        CustomText(
                          text: 'Total pages: $totalQuranPages',
                          color: Storage.themeState == 1
                              ? Colors.white.withOpacity(.8)
                              : bColor,
                          fontSize: 18,
                        ),
                        CustomText(
                          text: 'Total days: $selectedDays',
                          color: Storage.themeState == 1
                              ? Colors.white.withOpacity(.8)
                              : bColor,
                          fontSize: 18,
                        ),
                        // CustomText(
                        //   text: 'Pages per day: $pagesPerDay',
                        //   color: Colors.white.withOpacity(.8),
                        //   fontSize: 18,
                        // ),
                        // if (pagesPerDay * selectedDays > totalQuranPages)
                        //   Padding(
                        //     padding: const EdgeInsets.only(top: 8.0),
                        //     child: CustomText(
                        //       text:
                        //           'Note: Plan will complete before selected days',
                        //       color: Colors.orange,
                        //       fontSize: 14,
                        //     ),
                        //   ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 30),
                const Spacer(),
                CustomText(
                  text: 'Select number of days to complete:',
                  fontSize: 18,
                  color: Storage.themeState == 1
                      ? Colors.white.withOpacity(.8)
                      : bColor,
                  fontWeight: FontWeight.bold,
                ),
                Slider(
                  min: 1,
                  max: 100,
                  divisions: 99,
                  activeColor: bColor,
                  inactiveColor: sColor,
                  value: selectedDays.toDouble(),
                  label: selectedDays.toString(),
                  onChanged: (value) {
                    setState(() {
                      selectedDays = value.toInt();
                    });
                  },
                ),
                const Spacer(),
              ],
            ),
          ),
          if (isLoading)
            Container(
              color: Colors.black.withOpacity(0.5),
              child: const Center(
                child: CircularProgressIndicator(
                  color: bColor,
                ),
              ),
            ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: bColor,
        onPressed: () {
          saveCompletionPlan(days: selectedDays);
        },
        child: const Icon(Icons.save_outlined),
      ),
    );
  }
}
