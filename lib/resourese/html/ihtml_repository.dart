import '../ibase_repository.dart';

abstract class IHtmlRepository extends IBaseRepository {
  Future<String> getTermsAndPolicies();
}
