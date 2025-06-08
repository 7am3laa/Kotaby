import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class Storage {
  static const String keyIsLoggedIn = 'is_logged_in';
  static const String keyReciterName = 'reciter_name';
  static const String keyReciterId = 'reciter_id';
  static const String keyUserImage = 'user_image';

  static bool isLoggedIn = false;
  static String reciterName = "محمد صديق المنشاوي (المجود)";
  static String reciterId = "ar.minshawimujawwad";

  static int surahNumber = 1;
  static int verseNumber = 1;
  static int colorid = 0;

  static int useridCached = 0;
  static String usernameCached = '';
  static String userImageCached = '';
  static String userEmailCached = '';
  static String userPasswordCached = '';

  static bool isAzkarElsabah = false;
  static bool isAzkarElmasaa = false;
  static bool isAzkarElsalat = false;
  static bool isSurahAlbaqarah = false;
  static bool isSurahAlkahf = false;
  static bool isSurahAlmulk = false;
  static bool isWerdDaily = false;

  static bool isAutoDownload = false;

  static TimeOfDay azkarSabatTime = TimeOfDay(hour: 07, minute: 00);
  static TimeOfDay azkarElmasaaTime = TimeOfDay(hour: 19, minute: 00);
  static TimeOfDay surahAlbaqarahTime = TimeOfDay(hour: 21, minute: 00);
  static TimeOfDay surahAlkahfTime = TimeOfDay(hour: 12, minute: 00);
  static TimeOfDay surahAlmulkTime = TimeOfDay(hour: 21, minute: 30);
  static TimeOfDay dailyWerdTime = TimeOfDay(hour: 16, minute: 00);

  static int completionDays = 0;
  static int completionPages = 0;
  static int completionPageForPercentage = 0;
  static List<int> completionList = [];
  static List<int> readPages = [];

  static Future<void> init() async {
    await getLoginState();
    await loadReciterInfo();
    await loadSurahAndVerse();
    await loadColor();
    await getCachedUserData();
    await getCachedUserImage();
    await getAzkarElsabah();
    await getAzkarElmasaa();
    await getSurahAlbaqarah();
    await getSurahAlkahf();
    await getSurahAlmulk();
    await getWerdDaily();
    await getAutoDownload();
    await getAzkarElsabahTime();
    await getAzkarElmasaaTime();
    await getSurahAlbaqarahTime();
    await getSurahAlmulkTime();
    await getSurahAlkahfTime();
    await getDailyWerdTime();
    await getCompletionDays();
    await getCompletionPages();
    await getCompletionPercentage();
    await getCompletionList();
    await getReadPages();
  }

  static Future<void> saveCompletionDays(int days) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('completionDays', days);
    completionDays = days;
  }

  static Future<void> getCompletionDays() async {
    final prefs = await SharedPreferences.getInstance();
    completionDays = prefs.getInt('completionDays') ?? 0;
  }

  static Future<void> saveWerdDaily(bool value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('isWerdDaily', value);
    isWerdDaily = value;
  }

  static Future<void> getWerdDaily() async {
    final prefs = await SharedPreferences.getInstance();
    isWerdDaily = prefs.getBool('isWerdDaily') ?? false;
  }

  static Future<void> saveCompletionPages(int pages) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('completionPages', pages);
    completionPages = pages;
  }

  static Future<void> getCompletionPages() async {
    final prefs = await SharedPreferences.getInstance();
    completionPages = prefs.getInt('completionPages') ?? 0;
    print("completionPages: $completionPages");
  }

  static Future<void> saveCompletionPercentage(int percentage) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('completionPercentage', percentage);
    completionPageForPercentage = percentage;
  }

  static Future<void> getCompletionPercentage() async {
    final prefs = await SharedPreferences.getInstance();
    completionPageForPercentage = prefs.getInt('completionPercentage') ?? 0;
  }

  static Future<void> saveCompletionList(List<int> list) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList(
        'completionList', list.map((e) => e.toString()).toList());
    completionList = list;
  }

  static Future<void> getCompletionList() async {
    final prefs = await SharedPreferences.getInstance();
    completionList = prefs
            .getStringList('completionList')
            ?.map((e) => int.parse(e))
            .toList() ??
        [];
    print("completionList: $completionList");
  }

  static Future<void> saveReadPages(List<int> pages) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList(
        'readPages', pages.map((e) => e.toString()).toList());
    readPages = pages;
  }

  static Future<void> getReadPages() async {
    final prefs = await SharedPreferences.getInstance();
    readPages =
        prefs.getStringList('readPages')?.map((e) => int.parse(e)).toList() ??
            [];
  }

  static Future<void> clearAllCompletion() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('completionDays');
    await prefs.remove('completionPages');
    await prefs.remove('completionPercentage');
    await prefs.remove('completionList');
    await prefs.remove('readPages');
    completionDays = 0;
    completionPages = 0;
    completionPageForPercentage = 0;
    completionList = [];
    readPages = [];
    await saveCompletionDays(0);
    await saveCompletionPages(0);
    await saveCompletionPercentage(0);
    await saveCompletionList([]);
    await saveReadPages([]);
    await getCompletionDays();
    await getCompletionPages();
    await getCompletionPercentage();
    await getCompletionList();
    await getReadPages();
  }

  static Future<void> saveAzkarElsabah(bool azkarElsabah) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('isAzkarElsabah', azkarElsabah);
    isAzkarElsabah = azkarElsabah;
  }

  static Future<void> saveAzkarElsabahTime(TimeOfDay time) async {
    final prefs = await SharedPreferences.getInstance();
    final formattedTime = '${time.hour.toString()}:${time.minute.toString()}';
    print("Saving time: $formattedTime");
    await prefs.setString('azkarSabatTime', formattedTime);
    azkarSabatTime = time;
  }

  static Future<void> saveDailyWerdTime(TimeOfDay time) async {
    final prefs = await SharedPreferences.getInstance();
    final formattedTime = '${time.hour.toString()}:${time.minute.toString()}';
    await prefs.setString('dailyWerdTime', formattedTime);
    dailyWerdTime = time;
  }

  static Future<void> getDailyWerdTime() async {
    final prefs = await SharedPreferences.getInstance();
    final storedTime = prefs.getString('dailyWerdTime');
    print("Loaded time from prefs: $storedTime");
    if (storedTime != null) {
      final parts = storedTime.split(':');
      if (parts.length == 2) {
        final hour = int.tryParse(parts[0]);
        final minute = int.tryParse(parts[1]);
        if (hour != null && minute != null) {
          dailyWerdTime = TimeOfDay(hour: hour, minute: minute);
          return;
        }
      }
    }
    dailyWerdTime = dailyWerdTime;
  }

  static Future<void> getAzkarElsabahTime() async {
    final prefs = await SharedPreferences.getInstance();
    final storedTime = prefs.getString('azkarSabatTime');
    print("Loaded time from prefs: $storedTime");

    if (storedTime != null) {
      final parts = storedTime.split(':');
      if (parts.length == 2) {
        final hour = int.tryParse(parts[0]);
        final minute = int.tryParse(parts[1]);
        if (hour != null && minute != null) {
          azkarSabatTime = TimeOfDay(hour: hour, minute: minute);
          return;
        }
      }
    }
    azkarSabatTime = azkarSabatTime;
  }

  static Future<void> saveAzkarElmasaaTime(TimeOfDay time) async {
    final prefs = await SharedPreferences.getInstance();
    final formattedTime = '${time.hour.toString()}:${time.minute.toString()}';
    print("Saving time: $formattedTime");
    await prefs.setString('azkarelmasaaTime', formattedTime);
    azkarElmasaaTime = time;
  }

  static Future<void> getAzkarElmasaaTime() async {
    final prefs = await SharedPreferences.getInstance();
    final storedTime = prefs.getString('azkarelmasaaTime');
    print("Loaded time from prefs: $storedTime");

    if (storedTime != null) {
      final parts = storedTime.split(':');
      if (parts.length == 2) {
        final hour = int.tryParse(parts[0]);
        final minute = int.tryParse(parts[1]);
        if (hour != null && minute != null) {
          azkarElmasaaTime = TimeOfDay(hour: hour, minute: minute);
          return;
        }
      }
    }

    azkarElmasaaTime = azkarElmasaaTime;
  }

  static Future<void> saveSurahAlbaqarahTime(TimeOfDay time) async {
    final prefs = await SharedPreferences.getInstance();
    final formattedTime = '${time.hour.toString()}:${time.minute.toString()}';
    print("Saving time: $formattedTime");
    await prefs.setString('surahAlbaqarahTime', formattedTime);
    surahAlbaqarahTime = time;
  }

  static Future<void> getSurahAlbaqarahTime() async {
    final prefs = await SharedPreferences.getInstance();
    final storedTime = prefs.getString('surahAlbaqarahTime');
    print("Loaded time from prefs: $storedTime");

    if (storedTime != null) {
      final parts = storedTime.split(':');
      if (parts.length == 2) {
        final hour = int.tryParse(parts[0]);
        final minute = int.tryParse(parts[1]);
        if (hour != null && minute != null) {
          surahAlbaqarahTime = TimeOfDay(hour: hour, minute: minute);
          return;
        }
      }
    }

    surahAlbaqarahTime = surahAlbaqarahTime;
  }

  static Future<void> saveSurahAlmulkTime(TimeOfDay time) async {
    final prefs = await SharedPreferences.getInstance();
    final formattedTime = '${time.hour.toString()}:${time.minute.toString()}';
    print("Saving time: $formattedTime");
    await prefs.setString('surahAlmulkTime', formattedTime);
    surahAlmulkTime = time;
  }

  static Future<void> getSurahAlmulkTime() async {
    final prefs = await SharedPreferences.getInstance();
    final storedTime = prefs.getString('surahAlmulkTime');
    print("Loaded time from prefs: $storedTime");

    if (storedTime != null) {
      final parts = storedTime.split(':');
      if (parts.length == 2) {
        final hour = int.tryParse(parts[0]);
        final minute = int.tryParse(parts[1]);
        if (hour != null && minute != null) {
          surahAlmulkTime = TimeOfDay(hour: hour, minute: minute);
          return;
        }
      }
    }

    surahAlmulkTime = surahAlmulkTime;
  }

  static Future<void> saveSurahAlkahfTime(TimeOfDay time) async {
    final prefs = await SharedPreferences.getInstance();
    final formattedTime = '${time.hour.toString()}:${time.minute.toString()}';
    print("Saving time: $formattedTime");
    await prefs.setString('surahAlkahfTime', formattedTime);
    surahAlkahfTime = time;
  }

  static Future<void> getSurahAlkahfTime() async {
    final prefs = await SharedPreferences.getInstance();
    final storedTime = prefs.getString('surahAlkahfTime');
    print("Loaded time from prefs: $storedTime");

    if (storedTime != null) {
      final parts = storedTime.split(':');
      if (parts.length == 2) {
        final hour = int.tryParse(parts[0]);
        final minute = int.tryParse(parts[1]);
        if (hour != null && minute != null) {
          surahAlkahfTime = TimeOfDay(hour: hour, minute: minute);
          return;
        }
      }
    }

    surahAlkahfTime = surahAlkahfTime;
  }

  static Future<void> saveAzkarElmasaa(bool azkarElmasaa) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('isAzkarElmasaa', azkarElmasaa);
    isAzkarElmasaa = azkarElmasaa;
  }

  static Future<void> saveLoginState(bool value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(keyIsLoggedIn, value);
    isLoggedIn = value;
  }

  static Future<void> saveAutoDownload(bool value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('isAutoDownload', value);
    isAutoDownload = value;
  }

  static Future<void> saveSurahAlbaqarah(bool value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('isSurahAlbaqarah', value);
    isSurahAlbaqarah = value;
  }

  static Future<void> saveSurahAlkahf(bool value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('isSurahAlkahf', value);
    isSurahAlkahf = value;
  }

  static Future<void> saveSurahAlmulk(bool value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('isSurahAlmulk', value);
    isSurahAlmulk = value;
  }

  static Future<void> getLoginState() async {
    final prefs = await SharedPreferences.getInstance();
    isLoggedIn = prefs.getBool(keyIsLoggedIn) ?? false;
  }

  static Future<void> saveReciterInfo(String name, String id) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(keyReciterName, name);
    await prefs.setString(keyReciterId, id);
    reciterName = name;
    reciterId = id;
  }

  static Future<void> loadReciterInfo() async {
    final prefs = await SharedPreferences.getInstance();
    reciterName = prefs.getString(keyReciterName) ?? reciterName;
    reciterId = prefs.getString(keyReciterId) ?? reciterId;
  }

  static Future<void> saveSurahAndVerse(int surah, int verse) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('surah', surah);
    await prefs.setInt('verse', verse);
    surahNumber = surah;
    verseNumber = verse;
  }

  static Future<void> loadSurahAndVerse() async {
    final prefs = await SharedPreferences.getInstance();
    surahNumber = prefs.getInt('surah') ?? 1;
    verseNumber = prefs.getInt('verse') ?? 1;
  }

  static Future<void> saveColor(int color) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('color', color);
    colorid = color;
  }

  static Future<void> loadColor() async {
    final prefs = await SharedPreferences.getInstance();
    colorid = prefs.getInt('color') ?? 0;
  }

  static Future<void> cacheUserData({
    required String name,
    required int id,
    required String email,
    required String password,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString("userName", name);
    await prefs.setInt("userId", id);
    await prefs.setString("userEmail", email);
    await prefs.setString("userPassword", password);
    usernameCached = name;
    useridCached = id;
    userEmailCached = email;
    userPasswordCached = password;
  }

  static Future<void> getCachedUserData() async {
    final prefs = await SharedPreferences.getInstance();
    usernameCached = prefs.getString("userName") ?? '';
    useridCached = prefs.getInt("userId") ?? 0;
    userEmailCached = prefs.getString("userEmail") ?? '';
    userPasswordCached = prefs.getString("userPassword") ?? '';
  }

  static Future<void> getAzkarElsabah() async {
    final prefs = await SharedPreferences.getInstance();
    isAzkarElsabah = prefs.getBool('isAzkarElsabah') ?? false;
  }

  static Future<void> getAzkarElmasaa() async {
    final prefs = await SharedPreferences.getInstance();
    isAzkarElmasaa = prefs.getBool('isAzkarElmasaa') ?? false;
  }

  static Future<void> getSurahAlbaqarah() async {
    final prefs = await SharedPreferences.getInstance();
    isSurahAlbaqarah = prefs.getBool('isSurahAlbaqarah') ?? false;
  }

  static Future<void> getSurahAlkahf() async {
    final prefs = await SharedPreferences.getInstance();
    isSurahAlkahf = prefs.getBool('isSurahAlkahf') ?? false;
  }

  static Future<void> getSurahAlmulk() async {
    final prefs = await SharedPreferences.getInstance();
    isSurahAlmulk = prefs.getBool('isSurahAlmulk') ?? false;
  }

  static Future<void> getAutoDownload() async {
    final prefs = await SharedPreferences.getInstance();
    isAutoDownload = prefs.getBool('isAutoDownload') ?? false;
  }

  static Future<void> clearCachedUserData() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove("userName");
    await prefs.remove("userId");
    await prefs.remove("userEmail");
    await prefs.remove("userPassword");
    await prefs.remove("isAzkarElsabah");
    await prefs.remove("isAzkarElmasaa");
    await prefs.remove("isAutoDownload");
    await prefs.remove("isSurahAlbaqarah");
    await prefs.remove("isSurahAlkahf");
    await prefs.remove("isSurahAlmulk");
    await prefs.remove("azkarSabatTime");
    await prefs.remove("azkarElmasaaTime");
    await prefs.remove("surahAlbaqarahTime");
    await prefs.remove("surahAlkahfTime");
    await prefs.remove("surahAlmulkTime");
    await clearAllCompletion();
    await clearUserImage();
    usernameCached = '';
    useridCached = 0;
    userEmailCached = '';
    userPasswordCached = '';
    isAzkarElsabah = false;
    isAzkarElmasaa = false;
    isSurahAlbaqarah = false;
    isSurahAlkahf = false;
    isSurahAlmulk = false;
    isAutoDownload = false;
    azkarSabatTime = TimeOfDay(hour: 07, minute: 00);
    azkarElmasaaTime = TimeOfDay(hour: 19, minute: 00);
    surahAlbaqarahTime = TimeOfDay(hour: 21, minute: 00);
    surahAlkahfTime = TimeOfDay(hour: 12, minute: 00);
    surahAlmulkTime = TimeOfDay(hour: 21, minute: 30);
  }

  static Future<void> saveUserImage(String imageUrl) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(keyUserImage, imageUrl);
    userImageCached = imageUrl;
  }

  static Future<void> getCachedUserImage() async {
    final prefs = await SharedPreferences.getInstance();
    userImageCached = prefs.getString(keyUserImage) ?? '';
  }

  static Future<void> clearUserImage() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(keyUserImage);
    userImageCached = '';
  }
}
