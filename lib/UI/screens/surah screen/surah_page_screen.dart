import 'dart:async';
import 'dart:ui';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:kotaby/UI/screens/surah%20screen/cubit/surah_page_cubit/surah_page_cubit.dart';
import 'package:kotaby/UI/screens/surah%20screen/record_ayat_screen.dart';
import 'package:kotaby/core/functions/navigate.dart';
import 'package:kotaby/core/ui_components/basmallah.dart';
import 'package:kotaby/core/ui_components/custom_text.dart';
import 'package:kotaby/core/ui_components/header_widget.dart';
import 'package:kotaby/storage.dart';
import 'package:quran/quran.dart';
import 'package:quran/reciters.dart';
import 'package:quran/surah_data.dart';

class SurahPageScreen extends StatelessWidget {
  final int pageNumber;
  final bool shouldHighlightText;
  final String highlightVerse;
  final int? lastp;

  const SurahPageScreen({
    super.key,
    required this.pageNumber,
    required this.shouldHighlightText,
    required this.highlightVerse,
    this.lastp,
  });

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => SurahPageCubit(
        initialPage: pageNumber,
        initialHighlight: shouldHighlightText,
        initialVerse: highlightVerse,
        initLastPage: lastp ?? totalPagesCount + 1,
      ),
      child: _SurahPageContent(
        shouldHighlightText,
        highlightVerse,
        lastp,
      ),
    );
  }
}

class _SurahPageContent extends StatefulWidget {
  final bool shouldHighlight;
  final String verse;
  final int? lastp;
  const _SurahPageContent(
    this.shouldHighlight,
    this.verse,
    this.lastp,
  );

  @override
  State<_SurahPageContent> createState() => _SurahPageContentState();
}

class _SurahPageContentState extends State<_SurahPageContent> {
  Color color = const Color(0xffFAF1E2);
  Color textColor = Colors.black;
  bool isH = false;
  String se = "";
  Timer? highlightTimer;

  void changColor() {
    if (Storage.colorid == 0) {
      setState(() {
        color = const Color(0xffFAF1E2);
        textColor = Colors.black;
      });
    }
    if (Storage.colorid == 1) {
      setState(() {
        color = Colors.black;
        textColor = Colors.white;
      });
    }
  }

  @override
  void initState() {
    startHighlightAnimation();
    changColor();
    super.initState();
  }

  startHighlightAnimation() {
    setState(() {
      isH = widget.shouldHighlight;
      se = widget.verse;
    });

    int toggleCount = 0;
    highlightTimer = Timer.periodic(const Duration(milliseconds: 400), (timer) {
      if (toggleCount < 5) {
        setState(() {
          isH = toggleCount % 2 == 0;
        });
        toggleCount++;
      } else {
        setState(() {
          isH = false;
          se = "";
        });

        timer.cancel();
      }
    });
  }

