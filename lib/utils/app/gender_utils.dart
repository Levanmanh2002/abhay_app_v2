import 'package:get/get.dart';

enum Gender {
  male,
  female,
  // other,
}

extension GenderExtension on Gender {
  String get displayName {
    switch (this) {
      case Gender.male:
        return 'male'.tr;
      case Gender.female:
        return 'female'.tr;
      // case Gender.other:
      //   return 'other'.tr;
    }
  }

  // LinearGradient get gradient {
  //   switch (this) {
  //     case Gender.male:
  //       return AppGradient.gradientBlueGenderMale;
  //     case Gender.female:
  //       return AppGradient.gradientPinkFemale;
  //   }
  // }
}

extension GenderParsing on String {
  Gender get toGender {
    switch (toLowerCase()) {
      case 'male':
        return Gender.male;
      case 'female':
        return Gender.female;
      // case 'other':
      //   return Gender.other;
      default:
        return Gender.male;
    }
  }
}
