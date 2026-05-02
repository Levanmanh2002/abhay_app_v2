import 'dart:convert';
import 'dart:developer';
import 'dart:io';

import 'package:abhay_app_v2/resourese/api_error_handler.dart';
import 'package:abhay_app_v2/resourese/service/localization_service.dart';
import 'package:abhay_app_v2/routes/pages.dart';
import 'package:abhay_app_v2/utils/app_constants.dart';
import 'package:abhay_app_v2/utils/app_enums.dart';
import 'package:abhay_app_v2/utils/dialog_utils.dart';
import 'package:abhay_app_v2/utils/local_storage.dart';
import 'package:abhay_app_v2/utils/logger_helper.dart';
import 'package:abhay_app_v2/utils/shared_key.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;

class IBaseRepository {
  final int timeoutInSeconds = 60;

  void handleError(error) {
    loggerHelper.error(error);
    if (error.osError != null) {
      final osError = error.osError;
      if (osError.errorCode == 101) {
        DialogUtils.showErrorDialog(error.message);
      }
    }
  }

  getAuthorizationHeader() {
    final token = LocalStorage.getString(SharedKey.token);

    log(token, name: 'accesstoken-token');

    return {
      'Content-Type': 'application/json; charset=UTF-8',
      'Accept': 'application/json',
      'X-localization': LocalizationService.language.locale.languageCode,
      'accesstoken': token,
    };
  }

  Future<Response> clientGetData(String uri, {Map<String, String>? headers}) async {
    try {
      debugPrint('====> Get API Call: $uri\nHeader: ${getAuthorizationHeader()}');
      http.Response response = await http
          .get(
            Uri.parse(AppConstants.baseUrl + uri),
            headers: headers ?? getAuthorizationHeader(),
          )
          .timeout(Duration(seconds: timeoutInSeconds));

      return handleResponse(response, uri);
    } catch (e) {
      debugPrint('====> Get API Error: $e');
      rethrow;
    }
  }

  Future<Response> clientPostData(String uri, dynamic body, {Map<String, String>? headers}) async {
    try {
      debugPrint('====> Post API Call: $uri\nHeader: ${getAuthorizationHeader()}');
      debugPrint('====> Post API Body: $body');
      http.Response response = await http
          .post(
            Uri.parse(AppConstants.baseUrl + uri),
            body: jsonEncode(body),
            headers: headers ?? getAuthorizationHeader(),
          )
          .timeout(Duration(seconds: timeoutInSeconds));

      return handleResponse(response, uri);
    } catch (e) {
      debugPrint('====> Post API Error: $e');
      rethrow;
    }
  }

  Future<Response> clientPostMultipartData(
    String uri,
    Map<String, String> body,
    List<MultipartBody> multipartBody, {
    Map<String, String>? headers,
  }) async {
    try {
      debugPrint('====> API Call: $uri\nHeader: ${getAuthorizationHeader()}');
      debugPrint('====> API Body: $body with ${multipartBody.length} files');
      http.MultipartRequest request = http.MultipartRequest('POST', Uri.parse(AppConstants.baseUrl + uri));
      request.headers.addAll(headers ?? getAuthorizationHeader());
      for (MultipartBody multipart in multipartBody) {
        if (multipart.file != null) {
          File file = File(multipart.file!.path);
          request.files.add(http.MultipartFile(
            multipart.key,
            file.readAsBytes().asStream(),
            file.lengthSync(),
            filename: file.path.split('/').last,
          ));
        }
      }
      request.fields.addAll(body);
      http.Response response = await http.Response.fromStream(await request.send());
      return handleResponse(response, uri);
    } catch (e) {
      loggerHelper.error('====> Post AND FILES API Error: $e');
      rethrow;
    }
  }

  Future<Response> clientPutData(String uri, dynamic body, {Map<String, String>? headers}) async {
    try {
      loggerHelper.logBlue(
        '📡 Put API Call: $uri\n🧾 Header: ${getAuthorizationHeader()}\n📦 Put API Body: $body',
        name: 'PUT',
      );
      http.Response response = await http
          .put(
            Uri.parse(AppConstants.baseUrl + uri),
            body: jsonEncode(body),
            headers: headers ?? getAuthorizationHeader(),
          )
          .timeout(Duration(seconds: timeoutInSeconds));

      return handleResponse(response, uri);
    } catch (e) {
      loggerHelper.error('====> Post API Error: $e');
      rethrow;
    }
  }

  Future<Response> clientDeleteData(String uri, {Map<String, String>? headers, dynamic body}) async {
    try {
      final jsonBody = body != null ? jsonEncode(body) : null;

      debugPrint('====> DELETE API Call: $uri\nHeader: ${getAuthorizationHeader()}');
      if (jsonBody != null) {
        debugPrint('====> DELETE API Body: $jsonBody');
      }

      http.Response response = await http
          .delete(
            Uri.parse(AppConstants.baseUrl + uri),
            body: jsonBody,
            headers: headers ?? getAuthorizationHeader(),
          )
          .timeout(Duration(seconds: timeoutInSeconds));

      return handleResponse(response, uri);
    } catch (e) {
      return Response(statusCode: 1, statusText: 'connection_to_api_server_failed'.tr);
    }
  }

  Future<Response> handleResponse(http.Response response, String uri) async {
    dynamic body;
    try {
      body = jsonDecode(response.body);
    } catch (_) {}
    Response response0 = Response(
      body: body ?? response.body,
      bodyString: response.body.toString(),
      headers: response.headers,
      statusCode: response.statusCode,
      statusText: response.reasonPhrase,
    );

    if (response0.statusCode == 401 && Get.currentRoute != Routes.SIGN_IN) {
      await ApiErrorManager.handle401IfNeeded(() async {
        await _logout();
      });
    }

    if (response0.isOk) {
      debugPrint('====> API Response: [${response0.statusCode}] $uri');
      debugPrint('====> API Response Body: ${response0.body.toString()}');
    } else {
      loggerHelper.error('====> API Response: [${response0.statusCode}] $uri');
      loggerHelper.error('====> API Response Body: ${response0.body.toString()}');
    }

    return response0;
  }

  Future<void> _logout() async {
    if (Get.currentRoute == Routes.SIGN_IN) return;

    String? savedLanguage = LocalStorage.getString(SharedKey.language);

    await LocalStorage.clearAll();

    if (savedLanguage.isNotEmpty) {
      await LocalStorage.setString(SharedKey.language, savedLanguage);
    }
    Get.offAllNamed(Routes.SIGN_IN);
  }
}

class MultipartBody {
  String key;
  File? file;

  MultipartBody(this.key, this.file);
}
