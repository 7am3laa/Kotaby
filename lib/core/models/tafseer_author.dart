

class TafseerAuthor {
  final int id;
  final String name;
  final String language;
  final String author;
  final String bookName;

  TafseerAuthor({
    required this.id,
    required this.name,
    required this.language,
    required this.author,
    required this.bookName,
  });

  TafseerAuthor copyWith({
    int? id,
    String? name,
    String? language,
    String? author,
    String? bookName,
  }) =>
      TafseerAuthor(
        id: id ?? this.id,
        name: name ?? this.name,
        language: language ?? this.language,
        author: author ?? this.author,
        bookName: bookName ?? this.bookName,
      );



  factory TafseerAuthor.fromJson(Map<String, dynamic> json) => TafseerAuthor(
        id: json["id"] ?? 0,
        name: json["name"] ?? "Unknown",
        language: json["language"] ?? "Unknown",
        author: json["author"] ?? "Unknown",
        bookName: json["book_name"] ?? "Unknown",
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "name": name,
        "language": language,
        "author": author,
        "book_name": bookName,
      };
}
