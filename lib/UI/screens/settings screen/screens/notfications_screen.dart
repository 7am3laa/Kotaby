import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:kotaby/UI/screens/settings%20screen/cubits/notification_cubit.dart';
import 'package:kotaby/constants/constants.dart';
import 'package:kotaby/core/ui_components/custom_app_bar.dart';
import 'package:kotaby/core/ui_components/custom_text.dart';
import 'package:kotaby/storage.dart';
import 'package:kotaby/notfications_service.dart';
import 'package:quran/quran.dart';

class NotificationsScreen extends StatelessWidget {
  const NotificationsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => NotificationCubit(),
      child: BlocBuilder<NotificationCubit, NotificationState>(
        builder: (context, state) {
          final notCubit = context.read<NotificationCubit>();
          return Scaffold(
            backgroundColor: primaryColor,
            appBar: CustomAppBar(title: "Notifications", iscenterTitle: true),
            body: SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  buildNotificationTileGroup(
                    title: "الأذكار",
                    children: [
                      buildNotificationTile(
                        title: 'أذكار الصباح',
                        isOn: Storage.isAzkarElsabah,
                        onToggle: (value) => notCubit.toggleAzkarElsabah(value),
                        time: Storage.azkarSabatTime,
                        pickTime: () => notCubit.selectTime(
                          context,
                          initialTime: Storage.azkarSabatTime,
                          notificationId: 10,
                          saveTime: Storage.saveAzkarElsabahTime,
                          reschedule: NotificationsService
                              .scheduleAzkarElsabahNotification,
                        ),
                      ),
                      buildNotificationTile(
                        title: 'أذكار المساء',
                        isOn: Storage.isAzkarElmasaa,
                        onToggle: (value) => notCubit.toggleAzkarElmasaa(value),
                        time: Storage.azkarElmasaaTime,
                        pickTime: () => notCubit.selectTime(
                          context,
                          initialTime: Storage.azkarElmasaaTime,
                          notificationId: 11,
                          saveTime: Storage.saveAzkarElmasaaTime,
                          reschedule: NotificationsService
                              .scheduleAzkarElmasaaNotification,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 20.h),
                  buildNotificationTileGroup(
                    title: "الورد اليومي",
                    children: [
                      buildNotificationTile(
                        title: 'الورد اليومي',
                        isOn: Storage.isWerdDaily,
                        onToggle: (value) => notCubit.toggleWerdDaily(value),
                        time: Storage.dailyWerdTime,
                        pickTime: () => notCubit.selectTime(
                          context,
                          initialTime: Storage.dailyWerdTime,
                          notificationId: 12,
                          saveTime: Storage.saveDailyWerdTime,
                          reschedule: NotificationsService
                              .scheduleWerdDailyNotification,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 20.h),
                  buildNotificationTileGroup(
                    title: "السنن اليومية",
                    children: [
                      buildNotificationTile(
                        title: 'سُورة ${getSurahNameArabicFull(2)}',
                        isOn: Storage.isSurahAlbaqarah,
                        onToggle: (value) =>
                            notCubit.toggleSurahAlbaqarah(value),
                        time: Storage.surahAlbaqarahTime,
                        pickTime: () => notCubit.selectTime(
                          context,
                          initialTime: Storage.surahAlbaqarahTime,
                          notificationId: 12,
                          saveTime: Storage.saveSurahAlbaqarahTime,
                          reschedule: NotificationsService
                              .scheduleSurahElBaqraaNotification,
                        ),
                      ),
                      buildNotificationTile(
                        title: 'سُورة ${getSurahNameArabicFull(67)}',
                        isOn: Storage.isSurahAlmulk,
                        onToggle: (value) => notCubit.toggleSurahAlmulk(value),
                        time: Storage.surahAlmulkTime,
                        pickTime: () => notCubit.selectTime(
                          context,
                          initialTime: Storage.surahAlmulkTime,
                          notificationId: 13,
                          saveTime: Storage.saveSurahAlmulkTime,
                          reschedule: NotificationsService
                              .scheduleSurahElMulekNotification,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 20.h),
                  buildNotificationTileGroup(
                    title: "السنن الاسبوعية",
                    children: [
                      buildNotificationTile(
                        title: 'سُورة ${getSurahNameArabicFull(18)}',
                        isOn: Storage.isSurahAlkahf,
                        onToggle: (value) => notCubit.toggleSurahAlkahf(value),
                        time: Storage.surahAlkahfTime,
                        pickTime: () => notCubit.selectTime(
                          context,
                          initialTime: Storage.surahAlkahfTime,
                          notificationId: 14,
                          saveTime: Storage.saveSurahAlkahfTime,
                          reschedule: NotificationsService
                              .scheduleSurahElKahfNotification,
                        ),
                      ),
                    ],
                  )
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget buildNotificationTile({
    required String title,
    required bool isOn,
    required ValueChanged<bool> onToggle,
    required VoidCallback pickTime,
    TimeOfDay? time,
  }) {
    return Card(
      color: Colors.white.withOpacity(.1),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Switch(
                  inactiveThumbColor: Colors.red,
                  activeColor: Colors.green,
                  value: isOn,
                  onChanged: onToggle,
                ),
                CustomText(
                  text: title,
                  color: isOn ? Colors.white : Colors.grey,
                  fontSize: 25,
                  fontFamily: "Hafs",
                  textAlign: TextAlign.right,
                ),
                Icon(
                  isOn ? Icons.notifications_on : Icons.notifications_off,
                  color: isOn ? Colors.green : Colors.red,
                ),
              ],
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Padding(
                  padding: const EdgeInsets.all(2.0),
                  child: InkWell(
                    onTap: isOn ? pickTime : null,
                    child: CustomText(
                      text: formatTimeTo12Hour(time!),
                      color: isOn ? Colors.white : Colors.grey,
                    ),
                  ),
                ),
                CustomText(
                  text: (title == "سُورة ${getSurahNameArabicFull(18)}")
                      ? "الجمعة"
                      : "يوميا",
                  color: isOn ? Colors.white : Colors.grey,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  String formatTimeTo12Hour(TimeOfDay time) {
    final hour = time.hourOfPeriod == 0 ? 12 : time.hourOfPeriod;
    final minute = time.minute.toString().padLeft(2, '0');
    final period = time.period == DayPeriod.am ? "AM" : "PM";
    return "$hour:$minute $period";
  }

  Widget buildNotificationTileGroup(
      {required String title, required List<Widget> children}) {
    return Padding(
      padding: const EdgeInsets.only(right: 2, left: 2),
      child: Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: Colors.black,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: bColor,
              offset: const Offset(0, 4),
              blurRadius: 10,
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            CustomText(
              text: title,
              color: Colors.white,
              fontSize: 25,
              fontFamily: "Hafs",
              textAlign: TextAlign.right,
            ),
            SizedBox(height: 10.h),
            Column(
              children: children,
            ),
          ],
        ),
      ),
    );
  }
}
