import 'package:flutter/material.dart';
import 'package:kotaby/UI/screens/tafsir%20screen/tafsir_text_screen.dart';
import 'package:kotaby/constants/constants.dart';
import 'package:kotaby/constants/e3rab.dart';
import 'package:kotaby/core/functions/navigate.dart';
import 'package:kotaby/core/functions/to_arabic_number.dart';
import 'package:kotaby/core/models/tafseer_author.dart';
import 'package:kotaby/core/services/tafseer_api.dart';
import 'package:quran/quran.dart';

class TafsirScreen extends StatefulWidget {
  final int suranumber;

  const TafsirScreen({
    super.key,
    required this.suranumber,
  });

  @override
  State<TafsirScreen> createState() => _TafsirScreenState();
}

class _TafsirScreenState extends State<TafsirScreen> {
  List<String> ayat = [];
  List<TafseerAuthor> tafseerList = [];
  List<int> selectedTafsirIndices = [];
  bool isLoading = true;

  ApiServices apiServices = ApiServices();
  Set<int> loadingIndices = {};

  @override
  void initState() {
    super.initState();
    _initializeData();
  }

  Future<void> _initializeData() async {
    await Future.wait([
      loadAyat(),
      loadTafsirName(),
    ]);
    if (mounted) {
      setState(() {
        isLoading = false;
      });
    }
  }

  Future<void> loadAyat() async {
    List<String> loadedAyat = [];
    for (int i = 1; i <= getVerseCount(widget.suranumber); i++) {
      final verse = getVerse(widget.suranumber, i);
      loadedAyat.add("$verse ${i.toArabicNumbers}");
    }
    if (mounted) {
      setState(() {
        ayat = loadedAyat;
        selectedTafsirIndices = List.generate(loadedAyat.length, (_) => 0);
      });
    }
  }

  Future<void> loadTafsirName() async {
    final list = await apiServices.getTafseerList();
    if (mounted) {
      setState(() {
        tafseerList = list;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    bool isWidth = MediaQuery.of(context).size.width > 500;

    if (isLoading) {
      return Scaffold(
        backgroundColor: primaryColor,
        body: const Center(
          child: CircularProgressIndicator(color: Colors.white),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        backgroundColor: primaryColor,
        elevation: 9,
        automaticallyImplyLeading: false,
        leading: IconButton(
          onPressed: () {
            N.pop(context: context);
          },
          icon: const Icon(Icons.arrow_back_ios, color: Colors.white),
        ),
        title: Text(
          "000 ${widget.suranumber <= 9 ? "00${widget.suranumber}" : widget.suranumber <= 99 ? "0${widget.suranumber}" : widget.suranumber}",
          style: const TextStyle(
            color: Colors.white,
            fontFamily: "SurahName",
            fontSize: 45,
            fontWeight: FontWeight.w500,
          ),
          textAlign: TextAlign.right,
          textDirection: TextDirection.rtl,
        ),
        centerTitle: true,
      ),
      backgroundColor: primaryColor,
      body: ListView.builder(
        padding: const EdgeInsets.symmetric(vertical: 12),
        itemCount: ayat.length,
        itemBuilder: (context, index) {
          final aya = ayat[index];
          final selectedIndex = selectedTafsirIndices[index];

          return Card(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(15),
            ),
            elevation: 4,
            shadowColor: Colors.black54,
            color: Colors.white30,
            margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            child: Padding(
              padding: const EdgeInsets.all(12.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    aya,
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w500,
                      fontFamily: "Hafs",
                      fontSize: isWidth ? 20 : 30,
                    ),
                    textAlign: TextAlign.right,
                    textDirection: TextDirection.rtl,
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12),
                          decoration: BoxDecoration(
                            color: Colors.black87,
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: DropdownButton<int>(
                            value: selectedIndex,
                            isExpanded: true,
                            dropdownColor: Colors.black87,
                            iconEnabledColor: Colors.white,
                            underline: const SizedBox(),
                            items: List.generate(tafseerList.length, (i) {
                              return DropdownMenuItem<int>(
                                value: i,
                                child: Text(
                                  tafseerList[i].name,
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.w500,
                                    fontSize: isWidth ? 15 : 22,
                                  ),
                                  textAlign: TextAlign.right,
                                  textDirection: TextDirection.rtl,
                                ),
                              );
                            }),
                            onChanged: (value) {
                              if (value != null) {
                                setState(() {
                                  selectedTafsirIndices[index] = value;
                                });
                              }
                            },
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),

                      loadingIndices.contains(index)
                          ? const SizedBox(
                              width: 30,
                              height: 30,
                              child: CircularProgressIndicator(
                                color: Colors.white,
                                strokeWidth: 2,
                              ),
                            )
                          : IconButton(
                              onPressed: () async {
                                setState(() {
                                  loadingIndices.add(index);
                                });

                                try {
                                  final tafsirAya =
                                      await apiServices.getTafseerText(
                                    tafseerList[selectedIndex].id,
                                    widget.suranumber,
                                    index + 1,
                                  );

                                  if (mounted) {
                                    N.pushto(
                                      context: context,
                                      screen: TafsirTextScreen(
                                        ayaNumber: index + 1,
                                        surahName: getSurahNameArabic(
                                            widget.suranumber),
                                        tafsirAya: tafsirAya,
                                        isE3rab: false,
                                      ),
                                    );
                                  }
                                } finally {
                                  if (mounted) {
                                    setState(() {
                                      loadingIndices.remove(index);
                                    });
                                  }
                                }
                              },
                              icon: const Icon(Icons.menu_book,
                                  color: Colors.white),
                            ),
                    ],
                  ),
                  const SizedBox(height: 12),

                  Card(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15),
                    ),
                    color: Colors.black,
                    child: ListTile(
                      title: Center(
                        child: Text(
                          "الاعراب",
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w500,
                            fontSize: 25,
                          ),
                        ),
                      ),
                      onTap: () {
                        N.pushto(
                          context: context,
                          screen: TafsirTextScreen(
                            ayaNumber: index + 1,
                            surahName: getSurahNameArabic(widget.suranumber),
                            tafsirAya: getE3rab(
                              surahNumber: widget.suranumber,
                              ayaNumber: index + 1,
                            ),
                            isE3rab: true,
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
