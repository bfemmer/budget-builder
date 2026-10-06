import 'package:flutter/material.dart';
import '../../data/datasources/backup_restore_datasource.dart';

class BackupViewModel extends ChangeNotifier {
  final BackupRestoreDataSource dataSource;

  bool _isProcessing = false;
  String? _statusMessage;

  bool get isProcessing => _isProcessing;
  String? get statusMessage => _statusMessage;

  BackupViewModel({required this.dataSource});

  Future<String?> exportToJson() async {
    _isProcessing = true;
    _statusMessage = null;
    notifyListeners();

    try {
      final jsonStr = await dataSource.exportToJsonString();
      await dataSource.exportToJsonFile();
      _statusMessage = 'Export generated successfully!';
      return jsonStr;
    } catch (e) {
      _statusMessage = 'Export failed: $e';
      return null;
    } finally {
      _isProcessing = false;
      notifyListeners();
    }
  }

  Future<bool> importFromJson(String jsonStr) async {
    _isProcessing = true;
    _statusMessage = null;
    notifyListeners();

    try {
      final success = await dataSource.importFromJsonString(jsonStr);
      _statusMessage = success ? 'Data restored successfully!' : 'Invalid JSON data format.';
      return success;
    } catch (e) {
      _statusMessage = 'Import failed: $e';
      return false;
    } finally {
      _isProcessing = false;
      notifyListeners();
    }
  }
}
