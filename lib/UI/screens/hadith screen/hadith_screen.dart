import 'package:flutter/material.dart';
import 'package:kotaby/constants/constants.dart';
import 'package:kotaby/core/ui_components/custom_app_bar.dart';
import 'package:kotaby/core/ui_components/custom_button.dart';
import 'package:kotaby/core/ui_components/custom_search_icon.dart';

class HadithScreen extends StatelessWidget {
  const HadithScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return  Scaffold(
        backgroundColor: primaryColor,
        appBar: CustomAppBar(
          title: "Hadith Classification",
          islead: false,
          actions: [
            CustomSearchIcon(
              onPressed: () => print("Search button hadith Screen pressed"),
            ),
          ],
        ),
        body: Padding(
          padding: const EdgeInsets.all(8.0),
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              spacing: 10,
              children: [
                SizedBox(height: 10),
                TextField(
                  maxLines: 10,
                  decoration: InputDecoration(
                    hintText: 'Enter hadith to classify',
                    filled: true,
                    fillColor: Colors.grey[200],
                    border: OutlineInputBorder(
                      borderSide: BorderSide(color: Colors.blue),
                    ),
                  ),
                ),
                CustomButton(
                  buttonText: "Classify",
                  onPressed: () {},
                ),
              ],
            ),
          ),
        ),
      
    );
  }
}
