import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:kotaby/UI/screens/auth%20screen/cubits/login%20cubit/login_cubit.dart';
import 'package:kotaby/UI/screens/auth%20screen/cubits/login%20cubit/login_state.dart';
import 'package:kotaby/UI/screens/settings%20screen/screens/contact_us_screen.dart';
import 'package:kotaby/UI/screens/settings%20screen/cubits/update_info_cubit.dart';
import 'package:kotaby/UI/screens/settings%20screen/screens/storage_screen.dart';
import 'package:kotaby/UI/screens/settings%20screen/screens/theme_color_screen.dart';
import 'package:kotaby/UI/screens/settings%20screen/screens/top_10_screen.dart';
import 'package:kotaby/UI/screens/settings%20screen/screens/check_password.dart';
import 'package:kotaby/UI/screens/settings%20screen/screens/notfications_screen.dart';
import 'package:kotaby/constants/constants.dart';
import 'package:kotaby/core/functions/navigate.dart';
import 'package:kotaby/core/models/settings_model.dart';
import 'package:kotaby/core/ui_components/custom_app_bar.dart';
import 'package:kotaby/core/ui_components/custom_text.dart';
import 'package:kotaby/storage.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  @override
  Widget build(BuildContext context) {
    final loginCubit = context.watch<LoginCubit>();
    bool isWideScreen = MediaQuery.of(context).size.width >= 500;

    return Scaffold(
      backgroundColor: Storage.themeState == 1 ? primaryColor : Colors.white,
      appBar: const CustomAppBar(
        title: "Settings",
        islead: false,
        iscenterTitle: false,
      ),
      body: ListView(
        padding: const EdgeInsets.all(15),
        children: [
          BlocBuilder<UpdateInfoCubit, UpdateInfoState>(
            builder: (context, state) {
              return Row(
                children: [
                  buildProfilePicture(context, loginCubit),
                  SizedBox(width: 15.w),
                  Expanded(
                    child: CustomText(
                      text: Storage.usernameCached,
                      color: Storage.themeState == 1 ? Colors.white : bColor,
                      fontSize: isWideScreen ? 20 : 30,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              );
            },
          ),
          SizedBox(height: 20.h),
          _buildTile(
            context: context,
            isWideScreen: isWideScreen,
            index: 0,
            screen: const CheckPassword(),
          ),
          SizedBox(height: 10.h),
          _buildTile(
            context: context,
            isWideScreen: isWideScreen,
            index: 1,
            screen: const Top10Screen(),
          ),
          SizedBox(height: 10.h),
          _buildTile(
            context: context,
            isWideScreen: isWideScreen,
            index: 2,
            screen: const NotificationsScreen(),
          ),
          SizedBox(height: 10.h),
          _buildTile(
            context: context,
            isWideScreen: isWideScreen,
            index: 3,
            screen: const StorageScreen(),
          ),
          SizedBox(height: 10.h),
          _buildTile(
            context: context,
            isWideScreen: isWideScreen,
            index: 4,
            screen: const ThemeColorScreen(),
          ),
          SizedBox(height: 10.h),
          _buildTile(
            context: context,
            isWideScreen: isWideScreen,
            index: 5,
            screen: const ContactUsScreen(),
          ),
          SizedBox(height: 20.h),
          BlocBuilder<LoginCubit, LoginState>(
            builder: (context, state) {
              return state is UserLoggingOut
                  ? Center(
                      child: SizedBox(
                        height: 24,
                        width: 24,
                        child: CircularProgressIndicator(
                          color: Colors.red,
                          strokeWidth: 2,
                        ),
                      ),
                    )
                  : ListTile(
                      leading: Icon(
                        Icons.logout_outlined,
                        size: isWideScreen ? 25.sp : 30.sp,
                        color: Colors.red,
                      ),
                      title: CustomText(
                        text: "Logout",
                        color: Colors.red,
                        fontSize: isWideScreen ? 14 : 20,
                        fontWeight: FontWeight.bold,
                      ),
                      onTap: () => loginCubit.logout(context),
                    );
            },
          ),
        ],
      ),
    );
  }

  Widget buildProfilePicture(BuildContext context, LoginCubit loginCubit) {
    return BlocBuilder<LoginCubit, LoginState>(
      builder: (context, state) {
        final isLoading = state is UploadLoading;

        return Stack(
          alignment: Alignment.center,
          children: [
            Container(
              width: 85.w,
              height: 85.w,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: Storage.userImageCached.isEmpty
                      ? Colors.red
                      : Colors.green,
                  width: 2.w,
                ),
              ),
              child: ClipOval(
                child: _buildProfileImage(Storage.userImageCached),
              ),
            ),
            if (isLoading)
              Positioned.fill(
                child: Center(
                  child: CircularProgressIndicator(
                    color: Colors.red,
                    strokeWidth: 3,
                  ),
                ),
              ),
            if (!isLoading)
              Positioned(
                bottom: 0,
                right: 0,
                child: GestureDetector(
                  onTap: () => loginCubit.uploadProfilePicture(context),
                  child: Container(
                    decoration: BoxDecoration(
                      color: Storage.userImageCached.isEmpty
                          ? Colors.red
                          : Colors.green,
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: Colors.white,
                        width: 2,
                      ),
                    ),
                    padding: EdgeInsets.all(4),
                    child: Icon(
                      Icons.camera_alt,
                      color: Colors.white,
                      size: 16.sp,
                    ),
                  ),
                ),
              ),
          ],
        );
      },
    );
  }

  Widget _buildProfileImage(String? imageUrl) {
    if (imageUrl == null ||
        imageUrl.isEmpty ||
        Uri.tryParse(imageUrl)?.hasAbsolutePath != true) {
      return Icon(
        Icons.person,
        color: Colors.white,
        size: 30.sp,
      );
    }

    final cacheBusterUrl =
        "$imageUrl?t=${DateTime.now().millisecondsSinceEpoch}";

    return CachedNetworkImage(
      imageUrl: cacheBusterUrl,
      fit: BoxFit.cover,
      placeholder: (context, url) => Center(
        child: CircularProgressIndicator(
          color: Colors.red,
          strokeWidth: 2,
        ),
      ),
      errorWidget: (context, url, error) => Icon(
        Icons.person,
        color: Colors.white,
        size: 30.sp,
      ),
      memCacheHeight: 200,
      memCacheWidth: 150,
      cacheKey: imageUrl.split('?').first,
    );
  }

  Widget _buildTile({
    required BuildContext context,
    required bool isWideScreen,
    required int index,
    required Widget screen,
  }) {
    return ListTile(
      leading: Icon(
        settings[index].icon,
        size: isWideScreen ? 25.w : 30.w,
        color: Storage.themeState == 1 ? Colors.white : bColor,
      ),
      title: CustomText(
        text: settings[index].title,
        color: Storage.themeState == 1 ? Colors.white : bColor,
        fontSize: isWideScreen ? 14 : 22,
        fontWeight: FontWeight.w600,
      ),
      subtitle: CustomText(
        text: settings[index].subtitle,
        fontSize: isWideScreen ? 10 : 12,
        color: Storage.themeState == 1 ? Colors.white.withOpacity(0.7) : bColor,
      ),
      onTap: index != 4
          ? () => N.pushto(context: context, screen: screen)
          : () async {
              final result = await Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => ThemeColorScreen()),
              );
              if (result == true) {
                setState(() {});
              }
            },
    );
  }
}
