import 'package:abhay_app_v2/models/response/recipients/recipients_model.dart';

import '../ibase_repository.dart';

abstract class IRecipientsRepository extends IBaseRepository {
  Future<List<RecipientsModel>> getRecipients();
  Future<int> createRecipient(String code);
  Future<bool> deleteRecipient(int id);
  Future<bool> updateRecipient({
    required int id,
    String? receiverEmail,
    String? receiverPhone,
    required int isPush,
    required int isEmail,
    required int isSms,
  });
  Future<bool> addRequest({required int userId});
}
