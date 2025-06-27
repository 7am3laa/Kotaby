import 'package:flutter/material.dart';

class SettingsModel {
  final String title;
  final String subtitle;
  final IconData icon;

  SettingsModel(
      {required this.title, required this.subtitle, required this.icon});
}

List<SettingsModel> settings = [
  SettingsModel(
    title: "Account",
    subtitle: "Security, change name, email or password",
    icon: Icons.person_outlined,
  ),
  SettingsModel(
    title: "Top 10",
    subtitle: "Top 10 users of the app",
    icon: Icons.leaderboard_outlined,
  ),
  SettingsModel(
    title: "Notifications",
    subtitle: "quran, Azkar notifications",
    icon: Icons.notifications_outlined,
  ),
  SettingsModel(
    title: "Storage and data",
    subtitle: "Network usage, auto-download",
    icon: Icons.sd_storage_outlined,
  ),
  SettingsModel(
    title: "Theme and Color",
    subtitle: "change theme color",
    icon: Icons.color_lens_rounded,
  ),
  SettingsModel(
    title: "Help",
    subtitle: "Help center, contact us",
    icon: Icons.headset_mic_outlined,
  ),
];
