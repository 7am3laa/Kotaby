import 'package:flutter/material.dart';
import 'package:kotaby/UI/screens/surah%20screen/surah_page_screen.dart';
import 'package:kotaby/constants/constants.dart';
import 'package:kotaby/core/functions/navigate.dart';
import 'package:kotaby/core/models/completion_model.dart';
import 'package:kotaby/core/services/completion_service.dart';
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
  List<CompletionItem> _items = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadItems();
  }

  Future<void> _loadItems() async {
    setState(() => _isLoading = true);
    _items = await CompletionService.getCompletionItems();
    setState(() => _isLoading = false);
  }

  Future<void> _markAsRead(CompletionItem item) async {
    await CompletionService.markAsRead(item);
    // Update completion percentage after marking as read
    await _loadItems(); // Reload items to update UI
  }

  Future<void> _showDeleteConfirmation() async {
    return showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: primaryColor,
        title: const CustomText(
          text: 'Delete Completion List',
          color: Colors.white,
          fontSize: 20,
        ),
        content: const CustomText(
          text:
              'Are you sure you want to delete your completion list? This action cannot be undone.',
          color: Colors.white70,
          fontSize: 16,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const CustomText(
              text: 'Cancel',
              color: Colors.white70,
              fontSize: 16,
            ),
          ),
          TextButton(
            onPressed: () async {
              await CompletionService.clearAll();
              NotificationsService.cancelNotificationById(60);
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: primaryColor,
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
          ? const Center(child: CircularProgressIndicator())
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
  final CompletionItem item;
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
          color: item.isRead
              ? Colors.green.withOpacity(0.2)
              : Colors.white.withOpacity(0.1),
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
                color: item.isRead
                    ? Colors.green.withOpacity(0.3)
                    : bColor.withOpacity(0.2),
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(16),
                ),
              ),
              child: Row(
                children: [
                  CustomText(
                    text: 'Day ${item.dayIndex + 1}',
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
                    onPressed: item.isRead ? null : onMarkAsRead,
                    icon: Icon(
                      item.isRead
                          ? Icons.check_circle
                          : Icons.check_circle_outline,
                      size: 20,
                    ),
                    color: item.isRead ? Colors.green : Colors.white70,
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
                      color: Colors.white,
                      fontSize: 18,
                      fontFamily: "new",
                      fontWeight: FontWeight.bold,
                      textAlign: TextAlign.center,
                    ),
                  ),
                  const Icon(
                    Icons.arrow_forward,
                    color: Colors.white70,
                    size: 20,
                  ),
                  Expanded(
                    child: CustomText(
                      text: getSurahNameArabicFull(
                          getPageData(item.endPage)[0]["surah"]),
                      color: Colors.white,
                      fontFamily: "new",
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
