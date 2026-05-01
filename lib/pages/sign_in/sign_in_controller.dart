import 'package:abhay_app_v2/resourese/auth/iauth_repository.dart';
import 'package:get/get.dart';

class SignInController extends GetxController {
  final IAuthRepository authRepository;

  SignInController({
    required this.authRepository,
  });
}
