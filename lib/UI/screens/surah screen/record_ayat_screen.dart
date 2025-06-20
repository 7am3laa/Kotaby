import 'dart:io';
import 'package:flutter/material.dart';
import 'package:kotaby/constants/constants.dart';
import 'package:kotaby/core/services/quran_data_service.dart';
import 'package:kotaby/core/services/uplaod_record_service.dart';
import 'package:kotaby/core/ui_components/custom_app_bar.dart';
import 'package:kotaby/core/ui_components/custom_text.dart';
import 'package:kotaby/main.dart';
import 'package:kotaby/storage.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;
import 'package:quran/quran.dart';
import 'package:record/record.dart';

String _toArabicNumerals(int number) {
  const arabicNumerals = ['٠', '١', '٢', '٣', '٤', '٥', '٦', '٧', '٨', '٩'];
  return number.toString().split('').map((digit) {
    return arabicNumerals[int.parse(digit)];
  }).join('');
}

class RecordAyatScreen extends StatefulWidget {
  final String ayaText;
  final String fontFamily;
  final int surah;
  final int verse;
  final int pageNumber;

  const RecordAyatScreen({
    super.key,
    required this.ayaText,
    required this.fontFamily,
    required this.surah,
    required this.verse,
    required this.pageNumber,
  });

  @override
  State<RecordAyatScreen> createState() => _RecordAyatScreenState();
}

class _RecordAyatScreenState extends State<RecordAyatScreen> {
  final QuranDataService quranDataService = QuranDataService();
  final AudioRecorder recorder = AudioRecorder();
  bool isRecording = false;
  bool isPlaying = false;
  bool isProcessing = false;
  String? recordingPath;
  Color color = Colors.white;
  String processed = "";
  List<bool>? characterMatches; // To track which characters match
  bool isTashkeelErrorOnly = false;
  Map<String, List<bool>>? ayatMatches; // Store matches for each aya
  int totalWordsToMatch = 0;
  List<String> transcribedWords = [];
  static const String tashkeelPattern = r'[\u064B-\u065F\u0670\u06D6-\u06ED]';

  late Future<List<dynamic>?> _pageVersesFuture;

  @override
  void initState() {
    super.initState();
    // Initialize the future once
    _pageVersesFuture =
        quranDataService.getPage(pageNumber: widget.pageNumber.toString());
  }

  Future<void> _startRecording() async {
    if (await recorder.hasPermission()) {
      Directory? dir = await getExternalStorageDirectory();
      if (dir != null) {
        String folderPath = p.join(dir.path, 'records');
        await Directory(folderPath).create(recursive: true);
        String filePath =
            p.join(folderPath, '${widget.surah}_${widget.verse}.wav');

        await recorder.start(
          const RecordConfig(),
          path: filePath,
        );
        recordingPath = null;
        characterMatches = null;
        isTashkeelErrorOnly = false;
      }
    }
  }

  Future<void> _stopRecording() async {
    String? filePath = await recorder.stop();
    if (filePath != null) {
      recordingPath = filePath;
    }
  }

  // Helper function to remove tashkeel
  String _removeTashkeel(String text) {
    return text.replaceAll(RegExp(r'[\u064B-\u065F\u0670]'), '');
  }

