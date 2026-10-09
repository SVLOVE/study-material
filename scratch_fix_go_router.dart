import 'dart:io';

void main() {
  final dir = Directory('d:/GOVT/govprep/lib');
  final files = dir.listSync(recursive: true).whereType<File>().where((f) => f.path.endsWith('.dart'));

  for (final file in files) {
    String content = file.readAsStringSync();
    
    // Check if the file needs go_router
    bool needsGoRouter = content.contains('context.go(') || 
                         content.contains('context.push(') || 
                         content.contains('context.pop(') || 
                         content.contains('context.pushReplacement(') ||
                         content.contains('context.canPop()');
                         
    if (needsGoRouter && !content.contains("import 'package:go_router/go_router.dart';")) {
      content = "import 'package:go_router/go_router.dart';\n" + content;
      file.writeAsStringSync(content);
      print('Added go_router.dart to ${file.path}');
    }
  }
}
