import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'dart:io';

class AuthRepository {
  final SupabaseClient _supabase = Supabase.instance.client;
  final DeviceInfoPlugin _deviceInfo = DeviceInfoPlugin();

  Stream<AuthState> get authStateChanges => _supabase.auth.onAuthStateChange;

  User? get currentUser => _supabase.auth.currentUser;

  Future<AuthResponse> signInWithEmailPassword(String email, String password) async {
    final response = await _supabase.auth.signInWithPassword(email: email, password: password);
    if (response.user != null) {
      await _registerDevice(response.user!.id);
    }
    return response;
  }

  Future<AuthResponse> signUpWithEmailPassword(String email, String password, String fullName) async {
    return await _supabase.auth.signUp(
      email: email,
      password: password,
      data: {'full_name': fullName},
    );
  }

  Future<void> resetPasswordForEmail(String email) async {
    await _supabase.auth.resetPasswordForEmail(email, redirectTo: 'govprep://login-callback');
  }

  Future<void> signOut() async {
    final user = _supabase.auth.currentUser;
    if (user != null) {
      try {
        final deviceId = await _getDeviceId();
        await _supabase.from('user_devices').delete().eq('user_id', user.id).eq('device_id', deviceId);
      } catch (e) {
        // Log error silently, proceed to signout
      }
    }
    await _supabase.auth.signOut();
  }

  Future<String> _getDeviceId() async {
    if (Platform.isAndroid) {
      final androidInfo = await _deviceInfo.androidInfo;
      return androidInfo.id;
    } else if (Platform.isIOS) {
      final iosInfo = await _deviceInfo.iosInfo;
      return iosInfo.identifierForVendor ?? 'unknown_ios';
    }
    return 'unknown_device';
  }

  Future<void> _registerDevice(String userId) async {
    try {
      final deviceId = await _getDeviceId();
      final devices = await _supabase.from('user_devices').select('id, device_id').eq('user_id', userId);
      
      bool deviceExists = devices.any((d) => d['device_id'] == deviceId);
      
      if (!deviceExists) {
        if (devices.length >= 2) {
          throw Exception('Device limit reached. You can only login on 2 devices.');
        }
        
        await _supabase.from('user_devices').insert({
          'user_id': userId,
          'device_id': deviceId,
          'device_name': Platform.isAndroid ? 'Android Device' : 'iOS Device',
        });
      } else {
        await _supabase.from('user_devices').update({
          'last_login': DateTime.now().toIso8601String()
        }).eq('user_id', userId).eq('device_id', deviceId);
      }
    } catch (e) {
      // Re-throw if it's the limit exception
      if (e.toString().contains('Device limit reached')) rethrow;
      // Otherwise log and ignore so they can still login if DB fails
      print('Device registration failed');
    }
  }
}
