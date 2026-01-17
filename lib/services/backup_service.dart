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
