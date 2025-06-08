import 'dart:io';
import 'package:flutter/material.dart';
import 'package:kotaby/constants/constants.dart';
import 'package:kotaby/core/services/uplaod_record_service.dart';
import 'package:kotaby/core/ui_components/custom_app_bar.dart';
import 'package:kotaby/core/ui_components/custom_text.dart';
import 'package:kotaby/main.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;
import 'package:quran/quran.dart';
import 'package:record/record.dart';

class RecordAyatScreen extends StatefulWidget {
  final String ayaText;
  final String fontFamily;
  final int surah;
  final int verse;

  const RecordAyatScreen({
    super.key,
    required this.ayaText,
    required this.fontFamily,
    required this.surah,
    required this.verse,
  });

  @override
  State<RecordAyatScreen> createState() => _RecordAyatScreenState();
}

class _RecordAyatScreenState extends State<RecordAyatScreen> {
  final AudioRecorder recorder = AudioRecorder();
  bool isRecording = false;
  bool isPlaying = false;
  bool isProcessing = false;

  String? recordingPath;
  Color color = Colors.white;
  String processed = "";

  Future<void> _startRecording() async {
    if (await recorder.hasPermission()) {
      Directory? dir = await getExternalStorageDirectory();
      if (dir != null) {
        String folderPath = p.join(dir.path, 'records');
        await Directory(folderPath).create(recursive: true);
        String filePath =
            p.join(folderPath, '${widget.surah}_${widget.verse}.wav');

        await recorder.start(
          const RecordConfig(),
          path: filePath,
        );

        setState(() {
          isRecording = true;
          recordingPath = null;
        });
      }
    }
  }

  Future<void> _stopRecording() async {
    String? filePath = await recorder.stop();
    if (filePath != null) {
      setState(() {
        isRecording = false;
        recordingPath = filePath;
      });
    }
  }

  Future<void> _uploadAndCompare() async {
    if (recordingPath == null) return;

    setState(() {
      isProcessing = true;
    });

    try {
      final response = await UplaodRecordService().uploadAudio(recordingPath!);

      setState(() {
        processed = response.transcription;
      });

      if (response.transcription == getVerse(widget.surah, widget.verse)) {
        setState(() {
          color = Colors.green;
        });
      } else {
        setState(() {
          color = Colors.red;
        });
      }
    } catch (e) {
      print("Upload error: $e");
    } finally {
      setState(() {
        isProcessing = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: primaryColor,
      appBar: CustomAppBar(title: "تسميع الاية"),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (recordingPath == null)
              const CustomText(text: "No recording Found"),
            CustomText(
              text: getVerseQCF(widget.surah, widget.verse),
              fontFamily: widget.fontFamily,
              color: color,
            ),
            if (processed.isNotEmpty)
              CustomText(
                text: processed,
                fontFamily: "Hafs",
                color: color,
              ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                if (audioHandler.playbackState.value.playing) {
                  audioHandler.stop();
                  setState(() {
                    isPlaying = false;
                  });
                } else if (recordingPath != null) {
                  setState(() {
                    isPlaying = true;
                  });
                }
              },
              child: Icon(isPlaying ? Icons.pause : Icons.play_arrow),
            ),
            const SizedBox(height: 12),
            ElevatedButton(
              onPressed: () async {
                isRecording ? await _stopRecording() : await _startRecording();
              },
              child: Icon(isRecording ? Icons.stop : Icons.mic),
            ),
            const SizedBox(height: 12),
            ElevatedButton(
              onPressed: isProcessing ? null : _uploadAndCompare,
              child: isProcessing
                  ? const CircularProgressIndicator(color: Colors.white)
                  : const Text("🎧 إرسال"),
            ),
          ],
        ),
      ),
    );
  }
}
