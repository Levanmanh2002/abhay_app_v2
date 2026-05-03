import 'package:abhay_app_v2/utils/app_constants.dart';

import 'ihtml_repository.dart';

class HtmlRepository extends IHtmlRepository {
  @override
  Future<String> getTermsAndPolicies() async {
    try {
      final response = await clientGetData(AppConstants.termsAndPoliciesUri);

      if (response.isOk) {
        return response.body?['data']?['info'] ?? '';
      } else {
        return '';
      }
    } catch (error) {
      handleError(error);
      rethrow;
    }
  }
}
