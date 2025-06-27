import 'package:flutter/material.dart';
import 'package:kotaby/UI/screens/tafsir%20screen/tafsir_text_screen.dart';
import 'package:kotaby/constants/constants.dart';
import 'package:kotaby/constants/e3rab.dart';
import 'package:kotaby/core/functions/navigate.dart';
import 'package:kotaby/core/functions/to_arabic_number.dart';
import 'package:kotaby/core/models/tafseer_author.dart';
import 'package:kotaby/core/services/tafseer_api.dart';
import 'package:kotaby/core/ui_components/custom_text.dart';
import 'package:kotaby/storage.dart';
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
  List<String> ayatEN = [];
  List<TafseerAuthor> tafseerList = [];
  List<int> selectedTafsirIndices = [];
  List<int> selectedTafsirIndicesEn = [];

  bool isLoading = true;
  bool isReload = false;

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
      //    loadAyatEN(),
    ]);
    if (mounted) {
      setState(() {
        isLoading = false;
      });
    }
  }

  Future<void> loadAyatEN() async {
    List<String> laodAyatEn = [];
    for (int i = 1; i <= getVerseCount(widget.suranumber); i++) {
      final verse = getVerseTranslation(widget.suranumber, i);
      laodAyatEn.add("$verse ${i.toArabicNumbers}");
    }
    if (mounted) {
      setState(() {
        ayatEN = laodAyatEn;
        selectedTafsirIndicesEn = List.generate(laodAyatEn.length, (_) => 0);
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

  Future<void> relaodTafsirName() async {
    setState(() {
      isReload = true;
    });
    await loadTafsirName();
    setState(() {
      isReload = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    bool isWidth = MediaQuery.of(context).size.width > 500;

    if (isLoading) {
      return Scaffold(
        backgroundColor: Storage.themeState == 1 ? primaryColor : Colors.white,
        body: const Center(
          child: CircularProgressIndicator(color: bColor),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Storage.themeState == 1 ? primaryColor : Colors.white,
        elevation: 9,
        automaticallyImplyLeading: false,
        leading: IconButton(
          onPressed: () {
            N.pop(context: context);
          },
          icon: Icon(Icons.arrow_back_ios,
              color: Storage.themeState == 1 ? Colors.white : Colors.black),
        ),
        title: Text(
          "000 ${widget.suranumber <= 9 ? "00${widget.suranumber}" : widget.suranumber <= 99 ? "0${widget.suranumber}" : widget.suranumber}",
          style: TextStyle(
            color: Storage.themeState == 1 ? Colors.white : bColor,
            fontFamily: "SurahName",
            fontSize: 45,
            fontWeight: FontWeight.w500,
          ),
          textAlign: TextAlign.right,
          textDirection: TextDirection.rtl,
        ),
        centerTitle: true,
      ),
      backgroundColor: Storage.themeState == 1 ? primaryColor : Colors.white,
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
            color: Storage.themeState == 1 ? Colors.white30 : Colors.white,
            margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            child: Padding(
              padding: const EdgeInsets.all(12.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    aya,
                    style: TextStyle(
                      color: Storage.themeState == 1 ? Colors.white : bColor,
                      fontWeight: FontWeight.w500,
                      fontFamily: "Hafs",
                      fontSize: isWidth ? 20 : 30,
                    ),
                    textAlign: TextAlign.right,
                    textDirection: TextDirection.rtl,
                  ),
                  // Text(
                  //   ayatEN[index],
                  //   style: TextStyle(
                  //     color: Colors.white,
                  //     fontWeight: FontWeight.w500,
                  //     fontFamily: "Hafs",
                  //     fontSize: isWidth ? 20 : 30,
                  //   ),
                  //   textAlign: TextAlign.right,
                  //   textDirection: TextDirection.rtl,
                  // ),
                  const SizedBox(height: 12),
                  tafseerList.isNotEmpty
                      ? Row(
                          children: [
                            Expanded(
                              child: Container(
                                padding:
                                    const EdgeInsets.symmetric(horizontal: 12),
                                decoration: BoxDecoration(
                                  color: Storage.themeState == 1
                                      ? primaryColor
                                      : bColor,
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: DropdownButton<int>(
                                  value: selectedIndex,
                                  isExpanded: true,
                                  dropdownColor: Storage.themeState == 1
                                      ? Colors.black87
                                      : bColor,
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
                                      color: bColor,
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
                                    icon: Icon(
                                      Icons.menu_book,
                                      color: Storage.themeState == 1
                                          ? Colors.white
                                          : bColor,
                                    ),
                                  ),
                          ],
                        )
                      : ListTile(
                          leading: IconButton(
                            onPressed: () {
                              relaodTafsirName();
                            },
                            icon: isReload
                                ? CircularProgressIndicator(
                                    color: bColor,
                                  )
                                : Icon(Icons.replay_outlined),
                          ),
                          title: CustomText(
                            text: "للتفسير اتصل بالانترنت",
                            color:
                                Storage.themeState == 1 ? primaryColor : bColor,
                            textAlign: TextAlign.right,
                          ),
                        ),
                  const SizedBox(height: 12),
                  Card(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15),
                    ),
                    color: Storage.themeState == 1 ? primaryColor : bColor,
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
