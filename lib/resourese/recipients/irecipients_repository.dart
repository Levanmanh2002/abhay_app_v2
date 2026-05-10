import 'package:abhay_app_v2/models/response/recipients/recipients_model.dart';

import '../ibase_repository.dart';

abstract class IRecipientsRepository extends IBaseRepository {
  Future<List<RecipientsModel>> getRecipients();
  Future<bool> createRecipient(String code);
}
