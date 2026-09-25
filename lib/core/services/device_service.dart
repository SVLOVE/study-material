import 'dart:io';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:flutter/foundation.dart';

class DeviceService {
  static final DeviceInfoPlugin _deviceInfoPlugin = DeviceInfoPlugin();

  static Future<Map<String, String>> getDeviceInfo() async {
    String deviceId = 'unknown_device_id';
    String deviceName = 'Unknown Device';

    try {
      if (kIsWeb) {
        final webBrowserInfo = await _deviceInfoPlugin.webBrowserInfo;
        deviceId = webBrowserInfo.vendor ?? 'web_vendor' + (webBrowserInfo.userAgent ?? 'web_agent');
        deviceName = webBrowserInfo.browserName.toString();
      } else if (Platform.isAndroid) {
        final androidInfo = await _deviceInfoPlugin.androidInfo;
        // In newer Android versions, androidId is not reliable, but it works for basic tracking.
        deviceId = androidInfo.id;
        deviceName = "${androidInfo.brand} ${androidInfo.model}";
      } else if (Platform.isIOS) {
        final iosInfo = await _deviceInfoPlugin.iosInfo;
        deviceId = iosInfo.identifierForVendor ?? 'unknown_ios_id';
        deviceName = iosInfo.name;
      } else if (Platform.isWindows) {
        final windowsInfo = await _deviceInfoPlugin.windowsInfo;
        deviceId = windowsInfo.deviceId;
        deviceName = windowsInfo.computerName;
      }
    } catch (e) {
      debugPrint('Failed to get device info: $e');
    }

    return {
      'deviceId': deviceId,
      'deviceName': deviceName,
    };
  }
}

