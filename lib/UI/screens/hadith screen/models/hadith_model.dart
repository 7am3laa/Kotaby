class HadithResult {
  final String hadithText;
  final String narrator;
  final String scholar;
  final String source;
  final String authenticity;

  HadithResult({
    required this.hadithText,
    required this.narrator,
    required this.scholar,
    required this.source,
    required this.authenticity,
  });
}

class HadithResponse {
  final List<HadithResult> ahadith;

  HadithResponse({required this.ahadith});
}
