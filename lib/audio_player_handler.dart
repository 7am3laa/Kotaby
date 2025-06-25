import 'dart:async';
import 'dart:io';
import 'package:audio_service/audio_service.dart';
import 'package:flutter/services.dart';
import 'package:just_audio/just_audio.dart';
import 'package:kotaby/UI/screens/surah%20screen/cubit/surah_page_cubit/surah_page_cubit.dart';
import 'package:kotaby/core/functions/to_arabic_number.dart';
import 'package:kotaby/core/services/download_audio.dart';
import 'package:kotaby/storage.dart';
import 'package:quran/quran.dart';

class AudioPlayerHandler extends BaseAudioHandler
    with QueueHandler, SeekHandler {
  final AudioPlayer _audioPlayer = AudioPlayer();
  final List<MediaItem> _mediaItems = [];

  StreamSubscription<ProcessingState>? _stateSubscription;
  StreamSubscription<PlaybackEvent>? _playbackEventSubscription;
  StreamSubscription<int?>? _currentIndexSubscription;

  PlaybackMode _currentMode = PlaybackMode.none;

  AudioPlayerHandler() {
    _init();
  }

  Future<void> _init() async {
    _playbackEventSubscription = _audioPlayer.playbackEventStream.listen(
      _handlePlaybackEvent,
      onError: _handlePlaybackError,
    );

    _stateSubscription = _audioPlayer.processingStateStream.listen(
      _handleProcessingStateChange,
    );
  }

  void _handlePlaybackEvent(PlaybackEvent event) {
    playbackState.add(playbackState.value.copyWith(
      controls: _getControls(),
      playing: _audioPlayer.playing,
      processingState: _transformProcessingState(_audioPlayer.processingState),
      updatePosition: _audioPlayer.position,
      bufferedPosition: _audioPlayer.bufferedPosition,
      speed: _audioPlayer.speed,
      queueIndex: event.currentIndex,
      shuffleMode: AudioServiceShuffleMode.none,
      repeatMode: _getRepeatMode(),
    ));

    if (event.currentIndex != null && _mediaItems.isNotEmpty) {
      final currentItem = _mediaItems[event.currentIndex!];
      final updatedItem = currentItem.copyWith(
        duration: _audioPlayer.duration,
      );
      mediaItem.add(updatedItem);
    }

    if (event.currentIndex != null && _mediaItems.isNotEmpty) {
      final currentItem = _mediaItems[event.currentIndex!];
      if (currentItem.extras != null) {
        final surah = currentItem.extras!['surah'];
        final verse = currentItem.extras!['verse'];
        if (surah != null && verse != null) {
          _updateVerseHighlight(surah, verse);
        }
      }
    }
  }

  void _handlePlaybackError(Object error, StackTrace stackTrace) {
    print('Audio playback error: $error');
    if (error is PlatformException) {
      print('Platform Error - Code: ${error.code}, Message: ${error.message}');
      if (error.details != null) {
        print('Error details: ${error.details}');
      }
    }

    playbackState.add(playbackState.value.copyWith(
      processingState: AudioProcessingState.error,
    ));
  }

  void _handleProcessingStateChange(ProcessingState state) {
    if (state == ProcessingState.completed) {
      _resetVerseHighlight();
    }
  }

  void _updateVerseHighlight(int surah, int verse) {
    try {
      final cubit = SurahPageCubit.instance;
      if (cubit != null && !cubit.isClosed) {
        cubit.selectVerse(surah, verse);
      }
    } catch (e) {
      print('Warning: Could not update verse highlight: $e');
      _resetVerseHighlight();
    }
  }

  void _resetVerseHighlight() {
    try {
      final cubit = SurahPageCubit.instance;
      if (cubit != null && !cubit.isClosed) {
        cubit.resetVerseHighlight();
      }
    } catch (e) {
      print('Warning: Could not reset verse highlight: $e');
    }
  }

  List<MediaControl> _getControls() {
    final controls = <MediaControl>[];

    if (_mediaItems.length > 1 && (_audioPlayer.currentIndex ?? 0) > 0) {
      controls.add(MediaControl.skipToPrevious);
    }

    controls.add(_audioPlayer.playing ? MediaControl.pause : MediaControl.play);

    final currentIndex = _audioPlayer.currentIndex ?? 0;
    if (_mediaItems.length > 1 && currentIndex < _mediaItems.length - 1) {
      controls.add(MediaControl.skipToNext);
    }

    if (_currentMode == PlaybackMode.radio) {
      controls.add(MediaControl.stop);
    }

    return controls;
  }

  AudioServiceRepeatMode _getRepeatMode() {
    switch (_audioPlayer.loopMode) {
      case LoopMode.off:
        return AudioServiceRepeatMode.none;
      case LoopMode.one:
        return AudioServiceRepeatMode.one;
      case LoopMode.all:
        return AudioServiceRepeatMode.all;
    }
  }

  AudioProcessingState _transformProcessingState(ProcessingState state) {
    switch (state) {
      case ProcessingState.idle:
        return AudioProcessingState.idle;
      case ProcessingState.loading:
        return AudioProcessingState.buffering;
      case ProcessingState.buffering:
        return AudioProcessingState.buffering;
      case ProcessingState.ready:
        return AudioProcessingState.ready;
      case ProcessingState.completed:
        return AudioProcessingState.completed;
    }
  }

  @override
  Future<void> play() async {
    try {
      await _audioPlayer.play();
    } catch (e) {
      print('Failed to play: $e');
      rethrow;
    }
  }

  @override
  Future<void> pause() async {
    try {
      await _audioPlayer.pause();
    } catch (e) {
      print('Failed to pause: $e');
      rethrow;
    }
  }

  @override
  Future<void> stop() async {
    try {
      await _audioPlayer.stop();
      _currentMode = PlaybackMode.none;
      _mediaItems.clear();
      mediaItem.add(null);
      _resetVerseHighlight();
    } catch (e) {
      print('Failed to stop: $e');
      rethrow;
    }
  }

  @override
  Future<void> seek(Duration position) async {
    try {
      final currentIndex = _audioPlayer.currentIndex;
      if (currentIndex != null) {
        await _audioPlayer.seek(position, index: currentIndex);
      } else {
        await _audioPlayer.seek(position);
      }
    } catch (e) {
      print('Failed to seek: $e');
      rethrow;
    }
  }

  @override
  Future<void> skipToNext() async {
    try {
      final currentIndex = _audioPlayer.currentIndex;
      if (currentIndex != null && currentIndex + 1 < _mediaItems.length) {
        await _audioPlayer.seek(Duration.zero, index: currentIndex + 1);
        await play();
      }
    } catch (e) {
      print('Failed to skip to next: $e');
    }
  }

  @override
  Future<void> skipToPrevious() async {
    try {
      final currentIndex = _audioPlayer.currentIndex;
      if (currentIndex != null && currentIndex > 0) {
        await _audioPlayer.seek(Duration.zero, index: currentIndex - 1);
        await play();
      }
    } catch (e) {
      print('Failed to skip to previous: $e');
    }
  }

  Future<void> setPlaylist({
    required List<String> urls,
    required String name,
    required int surahNumber,
    required int verse,
  }) async {
    try {
      _currentMode = PlaybackMode.playlist;

      final audioSources = <AudioSource>[];
      _mediaItems.clear();

      for (int i = 0; i < urls.length; i++) {
        final url = urls[i];
        final fileName = url.split('/').last;

        final localPath =
            await AudioDownloader.getLocalPath(fileName, Storage.reciterId);
        bool fileExists = false;

        if (localPath != null) {
          final file = File(localPath);
          fileExists = await file.exists();
        }

        final source = fileExists
            ? AudioSource.uri(Uri.file(localPath!))
            : AudioSource.uri(Uri.parse(url));

        audioSources.add(source);

        _mediaItems.add(MediaItem(
          id: fileExists ? localPath! : url,
          album: 'قران كريم',
          title: 'سُّورَةُ $name الآية ${(i + 1).toArabicNumbers}',
          artist: Storage.reciterName,
          duration: Duration.zero,
          extras: {
            'surah': surahNumber,
            'verse': i + 1,
            'url': url,
            'localPath': fileExists ? localPath : null,
          },
        ));
      }

      final playlist = ConcatenatingAudioSource(children: audioSources);
      await _audioPlayer.setAudioSource(playlist);

      await _audioPlayer.seek(Duration.zero, index: verse - 1);

      _updateVerseHighlight(surahNumber, verse);

      _currentIndexSubscription?.cancel();
      _currentIndexSubscription =
          _audioPlayer.currentIndexStream.listen((index) async {
        if (index == null) return;

        try {
          _updateVerseHighlight(surahNumber, index + 1);

          if (Storage.isAutoDownload) {
            final currentUrl = urls[index];
            final fileName = currentUrl.split('/').last;
            final localPath =
                await AudioDownloader.getLocalPath(fileName, Storage.reciterId);
            final fileExists =
                localPath != null && await File(localPath).exists();

            if (!fileExists) {
              print("Downloading verse during playback: $fileName");
              final downloadedPath = await AudioDownloader.downloadAudio(
                currentUrl,
                fileName,
                Storage.reciterId,
              );
              if (downloadedPath != null) {
                print("Successfully downloaded: $downloadedPath");
              } else {
                print("Download failed for: $fileName");
              }
            }
          }
        } catch (e) {
          print("Error in verse change handler: $e");
          _resetVerseHighlight();
        }
      });

      await _audioPlayer.play();

      print('Playlist set successfully with ${urls.length - verse} verses');
    } catch (e) {
      print('Failed to set playlist: $e');
      rethrow;
    }
  }

  Future<void> playFile({required String path}) async {
    try {
      _currentMode = PlaybackMode.file;

      final mediaItem = MediaItem(
        id: path,
        album: 'ملف محلي',
        title: path.split('/').last,
        artist: 'ملف صوتي',
        duration: Duration.zero,
      );

      _mediaItems.clear();
      _mediaItems.add(mediaItem);
      this.mediaItem.add(mediaItem);

      await _audioPlayer.setFilePath(path);
      await play();

      print('Playing local file: $path');
    } catch (e) {
      print('Failed to play file: $e');
      rethrow;
    }
  }

  Future<void> playNewIndex({
    required String url,
    required int surah,
    required int verse,
    required int repeatCount,
  }) async {
    try {
      _currentIndexSubscription?.cancel();
      await _audioPlayer.stop();

      _currentMode = PlaybackMode.singleVerse;

      _resetVerseHighlight();

      _updateVerseHighlight(surah, verse);

      String fileName = url.split('/').last;
      String? localPath;

      if (Storage.isAutoDownload) {
        localPath = await AudioDownloader.downloadAudio(
          url,
          fileName,
          Storage.reciterId,
        );
      } else {
        localPath = await AudioDownloader.getLocalPath(
          fileName,
          Storage.reciterId,
        );
      }

      final mediaItem = MediaItem(
        id: url,
        album: 'قران كريم',
        title:
            'سُّورَةُ ${getSurahNameArabicFull(surah)} الآية ${verse.toArabicNumbers}',
        artist: Storage.reciterName,
        duration: Duration.zero,
        extras: {
          'surah': surah,
          'verse': verse,
          'url': url,
          'localPath': localPath,
        },
      );

      _mediaItems.clear();
      _mediaItems.add(mediaItem);
      this.mediaItem.add(mediaItem);

      final source = localPath != null
          ? AudioSource.uri(Uri.file(localPath))
          : AudioSource.uri(Uri.parse(url));

      StreamSubscription<Duration?>? durationSubscription;
      durationSubscription = _audioPlayer.durationStream.listen((duration) {
        if (duration != null) {
          final updatedItem = mediaItem.copyWith(duration: duration);
          this.mediaItem.add(updatedItem);
          durationSubscription?.cancel();
        }
      });

      for (int i = 0; i < repeatCount; i++) {
        print(' تكرار ${i + 1} من $repeatCount');

        await _audioPlayer.setAudioSource(source);

        _updateVerseHighlight(surah, verse);

        await _audioPlayer.play();

        await _audioPlayer.playbackEventStream.firstWhere(
          (event) => event.processingState == ProcessingState.completed,
        );

        await _audioPlayer.stop();

        if (i < repeatCount - 1) {
          await Future.delayed(const Duration(milliseconds: 300));
        }
      }

      _currentIndexSubscription?.cancel();
      durationSubscription.cancel();

      _resetVerseHighlight();
    } catch (e) {
      print('Failed to play verse $surah:$verse - $e');
      _resetVerseHighlight();
      rethrow;
    }
  }

  Future<void> playVerseRange({
    required int surah,
    required int startVerse,
    required int endVerse,
    required int repeatCount,
  }) async {
    try {
      if (startVerse > endVerse) {
        throw ArgumentError('Start verse cannot be greater than end verse');
      }

      if (startVerse < 1 || endVerse > getVerseCount(surah)) {
        throw ArgumentError('Invalid verse range for surah $surah');
      }

      _currentIndexSubscription?.cancel();
      await _audioPlayer.stop();

      _currentMode = PlaybackMode.verseRange;

      _resetVerseHighlight();
      await Future.delayed(const Duration(milliseconds: 100));

      _updateVerseHighlight(surah, startVerse);

      print(
          'Playing verse range: $surah:$startVerse to $surah:$endVerse (${repeatCount}x)');

      final List<String> urls = [];
      final List<MediaItem> rangeMediaItems = [];

      for (int verse = startVerse; verse <= endVerse; verse++) {
        final url = getAudioURLByVerse(surah, verse, Storage.reciterId);
        urls.add(url);

        final mediaItem = MediaItem(
          id: url,
          album: 'قران كريم',
          title:
              'سُّورَةُ ${getSurahNameArabicFull(surah)} الآية ${verse.toArabicNumbers}',
          artist: Storage.reciterName,
          duration: Duration.zero,
          extras: {
            'surah': surah,
            'verse': verse,
            'url': url,
            'isRange': true,
            'startVerse': startVerse,
            'endVerse': endVerse,
          },
        );
        rangeMediaItems.add(mediaItem);
      }

      final List<AudioSource> audioSources = [];

      for (int i = 0; i < urls.length; i++) {
        final url = urls[i];
        final fileName = url.split('/').last;

        String? localPath;
        if (Storage.isAutoDownload) {
          localPath =
              await AudioDownloader.getLocalPath(fileName, Storage.reciterId);
          if (localPath != null) {
            final file = File(localPath);
            if (!await file.exists()) {
              localPath = null;
            }
          }
        }

        final source = localPath != null
            ? AudioSource.uri(Uri.file(localPath))
            : AudioSource.uri(Uri.parse(url));

        audioSources.add(source);
      }

      for (int repeatIndex = 0; repeatIndex < repeatCount; repeatIndex++) {
        print('Repeat ${repeatIndex + 1} of $repeatCount');

        final playlist = ConcatenatingAudioSource(children: audioSources);

        _mediaItems.clear();
        _mediaItems.addAll(rangeMediaItems);

        await _audioPlayer.setAudioSource(playlist);

        StreamSubscription<int?>? indexSubscription;
        indexSubscription = _audioPlayer.currentIndexStream.listen((index) {
          if (index != null && index < rangeMediaItems.length) {
            final currentVerse = startVerse + index;
            _updateVerseHighlight(surah, currentVerse);

            if (Storage.isAutoDownload) {
              _downloadVerseIfNeeded(urls[index], Storage.reciterId);
            }
          }
        });

        await _audioPlayer.play();

        await _audioPlayer.playbackEventStream.firstWhere(
          (event) => event.processingState == ProcessingState.completed,
        );

        await indexSubscription.cancel();
        await _audioPlayer.stop();

        if (repeatIndex < repeatCount - 1) {
          _resetVerseHighlight();
          await Future.delayed(const Duration(milliseconds: 500));
          _updateVerseHighlight(surah, startVerse);
        }
      }

      _currentIndexSubscription?.cancel();
      _resetVerseHighlight();

      print('Verse range playback completed');
    } catch (e) {
      print('Failed to play verse range $surah:$startVerse-$endVerse - $e');
      _resetVerseHighlight();
      rethrow;
    }
  }

  Future<void> playPauseAll() async {
    try {
      if (_audioPlayer.playing) {
        await pause();
      } else {
        if (_audioPlayer.currentIndex == null && _mediaItems.isNotEmpty) {
          await _audioPlayer.seek(Duration.zero, index: 0);
        }
        await _audioPlayer.setLoopMode(LoopMode.off);
        await play();
      }
    } catch (e) {
      print('Failed to play/pause all: $e');
    }
  }

  Future<void> playRadio({required String url, String? title}) async {
    try {
      _currentMode = PlaybackMode.radio;

      final radioItem = MediaItem(
        id: url,
        album: 'راديو مباشر',
        title: title ?? 'بث مباشر',
        artist: 'راديو مباشر',
        duration: Duration.zero,
        extras: {
          'isRadio': true,
          'url': url,
        },
      );

      _mediaItems.clear();
      _mediaItems.add(radioItem);
      mediaItem.add(radioItem);

      await _audioPlayer.setAudioSource(AudioSource.uri(Uri.parse(url)));
      await _audioPlayer.setLoopMode(LoopMode.off);
      await play();

      print("Radio started: $url");
    } catch (e) {
      print('Failed to play radio: $e');
      rethrow;
    }
  }

  Future<void> repeatCurrentVerse() async {
    try {
      await _audioPlayer.setLoopMode(LoopMode.one);
    } catch (e) {
      print('Failed to set repeat mode: $e');
    }
  }

  Stream<int?> get currentIndex => _audioPlayer.currentIndexStream.distinct();

  Stream<int?> get currentVerseStream => _audioPlayer.currentIndexStream
      .distinct()
      .map((index) => index != null ? index + 1 : null);

  Stream<Duration> get positionStream => _audioPlayer.positionStream;

  Stream<Duration?> get durationStream => _audioPlayer.durationStream;

  Stream<bool> get playingStream => _audioPlayer.playingStream;

  Future<void> dispose() async {
    try {
      await _stateSubscription?.cancel();
      await _playbackEventSubscription?.cancel();
      await _currentIndexSubscription?.cancel();
      await _audioPlayer.dispose();

      _mediaItems.clear();
      mediaItem.add(null);

      print('Audio player disposed successfully');
    } catch (e) {
      print('Error during dispose: $e');
    }
  }
}

Future<void> _downloadVerseIfNeeded(String url, String reciterId) async {
  try {
    final fileName = url.split('/').last;
    final localPath = await AudioDownloader.getLocalPath(fileName, reciterId);

    if (localPath == null || !await File(localPath).exists()) {
      print("Auto-downloading: $fileName");
      final downloadedPath = await AudioDownloader.downloadAudio(
        url,
        fileName,
        reciterId,
      );
      if (downloadedPath != null) {
        print("Downloaded: $downloadedPath");
      } else {
        print("Download failed: $fileName");
      }
    }
  } catch (e) {
    print("Download error: $e");
  }
}

enum PlaybackMode {
  none,
  singleVerse,
  playlist,
  radio,
  file,
  verseRange,
}