  @override
  void dispose() {
    highlightTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isWidth = MediaQuery.of(context).size.width >= 500;
    return BlocConsumer<SurahPageCubit, SurahPageState>(
      listener: (context, state) {
        if (state.errorMessage != null) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(state.errorMessage!)),
          );
        }
      },
      builder: (context, state) {
        return Scaffold(
          backgroundColor: color,
          body: PageView.builder(
            reverse: true,
            scrollBehavior: const MaterialScrollBehavior().copyWith(
              dragDevices: {
                PointerDeviceKind.mouse,
                PointerDeviceKind.touch,
                PointerDeviceKind.stylus,
                PointerDeviceKind.unknown
              },
            ),
            controller: state.pageController,
            onPageChanged: context.read<SurahPageCubit>().updatePage,
            itemCount: state.lastPage ?? totalPagesCount + 1,
            itemBuilder: (context, index) {
              if (index == 0) {
                return Basmallah(
                  index: 0,
                  isStart: true,
                  textColor: textColor,
                );
              }

              return CustomScrollView(
                slivers: [
                  _buildAppBar(index, context, isWidth),
                  SliverToBoxAdapter(
                    child: _buildVerseContent(index, state, context, isWidth),
                  ),
                ],
              );
            },
          ),
        );
      },
    );
  }

  SliverAppBar _buildAppBar(int index, BuildContext context, bool isWidth) {
    return SliverAppBar(
      floating: true,
      elevation: 1,
      backgroundColor: color,
      centerTitle: false,
      scrolledUnderElevation: 0,
      leading: Padding(
        padding: const EdgeInsets.only(left: 10.0),
        child: IconButton(
          icon: Icon(Icons.arrow_back_ios, size: 24, color: textColor),
          onPressed: () async {
            N.pop(context: context);
            await context.read<SurahPageCubit>().close();
          },
        ),
      ),
      actions: [
        Padding(
          padding: const EdgeInsets.only(right: 10.0),
          child: IconButton(
            icon: Icon(
              Storage.colorid == 1
                  ? Icons.light_mode_outlined
                  : Icons.dark_mode_outlined,
              size: isWidth ? 34 : 24,
              color: textColor,
            ),
            onPressed: () async {
              if (Storage.colorid == 0) {
                await Storage.saveColor(1);
                changColor();
              } else if (Storage.colorid == 1) {
                await Storage.saveColor(0);
                changColor();
              }
            },
          ),
        ),
      ],
      title: _buildPageIndicator(index, context, isWidth),
    );
  }

  Widget _buildPageIndicator(
    int index,
    BuildContext context,
    bool isWidth,
  ) {
    final int surahNumber = surah[getPageData(index)[0]['surah'] - 1]["id"];
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 15.w),
      decoration: BoxDecoration(
        color: const Color.fromARGB(255, 91, 62, 29),
        borderRadius: BorderRadius.circular(10),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(.1),
            blurRadius: 5,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Center(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            CustomText(
              text: surahNumber <= 9
                  ? "00$surahNumber"
                  : surahNumber <= 99
                      ? "0$surahNumber"
                      : "$surahNumber",
              fontFamily: "surahName",
              color: Colors.white,
              fontSize: isWidth ? 18 : 30,
              fontWeight: FontWeight.w500,
            ),
            CustomText(
              text: "الجزء ${getJuzNumberByPage(index)}",
              fontSize: isWidth ? 14 : 18,
              fontWeight: FontWeight.w500,
              color: Colors.white,
              fontFamily: "Hafs",
            ),
            CustomText(
              text: "${"صفحة"} $index",
              fontSize: isWidth ? 14 : 18,
              fontWeight: FontWeight.w500,
              color: Colors.white,
              fontFamily: "Hafs",
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildVerseContent(
      int index, SurahPageState state, BuildContext context, bool isWidth) {
    return Center(
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: isWidth ? 15 : 4.67),
        child: RichText(
          textAlign: TextAlign.center,
          textDirection: TextDirection.rtl,
          text: TextSpan(
            children: getPageData(index)
                .expand(
                    (e) => _buildVerseSpans(e, index, state, context, isWidth))
                .toList(),
          ),
        ),
      ),
    );
  }

  List<InlineSpan> _buildVerseSpans(Map<String, dynamic> e, int index,
      SurahPageState state, BuildContext context, bool isWidth) {
    final cubit = context.read<SurahPageCubit>();
    final spans = <InlineSpan>[];

    if (e["start"] == 1) {
      spans.add(WidgetSpan(
        child: HeaderWidget(e: e, textColor: textColor),
      ));
      if (index != 187 && index != 1) {
        spans.add(
          WidgetSpan(
            child: Basmallah(
              index: 0,
              textColor: textColor,
            ),
          ),
        );
      }
    }

    for (var i = e["start"]; i <= e["end"]; i++) {
      spans.add(_buildVerseSpan(e, i, index, state, cubit, context, isWidth));
    }
    return spans;
  }

  TextSpan _buildVerseSpan(
    Map<String, dynamic> e,
    int i,
    int index,
    SurahPageState state,
    SurahPageCubit cubit,
    BuildContext context,
    bool isWidth,
  ) {
    final currentVerse = "${e["surah"]}:$i";
    final isPlaying = cubit.state.selectedVerse == currentVerse;
    final isHighlighted = isPlaying;
    final verseText = i == e["start"]
        ? "${getVerseQCF(e["surah"], i).replaceAll(" ", "").substring(0, 1)}\u200A${getVerseQCF(e["surah"], i).replaceAll(" ", "").substring(1)}"
        : getVerseQCF(e["surah"], i).replaceAll(' ', '');

    return TextSpan(
      recognizer: LongPressGestureRecognizer()
        ..onLongPress = () {
          cubit.selectVerse(e["surah"], i);
          _showVerseOptions(context, e["surah"], i, index);
        },
      text: verseText,
      style: TextStyle(
        color: textColor,
        height: _calculateLineHeight(index, isWidth, context),
        wordSpacing: 0.w,
        letterSpacing: 0.w,
        fontFamily: "QCF_P${index.toString().padLeft(3, "0")}",
        fontWeight: FontWeight.w500,
        fontSize: _calculateFontSize(index, isWidth),
        backgroundColor: isHighlighted || (isH && se == currentVerse)
            ? Storage.colorid == 1
                ? const Color.fromARGB(255, 135, 81, 0)
                : const Color.fromARGB(255, 70, 45, 6).withOpacity(.3)
            : Colors.transparent,
      ),
    );
  }

  double _calculateLineHeight(int index, bool isWidth, BuildContext context) {
    if (index == 1 || index == 2) {
      return 2.h;
    } else if (isWidth) {
      return 1.4.h;
    } else if (index == 526 || index == 77) {
      return 1.85.h;
    } else {
      return MediaQuery.of(context).size.height / 400.h;
    }
  }

  double _calculateFontSize(int index, bool isWidth) {
    if (index == 1 || index == 2) {
      return isWidth ? 21.8.sp : 29.5.sp;
    } else if (index == 145 || index == 201) {
      return 22.4.sp;
    } else if (index == 0) {
      return 23.1.sp;
    } else if (index == 50 || index == 54 || index == 78 || index == 96) {
      return isWidth ? 18.9.sp : 23.9.sp;
    } else if (index == 526) {
      return isWidth ? 18.9.sp : 24.3.sp;
    } else if (index == 51) {
      return isWidth ? 18.9.sp : 24.2.sp;
    } else {
      return isWidth ? 18.9.sp : 23.9.sp;
    }
  }

  void _showVerseOptions(
    BuildContext context,
    int surah,
    int verse,
    int index,
  ) {
    final cubit = context.read<SurahPageCubit>();
    showModalBottomSheet(
      context: context,
      builder: (context) => Container(
        decoration: BoxDecoration(
          color: color,
          border: Border.all(color: textColor, width: 3),
          borderRadius: BorderRadius.only(
            bottomLeft: Radius.circular(30),
            bottomRight: Radius.circular(30),
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            SizedBox(height: 10.h),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _buildActionButton(
                    icon: Icons.play_arrow,
                    label: "تشغيل الآية",
                    onTap: () => cubit.playVerse(surah, verse, context),
                  ),
                  SizedBox(
                    width: 1.w,
                    child: VerticalDivider(
                      color: Colors.black,
                      thickness: 1,
                    ),
                  ),
                  _buildActionButton(
                    icon: Icons.playlist_play,
                    label: "تشغيل السورة",
                    onTap: () => cubit.playSurah(surah, verse, context),
                  ),
                  _buildActionButton(
                      icon: Icons.mic,
                      label: "تسميع السورة",
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => RecordAyatScreen(
                              surah: surah,
                              verse: verse,
                              ayaText: getVerseQCF(surah, verse),
                              fontFamily:
                                  "QCF_P${index.toString().padLeft(3, "0")}",
                            ),
                          ),
                        );
                      }),
                  _buildActionButton(
                    icon: Icons.content_copy,
                    label: "نسخ الآية",
                    onTap: () => cubit.copyVerse(surah, verse, context),
                  ),
                  _buildActionButton(
                    icon: Icons.bookmark_outline,
                    label: "حفظ",
                    onTap: () => cubit.bookMark(surah, verse, context),
                  ),
                ],
              ),
            ),
            SizedBox(height: 10.h),
            StatefulBuilder(
              builder: (context, setState) => Container(
                padding: EdgeInsets.symmetric(horizontal: 20.w),
                child: SizedBox(
                  width: MediaQuery.of(context).size.width,
                  child: PopupMenuButton<String>(
                    color: color,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    position: PopupMenuPosition.under,
                    child: Container(
                      padding: EdgeInsets.symmetric(
                          horizontal: 10.w, vertical: 10.h),
                      decoration: BoxDecoration(
                        border: Border.all(color: textColor),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Text(
                        Storage.reciterName,
                        style: TextStyle(color: textColor),
                        textAlign: TextAlign.right,
                        textDirection: TextDirection.rtl,
                      ),
                    ),
                    itemBuilder: (context) => reciters.map((reciter) {
                      return PopupMenuItem<String>(
                        value: reciter['identifier'],
                        child: Align(
                          alignment: Alignment.centerRight,
                          child: Text(
                            reciter['name'],
                            style: TextStyle(color: textColor),
                          ),
                        ),
                      );
                    }).toList(),
                    onSelected: (value) async {
                      final selectedReciter = reciters.firstWhere(
                        (reciter) => reciter['identifier'] == value,
                      );
                      await Storage.saveReciterInfo(
                        selectedReciter['name'],
                        value,
                      );
                      await Storage.loadReciterInfo();
                      setState(() {
                        Storage.reciterId = value;
                        Storage.reciterName = selectedReciter['name'];
                      });
                    },
                  ),
                ),
              ),
            ),
            SizedBox(height: 20.h),
          ],
        ),
      ),
    );
  }

  Widget _buildActionButton({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return Column(
      children: [
        Card(
          color: textColor,
          child: IconButton(
            onPressed: onTap,
            icon: Icon(icon),
            iconSize: 25.w,
            color: color,
          ),
        ),
        CustomText(
          text: label,
          fontSize: 13,
          color: textColor,
        ),
      ],
    );
  }
}
