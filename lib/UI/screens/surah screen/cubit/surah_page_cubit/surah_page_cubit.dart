import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:audio_service/audio_service.dart';
import 'package:kotaby/core/functions/snake_bar.dart';
import 'package:kotaby/main.dart';
import 'package:kotaby/storage.dart';
import 'package:quran/quran.dart';
import 'package:connectivity_plus/connectivity_plus.dart';

class SurahPageCubit extends Cubit<SurahPageState> {
  SurahPageCubit({
    required int initialPage,
    required bool initialHighlight,
    required String initialVerse,
    required int initLastPage,
  }) : super(SurahPageState(
          currentPage: initialPage,
          shouldHighlight: initialHighlight,
          pageController: PageController(initialPage: initialPage),
          selectedReciterId: Storage.reciterId,
          lastPage: initLastPage,
        )) {
    _loadReciterInfo();
    instance = this;
  }

  Future<void> _loadReciterInfo() async {
    final reciterId = Storage.reciterId;
    emit(state.copyWith(selectedReciterId: reciterId));
  }

  void updatePage(int newPage) {
    if (newPage != state.currentPage) {
      if (state.pageController.hasClients) {
        state.pageController.jumpToPage(newPage);
      } else {
        emit(state.copyWith(currentPage: newPage));
      }
    }
  }

  void updateSelectedSpan(String span) {
    emit(state.copyWith(selectedSpan: span));
  }

  void selectVerse(int surah, int verse) {
    _updateVerseState(surah, verse);
  }

  void _updateVerseState(int surah, int verse) {
    final newVerseKey = "$surah:$verse";
    final versePage = getPageNumber(surah, verse);

    if (versePage != state.currentPage) {
      if (state.pageController.hasClients) {
        state.pageController.jumpToPage(versePage);
      }
      emit(state.copyWith(
        currentPage: versePage,
        selectedVerse: newVerseKey,
      ));
    } else {
      emit(state.copyWith(selectedVerse: newVerseKey));
    }
  }

  void resetVerseHighlight() {
    emit(state.copyWith(selectedVerse: null));
  }

  StreamSubscription<PlaybackState>? _playbackSubscription;
  StreamSubscription<int?>? _verseSubscription;

  static SurahPageCubit? instance;

  void _safeNavigatorPop(BuildContext context) {
    try {
      if (context.mounted) {
        Navigator.pop(context);
      }
    } catch (e) {
      print('Error popping navigator: $e');
    }
  }

  Future<bool> _checkConnectivity() async {
    final connectivityResult = await Connectivity().checkConnectivity();
    return connectivityResult[0] != ConnectivityResult.none;
  }

  void _showNoConnectionSnackBar(BuildContext context) {
    if (context.mounted) {
      customSnakeBar(
        context: context,
        tilte: "لا يوجد اتصال بالإنترنت",
        isSuccess: false,
      );
    }
  }

  Future<void> playVerse(int surah, int verse, BuildContext context) async {
    _safeNavigatorPop(context);
    try {
      if (!await _checkConnectivity()) {
        _showNoConnectionSnackBar(context);
        return;
      }

      _updateVerseState(surah, verse);

      await audioHandler.playNewIndex(
        url: getAudioURLByVerse(surah, verse, Storage.reciterId),
        surah: surah,
        verse: verse,
      );

      await _playbackSubscription?.cancel();

      _playbackSubscription = audioHandler.playbackState.listen(
        (playbackState) {
          if (playbackState.processingState == AudioProcessingState.completed) {
            resetVerseHighlight();
          }
          if (playbackState.processingState == AudioProcessingState.ready) {
            _updateVerseState(surah, verse);
          }
        },
        onError: (error) {
          print('Error in playback state stream: $error');
          resetVerseHighlight();
          if (context.mounted) {
            customSnakeBar(
              context: context,
              tilte: "حدث خطأ في تشغيل الآية",
              isSuccess: false,
            );
          }
        },
      );
    } catch (e) {
      print('Error in playVerse: $e');
      resetVerseHighlight();
      if (context.mounted) {
        customSnakeBar(
          context: context,
          tilte: "حدث خطأ في تشغيل الآية",
          isSuccess: false,
        );
      }
      _safeNavigatorPop(context);
    }
  }

