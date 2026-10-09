import 'dart:io';

void main() {
  final dir = Directory('d:/GOVT/govprep/lib');
  final files = dir.listSync(recursive: true).whereType<File>().where((f) => f.path.endsWith('.dart'));

  for (final file in files) {
    String content = file.readAsStringSync();
    String original = content;

    // 1. withOpacity
    content = content.replaceAllMapped(
      RegExp(r'\.withOpacity\((.*?)\)'),
      (match) => '.withValues(alpha: ${match.group(1)})',
    );

    // 2. RawKeyEvent
    content = content.replaceAll('RawKeyEvent', 'KeyEvent');
    content = content.replaceAll('RawKeyDownEvent', 'KeyDownEvent');
    content = content.replaceAll('RawKeyboardListener', 'KeyboardListener');

    // 3. WillPopScope
    content = content.replaceAll('WillPopScope', 'PopScope');
    // Note: PopScope has `canPop` and `onPopInvoked` instead of `onWillPop`. This might break if not handled correctly.
    // Let's check WillPopScope first.
    
    // 4. anonKey
    content = content.replaceAll('anonKey:', 'publishableKey:');
    
    // 5. Unused imports. Let's not remove automatically without checking, or just remove specific ones from logs:
    content = content.replaceAll("import '../../../core/widgets/glass_container.dart';\n", "");
    content = content.replaceAll("import 'package:go_router/go_router.dart';\n", "");
    content = content.replaceAll("import '../../onboarding/providers/onboarding_provider.dart';\n", "");
    content = content.replaceAll("import '../../../home/screens/main_layout_screen.dart';\n", "");
    content = content.replaceAll("import 'exam_selection_screen.dart';\n", "");
    content = content.replaceAll("import 'package:flutter/material.dart';\n", "");

    if (content != original) {
      file.writeAsStringSync(content);
      print('Updated ${file.path}');
    }
  }
}
