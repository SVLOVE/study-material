import 'dart:io';

void main() {
  final dir = Directory('d:/GOVT/govprep/lib');
  final files = dir.listSync(recursive: true).whereType<File>().where((f) => f.path.endsWith('.dart'));

  for (final file in files) {
    String content = file.readAsStringSync();
    
    bool needsGlass = content.contains('GlassContainer(');
    
    if (needsGlass && !content.contains('glass_container.dart')) {
      // calculate relative path from file to lib/core/widgets/glass_container.dart
      String path = file.path.replaceAll('\\', '/');
      List<String> parts = path.split('/lib/');
      if (parts.length == 2) {
        String libPath = parts[1]; // e.g. features/admin/screens/admin_dashboard_screen.dart
        int depth = libPath.split('/').length - 1;
        String prefix = '';
        for (int i = 0; i < depth; i++) {
          prefix += '../';
        }
        String importStmt = "import '${prefix}core/widgets/glass_container.dart';\n";
        content = importStmt + content;
        file.writeAsStringSync(content);
        print('Added glass_container to ${file.path}');
      }
    }
  }
}