  Map<String, dynamic> _compareTranscriptionWithAyat(
    List<dynamic> pageVerses,
    String transcribedText,
  ) {
    // Split transcribed text into words
    transcribedWords =
        transcribedText.split(' ').where((w) => w.isNotEmpty).toList();
    totalWordsToMatch = transcribedWords.length;

    // Find verses from the current surah starting from the target verse
    List<Map<String, dynamic>> relevantVerses = [];
    bool foundStartVerse = false;

    for (var verse in pageVerses) {
      if (verse['soraId'] == widget.surah) {
        if (verse['ayaOrder'] == widget.verse) {
          foundStartVerse = true;
        }
        if (foundStartVerse) {
          relevantVerses.add(verse);
        }
      }
    }

    // Collect words from ayat until we have enough to match transcription
    List<String> correctWords = [];
    Map<String, List<String>> ayaWordsMap = {};
    Map<String, List<bool>> matchResults = {};

    int wordsCollected = 0;
    for (var verse in relevantVerses) {
      List<String> verseWords = List<String>.from(verse['words']);
      String ayaKey = '${verse['soraId']}_${verse['ayaOrder']}';
      ayaWordsMap[ayaKey] = verseWords;

      // Add words from this aya until we have enough
      for (String word in verseWords) {
        if (wordsCollected < totalWordsToMatch) {
          correctWords.add(word);
          wordsCollected++;
        } else {
          break;
        }
      }

      if (wordsCollected >= totalWordsToMatch) break;
    }

    // Now compare word by word
    List<bool> overallMatches = [];
    bool hasNonTashkeelError = false;
    bool hasTashkeelError = false;

    for (int i = 0;
        i < transcribedWords.length && i < correctWords.length;
        i++) {
      String userWord = transcribedWords[i].trim();
      String correctWord = correctWords[i].trim();

      if (_compareWords(userWord, correctWord)) {
        overallMatches.add(true);
      } else {
        // More detailed analysis
        String userNoTashkeel = _removeTashkeel(_normalizeWord(userWord));
        String correctNoTashkeel = _removeTashkeel(_normalizeWord(correctWord));

        if (userNoTashkeel == correctNoTashkeel) {
          // Only tashkeel difference
          hasTashkeelError = true;
        } else {
          // Structural difference
          hasNonTashkeelError = true;
        }

        overallMatches.add(false);
      }
    }

    // Distribute matches back to individual ayat
    int matchIndex = 0;
    for (var ayaKey in ayaWordsMap.keys) {
      List<bool> ayaMatches = [];
      int wordsInThisAya = ayaWordsMap[ayaKey]!.length;

      for (int i = 0;
          i < wordsInThisAya && matchIndex < overallMatches.length;
          i++) {
        ayaMatches.add(overallMatches[matchIndex]);
        matchIndex++;
      }

      matchResults[ayaKey] = ayaMatches;
    }

    return {
      'matches': matchResults,
      'hasTashkeelError': hasTashkeelError && !hasNonTashkeelError,
      'hasNonTashkeelError': hasNonTashkeelError,
    };
  }

  Future<void> _uploadAndCompare() async {
    if (recordingPath == null) return;

    setState(() {
      isProcessing = true;
      ayatMatches = null;
      isTashkeelErrorOnly = false;
    });

    try {
      final response = await UplaodRecordService().uploadAudio(recordingPath!);
      final userText = response.transcription;

      setState(() {
        processed = userText;
      });

      // Get page verses
      final pageVerses = await quranDataService.getPage(
          pageNumber: widget.pageNumber.toString());

      if (pageVerses != null) {
        final comparisonResult =
            _compareTranscriptionWithAyat(pageVerses, userText);

        setState(() {
          ayatMatches = comparisonResult['matches'];
          isTashkeelErrorOnly = comparisonResult['hasTashkeelError'];

          if (comparisonResult['hasNonTashkeelError']) {
            color = Colors.red;
          } else if (comparisonResult['hasTashkeelError']) {
            color = Colors.orange;
          } else {
            color = Colors.green;
          }
        });
      }
    } catch (e) {
      print("Upload error: $e");
    } finally {
      setState(() {
        isProcessing = false;
      });
    }
  }

  List<Color> _getCharacterColors(String userWord, String correctWord) {
    List<Color> colors = [];

    // Parse both words into base characters with their tashkeel
    List<String> correctUnits = _parseIntoCharacterUnits(correctWord);
    List<String> userUnits = _parseIntoCharacterUnits(userWord);

    // Compare unit by unit
    int maxLength = correctUnits.length;

    for (int i = 0; i < maxLength; i++) {
      if (i < correctUnits.length) {
        String correctUnit = correctUnits[i];
        String userUnit = i < userUnits.length ? userUnits[i] : '';

        // Add colors for each character in the correct unit
        for (int j = 0; j < correctUnit.length; j++) {
          if (correctUnit == userUnit) {
            // Perfect match (including tashkeel)
            colors.add(Colors.green);
          } else if (_getBaseCharacter(correctUnit) ==
              _getBaseCharacter(userUnit)) {
            // Base character matches, check tashkeel
            if (j == 0) {
              colors.add(Colors.green); // Base character is correct
            } else if (_removeTashkeel(correctUnit) ==
                _removeTashkeel(userUnit)) {
              colors.add(Colors.orange); // Missing/wrong tashkeel
            } else {
              colors.add(Colors.orange); // Tashkeel difference
            }
          } else {
            // Base character is wrong
            colors.add(Colors.red);
          }
        }
      }
    }

    return colors;
  }

