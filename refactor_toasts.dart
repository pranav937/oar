import 'dart:io';

void main() {
  final directory = Directory('lib/screens');
  final files = directory
      .listSync(recursive: true)
      .whereType<File>()
      .where((f) => f.path.endsWith('.dart'));

  final scaffoldRegex = RegExp(
    r"ScaffoldMessenger\.of\([^)]+\)\.showSnackBar\(\s*const\s*SnackBar\(\s*content\:\s*Text\('([^']+)'\)[^)]*\)\s*,\s*\);",
    multiLine: true,
  );

  final scaffoldRegexNoConst = RegExp(
    r"ScaffoldMessenger\.of\([^)]+\)\.showSnackBar\(\s*SnackBar\(\s*content\:\s*Text\('([^']+)'\)[^)]*\)\s*,\s*\);",
    multiLine: true,
  );

  final scaffoldRegexVar = RegExp(
    r"ScaffoldMessenger\.of\([^)]+\)\.showSnackBar\(\s*SnackBar\(\s*content\:\s*Text\(([^)]+)\)[^)]*\)\s*,\s*\);",
    multiLine: true,
  );

  for (final file in files) {
    String content = file.readAsStringSync();
    bool changed = false;

    // Add import if needed
    if (!content.contains('custom_toast.dart') &&
        content.contains('ScaffoldMessenger')) {
      // Find the last import
      final importRegex = RegExp(r"import\s+'[^']+';");
      final imports = importRegex.allMatches(content);
      if (imports.isNotEmpty) {
        final lastImport = imports.last;
        content = content.replaceRange(
          lastImport.end,
          lastImport.end,
          "\nimport '../utils/custom_toast.dart';",
        );
        changed = true;
      }
    }

    // Attempt replacing standard const Snackbar
    content = content.replaceAllMapped(scaffoldRegex, (match) {
      changed = true;
      String text = match.group(1)!;
      bool isError =
          text.toLowerCase().contains('fail') ||
          text.toLowerCase().contains('error') ||
          text.toLowerCase().contains('invalid') ||
          text.toLowerCase().contains('incorrect') ||
          text.toLowerCase().contains('try again') ||
          text.toLowerCase().contains('match');
      if (isError) {
        return "CustomToast.showError(context, '$text');";
      } else {
        return "CustomToast.showSuccess(context, '$text');";
      }
    });

    content = content.replaceAllMapped(scaffoldRegexNoConst, (match) {
      changed = true;
      String text = match.group(1)!;
      bool isError =
          text.toLowerCase().contains('fail') ||
          text.toLowerCase().contains('error') ||
          text.toLowerCase().contains('invalid') ||
          text.toLowerCase().contains('incorrect') ||
          text.toLowerCase().contains('try again') ||
          text.toLowerCase().contains('match');
      if (isError) {
        return "CustomToast.showError(context, '$text');";
      } else {
        return "CustomToast.showSuccess(context, '$text');";
      }
    });

    content = content.replaceAllMapped(scaffoldRegexVar, (match) {
      changed = true;
      String text = match.group(1)!;
      // Since it's a variable or interpolation, default to showError if it's 'error' or 'e', else showInfo
      if (text == '_error' ||
          text.contains('error') ||
          text == 'e.toString()') {
        return "CustomToast.showError(context, $text);";
      } else {
        return "CustomToast.showSuccess(context, $text);";
      }
    });

    if (changed) {
      file.writeAsStringSync(content);
      print('Updated ${file.path}');
    }
  }
}
