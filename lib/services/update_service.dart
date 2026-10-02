import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:http/http.dart' as http;
import 'package:package_info_plus/package_info_plus.dart';
import 'package:path_provider/path_provider.dart';
import 'firebase_initializer.dart';

/// Result of an update check.
class UpdateCheckResult {
  /// Whether a newer version is available.
  final bool hasUpdate;

  /// Latest version string from Firestore (e.g. "1.1.0")
  final String? latestVersion;

  /// Direct download URL for the new APK.
  final String? downloadUrl;

  /// Human-readable release notes (optional).
  final String? releaseNotes;

  const UpdateCheckResult({
    required this.hasUpdate,
    this.latestVersion,
    this.downloadUrl,
    this.releaseNotes,
  });

  /// No update, or Firebase not available.
  static const noUpdate = UpdateCheckResult(hasUpdate: false);
}

/// Handles OTA (Over-the-Air) APK update checking and downloading.
///
/// Firestore document expected:
///   Collection: "app_config"
///   Document ID: "latest_version"
///   Fields:
///     version       : String  (e.g. "1.2.0")
///     download_url  : String  (direct APK URL in Firebase Storage, or external)
///     release_notes : String  (optional, shown in update dialog)
///     force_update  : bool    (optional, if true user cannot dismiss dialog)
class UpdateService {
  static const String _configCollection = 'app_config';
  static const String _versionDocument = 'latest_version';

  /// Check Firestore for a newer app version.
  /// Returns [UpdateCheckResult.noUpdate] if Firebase isn't ready or no update exists.
  Future<UpdateCheckResult> checkForUpdate() async {
    if (!FirebaseInitializer.isInitialized) return UpdateCheckResult.noUpdate;

    try {
      final currentVersion = await _getCurrentVersion();

      final doc = await FirebaseFirestore.instance
          .collection(_configCollection)
          .doc(_versionDocument)
          .get(const GetOptions(source: Source.server));

      if (!doc.exists || doc.data() == null) return UpdateCheckResult.noUpdate;

      final data = doc.data()!;
      final latestVersion = data['version'] as String?;
      final downloadUrl = data['download_url'] as String?;
      final releaseNotes = data['release_notes'] as String?;

      if (latestVersion == null || downloadUrl == null) {
        return UpdateCheckResult.noUpdate;
      }

      final hasUpdate = _isNewerVersion(latestVersion, currentVersion);

      return UpdateCheckResult(
        hasUpdate: hasUpdate,
        latestVersion: latestVersion,
        downloadUrl: downloadUrl,
        releaseNotes: releaseNotes,
      );
    } catch (_) {
      // Network unavailable, Firestore error, etc. — no update silently.
      return UpdateCheckResult.noUpdate;
    }
  }

  /// Download the APK to the device's external storage directory.
  /// Reports progress via [onProgress] (0.0 → 1.0).
  /// Returns the local file path on success, null on failure.
  Future<String?> downloadApk({
    required String downloadUrl,
    required void Function(double progress) onProgress,
  }) async {
    try {
      final dir = await getExternalStorageDirectory();
      if (dir == null) return null;

      final filePath = '${dir.path}/sparkshow_update.apk';
      final file = File(filePath);

      final response = await http.Client().send(
        http.Request('GET', Uri.parse(downloadUrl)),
      );

      final totalBytes = response.contentLength ?? 0;
      int receivedBytes = 0;

      final sink = file.openWrite();
      await response.stream.listen((chunk) {
        sink.add(chunk);
        receivedBytes += chunk.length;
        if (totalBytes > 0) {
          onProgress(receivedBytes / totalBytes);
        }
      }).asFuture();
      await sink.close();

      return filePath;
    } catch (_) {
      return null;
    }
  }

  /// Generates a fresh Firebase Storage download URL for the latest APK.
  /// Used when the stored URL has expired (Firebase Storage URLs don't expire
  /// when using getDownloadURL, but this is a safety refresh).
  Future<String?> getRefreshedDownloadUrl(String storagePath) async {
    if (!FirebaseInitializer.isInitialized) return null;

    try {
      final ref = FirebaseStorage.instance.ref(storagePath);
      return await ref.getDownloadURL();
    } catch (_) {
      return null;
    }
  }

  // ──────────────────────────────────────────────────────────
  // Helpers
  // ──────────────────────────────────────────────────────────

  Future<String> _getCurrentVersion() async {
    final info = await PackageInfo.fromPlatform();
    return info.version; // e.g. "1.0.0"
  }

  /// Returns true if [remote] is strictly newer than [current].
  /// Compares semantic version segments (major.minor.patch).
  bool _isNewerVersion(String remote, String current) {
    try {
      final r = _parseSemver(remote);
      final c = _parseSemver(current);

      for (int i = 0; i < 3; i++) {
        if (r[i] > c[i]) return true;
        if (r[i] < c[i]) return false;
      }
      return false; // Same version
    } catch (_) {
      return false;
    }
  }

  List<int> _parseSemver(String version) {
    final parts = version.split('.');
    return [
      int.tryParse(parts.elementAtOrNull(0) ?? '0') ?? 0,
      int.tryParse(parts.elementAtOrNull(1) ?? '0') ?? 0,
      int.tryParse(parts.elementAtOrNull(2) ?? '0') ?? 0,
    ];
  }
}
