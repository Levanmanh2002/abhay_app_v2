import 'dart:io';

import 'package:abhay_app_v2/utils/logger_helper.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:url_launcher/url_launcher_string.dart';

Future<void> makePhoneCall(String phoneNumber) async {
  if (phoneNumber.isEmpty) return;
  final Uri phoneUri = Uri(scheme: 'tel', path: phoneNumber);

  if (await canLaunchUrl(phoneUri)) {
    await launchUrl(phoneUri);
  } else {
    throw 'Could not launch $phoneUri';
  }
}

Future<void> openWebPage(String url) async {
  if (await canLaunchUrlString(url)) {
    try {
      await launchUrlString(url, mode: LaunchMode.externalApplication);
    } catch (e) {
      loggerHelper.error('Error launching URL: $e');
    }
  } else {
    loggerHelper.error('Could not launch URL: $url');
  }
}

Future<void> launchMapsDirURl({required String start, required String end}) async {
  String appleUrl = 'https://maps.apple.com/?saddr=&daddr=$end&directionsmode=driving';
  String googleUrl = 'https://www.google.com/maps/dir/$start/$end';

  if (Platform.isIOS) {
    if (await canLaunchUrl(Uri.parse(appleUrl))) {
      await launchUrl(Uri.parse(appleUrl));
    }
  } else {
    if (await canLaunchUrl(Uri.parse(googleUrl))) {
      await launchUrl(Uri.parse(googleUrl));
    } else {
      throw 'Could not open the map.';
    }
  }
}

Future<void> launchUrlLink(
  String url, {
  bool? isOpenBrowser,
  bool forceOpen = false,
}) async {
  Uri uri = Uri.parse(url);
  if (forceOpen && uri.scheme.isEmpty) {
    uri = uri.replace(scheme: 'https');
  }
  if (await canLaunchUrl(uri)) {
    await launchUrl(
      uri,
      mode: (isOpenBrowser ?? false) ? LaunchMode.externalApplication : LaunchMode.platformDefault,
    );
  }
}

Future<void> onLaunchZaloUrl(String phoneNumber) async {
  final String url = 'https://zalo.me/$phoneNumber';
  if (await canLaunchUrlString(url)) {
    await launchUrlString(url, mode: LaunchMode.externalApplication);
  } else {
    throw 'Could not launch Zalo URL: $url';
  }
}
