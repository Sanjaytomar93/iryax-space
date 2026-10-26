import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:path_provider/path_provider.dart';

/// Helper utility for directly downloading/saving files to device storage
/// (MakeMyTrip style: direct download to Downloads folder + system notification + floating popup).
class FileDownloadHelper {
  FileDownloadHelper._();

  static const MethodChannel _channel =
      MethodChannel('com.example.iryax_spaces/download_channel');

  /// Saves [bytes] directly into the device Downloads or Documents directory.
  /// Also triggers the mobile's system notification tray download entry.
  static Future<File> saveFile({
    required String fileName,
    required List<int> bytes,
    String mimeType = '*/*',
  }) async {
    File? savedFile;

    // 1. Android public Downloads folder
    if (Platform.isAndroid) {
      try {
        final publicDownload = Directory('/storage/emulated/0/Download');
        if (await publicDownload.exists()) {
          final target = File('${publicDownload.path}/$fileName');
          await target.writeAsBytes(bytes, flush: true);
          savedFile = target;
        }
      } catch (_) {
        // Scoped storage / security restrictions on newer Android
      }

      // 2. PathProvider downloads directory
      if (savedFile == null) {
        try {
          final dlDir = await getDownloadsDirectory();
          if (dlDir != null) {
            if (!await dlDir.exists()) await dlDir.create(recursive: true);
            final target = File('${dlDir.path}/$fileName');
            await target.writeAsBytes(bytes, flush: true);
            savedFile = target;
          }
        } catch (_) {}
      }

      // 3. App-specific external downloads directory (always writable on Android)
      if (savedFile == null) {
        try {
          final extDirs = await getExternalStorageDirectories(
              type: StorageDirectory.downloads);
          if (extDirs != null && extDirs.isNotEmpty) {
            final dir = extDirs.first;
            if (!await dir.exists()) await dir.create(recursive: true);
            final target = File('${dir.path}/$fileName');
            await target.writeAsBytes(bytes, flush: true);
            savedFile = target;
          }
        } catch (_) {}
      }

      // 4. App-specific external storage directory
      if (savedFile == null) {
        try {
          final ext = await getExternalStorageDirectory();
          if (ext != null) {
            final dir = Directory('${ext.path}/Download');
            if (!await dir.exists()) await dir.create(recursive: true);
            final target = File('${dir.path}/$fileName');
            await target.writeAsBytes(bytes, flush: true);
            savedFile = target;
          }
        } catch (_) {}
      }
    } else if (Platform.isIOS) {
      try {
        final dlDir = await getDownloadsDirectory();
        if (dlDir != null) {
          if (!await dlDir.exists()) await dlDir.create(recursive: true);
          final target = File('${dlDir.path}/$fileName');
          await target.writeAsBytes(bytes, flush: true);
          savedFile = target;
        }
      } catch (_) {}
    }

    // Universal fallback: Application Documents Directory
    if (savedFile == null) {
      final docs = await getApplicationDocumentsDirectory();
      final target = File('${docs.path}/$fileName');
      await target.writeAsBytes(bytes, flush: true);
      savedFile = target;
    }

    // ─── Trigger Mobile System Notification (Status Bar) ───
    if (Platform.isAndroid) {
      try {
        await _channel.invokeMethod('notifyDownloadComplete', {
          'fileName': fileName,
          'filePath': savedFile.path,
          'mimeType': mimeType,
        });
      } catch (_) {}
    }

    return savedFile;
  }

  /// Requests Android 13+ POST_NOTIFICATIONS permission
  static Future<bool> requestNotificationPermission() async {
    if (Platform.isAndroid) {
      try {
        final res = await _channel
            .invokeMethod<bool>('requestNotificationPermission');
        return res ?? false;
      } catch (_) {
        return false;
      }
    }
    return true;
  }

  /// Opens the app notification settings directly in phone Settings
  static Future<void> openNotificationSettings() async {
    if (Platform.isAndroid) {
      try {
        await _channel.invokeMethod('openNotificationSettings');
      } catch (_) {}
    }
  }

  /// Opens the downloaded file using the system default application viewer.
  static Future<bool> openFile({
    required String filePath,
    String mimeType = '*/*',
  }) async {
    if (Platform.isAndroid) {
      try {
        final res = await _channel.invokeMethod<bool>('openFile', {
          'filePath': filePath,
          'mimeType': mimeType,
        });
        return res ?? false;
      } catch (_) {
        return false;
      }
    }
    return false;
  }

  /// Displays a MakeMyTrip style floating popup slightly above the bottom navigation bar
  /// ("bottom me thoda uper").
  static void showDownloadedNotification({
    required String fileName,
    String? folderName,
    String? filePath,
    String mimeType = '*/*',
    VoidCallback? onView,
  }) {
    if (Get.isSnackbarOpen) {
      Get.closeCurrentSnackbar();
    }

    final folder = folderName ?? 'Downloads';

    Get.snackbar(
      'File Downloaded Successfully',
      '$fileName has been saved to $folder.',
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: const Color(0xFF0F172A),
      colorText: Colors.white,
      icon: Container(
        margin: const EdgeInsets.only(left: 12),
        width: 36,
        height: 36,
        decoration: BoxDecoration(
          color: const Color(0xFF10B981).withOpacity(0.18),
          shape: BoxShape.circle,
        ),
        child: const Icon(
          Icons.check_circle_rounded,
          color: Color(0xFF10B981),
          size: 24,
        ),
      ),
      mainButton: TextButton(
        onPressed: () {
          Get.closeCurrentSnackbar();
          if (onView != null) {
            onView();
          } else if (filePath != null && filePath.isNotEmpty) {
            openFile(filePath: filePath, mimeType: mimeType);
          }
        },
        style: TextButton.styleFrom(
          foregroundColor: const Color(0xFF38BDF8),
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        ),
        child: Text(
          onView != null ? 'VIEW' : 'OPEN',
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 13,
            letterSpacing: 0.6,
          ),
        ),
      ),
      // Position slightly above bottom navigation bar
      margin: const EdgeInsets.fromLTRB(14, 0, 14, 85),
      borderRadius: 14,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      duration: const Duration(seconds: 4),
      isDismissible: true,
      boxShadows: [
        BoxShadow(
          color: const Color(0xFF26204A).withOpacity(0.35),
          blurRadius: 14,
          offset: const Offset(0, 4),
        ),
      ],
    );
  }
}
