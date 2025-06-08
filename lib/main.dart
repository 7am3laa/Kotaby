import 'package:audio_service/audio_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get_navigation/src/root/get_material_app.dart';
import 'package:kotaby/UI/screens/auth%20screen/auth_screen.dart';
import 'package:kotaby/UI/screens/auth%20screen/cubits/login%20cubit/login_cubit.dart';
import 'package:kotaby/UI/screens/auth%20screen/cubits/signup%20cubit/signup_cubit.dart';
import 'package:kotaby/UI/screens/main%20screen/main_screen.dart';
import 'package:kotaby/UI/screens/settings%20screen/cubits/contact_us_cubit.dart';
import 'package:kotaby/UI/screens/settings%20screen/cubits/notification_cubit.dart';
import 'package:kotaby/UI/screens/settings%20screen/cubits/update_info_cubit.dart';
import 'package:kotaby/audio_player_handler.dart';
import 'package:kotaby/constants/constants.dart';
import 'package:kotaby/notfications_service.dart';
import 'package:kotaby/storage.dart';

late AudioPlayerHandler audioHandler;
Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await NotificationsService.initialize();
  SystemChrome.setPreferredOrientations(
    [
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ],
  );

  audioHandler = await AudioService.init(
    builder: () => AudioPlayerHandler(),
    config: const AudioServiceConfig(
      androidNotificationChannelId: 'media_channel',
      androidNotificationChannelName: 'Media Playback',
      androidNotificationOngoing: true,
    ),
  );
  await Storage.init();
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(create: (context) => LoginCubit()),
        BlocProvider(create: (context) => SignupCubit()),

        // BlocProvider(create: (context) => AllSurahCubit()),
        BlocProvider(create: (context) => UpdateInfoCubit()),
        BlocProvider(create: (context) => NotificationCubit()),
        BlocProvider(create: (context) => ContactUsCubit()),
      ],
      child: ScreenUtilInit(
        designSize: const Size(392.72727272727275, 800.7272727272727),
        minTextAdapt: true,
        splitScreenMode: true,
        child: GetMaterialApp(
          debugShowCheckedModeBanner: false,
          title: 'Kotaby',
          theme: ThemeData(
            colorScheme: ColorScheme.fromSeed(seedColor: primaryColor),
            useMaterial3: false,
          ),
          home: Storage.isLoggedIn ? MainScreen() : AuthScreen(),
        ),
      ),
    );
  }
}
