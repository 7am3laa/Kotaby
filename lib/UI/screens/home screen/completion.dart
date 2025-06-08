import 'package:flutter/material.dart';
import 'package:kotaby/UI/screens/home%20screen/completion_list.dart';
import 'package:kotaby/constants/constants.dart';
import 'package:kotaby/core/functions/navigate.dart';
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
  int pagesPerDay = 0;
  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    calculateReadingPlan();
  }

  void calculateReadingPlan() {
    if (selectedDays <= 0) {
      setState(() {
        pagesPerDay = totalQuranPages;
      });
      return;
    }

    setState(() {
      pagesPerDay = (totalQuranPages / selectedDays).ceil();
      // Ensure we don't exceed total pages
      if (pagesPerDay * selectedDays > totalQuranPages) {
        pagesPerDay = (totalQuranPages / selectedDays).floor();
      }
    });
  }

  Future<void> saveCompletionPlan() async {
    if (isLoading) return;

    setState(() {
      isLoading = true;
    });

    try {
      // Validate the plan
      if (selectedDays <= 0 || pagesPerDay <= 0) {
        throw Exception('Invalid reading plan parameters');
      }

      // Save basic plan data
      await Storage.saveCompletionDays(selectedDays);
      await Storage.saveCompletionPages(pagesPerDay);

      // Generate and save completion list
      List<int> completionList = [];
      int remainingPages = totalQuranPages;
      int currentPage = 1;

      for (int i = 0; i < selectedDays; i++) {
        if (remainingPages <= 0) break;

        int pagesForToday =
            (i == selectedDays - 1) ? remainingPages : pagesPerDay;

        completionList.add(currentPage);
        currentPage += pagesForToday;
        remainingPages -= pagesForToday;
      }

      await Storage.saveCompletionList(completionList);
      await NotificationsService.scheduleWerdDailyNotification();

      if (mounted) {
        N.pushReplacementto(context: context, screen: const CompletionList());
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error saving plan: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: primaryColor,
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
                  color: Colors.white.withOpacity(.8),
                  fontWeight: FontWeight.bold,
                ),
                const SizedBox(height: 20),
                const Spacer(),
                Card(
                  elevation: 4,
                  color: Colors.white.withOpacity(.1),
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        CustomText(
                          text: 'Your Reading Plan',
                          fontSize: 18,
                          color: Colors.white.withOpacity(.8),
                          fontWeight: FontWeight.bold,
                        ),
                        const SizedBox(height: 10),
                        CustomText(
                          text: 'Total pages: $totalQuranPages',
                          color: Colors.white.withOpacity(.8),
                          fontSize: 18,
                        ),
                        CustomText(
                          text: 'Total days: $selectedDays',
                          color: Colors.white.withOpacity(.8),
                          fontSize: 18,
                        ),
                        CustomText(
                          text: 'Pages per day: $pagesPerDay',
                          color: Colors.white.withOpacity(.8),
                          fontSize: 18,
                        ),
                        if (pagesPerDay * selectedDays > totalQuranPages)
                          Padding(
                            padding: const EdgeInsets.only(top: 8.0),
                            child: CustomText(
                              text:
                                  'Note: Plan will complete before selected days',
                              color: Colors.orange,
                              fontSize: 14,
                            ),
                          ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 30),
                const Spacer(),
                CustomText(
                  text: 'Select number of days to complete:',
                  fontSize: 18,
                  color: Colors.white.withOpacity(.8),
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
                      calculateReadingPlan();
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
                child: CircularProgressIndicator(),
              ),
            ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: bColor,
        onPressed: saveCompletionPlan,
        child: const Icon(Icons.save_outlined),
      ),
    );
  }
}
