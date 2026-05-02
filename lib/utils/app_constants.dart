import 'package:flutter_dotenv/flutter_dotenv.dart';

class AppConstants {
  static const String appName = 'Abhay App';

  static const int minNameLength = 2;
  static const int minAddressLength = 12;
  static const int maxAddressLength = 100;
  static const int maxNameLength = 255;
  static const int timeOtp = 120;
  static const int secondsTimeBannerSlide = 5;
  static const int otpLength = 4;

  static const int LIMIT = 20;
  static const int DEFAULT_VIP_LIMIT = 50;
  static const int DEFAULT_NUMBER_OF_DAYS_CHECK_CUSTOMER_VIP = 4;
  static const int DEFAULT_OLD_CUSTOMER_LIMIT = 2;
  static const int DEFAULT_NUMBER_OF_DAYS_CALCULATE_CUSTOMER_VISIT = 30;
  static const int MIN_LENGTH_NAME_SERVICE = 3;
  static const int MAX_IMAGE_BANNER_STORE = 3;
  static const int DEFAULT_POINT_RATIO_PER_USD = 100;

  static String baseUrl = dotenv.get('BASE_URL');
  static String socketUrl = dotenv.get('SOCKET_URL');
  static String windowsNotificationGuid = dotenv.get('WINDOW_NOTI_GUID');

  static const String notificationChannelId = 'POSNAIL_IPAD_CHANNEL_ID';

  static const String pos = 'pos';
  static const String all = 'all';

  //end-point
  static const String loginUri = '/api/v1/login';
  static const String signUpUri = '/api/v1/register';
  static const String resendOtpUri = '/api/v1/resend-otp';
  static const String verifyOtpUri = '/api/v1/verify';
  static const String forgotPasswordUri = '/api/v1/reset-password';
  static const String resetPasswordUri = '/api/v1/reset-password/update-password';

  static const String logoutUri = '/auth/logout';
}
