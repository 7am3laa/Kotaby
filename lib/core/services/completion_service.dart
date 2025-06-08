import 'package:kotaby/core/models/completion_model.dart';
import 'package:kotaby/storage.dart';

class CompletionService {
  static Future<List<CompletionItem>> getCompletionItems() async {
    final list = Storage.completionList;
    List<CompletionItem> items = [];

    for (int i = 0; i < list.length; i++) {
      int startPage = list[i];
      int endPage = (i + 1 < list.length) ? list[i + 1] - 1 : 604;
      bool isRead = Storage.readPages.contains(startPage);

      items.add(CompletionItem(
        startPage: startPage,
        endPage: endPage,
        dayIndex: i,
        isRead: isRead,
      ));
    }

    return items;
  }

  static Future<void> markAsRead(CompletionItem item) async {
    if (item.isRead) return;

    List<int> newReadPages = List.from(Storage.readPages);
    newReadPages.add(item.startPage);
    await Storage.saveReadPages(newReadPages);

    final currentPage = Storage.completionPageForPercentage + item.pageCount;
    await Storage.saveCompletionPercentage(currentPage);
  }

  static Future<void> clearAll() async {
    await Storage.clearAllCompletion();
  }

  static double getProgress(int dayIndex) {
    return (dayIndex + 1) / Storage.completionDays;
  }
}
