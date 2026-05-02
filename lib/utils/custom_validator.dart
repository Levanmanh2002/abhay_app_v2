import 'package:abhay_app_v2/utils/app_constants.dart';
import 'package:abhay_app_v2/utils/util.dart';
import 'package:get/get.dart';

class CustomValidator {
  static final RegExp emailRegex = RegExp(
      r'^(([^<>()[\]\\.,;:\s@\"]+(\.[^<>()[\]\\.,;:\s@\"]+)*)|(\".+\"))@((\[[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\])|(([a-zA-Z\-0-9]+\.)+[a-zA-Z]{2,}))$');

  static final RegExp passwordRegex = RegExp(
    r'^(?!.*[ÀÁÂÃÈÉÊÌÍÒÓÔÕÙÚĂĐĨŨƠàáâãèéêìíòóôõùúăđĩũơƯưĂâđêôơư])(?=.*[A-Z])(?=.*[a-z])(?=.*[0-9])(?=.*[#?!@$%^&*-])\S{8,}$',
  );

  static String validatePhone(String phone, {bool isRequired = true}) {
    if (isRequired && phone.trim().isEmpty) {
      return 'field_is_required'.trParams({'field': 'phone_number'.tr});
    }
    if (isRequired && !Utils.isPhoneNumber(phone)) {
      return 'field_is_invalid'.trParams({'field': 'phone_number'.tr});
    }
    return '';
  }

  static String validateFullName(String fullName, {bool isRequired = true}) {
    if (isRequired && fullName.trim().isEmpty) {
      return 'field_is_required'.trParams({'field': 'full_name'.tr});
    }
    if (fullName.isNotEmpty && fullName.trim().length < AppConstants.minNameLength ||
        fullName.trim().length > AppConstants.maxNameLength) {
      return 'enter_full_field'.trParams({'field': 'full_name'.tr.toLowerCase()});
    }
    return '';
  }

  static String validateFirstName(String fullName) {
    if (fullName.trim().isEmpty) {
      return 'field_is_required'.trParams({'field': 'first_name'.tr});
    }
    if (fullName.trim().length < AppConstants.minNameLength || fullName.trim().length > AppConstants.maxNameLength) {
      return 'enter_full_field'.trParams({'field': 'first_name'.tr.toLowerCase()});
    }
    return '';
  }

  static String validateLastName(String fullName, {bool isRequired = true}) {
    if (fullName.trim().isEmpty) {
      return isRequired ? 'field_is_required'.trParams({'field': 'last_name'.tr}) : '';
    }
    if (fullName.trim().length < AppConstants.minNameLength || fullName.trim().length > AppConstants.maxNameLength) {
      return 'enter_full_field'.trParams({'field': 'last_name'.tr.toLowerCase()});
    }
    return '';
  }

  static String validateStoreCode(String code) {
    if (code.trim().isEmpty) {
      return 'field_is_required'.trParams({'field': 'store_code'.tr});
    }
    if (code.trim().length < AppConstants.minNameLength || code.trim().length > AppConstants.maxNameLength) {
      return 'enter_full_field'.trParams({'field': 'store_code'.tr.toLowerCase()});
    }
    return '';
  }

  static String validatePassword(String password) {
    if (password.isEmpty) {
      return 'field_is_required'.trParams({'field': 'password'.tr});
    } else if (password.length < 6) {
      return 'common_pwd_too_short'.tr;
    }
    return '';
  }

  static String validateEmail(String? email, {bool isRequired = true}) {
    if (email == null || email.trim().isEmpty) {
      return isRequired ? 'field_is_required'.trParams({'field': 'email'.tr}) : '';
    }
    final regex = RegExp(r'^[\w\.-]+@[\w\.-]+\.\w+$');
    return regex.hasMatch(email.trim()) ? '' : 'field_is_invalid'.trParams({'field': 'email'.tr});
  }

  static String validateAddress(String address, {bool isRequired = true}) {
    if (address.trim().isEmpty) {
      return isRequired ? 'field_is_required'.trParams({'field': 'address'.tr}) : '';
    }
    if (address.trim().length < AppConstants.minAddressLength ||
        address.trim().length > AppConstants.maxAddressLength) {
      return 'enter_full_field'.trParams({'field': 'address'.tr.toLowerCase()});
    }
    return '';
  }

  static String validatePhoneSync(String phone, {bool isRequired = true}) {
    final trimmed = phone.trim();

    if (trimmed.isEmpty) {
      return isRequired ? 'field_is_required'.trParams({'field': 'phone_number'.tr}) : '';
    }

    final digits = trimmed.replaceAll(RegExp(r'\D'), '');
    if (isRequired && digits.isEmpty) {
      return 'field_is_invalid'.trParams({'field': 'phone_number'.tr});
    }

    if (digits.isNotEmpty && digits.length != 10) {
      return 'phone_number_must_be_10_digits'.tr;
    }

    final areaCode = digits.substring(0, 3);
    final isUsPhone = RegExp(r'^[2-9][0-9]{2}$').hasMatch(areaCode);
    if (!isUsPhone) {
      return 'this_is_not_a_valid_us_phone'.tr;
    }

    return '';
  }

  static String validateRequiredField(String value, String fieldName, {bool isRequired = true}) {
    if (value.trim().isEmpty) {
      return isRequired ? 'field_is_required'.trParams({'field': fieldName}) : '';
    }
    return '';
  }

  static String validateRequiredAndMinLength(String value, String fieldName, {int minLength = 3}) {
    if (value.trim().isEmpty) {
      return 'field_is_required'.trParams({'field': fieldName});
    }
    if (value.trim().length < minLength) {
      return 'field_must_be_at_least_min_characters'.trParams({'field': fieldName, 'min': minLength.toString()});
    }
    return '';
  }

  static String validateUrlField(String url, {String fieldName = '', bool isRequired = false}) {
    if (url.trim().isEmpty) {
      if (isRequired) {
        return 'field_is_required'.trParams({'field': fieldName});
      }
      return '';
    }

    final uri = Uri.tryParse(url.trim());

    if (uri == null || !uri.isAbsolute || uri.host.isEmpty || (uri.scheme != 'http' && uri.scheme != 'https')) {
      return 'field_is_invalid'.trParams({'field': fieldName});
    }

    return '';
  }
}

class PhoneValid {
  bool isValid;
  String phone;

  PhoneValid({required this.isValid, required this.phone});
}
