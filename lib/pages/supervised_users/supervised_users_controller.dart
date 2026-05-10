import 'package:abhay_app_v2/models/response/profile/user_model.dart';
import 'package:abhay_app_v2/resourese/supervised_users/isupervised_users_repository.dart';
import 'package:abhay_app_v2/utils/logger_helper.dart';
import 'package:get/get.dart';

class SupervisedUsersController extends GetxController {
  final ISupervisedUsersRepository supervisedUsersRepository;

  SupervisedUsersController({required this.supervisedUsersRepository});

  RxList<UserModel> supervisedUsers = <UserModel>[].obs;

  var isLoading = false.obs;

  @override
  void onInit() {
    super.onInit();
    fetchSupervisedUsers();
  }

  void fetchSupervisedUsers() async {
    try {
      isLoading.value = true;

      final users = await supervisedUsersRepository.getSupervisedUsers();
      supervisedUsers.assignAll(users);
    } catch (error) {
      loggerHelper.error('Error fetching supervised users: $error');
    } finally {
      isLoading.value = false;
    }
  }
}
