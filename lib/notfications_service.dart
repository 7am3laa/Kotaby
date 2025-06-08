import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:kotaby/UI/screens/home%20screen/azkar_screen.dart';
import 'package:kotaby/UI/screens/home%20screen/completion_list.dart';
import 'package:kotaby/UI/screens/main%20screen/main_screen.dart';
import 'package:kotaby/UI/screens/surah%20screen/surah_page_screen.dart';
import 'package:kotaby/constants/azkar_elmassa.dart';
import 'package:kotaby/constants/azkar_elsabah.dart';
import 'package:kotaby/constants/constants.dart';
import 'package:kotaby/storage.dart';
import 'package:quran/quran.dart';
import 'package:awesome_notifications/awesome_notifications.dart';

class NotificationsService {
  static final NotificationsService _instance =
      NotificationsService._internal();

  factory NotificationsService() {
    return _instance;
  }

  NotificationsService._internal();

  static Future<void> initialize() async {
    await AwesomeNotifications().initialize(
      null,
      [
        NotificationChannel(
          channelKey: 'basic_channel',
          channelName: 'Basic Notifications',
          channelDescription: 'Channel for basic notifications',
          importance: NotificationImportance.High,
          defaultColor: Colors.teal,
          ledColor: Colors.white,
        ),
        NotificationChannel(
          channelKey: 'scheduled_channel',
          channelName: 'Scheduled Notifications',
          channelDescription: 'Channel for scheduled notifications',
          importance: NotificationImportance.High,
          defaultColor: primaryColor,
          ledColor: bColor,
          enableLights: true,
          vibrationPattern: Int64List.fromList([0, 1000, 500, 1000]),
        ),
      ],
    );

    bool isAllowed = await AwesomeNotifications().isNotificationAllowed();
    if (!isAllowed) {
      await AwesomeNotifications().requestPermissionToSendNotifications();
    }

    AwesomeNotifications().setListeners(
      onActionReceivedMethod: onNotificationTap,
    );
  }

  static Future<void> onNotificationTap(ReceivedAction action) async {
    if (action.payload != null) {
      final type = action.payload!['type'];

      // First navigate to main screen
      Get.offAll(() => MainScreen());

      // Add a small delay to ensure the main screen is loaded
      await Future.delayed(const Duration(milliseconds: 500));

      // Then navigate to the target screen
      _navigateToTargetScreen(type);
    }
  }

  static void _navigateToTargetScreen(String? type) {
    switch (type) {
      case 'Surah El Baqraa':
        Get.offAll(
          () => SurahPageScreen(
            pageNumber: 2,
            shouldHighlightText: true,
            highlightVerse: getVerse(2, 1),
          ),
        );
        break;

      case 'Surah El Mulek':
        Get.offAll(
          () => SurahPageScreen(
            pageNumber: 562,
            shouldHighlightText: true,
            highlightVerse: getVerse(67, 1),
          ),
        );
        break;

      case 'Surah El Kahf':
        Get.offAll(
          () => SurahPageScreen(
            pageNumber: 293,
            shouldHighlightText: true,
            highlightVerse: getVerse(18, 1),
          ),
        );
        break;

      case 'Morning Azkar':
        print('Morning azkar notification tapped');
        Get.offAll(
          () => AzkarScreen(
            azkarList: azkarElsabah,
            title: 'أذكار الصباح',
          ),
        );
        break;

      case 'Evening Azkar':
        Get.offAll(
          () => AzkarScreen(
            azkarList: azkarElmassa,
            title: 'أذكار المساء',
          ),
        );
        break;

      case 'werd_daily':
        Get.offAll(() => CompletionList());
        break;

      default:
        print('Unknown notification type: $type');
    }
  }

  static Future<void> onNotificationTapAlternative(
      ReceivedAction action) async {
    if (action.payload != null) {
      final type = action.payload!['type'];

      Get.offAll(() => MainScreen());

      await Future.delayed(const Duration(milliseconds: 800));

      _navigateToTargetScreen(type);
    }
  }

  static Future<void> scheduleAzkarElsabahNotification() async {
    final time = Storage.azkarSabatTime;

    await AwesomeNotifications().createNotification(
      content: NotificationContent(
        id: 10,
        channelKey: 'scheduled_channel',
        title: 'أذكار الصباح',
        body: 'لاتنسى قراءة أذكار الصباح 🌞',
        payload: {'type': 'Morning Azkar'},
      ),
      schedule: NotificationCalendar(
        hour: time.hour,
        minute: time.minute,
        second: 0,
        millisecond: 0,
        repeats: true,
      ),
      actionButtons: [
        NotificationActionButton(
          key: 'READ_NOW',
          label: 'اقرأ الآن',
          actionType: ActionType.Default,
        ),
      ],
    );
  }

