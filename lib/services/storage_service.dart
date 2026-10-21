import 'dart:convert';
import 'dart:io';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';

import '../models/app_data.dart';

class StorageService {
  static const String _fileName = 'ebbinghaus_planner_data.json';

  Future<File> getLocalFile() async {
    final directory = await getApplicationDocumentsDirectory();
    return File('${directory.path}/$_fileName');
  }

  /// Loads application data from the local JSON file.
  /// If the file does not exist, writes default data and returns it.
  Future<AppData> loadData() async {
    try {
      final file = await getLocalFile();
      if (!await file.exists()) {
        final initialData = AppData.defaultData();
        await saveData(initialData);
        return initialData;
      }

      final content = await file.readAsString();
      if (content.trim().isEmpty) {
        final initialData = AppData.defaultData();
        await saveData(initialData);
        return initialData;
      }

      final dynamic parsed = jsonDecode(content);
      if (parsed is! Map<String, dynamic>) {
        throw const FormatException('Корневой элемент JSON должен быть объектом');
      }

      return AppData.fromJson(parsed);
    } catch (e) {
      rethrow;
    }
  }

  /// Saves application data as formatted JSON into the local file.
  Future<void> saveData(AppData data) async {
    final file = await getLocalFile();
    final jsonString = const JsonEncoder.withIndent('  ').convert(data.toJson());
    // Write via temp file to ensure atomic write
    final tempFile = File('${file.path}.tmp');
    await tempFile.writeAsString(jsonString, flush: true);
    if (await file.exists()) {
      await file.delete();
    }
    await tempFile.rename(file.path);
  }

  /// Exports the local JSON file using the iOS/system Share sheet.
  Future<void> exportData({Rect? sharePositionOrigin}) async {
    final file = await getLocalFile();
    if (!await file.exists()) {
      await saveData(AppData.defaultData());
    }

    final xFile = XFile(
      file.path,
      mimeType: 'application/json',
      name: 'retain_backup_${DateTime.now().toIso8601String().substring(0, 10)}.json',
    );

    await SharePlus.instance.share(
      ShareParams(
        files: [xFile],
        subject: 'Retain Backup',
        sharePositionOrigin: sharePositionOrigin,
      ),
    );
  }

  /// Imports backup data from a user-selected JSON file.
  /// Returns the imported AppData, or null if the user canceled.
  /// Throws FormatException if the JSON is corrupted or invalid.
  Future<AppData?> importData() async {
    final pickedFiles = await FilePicker.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['json'],
    );

    if (pickedFiles.isEmpty) {
      // User canceled selection
      return null;
    }

    final selectedFile = pickedFiles.first;
    final bytes = await selectedFile.readAsBytes();
    final content = utf8.decode(bytes);

    if (content.trim().isEmpty) {
      throw const FormatException('Выбранный файл пуст.');
    }

    final dynamic parsed = jsonDecode(content);
    if (parsed is! Map<String, dynamic>) {
      throw const FormatException('Некорректная структура JSON файла.');
    }

    final importedData = AppData.fromJson(parsed);

    // Save newly imported data into local storage
    await saveData(importedData);

    return importedData;
  }
}
