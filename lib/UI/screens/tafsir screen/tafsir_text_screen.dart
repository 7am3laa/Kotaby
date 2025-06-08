import 'package:flutter/material.dart';
import 'package:kotaby/constants/constants.dart';
import 'package:kotaby/core/ui_components/custom_app_bar.dart';
import 'package:kotaby/core/ui_components/custom_text.dart';

class TafsirTextScreen extends StatelessWidget {
  final int ayaNumber;
  final String surahName;
  final String tafsirAya;
  final bool isE3rab;
  const TafsirTextScreen({
    super.key,
    required this.tafsirAya,
    required this.ayaNumber,
    required this.surahName,
    required this.isE3rab,
  });
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: primaryColor,
      appBar: CustomAppBar(
        title: !isE3rab
            ? "تفسير الآية $ayaNumber - $surahName"
            : "اعراب الآية $ayaNumber - $surahName",
      ),
      body: Directionality(
        textDirection: TextDirection.rtl,
        child: SingleChildScrollView(
          child: Padding(
            padding:
                const EdgeInsets.symmetric(horizontal: 16.0, vertical: 20.0),
            child: Align(
              alignment: Alignment.centerRight,
              child: CustomText(
                text: tafsirAya
                    .replaceAll(";", "")
                    .replaceAll(".", "")
                    .replaceAll("<", "")
                    .replaceAll(">", "")
                    .replaceAll("p", "")
                    .replaceAll("  ", " ")
                    .replaceAll("/", "\n\n"),
                fontSize: 22,
                color: Colors.white,
                textAlign: TextAlign.right,
                textDirection: TextDirection.rtl,
                // fontFamily: "new",
              ),
            ),
          ),
        ),
      ),
    );
  }
}
