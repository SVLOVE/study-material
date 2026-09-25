import 'package:supabase_flutter/supabase_flutter.dart';
import 'device_service.dart';

class DeviceRegistrationService {
  static final _supabase = Supabase.instance.client;

  /// Returns true if device is successfully registered or already registered.
  /// Returns false if the user has reached the max device limit (2 devices).
  static Future<bool> checkAndRegisterDevice(String userId) async {
    try {
      final deviceInfo = await DeviceService.getDeviceInfo();
      final deviceId = deviceInfo['deviceId']!;
      final deviceName = deviceInfo['deviceName']!;

      // 1. Fetch existing devices for this user
      final List<dynamic> existingDevices = await _supabase
          .from('user_devices')
          .select()
          .eq('user_id', userId);

      // 2. Check if current device is already registered
      final bool isAlreadyRegistered = existingDevices.any((d) => d['device_id'] == deviceId);

      if (isAlreadyRegistered) {
        // Update last_active timestamp
        await _supabase
            .from('user_devices')
            .update({'last_active': DateTime.now().toIso8601String()})
            .eq('user_id', userId)
            .eq('device_id', deviceId);
        return true;
      }

      // 3. Current device is NEW. Check limit.
      if (existingDevices.length >= 2) {
        return false; // Limit reached!
      }

      // 4. Register new device
      await _supabase.from('user_devices').insert({
        'user_id': userId,
        'device_id': deviceId,
        'device_name': deviceName,
      });

      return true;
    } catch (e) {
      // If error occurs, we could block or allow. Better to allow and log to avoid locking out.
      return true;
    }
  }

  /// Optional: Remove a device manually
  static Future<void> removeDevice(String deviceId) async {
    await _supabase.from('user_devices').delete().eq('device_id', deviceId);
  }
}
