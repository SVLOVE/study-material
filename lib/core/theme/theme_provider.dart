import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

final themeModeProvider = NotifierProvider<ThemeModeNotifier, ThemeMode>(() {
  return ThemeModeNotifier();
});

class ThemeModeNotifier extends Notifier<ThemeMode> {
  @override
  ThemeMode build() {
    _loadPreference();
    return ThemeMode.light;
  }

  Future<void> _loadPreference() async {
    try {
      final user = Supabase.instance.client.auth.currentUser;
      if (user != null) {
        final response = await Supabase.instance.client
            .from('profiles')
            .select('appearance_preference')
            .eq('id', user.id)
            .maybeSingle();
            
        if (response != null && response['appearance_preference'] != null) {
          final pref = response['appearance_preference'] as String;
          if (pref == 'dark') {
            state = ThemeMode.dark;
          } else if (pref == 'system') {
            state = ThemeMode.system;
          } else {
            state = ThemeMode.light;
          }
        }
      }
    } catch (e) {
      debugPrint('Failed to load theme preference: $e');
    }
  }

  Future<void> setThemeMode(ThemeMode mode) async {
    state = mode;
    try {
      final user = Supabase.instance.client.auth.currentUser;
      if (user != null) {
        String pref = 'light';
        if (mode == ThemeMode.dark) pref = 'dark';
        if (mode == ThemeMode.system) pref = 'system';
        
        await Supabase.instance.client
            .from('profiles')
            .update({'appearance_preference': pref})
            .eq('id', user.id);
      }
    } catch (e) {
      debugPrint('Failed to save theme preference: $e');
    }
  }
}
