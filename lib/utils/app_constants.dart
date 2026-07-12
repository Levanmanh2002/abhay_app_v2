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
  static String tomtomApiKey = dotenv.get('TOMTOM_API_KEY');
  static String keySpeedLimit = dotenv.get('KEY_SPEED_LIMIT');
  static String urlSpeedLimit = dotenv.get('URL_SPEED_LIMIT');

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
  static const String logoutUri = '/';
  static const String updateFcmTokenUri = '/api/v1/notifications/update-device-token';

  static const String createSupervisedUsersUri = '/api/';
  static const String sendOTPChildUri = '/api/v1/children/send-otp';
  static const String verifyOTPAddChildUri = '/api/v1/children/verify-otp';
  static const String getSupervisedUsersUri = '/api/v1/children';

  static const String addRequestUri = '/api/v1/requests/add';
  static const String getUserLocationHistoryUri = '/api/v1/children/location-history';
  static const String getRecipientsUri = '/api/v1/user-notifications';
  static const String createRecipientUri = '/api/v1/users/show';
  static const String deleteRecipientUri = '/api/v1/user-notifications';
  static const String updateRecipientUri = '/api/v1/user-notifications/update';
  static const String getAlertDetailUri = '/api/v1/notifications/alert-show';

  static const String getNotiAlertsUri = '/api/v1/notifications/alert';
  static const String getReceivedAlertsUri = '/api/v1/notifications/alert'; // GET - nhận từ người khác
  static const String getReceiverRequestsUri = '/api/v1/requests';
  static const String confirmReceiverRequestUri = '/api/v1/requests/confirm'; // GET /{id}
  static const String deleteReceiverRequestUri = '/api/v1/requests/delete'; // GET /{id}
  static const String getAcceptedSendersUri = '/api/v1/user-notifications/get-sender';

  // Tracking / Alert
  static const String sendAlertUri = '/api/v1/notifications/send-notification';
  static const String alertHistoryUri = '/api/v1/notifications/send-alert-history';
  static const String updateUserUri = '/api/v1/auth/update';

  static const String sosUri = '/api/v1/sos/send';

  // TomTom Traffic Incidents API
  // key dùng chung KEY_SPEED_LIMIT (đã có quyền Traffic Incidents API)
  static const String trafficIncidentsUrl = 'https://api.tomtom.com/traffic/services/5/incidentDetails';
}
