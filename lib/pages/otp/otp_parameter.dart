enum OtpType { signUp, forgotPassword }

class OtpParameter {
  final String email;
  final OtpType type;

  OtpParameter({required this.email, required this.type});
}
