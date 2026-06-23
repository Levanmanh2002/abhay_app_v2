import 'package:abhay_app_v2/utils/logger_helper.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';

class PlacemarkAddress {
  final String fullAddress;
  final String shortAddress;

  PlacemarkAddress({required this.fullAddress, required this.shortAddress});
}

class MapUtils {
  static Future<PlacemarkAddress> getAddressFromPosition(Position? position) async {
    if (position == null) return PlacemarkAddress(fullAddress: '', shortAddress: '');

    final fallback = '${position.latitude}, ${position.longitude}';

    try {
      final placemarks = await placemarkFromCoordinates(position.latitude, position.longitude);

      if (placemarks.isEmpty) {
        return PlacemarkAddress(fullAddress: fallback, shortAddress: fallback);
      }

      final placemark = placemarks[0];

      List<String> buildAddress(List<String?> parts) {
        final result = <String>[];
        for (final part in parts) {
          if (part == null || part.isEmpty) continue;
          if (result.isNotEmpty && result.last == part) continue;
          result.add(part);
        }
        return result;
      }

      final shortAddress = buildAddress([
        placemark.subThoroughfare,
        placemark.thoroughfare,
        placemark.subLocality,
      ]).join(', ');

      final fullAddress = buildAddress([
        placemark.subThoroughfare,
        placemark.thoroughfare,
        placemark.subLocality,
        placemark.locality,
        placemark.subAdministrativeArea,
        placemark.administrativeArea,
        placemark.country,
      ]).join(', ');

      return PlacemarkAddress(
        fullAddress: fullAddress.isNotEmpty ? fullAddress : fallback,
        shortAddress: shortAddress.isNotEmpty ? shortAddress : fallback,
      );
    } catch (e) {
      loggerHelper.log('Error in getAddressFromPosition: $e');
      return PlacemarkAddress(fullAddress: fallback, shortAddress: fallback);
    }
  }

  static Future<Position?> determinePosition() async {
    if (!await Geolocator.isLocationServiceEnabled()) {
      await Geolocator.openLocationSettings();
      return null;
    }

    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
    }

    if (permission == LocationPermission.denied) {
      return null;
    }

    if (permission == LocationPermission.deniedForever) {
      await Geolocator.openAppSettings();
      return null;
    }

    return await Geolocator.getCurrentPosition(
      locationSettings: const LocationSettings(accuracy: LocationAccuracy.high, distanceFilter: 10),
    );
  }
}