  static Future<void> scheduleAzkarElmasaaNotification() async {
    final time = Storage.azkarElmasaaTime;

    await AwesomeNotifications().createNotification(
      content: NotificationContent(
        id: 11,
        channelKey: 'scheduled_channel',
        title: 'أذكار المساء',
        body: 'لاتنسى قراءة أذكار المساء 🌙',
        payload: {'type': 'Evening Azkar'},
      ),
      schedule: NotificationCalendar(
        hour: time.hour,
        minute: time.minute,
        second: 0,
        millisecond: 0,
        repeats: true,
      ),
      actionButtons: [
        NotificationActionButton(
          key: 'READ_NOW',
          label: 'اقرأ الآن',
          actionType: ActionType.Default,
        ),
      ],
    );
  }

  static Future<void> scheduleSurahElBaqraaNotification() async {
    final time = Storage.surahAlbaqarahTime;

    await AwesomeNotifications().createNotification(
      content: NotificationContent(
        id: 12,
        channelKey: 'scheduled_channel',
        title: 'سورة البقرة',
        body: 'لاتنسى قراءة سورة البقرة',
        payload: {'type': 'Surah El Baqraa'},
      ),
      schedule: NotificationCalendar(
        hour: time.hour,
        minute: time.minute,
        second: 0,
        millisecond: 0,
        repeats: true,
      ),
      actionButtons: [
        NotificationActionButton(
          key: 'READ_NOW',
          label: 'اقرأ الآن',
          actionType: ActionType.Default,
        ),
      ],
    );
  }

  static Future<void> scheduleSurahElMulekNotification() async {
    final time = Storage.surahAlmulkTime;

    await AwesomeNotifications().createNotification(
      content: NotificationContent(
        id: 13,
        channelKey: 'scheduled_channel',
        title: 'سورة الملك',
        body: 'لاتنسى قراءة سورة الملك',
        payload: {'type': 'Surah El Mulek'},
      ),
      schedule: NotificationCalendar(
        hour: time.hour,
        minute: time.minute,
        second: 0,
        millisecond: 0,
        repeats: true,
      ),
      actionButtons: [
        NotificationActionButton(
          key: 'READ_NOW',
          label: 'اقرأ الآن',
          actionType: ActionType.Default,
        ),
      ],
    );
  }

  static Future<void> scheduleSurahElKahfNotification() async {
    final time = Storage.surahAlkahfTime;

    await AwesomeNotifications().createNotification(
      content: NotificationContent(
        id: 14,
        channelKey: 'scheduled_channel',
        title: 'سورة الكهف',
        body: 'لاتنسى قراءة سورة الكهف اليوم! 📖',
        payload: {'type': 'Surah El Kahf'},
      ),
      schedule: NotificationCalendar(
        weekday: DateTime.friday,
        hour: time.hour,
        minute: time.minute,
        second: 0,
        millisecond: 0,
        repeats: true,
      ),
      actionButtons: [
        NotificationActionButton(
          key: 'READ_NOW',
          label: 'اقرأ الآن',
          actionType: ActionType.Default,
        ),
      ],
    );
  }

  static Future<void> scheduleWerdDailyNotification() async {
    final time = Storage.dailyWerdTime;

    await AwesomeNotifications().createNotification(
      content: NotificationContent(
        id: 60,
        channelKey: 'scheduled_channel',
        title: 'الورد اليومي',
        body: 'لاتنسى قراءة ورد اليوم! 📖',
        payload: {'type': 'werd_daily'},
      ),
      schedule: NotificationCalendar(
        hour: time.hour,
        minute: time.minute,
        second: 0,
        millisecond: 0,
        repeats: true,
      ),
      actionButtons: [
        NotificationActionButton(
          key: 'READ_NOW',
          label: 'اقرأ الآن',
          actionType: ActionType.Default,
        ),
      ],
    );
  }

  static void cancelAllNotifications() {
    AwesomeNotifications().cancelAll();
  }

  static void cancelNotificationById(int id) {
    AwesomeNotifications().cancel(id);
  }
}
