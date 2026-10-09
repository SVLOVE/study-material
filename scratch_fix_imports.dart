import 'dart:io';

void main() {
  final dir = Directory('d:/GOVT/govprep/lib');
  final files = dir.listSync(recursive: true).whereType<File>().where((f) => f.path.endsWith('.dart'));

  for (final file in files) {
    String content = file.readAsStringSync();
    
    // Check if the file needs material.dart
    bool needsMaterial = content.contains('Widget ') || 
                         content.contains('BuildContext') || 
                         content.contains('Colors.') || 
                         content.contains('StatefulWidget') || 
                         content.contains('StatelessWidget') ||
                         content.contains('MaterialApp') ||
                         content.contains('ThemeData') ||
                         content.contains('GlassContainer') ||
                         content.contains('Scaffold');
                         
    if (needsMaterial && !content.contains("import 'package:flutter/material.dart';")) {
      // Find the last import line or beginning of file
      content = "import 'package:flutter/material.dart';\n" + content;
      file.writeAsStringSync(content);
      print('Added material.dart to ${file.path}');
    }
  }
}
