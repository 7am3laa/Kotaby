class CompletionItem {
  final int startPage;
  final int endPage;
  final int dayIndex;
  final bool isRead;

  CompletionItem({
    required this.startPage,
    required this.endPage,
    required this.dayIndex,
    this.isRead = false,
  });

  factory CompletionItem.fromPages(int startPage, int endPage, int dayIndex) {
    return CompletionItem(
      startPage: startPage,
      endPage: endPage,
      dayIndex: dayIndex,
    );
  }

  int get pageCount => endPage - startPage + 1;
}