  List<TextSpan> _buildHighlightedWords(
    List<String> words,
    List<bool>? matches,
    bool isTargetVerse,
  ) {
    if (matches == null || matches.isEmpty || words.isEmpty) {
      return [
        for (int i = 0; i < words.length; i++) ...[
          TextSpan(
            text: words[i],
            style: TextStyle(
              color:
                  isTargetVerse ? Colors.yellow.withOpacity(0.7) : Colors.white,
              fontFamily: "MeQuran",
            ),
          ),
          if (i < words.length - 1) TextSpan(text: ' '),
        ]
      ];
    }

    List<TextSpan> spans = [];

    for (int i = 0; i < words.length; i++) {
      if (i < matches.length && matches[i] != null) {
        if (matches[i]) {
          // Perfect match
          spans.add(TextSpan(
            text: words[i],
            style: TextStyle(
              color: Colors.green,
              fontFamily: "MeQuran",
              fontWeight: FontWeight.bold,
            ),
          ));
        } else {
          // Character-by-character coloring
          String userWord =
              i < transcribedWords.length ? transcribedWords[i] : '';
          String correctWord = words[i];

          // Only do detailed comparison if we have user input
          if (userWord.isNotEmpty) {
            List<Color> charColors = _getCharacterColors(userWord, correctWord);

            for (int j = 0; j < correctWord.length; j++) {
              Color charColor =
                  j < charColors.length ? charColors[j] : Colors.red;
              spans.add(TextSpan(
                text: correctWord[j],
                style: TextStyle(
                  color: charColor,
                  backgroundColor: charColor != Colors.green
                      ? charColor.withOpacity(0.3)
                      : null,
                  fontFamily: "MeQuran",
                  fontWeight: charColor == Colors.red
                      ? FontWeight.bold
                      : FontWeight.normal,
                ),
              ));
            }
          } else {
            // No user input for this word
            spans.add(TextSpan(
              text: words[i],
              style: TextStyle(
                color: Colors.grey,
                fontFamily: "MeQuran",
              ),
            ));
          }
        }
      } else {
        // No match data
        spans.add(TextSpan(
          text: words[i],
          style: TextStyle(
            color:
                isTargetVerse ? Colors.yellow.withOpacity(0.7) : Colors.white,
            fontFamily: "MeQuran",
          ),
        ));
      }

      if (i < words.length - 1) {
        spans.add(TextSpan(text: ' '));
      }
    }

    return spans;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: primaryColor,
      appBar: CustomAppBar(title: "تسميع الصفحة"),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (recordingPath == null)
              const Text("No recording Found",
                  style: TextStyle(color: Colors.white)),

            // FutureBuilder for the page verses
            Expanded(
              child: FutureBuilder<List<dynamic>?>(
                future: _pageVersesFuture,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(
                      child: CircularProgressIndicator(color: Colors.white),
                    );
                  }

                  if (snapshot.hasError) {
                    return Center(
                      child: Text(
                        "Error loading verses: ${snapshot.error}",
                        style: TextStyle(color: Colors.white),
                      ),
                    );
                  }

                  if (!snapshot.hasData || snapshot.data!.isEmpty) {
                    return const Center(
                      child: Text("No verses found",
                          style: TextStyle(color: Colors.white)),
                    );
                  }

                  final pageVerses = snapshot.data!;

                  return SingleChildScrollView(
                    padding: const EdgeInsets.all(16),
                    child: Directionality(
                      textDirection: TextDirection.rtl,
                      child: RichText(
                        text: TextSpan(
                          style: TextStyle(
                            fontFamily: widget.fontFamily,
                            fontSize: 28,
                            color: Colors.white,
                            height: 2.0,
                          ),
                          children: [
                            for (var verse in pageVerses) ...[
                              if (verse['soraId'] == widget.surah) ...[
                                TextSpan(
                                  children: _buildHighlightedWords(
                                    List<String>.from(verse['words']),
                                    ayatMatches?[
                                        '${verse['soraId']}_${verse['ayaOrder']}'],
                                    true,
                                  ),
                                ),
                                TextSpan(
                                  text:
                                      ' \u06DD${_toArabicNumerals(verse['ayaOrder'])} ',
                                  style: TextStyle(
                                    fontSize: 24,
                                  ),
                                ),
                              ]
                            ],
                          ],
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),

            if (processed.isNotEmpty)
              Padding(
                padding: const EdgeInsets.all(16),
                child: Text(
                  processed,
                  style: TextStyle(
                    fontFamily: "Hafs",
                    fontSize: 24,
                    color: color,
                  ),
                  textAlign: TextAlign.right,
                  textDirection: TextDirection.rtl,
                ),
              ),

            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ElevatedButton(
                  onPressed: () {
                    if (audioHandler.playbackState.value.playing) {
                      audioHandler.stop();
                      setState(() {
                        isPlaying = false;
                      });
                    } else if (recordingPath != null) {
                      setState(() {
                        isPlaying = true;
                      });
                    }
                  },
                  child: Icon(isPlaying ? Icons.pause : Icons.play_arrow),
                ),
                const SizedBox(width: 20),
                StatefulBuilder(builder: (context, setRecordState) {
                  return ElevatedButton(
                    onPressed: () async {
                      if (isRecording) {
                        setRecordState(() {
                          isRecording = false;
                        });
                        await _stopRecording();
                      } else {
                        setRecordState(() {
                          isRecording = true;
                        });
                        await _startRecording();
                      }
                    },
                    child: Icon(isRecording ? Icons.stop : Icons.mic),
                  );
                }),
              ],
            ),
            const SizedBox(height: 12),
            ElevatedButton(
              onPressed: isProcessing ? null : _uploadAndCompare,
              child: isProcessing
                  ? const CircularProgressIndicator(color: Colors.white)
                  : const Text("🎧 إرسال"),
            ),
          ],
        ),
      ),
    );
  }
}

