import 'dart:io';

void main() async {
  final screensDir = Directory('lib/screens');
  final modelsDir = Directory('lib/models');
  
  final screensVendorDir = Directory('lib/screens/vendor');
  final screensOtrDir = Directory('lib/screens/otr');
  final modelsVendorDir = Directory('lib/models/vendor');
  final modelsOtrDir = Directory('lib/models/otr');
  
  if (!screensVendorDir.existsSync()) screensVendorDir.createSync(recursive: true);
  if (!screensOtrDir.existsSync()) screensOtrDir.createSync(recursive: true);
  if (!modelsVendorDir.existsSync()) modelsVendorDir.createSync(recursive: true);
  if (!modelsOtrDir.existsSync()) modelsOtrDir.createSync(recursive: true);

  final vendorScreenFiles = [
    'vendor_dashboard_page.dart',
    'vendor_finance_page.dart',
    'vendor_my_bids_page.dart',
    'vendor_open_eois_page.dart',
    'vendor_performance_page.dart',
    'vendor_profile_page.dart',
    'vendor_raise_invoice_page.dart',
    'vendor_registration_page.dart',
    'vendor_submit_proposal_page.dart',
    'vendor_work_orders_page.dart'
  ];

  final otrScreenFiles = [
    'address_page.dart',
    'admit_card_detail_page.dart',
    'admit_card_page.dart',
    'applied_recruitment_page.dart',
    'apply_now_page.dart',
    'bio_page.dart',
    'dashboard_page.dart',
    'documents_page.dart',
    'forgot_password_page.dart',
    'login_page.dart',
    'otp_verification_page.dart',
    'payment_history_page.dart',
    'payment_page.dart',
    'pdf_viewer_page.dart',
    'profile_detail_page.dart',
    'recruitment_detail_page.dart',
    'registration_page.dart',
    'splash_screen.dart',
    'total_recruitment_page.dart'
  ];

  final vendorModelFiles = [
    'eoi_model.dart',
    'vendor_finance_models.dart',
    'vendor_performance_model.dart',
    'work_order_model.dart'
  ];

  final otrModelFiles = [
    'advertisement_model.dart',
    'dashboard_model.dart',
    'document_type.dart'
  ];

  // Maps to store old path -> new path mapping
  final fileMap = <String, String>{};
  
  for (var f in vendorScreenFiles) {
    fileMap['lib/screens/$f'] = 'lib/screens/vendor/$f';
  }
  for (var f in otrScreenFiles) {
    fileMap['lib/screens/$f'] = 'lib/screens/otr/$f';
  }
  for (var f in vendorModelFiles) {
    fileMap['lib/models/$f'] = 'lib/models/vendor/$f';
  }
  for (var f in otrModelFiles) {
    fileMap['lib/models/$f'] = 'lib/models/otr/$f';
  }

  // Define a helper to replace imports in a file
  String updateImports(String content, String filePath) {
    bool isMoved = fileMap.values.contains(filePath);
    
    // We only need to fix relative paths going UP: e.g. `../` -> `../../` if moved.
    if (isMoved) {
      // If a file moved from lib/screens/ to lib/screens/vendor/, it went one level deeper.
      // So its `../` references (to e.g. `../theme/`) should become `../../`
      content = content.replaceAll(RegExp(r"'(\.\./)(?!(screens|models|services|theme|utils|widgets))"), "'../../");
      content = content.replaceAll("'../theme/", "'../../theme/");
      content = content.replaceAll("'../services/", "'../../services/");
      content = content.replaceAll("'../utils/", "'../../utils/");
      content = content.replaceAll("'../widgets/", "'../../widgets/");
      content = content.replaceAll("'../models/", "'../../models/");
      content = content.replaceAll("'../screens/", "'../../screens/");
    }

    // Now fix any direct references to the moved files from anywhere.
    // For example: `import 'screens/login_page.dart';` -> `import 'screens/otr/login_page.dart';`
    for (var entry in fileMap.entries) {
      final oldPath = entry.key; // e.g., lib/screens/login_page.dart
      final newPath = entry.value; // e.g., lib/screens/otr/login_page.dart
      
      final oldRelative = oldPath.replaceFirst('lib/', ''); // screens/login_page.dart
      final newRelative = newPath.replaceFirst('lib/', ''); // screens/otr/login_page.dart
      
      content = content.replaceAll("'$oldRelative'", "'$newRelative'");
      
      // Also catch imports like `import '../screens/login_page.dart';` -> `import '../screens/otr/login_page.dart';`
      // But if the file was moved to a subfolder, its own relative imports might be messed up.
      // E.g., `import '../models/eoi_model.dart';`
      // We already changed `../models/` to `../../models/` above.
      // So it would be `../../models/eoi_model.dart`.
      // We should replace `models/eoi_model.dart` with `models/vendor/eoi_model.dart`
      content = content.replaceAll("'$oldRelative'", "'$newRelative'");
      content = content.replaceAll("'../$oldRelative'", "'../$newRelative'");
      content = content.replaceAll("'../../$oldRelative'", "'../../$newRelative'");
      
      // What about imports within the same new folder?
      // E.g. in lib/screens/otr/login_page.dart, there might be `import 'dashboard_page.dart';`
      // This is still fine since both moved to the same directory.
    }

    return content;
  }

  // Process all dart files
  final allDartFiles = Directory('lib').listSync(recursive: true)
      .where((e) => e is File && e.path.endsWith('.dart'))
      .map((e) => e as File)
      .toList();

  // We first perform in-memory changes, then write and move.
  final newContents = <String, String>{};
  
  for (var file in allDartFiles) {
    // Normalise path separators to forward slash
    final path = file.path.replaceAll('\\', '/');
    final newPath = fileMap[path] ?? path;
    
    var content = file.readAsStringSync();
    content = updateImports(content, newPath);
    newContents[path] = content;
  }

  // Write the changes
  for (var entry in newContents.entries) {
    final oldPath = entry.key;
    final newPath = fileMap[oldPath] ?? oldPath;
    
    final file = File(newPath);
    file.writeAsStringSync(entry.value);
    
    if (oldPath != newPath) {
      File(oldPath).deleteSync();
      print("Moved: $oldPath -> $newPath");
    } else {
      print("Updated imports in: $oldPath");
    }
  }

  print("Done!");
}
