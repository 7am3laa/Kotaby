import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:kotaby/notfications_service.dart';
import 'package:kotaby/storage.dart';

class NotificationCubit extends Cubit<NotificationState> {
  NotificationCubit() : super(NotificationInitial());

  Future<void> toggleAzkarElsabah(bool value) async {
    await Storage.saveAzkarElsabah(value);
    if (value) {
      await NotificationsService.scheduleAzkarElsabahNotification();
    } else {
      NotificationsService.cancelNotificationById(10);
    }
    emit(NotificationUpdated());
  }

  Future<void> toggleAzkarElmasaa(bool value) async {
    await Storage.saveAzkarElmasaa(value);
    if (value) {
      await NotificationsService.scheduleAzkarElmasaaNotification();
    } else {
      NotificationsService.cancelNotificationById(11);
    }
    emit(NotificationUpdated());
  }

  Future<void> toggleSurahAlbaqarah(bool value) async {
    await Storage.saveSurahAlbaqarah(value);
    if (value) {
      await NotificationsService.scheduleSurahElBaqraaNotification();
    } else {
      NotificationsService.cancelNotificationById(12);
    }
    emit(NotificationUpdated());
  }

  Future<void> toggleWerdDaily(bool value) async {
    await Storage.saveWerdDaily(value);
    if (value) {
      await NotificationsService.scheduleWerdDailyNotification();
    } else {
      NotificationsService.cancelNotificationById(60);
    }
    emit(NotificationUpdated());
  } 


  Future<void> toggleSurahAlkahf(bool value) async {
    await Storage.saveSurahAlkahf(value);
    if (value) {
      await NotificationsService.scheduleSurahElKahfNotification();
    } else {
      NotificationsService.cancelNotificationById(14);
    }
    emit(NotificationUpdated());
  }

  Future<void> toggleSurahAlmulk(bool value) async {
    await Storage.saveSurahAlmulk(value);
    if (value) {
      await NotificationsService.scheduleSurahElMulekNotification();
    } else {
      NotificationsService.cancelNotificationById(13);
    }
    emit(NotificationUpdated());
  }

  Future<void> updateTimeAndReschedule({
    required int id,
    required TimeOfDay time,
    required Future<void> Function(TimeOfDay) saveTime,
    required Future<void> Function() reschedule,
  }) async {
    await saveTime(time);
    NotificationsService.cancelNotificationById(id);
    await reschedule();
    emit(NotificationUpdated());
  }

  Future<void> updateAzkarElsabahTime(TimeOfDay time) async {
    await Storage.saveAzkarElsabahTime(time);
    await NotificationsService.scheduleAzkarElsabahNotification();
    emit(NotificationUpdated());
  }

  Future<void> updateAzkarElmasaaTime(TimeOfDay time) async {
    await Storage.saveAzkarElmasaaTime(time);
    await NotificationsService.scheduleAzkarElmasaaNotification();
    emit(NotificationUpdated());
  }

  Future<void> selectTime(
    BuildContext context, {
    required TimeOfDay initialTime,
    required int notificationId,
    required Future<void> Function(TimeOfDay) saveTime,
    required Future<void> Function() reschedule,
  }) async {
    final picked = await showTimePicker(
      context: context,
      initialTime: initialTime,
    );
    if (picked != null) {
      context.read<NotificationCubit>().updateTimeAndReschedule(
            id: notificationId,
            time: picked,
            saveTime: saveTime,
            reschedule: reschedule,
          );
    }
  }
}

abstract class NotificationState {}

class NotificationInitial extends NotificationState {}

class NotificationUpdated extends NotificationState {}
