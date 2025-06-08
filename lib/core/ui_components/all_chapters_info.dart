import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:kotaby/core/ui_components/custom_text.dart';
import 'package:quran/surah_data.dart';

class AllChaptersInfo extends StatelessWidget {
  final Function(int) onTap;
  const AllChaptersInfo({super.key, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      itemCount: surah.length,
      itemBuilder: (context, index) {
        return Card(
          color: const Color(0xff121931),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
          child: ListTile(
            leading: Image.asset(
              surah[index]["place"] == "Madinah"
                  ? "assets/images/madinah.png"
                  : "assets/images/makkah.png",
              width: 50.w,
              height: 45.h,
              fit: BoxFit.cover,
            ),
            trailing: CustomText(
              text: "${surah[index]['id']}",
              color: Colors.white,
            ),
            title: Align(
              alignment: Alignment.centerRight,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  CustomText(
                    text: "${surah[index]['name']}",
                    color: Colors.white,
                    fontSize: 17,
                  ),
                  CustomText(
                    text: "${surah[index]['arabic']}",
                    color: Colors.white,
                    fontFamily: "Hafs",
                  ),
                ],
              ),
            ),
            subtitle: Align(
              alignment: Alignment.centerRight,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  CustomText(
                    text: "عدد آياتها ${surah[index]['aya'].toString()}",
                    color: Colors.white.withOpacity(.6),
                    fontFamily: "Hafs",
                    fontSize: 14,
                  ),
                ],
              ),
            ),
            onTap: () => onTap(index),
          ),
        );
      },
    );
  }
}
