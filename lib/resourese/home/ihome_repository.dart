import '../ibase_repository.dart';

abstract class IHomeRepository extends IBaseRepository {
  Future<bool> onSosSend({
    required double latitude,
    required double longitude,
    required String address,
    String? content,
  });
}