  Future<void> playSurah(int surah, int verse, BuildContext context) async {
    _safeNavigatorPop(context);

    try {
      await _verseSubscription?.cancel();
      await _playbackSubscription?.cancel();

      resetVerseHighlight();

      final startPage = getPageNumber(surah, verse);
      if (startPage != state.currentPage) {
        if (state.pageController.hasClients) {
          state.pageController.jumpToPage(startPage);
        }
        emit(state.copyWith(currentPage: startPage));
      }

      await audioHandler.setPlaylist(
        urls: getAudioURLSurah(surah, Storage.reciterId),
        name: getSurahNameArabicFull(surah),
        verse: verse-1,
        surahNumber: surah,
      );

      _updateVerseState(surah, verse);

      _verseSubscription = audioHandler.currentVerseStream.listen(
        (verseNumber) {
          if (verseNumber != null) {
            _updateVerseState(surah, verseNumber);
          } else {
            resetVerseHighlight();
          }
        },
      );
    } catch (e) {
      print('Error in playSurah: $e');
      resetVerseHighlight();
      if (context.mounted) {
        customSnakeBar(
          context: context,
          tilte: "حدث خطأ في تشغيل السورة",
          isSuccess: false,
        );
      }
      _safeNavigatorPop(context);
    }
  }

  void copyVerse(int surah, int verse, BuildContext context) {
    try {
      Clipboard.setData(ClipboardData(
        text:
            "${getVerse(surah, verse, verseEndSymbol: true)}  [${getSurahNameArabic(surah)}]",
      ));
    } catch (e) {
      print('Error copying verse: $e');
      _safeNavigatorPop(context);
    }
  }

  void bookMark(int surah, int verse, BuildContext context) async {
    try {
      await Storage.saveSurahAndVerse(surah, verse);
      if (context.mounted) {
        customSnakeBar(
          context: context,
          tilte: "\u062a\u0645 \u0627\u0644\u062d\u0641\u0638",
          isSuccess: true,
        );
      }
      _safeNavigatorPop(context);
    } catch (e) {
      print('Error bookmarking verse: $e');
      _safeNavigatorPop(context);
    }
  }

  @override
  Future<void> close() async {
    await _verseSubscription?.cancel();
    await _playbackSubscription?.cancel();
    await audioHandler.stop();

    instance = null;
    return super.close();
  }
}

class SurahPageState {
  final int currentPage;
  final String? highlightVerse;
  final String? selectedSpan;
  final String? selectedVerse;
  final bool shouldHighlight;
  final PageController pageController;
  final String selectedReciterId;
  final String? errorMessage;
  final int? lastPage;

  const SurahPageState({
    required this.currentPage,
    this.highlightVerse,
    this.selectedSpan,
    this.selectedVerse,
    required this.shouldHighlight,
    required this.pageController,
    required this.selectedReciterId,
    this.errorMessage,
    this.lastPage,
  });

  SurahPageState copyWith({
    int? currentPage,
    String? highlightVerse,
    String? selectedSpan,
    String? selectedVerse,
    bool? shouldHighlight,
    PageController? pageController,
    String? selectedReciterId,
    String? errorMessage,
    int? lastPage,
  }) {
    return SurahPageState(
      currentPage: currentPage ?? this.currentPage,
      lastPage: lastPage ?? this.lastPage,
      highlightVerse: highlightVerse ?? this.highlightVerse,
      selectedSpan: selectedSpan ?? this.selectedSpan,
      selectedVerse: selectedVerse ?? this.selectedVerse,
      shouldHighlight: shouldHighlight ?? this.shouldHighlight,
      pageController: pageController ?? this.pageController,
      selectedReciterId: selectedReciterId ?? this.selectedReciterId,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }

  List<Object?> get props => [
        currentPage,
        highlightVerse,
        selectedSpan,
        selectedVerse,
        shouldHighlight,
        pageController,
        selectedReciterId,
        errorMessage,
        lastPage,
      ];
}
