import 'dart:io';

import 'package:abhay_app_v2/extension/color_extension.dart';
import 'package:abhay_app_v2/resourese/service/app_service.dart';
import 'package:abhay_app_v2/resourese/service/localization_service.dart';
import 'package:abhay_app_v2/routes/pages.dart';
import 'package:abhay_app_v2/theme/app_theme_util.dart';
import 'package:abhay_app_v2/theme/base_theme_data.dart';
import 'package:abhay_app_v2/utils/app_constants.dart';
import 'package:abhay_app_v2/utils/app_enums.dart';
import 'package:abhay_app_v2/utils/local_storage.dart';
import 'package:abhay_app_v2/widget/reponsive/size_config.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:get/get.dart';
import 'package:launch_at_startup/launch_at_startup.dart';
import 'package:window_manager/window_manager.dart';

// final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();

AppThemeUtil themeUtil = AppThemeUtil();
BaseThemeData get appTheme => themeUtil.getAppTheme();

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await dotenv.load(fileName: '.env');
  await LocalStorage.init();
  await AppService.initAppService();
  await SystemChrome.setPreferredOrientations([DeviceOrientation.landscapeRight, DeviceOrientation.landscapeLeft]);
  if (Platform.isMacOS || Platform.isWindows || Platform.isLinux || kIsWeb) {
    await windowManager.ensureInitialized();
    WindowOptions windowOptions = WindowOptions(
      size: const Size(1180, 820),
      minimumSize: const Size(1000, 700),
      center: true,
      backgroundColor: appTheme.transparentColor,
      titleBarStyle: Platform.isWindows ? TitleBarStyle.normal : TitleBarStyle.hidden,
    );
    windowManager.waitUntilReadyToShow(windowOptions, () async {
      await windowManager.show();
      await windowManager.focus();
      await windowManager.maximize();
    });
  }
  if (Platform.isMacOS || Platform.isWindows) {
    launchAtStartup.setup(appName: AppConstants.appName, appPath: Platform.resolvedExecutable);
  }
  // if (!Platform.isWindows) {
  //   await Firebase.initializeApp();
  //   NotificationService().onInit();
  // }
  runApp(LayoutBuilder(builder: (context, constraints) {
    SizeConfig.instance.init(
      constraints: constraints,
      screenHeight: constraints.maxHeight,
      screenWidth: constraints.maxWidth,
    );

    return const MyApp();
  }));
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  void dispose() {
    themeUtil.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MediaQuery(
      data: MediaQuery.of(context).copyWith(textScaler: const TextScaler.linear(1.0)),
      child: GetMaterialApp(
        title: AppConstants.appName,
        debugShowCheckedModeBanner: false,
        locale: LocalizationService.language.locale,
        supportedLocales: LocalizationService.supportedLanguage.map((e) => e.locale).toList(),
        localizationsDelegates: const [
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
        fallbackLocale: LocalizationService.fallbackLanguage.locale,
        translations: LocalizationService(),
        theme: ThemeData(
          primarySwatch: MaterialColor(
            appTheme.appColor.toInt32,
            <int, Color>{
              50: appTheme.appColor,
              100: appTheme.appColor,
              200: appTheme.appColor,
              300: appTheme.appColor,
              400: appTheme.appColor,
              500: appTheme.appColor,
              600: appTheme.appColor,
              700: appTheme.appColor,
              800: appTheme.appColor,
              900: appTheme.appColor,
            },
          ),
          scaffoldBackgroundColor: appTheme.whiteColor,
        ),
        initialRoute: Routes.SPLASH,
        getPages: AppPages.pages,
        builder: EasyLoading.init(),
      ),
    );
  }
}
