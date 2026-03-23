import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:googleapis/drive/v3.dart' as drive;
import 'package:http/http.dart' as http;
import 'storage_service.dart';

class GoogleAuthClient extends http.BaseClient {
  final Map<String, String> _headers;
  final http.Client _client = http.Client();

  GoogleAuthClient(this._headers);

  @override
  Future<http.StreamedResponse> send(http.BaseRequest request) {
    return _client.send(request..headers.addAll(_headers));
  }
}

class GoogleDriveSyncService extends ChangeNotifier {
  final GoogleSignIn _googleSignIn = GoogleSignIn(
    // Scopes for Google Drive App Data
    scopes: [drive.DriveApi.driveAppdataScope],
  );

  bool _isSyncing = false;
  bool get isSyncing => _isSyncing;

  GoogleSignInAccount? _currentUser;

  Future<bool> signIn() async {
    try {
      debugPrint("Starting sign-in process...");
      _currentUser = await _googleSignIn.signInSilently();
      if (_currentUser == null) {
        debugPrint("Silent sign-in failed, trying interactive...");
        _currentUser = await _googleSignIn.signIn();
      }
      
      notifyListeners();
      
      if (_currentUser == null) {
        throw Exception("Sign-in canceled. (Error 10 often means SHA-1 mismatch in Google Console)");
      }
      debugPrint("Sign-in successful: ${_currentUser!.email}");
      return true;
    } catch (e) {
      debugPrint("Detailed Sign-in Error: $e");
      rethrow;
    }
  }

  Future<void> signOut() async {
    await _googleSignIn.signOut();
    _currentUser = null;
    notifyListeners();
  }

  Future<drive.DriveApi?> _getDriveApi() async {
    if (_currentUser == null) {
      final success = await signIn();
      if (!success) return null;
    }

    final headers = await _currentUser!.authHeaders;
    final client = GoogleAuthClient(headers);
    return drive.DriveApi(client);
  }

  Future<bool> backupToDrive() async {
    _setSyncing(true);
    try {
      final driveApi = await _getDriveApi();
      if (driveApi == null) return false;

      final dbPath = await StorageService().getDatabasePathStr();
      final file = File(dbPath);
      if (!await file.exists()) return false;

      final query = "name='passwords.db' and 'appDataFolder' in parents and trashed=false";
      final fileList = await driveApi.files.list(q: query, spaces: 'appDataFolder');
      
      final driveFile = drive.File()..name = 'passwords.db'..parents = ['appDataFolder'];
      final media = drive.Media(file.openRead(), file.lengthSync());

      if (fileList.files != null && fileList.files!.isNotEmpty) {
        final fileId = fileList.files!.first.id!;
        await driveApi.files.update(driveFile, fileId, uploadMedia: media);
      } else {
        await driveApi.files.create(driveFile, uploadMedia: media);
      }
      return true;
    } catch (e) {
      debugPrint("Backup error: $e");
      // Re-throw or handle to let UI know the specific error
      throw e;
    } finally {
      _setSyncing(false);
    }
  }

  Future<bool> restoreFromDrive() async {
    _setSyncing(true);
    try {
      final driveApi = await _getDriveApi();
      if (driveApi == null) return false;

      final query = "name='passwords.db' and 'appDataFolder' in parents and trashed=false";
      final fileList = await driveApi.files.list(q: query, spaces: 'appDataFolder');

      if (fileList.files == null || fileList.files!.isEmpty) {
        debugPrint("No backup found");
        return false;
      }

      final fileId = fileList.files!.first.id!;
      final drive.Media response = await driveApi.files.get(
        fileId, 
        downloadOptions: drive.DownloadOptions.fullMedia
      ) as drive.Media;

      final dbPath = await StorageService().getDatabasePathStr();
      final file = File(dbPath);

      final List<int> dataStore = [];
      await for (final data in response.stream) {
        dataStore.addAll(data);
      }
      await file.writeAsBytes(dataStore);

      await StorageService().loadPasswords();
      return true;
    } catch (e) {
      debugPrint("Restore error: $e");
      throw e;
    } finally {
      _setSyncing(false);
    }
  }

  void _setSyncing(bool val) {
    _isSyncing = val;
    notifyListeners();
  }
}
