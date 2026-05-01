import 'package:abhay_app_v2/pages/dashboard/dashboard_binding.dart';
import 'package:abhay_app_v2/pages/dashboard/dashboard_page.dart';
import 'package:abhay_app_v2/pages/sign_in/sign_in_binding.dart';
import 'package:abhay_app_v2/pages/sign_in/sign_in_page.dart';
import 'package:abhay_app_v2/pages/splash/splash_binding.dart';
import 'package:abhay_app_v2/pages/splash/splash_page.dart';
import 'package:get/get.dart';

part 'routes.dart';

abstract class AppPages {
  static final pages = [
    GetPage(
      name: Routes.SPLASH,
      page: () => SplashPage(),
      binding: SplashBinding(),
    ),
    GetPage(
      name: Routes.SIGN_IN,
      page: () => SignInPage(),
      binding: SignInBinding(),
    ),
    GetPage(
      name: Routes.DASHBOARD,
      page: () => DashboardPage(),
      binding: DashboardBinding(),
    ),
  ];
}
