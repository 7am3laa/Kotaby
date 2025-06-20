import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:kotaby/constants/constants.dart';
import 'package:kotaby/constants/radio_list.dart';
import 'package:kotaby/core/ui_components/custom_app_bar.dart';
import 'package:kotaby/core/ui_components/custom_text.dart';
import 'package:kotaby/main.dart';
import 'package:audio_service/audio_service.dart';

class RadioScreen extends StatefulWidget {
  const RadioScreen({super.key});

  @override
  State<RadioScreen> createState() => _RadioScreenState();
}

class _RadioScreenState extends State<RadioScreen> {
  bool _isPlaying = false;
  bool _isLoading = false;
  String _currentTitle = "";
  String _currentUrl = "";

  final TextEditingController _searchController = TextEditingController();
  List<Map<String, dynamic>> _filteredRadios = [];

  late StreamSubscription _playbackStateSubscription;
  late StreamSubscription _mediaItemSubscription;

  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _filteredRadios = radios;
    _initializeAudioListeners();
  }

  void _initializeAudioListeners() {
    _playbackStateSubscription = audioHandler.playbackState.listen((state) {
      if (!mounted) return;
      setState(() {
        _isPlaying = state.playing;
        _isLoading = state.processingState == AudioProcessingState.buffering;
      });
    });

    _mediaItemSubscription = audioHandler.mediaItem.listen((item) {
      if (!mounted) return;

      setState(() {
        _currentTitle = item?.title ?? "";
        _currentUrl = item?.id ?? "";
      });

      // _scrollToCurrentRadio();
    });
  }

  // void _scrollToCurrentRadio() {
  //   final index = _filteredRadios.indexWhere((r) => r["url"] == _currentUrl);
  //   if (index != -1 && _scrollController.hasClients) {
  //     WidgetsBinding.instance.addPostFrameCallback((_) {
  //       final screenHeight = MediaQuery.of(context).size.height;
  //       final scrollOffset = (index) - (screenHeight / 2);

  //       _scrollController.animateTo(
  //         scrollOffset.clamp(0.0, _scrollController.position.maxScrollExtent),
  //         duration: const Duration(milliseconds: 500),
  //         curve: Curves.easeInOutCubic,
  //       );
  //     });
  //   }
  // }

  void _filterRadios(String query) {
    final filtered = radios.where((radio) {
      final name = radio["name"].toString();
      return name.contains(query);
    }).toList();

    setState(() {
      _filteredRadios = filtered;
    });
  }

  @override
  void dispose() {
    _playbackStateSubscription.cancel();
    _mediaItemSubscription.cancel();
    _scrollController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  void _toggleRadio(String url, String title) {
    try {
      if (url == _currentUrl && _isPlaying) {
        audioHandler.pause();
      } else {
        audioHandler.playRadio(url: url, title: title);
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('خطأ في تشغيل الراديو: ${e.toString()}')),
      );
    }
  }

  void _playNextRadio() {
    final currentIndex =
        _filteredRadios.indexWhere((r) => r["url"] == _currentUrl);
    if (currentIndex != -1 && currentIndex < _filteredRadios.length - 1) {
      final nextRadio = _filteredRadios[currentIndex + 1];
      _toggleRadio(nextRadio["url"], nextRadio["name"]);
    }
  }

  void _playPreviousRadio() {
    final currentIndex =
        _filteredRadios.indexWhere((r) => r["url"] == _currentUrl);
    if (currentIndex > 0) {
      final previousRadio = _filteredRadios[currentIndex - 1];
      _toggleRadio(previousRadio["url"], previousRadio["name"]);
    }
  }

  Widget _buildRadioListItem(Map<String, dynamic> radio, int index) {
    final isCurrent = radio["url"] == _currentUrl;

    return Container(
      margin: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: isCurrent
              ? [
                  bColor.withOpacity(.8),
                  bColor,
                  bColor.withOpacity(.8),
                ]
              : [Colors.white.withOpacity(0.1), Colors.white.withOpacity(0.05)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: primaryColor.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () {
            _toggleRadio(radio["url"], radio["name"]);
            //  _scrollToCurrentRadio();
          },
          borderRadius: BorderRadius.circular(16),
          child: Padding(
            padding: EdgeInsets.all(16.w),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                if (isCurrent)
                  Container(
                    padding:
                        EdgeInsets.symmetric(horizontal: 12.w, vertical: 6.h),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: CustomText(
                      text: "جاري التشغيل",
                      color: bColor,
                      fontSize: 12.sp,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                SizedBox(width: 16.w),
                Expanded(
                  child: CustomText(
                    text: radio["name"],
                    color: Colors.white,
                    fontSize: 18.sp,
                    fontWeight: FontWeight.w600,
                    textAlign: TextAlign.right,
                  ),
                ),
                SizedBox(width: 16.w),
                Container(
                  width: 50.w,
                  height: 50.w,
                  decoration: BoxDecoration(
                    color: isCurrent
                        ? Colors.white
                        : Colors.white.withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                  child: (_isLoading && radio['url'] == _currentUrl)
                      ? Center(
                          child: SizedBox(
                            width: 24.w,
                            height: 24.w,
                            child: const CircularProgressIndicator(
                              color: bColor,
                              strokeWidth: 2,
                            ),
                          ),
                        )
                      : Icon(
                          Icons.radio_outlined,
                          color: isCurrent ? bColor : Colors.white,
                          size: 24.w,
                        ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildNowPlayingBar() {
    if (_currentTitle.isEmpty) return const SizedBox();

    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: 16.w,
        vertical: 10.h,
      ),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(50),
          topRight: Radius.circular(50),
        ),
        gradient: LinearGradient(
          colors: [
            bColor.withOpacity(.8),
            bColor,
            bColor.withOpacity(.8),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.2),
            blurRadius: 10,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          CustomText(
            text: _currentTitle,
            color: Colors.white,
            fontWeight: FontWeight.w600,
            textAlign: TextAlign.center,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
          SizedBox(height: 12.h),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _buildControlButton(
                icon: Icons.skip_previous,
                onPressed: _playPreviousRadio,
              ),
              SizedBox(width: 16.w),
              _buildControlButton(
                icon: _isLoading
                    ? null
                    : (_isPlaying ? Icons.pause_circle : Icons.play_circle),
                isLoading: _isLoading,
                isMain: true,
                onPressed: () {
                  _isPlaying ? audioHandler.pause() : audioHandler.play();
                },
              ),
              SizedBox(width: 16.w),
              _buildControlButton(
                icon: Icons.skip_next,
                onPressed: _playNextRadio,
              ),
            ],
          ),
          SizedBox(height: 12.h),
        ],
      ),
    );
  }

  Widget _buildControlButton({
    IconData? icon,
    required VoidCallback onPressed,
    bool isMain = false,
    bool isLoading = false,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onPressed,
        borderRadius: BorderRadius.circular(50),
        child: Container(
          padding: EdgeInsets.all(8.w),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.1),
            shape: BoxShape.circle,
          ),
          child: isLoading
              ? SizedBox(
                  width: isMain ? 48.w : 32.w,
                  height: isMain ? 48.w : 32.w,
                  child: const CircularProgressIndicator(
                    color: Colors.white,
                    strokeWidth: 2,
                  ),
                )
              : Icon(
                  icon,
                  size: isMain ? 48.w : 40.w,
                  color: Colors.white,
                ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const CustomAppBar(
        title: "Radio",
        iscenterTitle: true,
        islead: true,
      ),
      backgroundColor: primaryColor,
      body: Column(
        children: [
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 16.0.w),
            child: SizedBox(
              height: 50,
              child: Center(
                child: TextField(
                  cursorColor: Colors.white,
                  controller: _searchController,
                  onChanged: _filterRadios,
                  textAlign: TextAlign.right,
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16.sp,
                    fontWeight: FontWeight.w500,
                  ),
                  decoration: InputDecoration(
                    hintText: '... ابحث عن إذاعة',
                    hintStyle: TextStyle(
                      color: Colors.white54,
                      fontSize: 16.sp,
                      fontWeight: FontWeight.w400,
                      fontFamily: "Poppins",
                    ),
                    suffixIcon:
                        Icon(Icons.search, color: Colors.white, size: 24.w),
                    filled: true,
                    fillColor: Colors.white.withOpacity(0.1),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(25),
                      borderSide: BorderSide.none,
                    ),
                    contentPadding: EdgeInsets.symmetric(horizontal: 16.w),
                    prefixIcon: _searchController.text.isNotEmpty
                        ? IconButton(
                            icon: Icon(Icons.clear,
                                color: Colors.white, size: 24.w),
                            onPressed: () {
                              _searchController.clear();
                              _filterRadios('');
                            },
                          )
                        : null,
                  ),
                ),
              ),
            ),
          ),
          Expanded(
            child: ListView.builder(
              controller: _scrollController,
              padding: EdgeInsets.symmetric(vertical: 8.h),
              physics: const BouncingScrollPhysics(),
              itemCount: _filteredRadios.length,
              itemBuilder: (context, index) =>
                  _buildRadioListItem(_filteredRadios[index], index),
            ),
          ),
          _buildNowPlayingBar(),
        ],
      ),
    );
  }
}
