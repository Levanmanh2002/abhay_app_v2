import 'package:flutter_dotenv/flutter_dotenv.dart';

class AppConstants {
  static const String appName = 'Chaitany Abhay';

  static const int minNameLength = 2;
  static const int minAddressLength = 12;
  static const int maxAddressLength = 100;
  static const int maxNameLength = 255;
  static const int timeOtp = 120;
  static const int secondsTimeBannerSlide = 5;
  static const int otpLength = 4;

  static const int LIMIT = 20;

  static String baseUrl = dotenv.get('BASE_URL');
  static String socketUrl = dotenv.get('SOCKET_URL');
  static String apiKey = dotenv.get('API_KEY');

  static const String notificationChannelId = 'notification';

  //end-point
  static const String loginUri = '/api/v1/login';
  static const String signUpUri = '/api/v1/register';
  static const String resendOtpUri = '/api/v1/resend-otp';
  static const String verifyOtpUri = '/api/v1/verify';
  static const String forgotPasswordUri = '/api/v1/reset-password';
  static const String resetPasswordUri = '/api/v1/reset-password/update-password';
  static const String profileUri = '/api/v1/auth';
  static const String updateProfileUri = '/api/v1/auth/update';
  static const String termsAndPoliciesUri = '/api/v1/setting/terms-policies';
  static const String configInfoUri = '/api/v1/setting/contact';
  static const String changePasswordUri = '/api/v1/auth/update-password';
  static const String logoutUri = '/auth/logout';

  static const String createSupervisedUsersUri = '/api/';
  static const String sendOTPChildUri = '/api/v1/children/send-otp';
  static const String verifyOTPAddChildUri = '/api/v1/children/verify-otp';
  static const String getSupervisedUsersUri = '/api/v1/children';

  static const String getRecipientsUri = '/api/v1/user-notifications';
  static const String createRecipientUri = '/api/v1/users/show';
  static const String getNotiAlertsUri = '/api/v1/notifications/alert';
}

