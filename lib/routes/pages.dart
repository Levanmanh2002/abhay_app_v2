import 'package:abhay_app_v2/pages/alert_history/alert_history_binding.dart';
import 'package:abhay_app_v2/pages/alert_history/alert_history_page.dart';
import 'package:abhay_app_v2/pages/change_password/change_password_binding.dart';
import 'package:abhay_app_v2/pages/change_password/change_password_page.dart';
import 'package:abhay_app_v2/pages/contact_support/contact_support_binding.dart';
import 'package:abhay_app_v2/pages/contact_support/contact_support_page.dart';
import 'package:abhay_app_v2/pages/dashboard/dashboard_binding.dart';
import 'package:abhay_app_v2/pages/dashboard/dashboard_page.dart';
import 'package:abhay_app_v2/pages/forgot_password/forgot_password_binding.dart';
import 'package:abhay_app_v2/pages/forgot_password/forgot_password_page.dart';
import 'package:abhay_app_v2/pages/html/html_binding.dart';
import 'package:abhay_app_v2/pages/html/html_page.dart';
import 'package:abhay_app_v2/pages/map_app/map_app_binding.dart';
import 'package:abhay_app_v2/pages/map_app/map_app_page.dart';
import 'package:abhay_app_v2/pages/my_info/my_info_binding.dart';
import 'package:abhay_app_v2/pages/my_info/my_info_page.dart';
import 'package:abhay_app_v2/pages/otp/otp_binding.dart';
import 'package:abhay_app_v2/pages/otp/otp_page.dart';
import 'package:abhay_app_v2/pages/settings/settings_binding.dart';
import 'package:abhay_app_v2/pages/settings/settings_page.dart';
import 'package:abhay_app_v2/pages/sign_in/sign_in_binding.dart';
import 'package:abhay_app_v2/pages/sign_in/sign_in_page.dart';
import 'package:abhay_app_v2/pages/sign_up/sign_up_binding.dart';
import 'package:abhay_app_v2/pages/sign_up/sign_up_page.dart';
import 'package:abhay_app_v2/pages/splash/splash_binding.dart';
import 'package:abhay_app_v2/pages/splash/splash_page.dart';
import 'package:abhay_app_v2/pages/supervised_users/supervised_users_binding.dart';
import 'package:abhay_app_v2/pages/supervised_users/supervised_users_page.dart';
import 'package:abhay_app_v2/pages/update_password/update_password_binding.dart';
import 'package:abhay_app_v2/pages/update_password/update_password_page.dart';
import 'package:abhay_app_v2/pages/upsert_supervised_users/upsert_supervised_users_binding.dart';
import 'package:abhay_app_v2/pages/upsert_supervised_users/upsert_supervised_users_page.dart';
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
      name: Routes.SIGN_UP,
      page: () => SignUpPage(),
      binding: SignUpBinding(),
    ),
    GetPage(
      name: Routes.FORGOT_PASSWORD,
      page: () => ForgotPasswordPage(),
      binding: ForgotPasswordBinding(),
    ),
    GetPage(
      name: Routes.OTP,
      page: () => OtpPage(),
      binding: OtpBinding(),
    ),
    GetPage(
      name: Routes.CHANGE_PASSWORD,
      page: () => ChangePasswordPage(),
      binding: ChangePasswordBinding(),
    ),
    GetPage(
      name: Routes.DASHBOARD,
      page: () => DashboardPage(),
      binding: DashboardBinding(),
    ),
    GetPage(
      name: Routes.MY_INFO,
      page: () => MyInfoPage(),
      binding: MyInfoBinding(),
    ),
    GetPage(
      name: Routes.HTML,
      page: () => HtmlPage(),
      binding: HtmlBinding(),
    ),
    GetPage(
      name: Routes.CONTACT_SUPPORT,
      page: () => ContactSupportPage(),
      binding: ContactSupportBinding(),
    ),
    GetPage(
      name: Routes.UPDATE_PASSWORD,
      page: () => UpdatePasswordPage(),
      binding: UpdatePasswordBinding(),
    ),
    GetPage(
      name: Routes.SUPERVISED_USERS,
      page: () => SupervisedUsersPage(),
      binding: SupervisedUsersBinding(),
    ),
    GetPage(
      name: Routes.UPSERT_SUPERVISED_USERS,
      page: () => UpsertSupervisedUsersPage(),
      binding: UpsertSupervisedUsersBinding(),
    ),
    GetPage(
      name: Routes.SETTINGS,
      page: () => SettingsPage(),
      binding: SettingsBinding(),
    ),
    GetPage(
      name: Routes.MAP_APP,
      page: () => MapAppPage(),
      binding: MapAppBinding(),
    ),
    GetPage(
      name: Routes.ALERT_HISTORY,
      page: () => AlertHistoryPage(),
      binding: AlertHistoryBinding(),
    ),
  ];
}
