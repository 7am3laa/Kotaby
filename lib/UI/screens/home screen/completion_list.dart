import 'package:flutter/material.dart';
import 'package:kotaby/UI/screens/surah%20screen/surah_page_screen.dart';
import 'package:kotaby/constants/constants.dart';
import 'package:kotaby/core/functions/navigate.dart';
import 'package:kotaby/core/models/task_model.dart';
import 'package:kotaby/core/services/tasks_service.dart';
import 'package:kotaby/core/ui_components/custom_app_bar.dart';
import 'package:kotaby/core/ui_components/custom_text.dart';
import 'package:kotaby/notfications_service.dart';
import 'package:kotaby/storage.dart';
import 'package:quran/quran.dart';

class CompletionList extends StatefulWidget {
  const CompletionList({super.key});

  @override
  State<CompletionList> createState() => _CompletionListState();
}

class _CompletionListState extends State<CompletionList> {
  List<TaskModel> _items = [];
  bool _isLoading = false;
  final taskService = TasksService();

  @override
  void initState() {
    super.initState();
    _loadItems();
  }

  Future<void> _loadItems() async {
    if (!mounted) return;
    setState(() {
      _isLoading = true;
    });
    try {
      _items = await taskService.getUserTasks();
    } catch (e) {
      print('Error fetching tasks: $e');
    }
    if (!mounted) return;
    setState(() {
      _isLoading = false;
    });
  }

  Future<void> _showDeleteConfirmation() async {
    return showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Storage.themeState == 1 ? primaryColor : Colors.white,
        title: CustomText(
          text: 'Delete Completion List',
          color: Storage.themeState == 1 ? Colors.white : bColor,
          fontSize: 20,
        ),
        content: CustomText(
          text:
              'Are you sure you want to delete your completion list? This action cannot be undone.',
          color: Storage.themeState == 1 ? Colors.white70 : bColor,
          fontSize: 16,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: CustomText(
              text: 'Cancel',
              color: Storage.themeState == 1 ? Colors.white70 : bColor,
              fontSize: 16,
            ),
          ),
          TextButton(
            onPressed: () async {
              await taskService.deleteUserTasks();
              await Storage.saveTaskPlanState(0);
              NotificationsService.cancelNotificationById(60);
              await Storage.saveWerdDaily(false);
              final peren = await taskService.getTaskSummary();
              await Storage.saveCompletionPercentage(
                  peren.completionPercentage);
              if (mounted) {
                Navigator.pop(context);
                N.pop(context: context);
              }
            },
            child: const CustomText(
              text: 'Delete',
              color: Colors.red,
              fontSize: 16,
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _markAsRead(TaskModel item) async {
    try {
      if (!item.completed) {
        await taskService.completeTask(item.id);
      }
      final updatedItem = TaskModel(
        id: item.id,
        userId: item.userId,
        dayNumber: item.dayNumber,
        startPage: item.startPage,
        endPage: item.endPage,
        taskDate: item.taskDate,
        progress: item.progress,
        surahRange: item.surahRange,
        completed: true,
      );
      setState(() {
        _items[_items.indexWhere((t) => t.id == item.id)] = updatedItem;
      });
      final peren = await taskService.getTaskSummary();
      await Storage.saveCompletionPercentage(peren.completionPercentage);
      print(peren.completionPercentage);
    } catch (e) {
      print('Error marking as read: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Storage.themeState == 1 ? primaryColor : Colors.white,
      appBar: CustomAppBar(
        title: 'Completion List',
        actions: [
          IconButton(
            onPressed: _showDeleteConfirmation,
            icon: const Icon(
              Icons.delete_outlined,
              color: Colors.red,
            ),
          ),
        ],
      ),
      body: _isLoading
          ? const Center(
              child: CircularProgressIndicator(
              color: bColor,
            ))
          : Column(
              children: [
                Expanded(
                  child: RefreshIndicator(
                    onRefresh: _loadItems,
                    child: ListView.builder(
                      padding: const EdgeInsets.all(16),
                      itemCount: _items.length,
                      itemBuilder: (context, index) {
                        final item = _items[index];
                        return _CompletionItemWidget(
                          item: item,
                          onMarkAsRead: () => _markAsRead(item),
                        );
                      },
                    ),
                  ),
                ),
              ],
            ),
    );
  }
}

class _CompletionItemWidget extends StatelessWidget {
  final TaskModel item;
  final VoidCallback onMarkAsRead;

  const _CompletionItemWidget({
    required this.item,
    required this.onMarkAsRead,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        final pageData = getPageData(item.startPage);
        final suarhNumber = pageData[0]['surah'];
        final ayaNumber = pageData[0]['start'];
        N.pushto(
          context: context,
          screen: SurahPageScreen(
            pageNumber: item.startPage,
            shouldHighlightText: true,
            highlightVerse: "$suarhNumber:$ayaNumber",
            lastp: item.endPage + 1,
          ),
        );
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
        decoration: BoxDecoration(
          color: item.completed
              ? Colors.green.withOpacity(0.5)
              : Storage.themeState == 1
                  ? Colors.white.withOpacity(.2)
                  : Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.2),
              blurRadius: 8,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: item.completed ? Colors.green.withOpacity(0.3) : bColor,
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(16),
                ),
              ),
              child: Row(
                children: [
                  CustomText(
                    text: 'Day ${item.dayNumber}',
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                  const Spacer(),
                  CustomText(
                    text: 'Pages ${item.startPage} - ${item.endPage}',
                    color: Colors.white.withOpacity(0.8),
                    fontSize: 16,
                  ),
                  const Spacer(),
                  IconButton(
                    onPressed: item.completed ? null : onMarkAsRead,
                    icon: Icon(
                      item.completed
                          ? Icons.check_circle
                          : Icons.check_circle_outline_outlined,
                      size: 20,
                    ),
                    color: item.completed ? Colors.green : Colors.white,
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: CustomText(
                      text: getSurahNameArabicFull(
                          getPageData(item.startPage)[0]["surah"]),
                      color: Storage.themeState == 1 ? Colors.white : bColor,
                      fontSize: 18,
                      fontFamily: "Hafs",
                      fontWeight: FontWeight.bold,
                      textAlign: TextAlign.center,
                    ),
                  ),
                  Icon(
                    Icons.arrow_forward,
                    color: Storage.themeState == 1 ? Colors.white70 : bColor,
                    size: 20,
                  ),
                  Expanded(
                    child: CustomText(
                      text: getSurahNameArabicFull(
                          getPageData(item.endPage)[0]["surah"]),
                      color: Storage.themeState == 1 ? Colors.white : bColor,
                      fontFamily: "Hafs",
                      fontSize: 18,
                      textAlign: TextAlign.center,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