// Add this improved word comparison method
bool _compareWords(String userWord, String correctWord) {
  // Direct match
  if (userWord == correctWord) return true;

  // Normalize both words and compare
  String normalizedUser = _normalizeWord(userWord);
  String normalizedCorrect = _normalizeWord(correctWord);

  return normalizedUser == normalizedCorrect;
}

String _normalizeWord(String word) {
  String normalized = '';
  for (int i = 0; i < word.length; i++) {
    String char = word[i];
    if (!RegExp(r'[\u064B-\u065F]').hasMatch(char)) {
      normalized += _normalizeArabicChar(char);
    }
  }
  return normalized;
}

List<String> _parseIntoCharacterUnits(String text) {
  List<String> units = [];
  final tashkeelRegex = RegExp(r'[\u064B-\u065F\u0670\u06D6-\u06ED]');

  for (int i = 0; i < text.length; i++) {
    String char = text[i];

    // Skip if it's a tashkeel mark (already processed with previous base char)
    if (tashkeelRegex.hasMatch(char)) {
      continue;
    }

    // Base character - collect it with following tashkeel
    String unit = char;
    int j = i + 1;

    // Collect all tashkeel marks that follow this base character
    while (j < text.length && RegExp(r'[\u064B-\u065F]').hasMatch(text[j])) {
      unit += text[j];
      j++;
    }

    units.add(unit);
    i = j - 1; // Skip the tashkeel we just processed
  }

  return units;
}

String _getBaseCharacter(String characterUnit) {
  if (characterUnit.isEmpty) return '';
  return characterUnit[0]; // First character is always the base
}

String _normalizeArabicChar(String char) {
  return char
      // Remove all diacritics including Alif Khanjariyah
      .replaceAll(RegExp(r'[\u064B-\u065F\u0670\u06D6-\u06ED]'), '')
      // Normalize different forms of Alif
      .replaceAll('\u0622', '\u0627') // آ -> ا
      .replaceAll('\u0623', '\u0627') // أ -> ا
      .replaceAll('\u0625', '\u0627') // إ -> ا
      // Normalize other characters
      .replaceAll('\u0624', '\u0648') // ؤ -> و
      .replaceAll('\u0626', '\u064A') // ئ -> ي
      .replaceAll('\u0629', '\u0647') // ة -> ه
      .replaceAll('\u0649', '\u064A') // ى -> ي
      // Remove extra spaces
      .replaceAll(RegExp(r'\s+'), ' ')
      .trim();
}
