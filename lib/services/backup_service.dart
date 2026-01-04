import 'dart:io';
import 'package:file_picker/file_picker.dart';
import 'dart:convert';
import 'dart:typed_data';
//import 'package:file_saver/file_saver.dart';


import 'package:flutter/material.dart';

import '../database/app_database.dart';

/// Service responsible for exporting and importing app data
class BackupService {
  final AppDatabase _db;

  BackupService(this._db);

  /// Export all data to a JSON file and share it
  // Future<void> exportData() async {
  //   // // Get JSON from database
  //   // final json = await _db.exportToJson();

  //   // // Create backup file
  //   // // Android public Downloads folder
  //   // final directory = Directory('/storage/emulated/0/Download');

  //   // if (!await directory.exists()) {
  //   //   throw Exception('Downloads folder not found');
  //   // }

  //   // final file = File('${directory.path}/money_manager_backup.json');

  //   // // Write JSON to file
  //   // await file.writeAsString(json);

  //   // // Share the file
  //   // // await Share.shareXFiles([XFile(file.path)]);

  //   try {
  //     // 1. Get JSON from database
  //     final String jsonString = await _db.exportToJson();
  //     final Uint8List bytes = utf8.encode(jsonString);

  //     // Save the file using FileSaver
  //     // This explicitly tells the OS it's a JSON file
  //     String filePath = await FileSaver.instance.saveFile(
  //       name: 'money_manager_backup', // Name without extension
  //       bytes: bytes,
  //       ext: 'json',
  //       mimeType: MimeType.json,
  //     );
  //     print("Your file is located at: $filePath");

  //     if (filePath.isNotEmpty) {
  //       print('Backup saved successfully: $filePath');
  //     }
  //   } catch (e) {
  //     print('Export failed: $e');
  //   }
  // }

  Future<void> exportData(BuildContext context) async {
  try {
    // 1. Prepare your data
    final String jsonString = await _db.exportToJson();
    final Uint8List bytes = utf8.encode(jsonString);

    // 2. Use saveFile - This opens the System UI
    // The user can choose 'Downloads' here.
    final String? filePath = await FilePicker.platform.saveFile(
      dialogTitle: 'Select where to save your backup',
      fileName: 'money_manager_backup.json',
      bytes: bytes,
      type: FileType.custom,
      allowedExtensions: ['json'],
    );

    if (filePath != null) {
      debugPrint('Backup saved successfully: $filePath');
    }
  } catch (e) {
    debugPrint('Export failed: $e');
  }
}

  /// Import data from a selected JSON file
  Future<void> importData() async {
    // Let user pick a JSON file
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['json'],
    );

    if (result == null) return;

    final file = File(result.files.single.path!);
    final json = await file.readAsString();

    // Restore database
    await _db.importFromJson(json);
  }
}
