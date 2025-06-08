import 'package:flutter/material.dart';
import 'package:kotaby/constants/constants.dart';
import 'package:kotaby/core/ui_components/custom_app_bar.dart';
import 'package:kotaby/core/ui_components/custom_text.dart';

class AzkarScreen extends StatefulWidget {
  final String title;
  final List<Map<String, dynamic>> azkarList;
  const AzkarScreen({super.key, required this.azkarList, required this.title});

  @override
  State<AzkarScreen> createState() => _AzkarScreenState();
}

class _AzkarScreenState extends State<AzkarScreen> {
  final PageController _pageController = PageController();
  int currentPage = 0;

  @override
  void initState() {
    super.initState();
    for (var zekr in widget.azkarList) {
      zekr['counter'] = zekr['counter'] ?? 0;
    }
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _pageController.jumpToPage(0);
    });

    _pageController.addListener(() {
      final page = _pageController.page?.round() ?? 0;
      if (page != currentPage) {
        setState(() {
          currentPage = page;
        });
      }
    });
  }

  void _incrementCounter(int index) {
    setState(() {
      final zekr = widget.azkarList[index];
      final int requiredCount = int.tryParse(zekr['count']) ?? 1;

      if (zekr['counter'] < requiredCount) {
        zekr['counter'] += 1;
        if (zekr['counter'] >= requiredCount) {
          Future.delayed(const Duration(milliseconds: 500), () {
            if (index + 1 < widget.azkarList.length) {
              _pageController.nextPage(
                duration: const Duration(milliseconds: 200),
                curve: Curves.ease,
              );
            }
          });
        }
      }
    });
  }

  @override
  void dispose() {
    for (var zekr in widget.azkarList) {
      zekr['counter'] = 0;
    }
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final currentZekr = widget.azkarList[currentPage];
    final int requiredCount = int.tryParse(currentZekr['count']) ?? 1;
    final int currentCounter = currentZekr['counter'];
    final double progress = currentCounter / requiredCount;

    return Scaffold(
      backgroundColor: primaryColor,
      appBar: CustomAppBar(title: widget.title),
      body: Padding(
        padding: const EdgeInsets.symmetric(vertical: 12),
        child: PageView.builder(
          controller: _pageController,
          itemCount: widget.azkarList.length,
          physics: const NeverScrollableScrollPhysics(),
          scrollDirection: Axis.horizontal,
          reverse: true,
          itemBuilder: (context, index) {
            final zekr = widget.azkarList[index];
            final int requiredCount = int.tryParse(zekr['count']) ?? 1;
            final int currentCounter = zekr['counter'];

            return SizedBox(
              width: MediaQuery.of(context).size.width,
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(right: 16),
                      child: Align(
                        alignment: Alignment.topRight,
                        child: CustomText(
                          text: '${index + 1} / ${widget.azkarList.length}',
                          fontSize: 18,
                          color: Colors.white70,
                        ),
                      ),
                    ),
                    Expanded(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          CustomText(
                            text: "${zekr['zekr'].replaceAll('.', '')}",
                            textAlign: TextAlign.center,
                            color: Colors.white,
                            fontWeight: FontWeight.w800,
                            textDirection: TextDirection.rtl,
                          ),
                          const SizedBox(height: 10),
                          CustomText(
                            text: zekr['description'] != null
                                ? "${zekr['description'].replaceAll('.', '')}"
                                : '',
                            textAlign: TextAlign.center,
                            color: Colors.white.withOpacity(0.6),
                            fontWeight: FontWeight.w200,
                            textDirection: TextDirection.rtl,
                          ),
                          const SizedBox(height: 15),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.only(top: 10, bottom: 50),
        child: Stack(
          alignment: Alignment.center,
          children: [
            SizedBox(
              width: 100,
              height: 100,
              child: CircularProgressIndicator(
                value: progress,
                backgroundColor: Colors.white24,
                valueColor: AlwaysStoppedAnimation<Color>(Colors.green),
                strokeWidth: 6,
              ),
            ),
            GestureDetector(
              onTap: currentCounter < requiredCount
                  ? () => _incrementCounter(currentPage)
                  : null,
              child: Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: currentCounter < requiredCount ? bColor : Colors.green,
                ),
                alignment: Alignment.center,
                child: CustomText(
                  text: currentCounter < requiredCount
                      ? '${requiredCount - currentCounter}'
                      : 'أتممت',
                  color: Colors.white,
                  fontSize: 24,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
