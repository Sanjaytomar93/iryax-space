package com.example.iryax_spaces

import android.Manifest
import android.app.DownloadManager
import android.app.NotificationChannel
import android.app.NotificationManager
import android.app.PendingIntent
import android.content.Context
import android.content.Intent
import android.content.pm.PackageManager
import android.media.MediaScannerConnection
import android.net.Uri
import android.os.Build
import android.provider.Settings
import androidx.core.app.NotificationCompat
import androidx.core.content.FileProvider
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel
import java.io.File

class MainActivity : FlutterActivity() {
    private val CHANNEL = "com.example.iryax_spaces/download_channel"
    private val NOTIF_CHANNEL_ID = "downloads_channel_v2"

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)

        // 1. Create notification channel immediately so Android Settings enables the toggle
        createNotificationChannel()

        // 2. Request POST_NOTIFICATIONS on Android 13+ (API 33+)
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.TIRAMISU) {
            if (checkSelfPermission(Manifest.permission.POST_NOTIFICATIONS) != PackageManager.PERMISSION_GRANTED) {
                requestPermissions(arrayOf(Manifest.permission.POST_NOTIFICATIONS), 101)
            }
        }

        // 3. Set up method channel
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL).setMethodCallHandler { call, result ->
            when (call.method) {
                "notifyDownloadComplete" -> {
                    val fileName = call.argument<String>("fileName") ?: "Downloaded File"
                    val filePath = call.argument<String>("filePath") ?: ""
                    val mimeType = call.argument<String>("mimeType") ?: "*/*"

                    triggerDownloadNotification(fileName, filePath, mimeType)
                    result.success(true)
                }
                "openFile" -> {
                    val filePath = call.argument<String>("filePath") ?: ""
                    val mimeType = call.argument<String>("mimeType") ?: "*/*"

                    val opened = openDownloadedFile(filePath, mimeType)
                    result.success(opened)
                }
                "requestNotificationPermission" -> {
                    if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.TIRAMISU) {
                        if (checkSelfPermission(Manifest.permission.POST_NOTIFICATIONS) != PackageManager.PERMISSION_GRANTED) {
                            requestPermissions(arrayOf(Manifest.permission.POST_NOTIFICATIONS), 101)
                            result.success(false)
                            return@setMethodCallHandler
                        }
                    }
                    result.success(true)
                }
                "openNotificationSettings" -> {
                    openAppSettings()
                    result.success(true)
                }
                else -> result.notImplemented()
            }
        }
    }

    private fun createNotificationChannel() {
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
            val notificationManager = getSystemService(Context.NOTIFICATION_SERVICE) as? NotificationManager
                ?: return
            val channel = NotificationChannel(
                NOTIF_CHANNEL_ID,
                "File Downloads",
                NotificationManager.IMPORTANCE_HIGH
            ).apply {
                description = "Notifications for downloaded tickets, invoices, and reports"
                enableVibration(true)
                setShowBadge(true)
            }
            notificationManager.createNotificationChannel(channel)
        }
    }

    private fun triggerDownloadNotification(fileName: String, filePath: String, mimeType: String) {
        try {
            // Ensure channel exists
            createNotificationChannel()

            // 1. Scan file into MediaStore/Downloads
            if (filePath.isNotEmpty()) {
                MediaScannerConnection.scanFile(
                    this,
                    arrayOf(filePath),
                    arrayOf(mimeType),
                    null
                )
            }

            // 2. Register with Android DownloadManager if available
            try {
                val dm = getSystemService(Context.DOWNLOAD_SERVICE) as? DownloadManager
                val file = File(filePath)
                if (file.exists()) {
                    dm?.addCompletedDownload(
                        fileName,
                        "Download complete",
                        true,
                        mimeType,
                        file.absolutePath,
                        file.length(),
                        true
                    )
                }
            } catch (_: Exception) {
                // Handled below
            }

            // 3. Post Notification
            val notificationManager = getSystemService(Context.NOTIFICATION_SERVICE) as? NotificationManager
                ?: return

            val file = File(filePath)
            val pendingIntent: PendingIntent? = if (file.exists()) {
                try {
                    val uri = FileProvider.getUriForFile(
                        this,
                        "${applicationContext.packageName}.fileprovider",
                        file
                    )
                    val viewIntent = Intent(Intent.ACTION_VIEW).apply {
                        setDataAndType(uri, mimeType)
                        addFlags(Intent.FLAG_GRANT_READ_URI_PERMISSION)
                        addFlags(Intent.FLAG_ACTIVITY_NEW_TASK)
                    }
                    PendingIntent.getActivity(
                        this,
                        (System.currentTimeMillis() % 100000).toInt(),
                        Intent.createChooser(viewIntent, "Open with"),
                        PendingIntent.FLAG_UPDATE_CURRENT or PendingIntent.FLAG_IMMUTABLE
                    )
                } catch (_: Exception) {
                    null
                }
            } else {
                null
            }

            val iconRes = if (applicationInfo.icon != 0) applicationInfo.icon else R.mipmap.ic_launcher
            val builder = NotificationCompat.Builder(this, NOTIF_CHANNEL_ID)
                .setSmallIcon(iconRes)
                .setContentTitle(fileName)
                .setContentText("Download complete. Tap to view.")
                .setAutoCancel(true)
                .setPriority(NotificationCompat.PRIORITY_HIGH)
                .setDefaults(NotificationCompat.DEFAULT_ALL)

            if (pendingIntent != null) {
                builder.setContentIntent(pendingIntent)
            }

            notificationManager.notify((System.currentTimeMillis() % 100000).toInt(), builder.build())
        } catch (_: Exception) {
            // Ignore
        }
    }

    private fun openDownloadedFile(filePath: String, mimeType: String): Boolean {
        return try {
            val file = File(filePath)
            if (!file.exists()) return false

            val uri = FileProvider.getUriForFile(
                this,
                "${applicationContext.packageName}.fileprovider",
                file
            )
            val viewIntent = Intent(Intent.ACTION_VIEW).apply {
                setDataAndType(uri, mimeType)
                addFlags(Intent.FLAG_GRANT_READ_URI_PERMISSION)
                addFlags(Intent.FLAG_ACTIVITY_NEW_TASK)
            }
            startActivity(Intent.createChooser(viewIntent, "Open with"))
            true
        } catch (_: Exception) {
            false
        }
    }

    private fun openAppSettings() {
        try {
            val intent = Intent().apply {
                if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
                    action = Settings.ACTION_APP_NOTIFICATION_SETTINGS
                    putExtra(Settings.EXTRA_APP_PACKAGE, packageName)
                } else {
                    action = Settings.ACTION_APPLICATION_DETAILS_SETTINGS
                    data = Uri.fromParts("package", packageName, null)
                }
                addFlags(Intent.FLAG_ACTIVITY_NEW_TASK)
            }
            startActivity(intent)
        } catch (_: Exception) {
            try {
                val intent = Intent(Settings.ACTION_APPLICATION_DETAILS_SETTINGS).apply {
                    data = Uri.fromParts("package", packageName, null)
                    addFlags(Intent.FLAG_ACTIVITY_NEW_TASK)
                }
                startActivity(intent)
            } catch (_: Exception) {}
        }
    }
}
