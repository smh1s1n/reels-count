package com.antidoomscroll.reels.reels_count

import android.app.AppOpsManager
import android.content.Context
import android.content.Intent
import android.content.SharedPreferences
import android.content.pm.PackageManager
import android.net.Uri
import android.os.Build
import android.os.Process
import android.provider.Settings
import android.text.TextUtils
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.EventChannel
import io.flutter.plugin.common.MethodChannel
import java.text.SimpleDateFormat
import java.util.Date
import java.util.Locale

class MainActivity : FlutterActivity() {

    companion object {
        var pendingMindfulBreak: Boolean = false
        var pendingReelsCount: Int = 0
    }

    private val METHOD_CHANNEL = "com.antidoomscroll.reels/tracker"
    private val EVENT_CHANNEL = "com.antidoomscroll.reels/events"
    private val PREFS_NAME = "reels_detector_prefs"

    private var eventSink: EventChannel.EventSink? = null

    override fun onCreate(savedInstanceState: android.os.Bundle?) {
        super.onCreate(savedInstanceState)
        handleIntent(intent)
    }

    override fun onNewIntent(intent: Intent) {
        super.onNewIntent(intent)
        setIntent(intent)
        handleIntent(intent)
    }

    private fun handleIntent(intent: Intent?) {
        if (intent?.getBooleanExtra("open_mindful_break", false) == true) {
            val count = intent.getIntExtra("reels_count", 0)
            pendingMindfulBreak = true
            pendingReelsCount = count
            notifyFlutterMindfulBreak(count)
        }
    }

    private fun notifyFlutterMindfulBreak(count: Int) {
        val data = mapOf(
            "eventType" to "open_mindful_break",
            "appName" to "system",
            "reelsCount" to count,
            "durationSeconds" to 0L,
            "timestamp" to System.currentTimeMillis()
        )
        runOnUiThread {
            eventSink?.success(data)
        }
    }

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)

        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, METHOD_CHANNEL).setMethodCallHandler { call, result ->
            when (call.method) {
                "isAccessibilityGranted" -> {
                    result.success(isAccessibilityServiceEnabled())
                }
                "openAccessibilitySettings" -> {
                    val intent = Intent(Settings.ACTION_ACCESSIBILITY_SETTINGS).apply {
                        flags = Intent.FLAG_ACTIVITY_NEW_TASK
                    }
                    startActivity(intent)
                    result.success(true)
                }
                "isUsageStatsGranted" -> {
                    result.success(isUsageStatsPermissionGranted())
                }
                "openUsageStatsSettings" -> {
                    val intent = Intent(Settings.ACTION_USAGE_ACCESS_SETTINGS).apply {
                        flags = Intent.FLAG_ACTIVITY_NEW_TASK
                    }
                    startActivity(intent)
                    result.success(true)
                }
                "isOverlayGranted" -> {
                    result.success(isOverlayPermissionGranted())
                }
                "openOverlaySettings" -> {
                    if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.M) {
                        val intent = Intent(
                            Settings.ACTION_MANAGE_OVERLAY_PERMISSION,
                            Uri.parse("package:$packageName")
                        ).apply {
                            flags = Intent.FLAG_ACTIVITY_NEW_TASK
                        }
                        startActivity(intent)
                    }
                    result.success(true)
                }
                "isNotificationGranted" -> {
                    result.success(isNotificationPermissionGranted())
                }
                "openNotificationSettings" -> {
                    val intent = if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
                        Intent(Settings.ACTION_APP_NOTIFICATION_SETTINGS).apply {
                            putExtra(Settings.EXTRA_APP_PACKAGE, packageName)
                            flags = Intent.FLAG_ACTIVITY_NEW_TASK
                        }
                    } else {
                        Intent(Settings.ACTION_APPLICATION_DETAILS_SETTINGS).apply {
                            data = Uri.parse("package:$packageName")
                            flags = Intent.FLAG_ACTIVITY_NEW_TASK
                        }
                    }
                    startActivity(intent)
                    result.success(true)
                }
                "openAppSettings" -> {
                    val intent = Intent(Settings.ACTION_APPLICATION_DETAILS_SETTINGS).apply {
                        data = Uri.parse("package:$packageName")
                        flags = Intent.FLAG_ACTIVITY_NEW_TASK
                    }
                    startActivity(intent)
                    result.success(true)
                }
                "getDailyStats" -> {
                    result.success(getDailyStatsMap())
                }
                "resetDailyStats" -> {
                    resetDailyStats()
                    result.success(true)
                }
                "setReelLimit" -> {
                    val limit = call.argument<Int>("limit") ?: 30
                    val prefs = getSharedPreferences(PREFS_NAME, Context.MODE_PRIVATE)
                    prefs.edit()
                        .putInt("daily_reel_limit", limit)
                        .apply()
                    result.success(true)
                }
                "getReelLimit" -> {
                    val prefs = getSharedPreferences(PREFS_NAME, Context.MODE_PRIVATE)
                    result.success(prefs.getInt("daily_reel_limit", 30))
                }
                "checkPendingIntervention" -> {
                    val shouldOpen = pendingMindfulBreak
                    val count = pendingReelsCount
                    pendingMindfulBreak = false
                    result.success(mapOf("shouldOpen" to shouldOpen, "reelsCount" to count))
                }
                "resetInterventionTrigger" -> {
                    val prefs = getSharedPreferences(PREFS_NAME, Context.MODE_PRIVATE)
                    val dateKey = getTodayDateString()
                    prefs.edit().remove("last_intervention_reel_count_$dateKey").apply()
                    result.success(true)
                }
                "launchSms" -> {
                    val msg = call.argument<String>("message") ?: "Hey! Just taking a quick break from screens and wanted to say hi. How are you doing?"
                    try {
                        val smsIntent = Intent(Intent.ACTION_SENDTO).apply {
                            data = Uri.parse("smsto:")
                            putExtra("sms_body", msg)
                            flags = Intent.FLAG_ACTIVITY_NEW_TASK
                        }
                        startActivity(smsIntent)
                        result.success(true)
                    } catch (_: Exception) {
                        try {
                            val shareIntent = Intent(Intent.ACTION_SEND).apply {
                                type = "text/plain"
                                putExtra(Intent.EXTRA_TEXT, msg)
                                flags = Intent.FLAG_ACTIVITY_NEW_TASK
                            }
                            startActivity(Intent.createChooser(shareIntent, "Connect with a friend").apply {
                                flags = Intent.FLAG_ACTIVITY_NEW_TASK
                            })
                            result.success(true)
                        } catch (e: Exception) {
                            result.error("ERROR", e.message, null)
                        }
                    }
                }
                "launchDialer" -> {
                    try {
                        val dialIntent = Intent(Intent.ACTION_DIAL).apply {
                            flags = Intent.FLAG_ACTIVITY_NEW_TASK
                        }
                        startActivity(dialIntent)
                        result.success(true)
                    } catch (e: Exception) {
                        result.error("ERROR", e.message, null)
                    }
                }
                "shareText" -> {
                    val text = call.argument<String>("text") ?: ""
                    try {
                        val sendIntent = Intent().apply {
                            action = Intent.ACTION_SEND
                            putExtra(Intent.EXTRA_TEXT, text)
                            type = "text/plain"
                        }
                        val shareIntent = Intent.createChooser(sendIntent, "Connect with a friend").apply {
                            flags = Intent.FLAG_ACTIVITY_NEW_TASK
                        }
                        startActivity(shareIntent)
                        result.success(true)
                    } catch (e: Exception) {
                        result.error("ERROR", e.message, null)
                    }
                }
                "getInstalledSocialApps" -> {
                    result.success(getInstalledSocialAppsList())
                }
                else -> {
                    result.notImplemented()
                }
            }
        }

        EventChannel(flutterEngine.dartExecutor.binaryMessenger, EVENT_CHANNEL).setStreamHandler(
            object : EventChannel.StreamHandler {
                override fun onListen(arguments: Any?, events: EventChannel.EventSink?) {
                    eventSink = events
                    ReelDetectorAccessibilityService.eventListener = { eventData ->
                        runOnUiThread {
                            eventSink?.success(eventData)
                        }
                    }
                    if (pendingMindfulBreak) {
                        notifyFlutterMindfulBreak(pendingReelsCount)
                    }
                }

                override fun onCancel(arguments: Any?) {
                    eventSink = null
                    ReelDetectorAccessibilityService.eventListener = null
                }
            }
        )
    }

    private fun isAccessibilityServiceEnabled(): Boolean {
        val expectedService = "$packageName/${ReelDetectorAccessibilityService::class.java.canonicalName}"
        val enabledServices = Settings.Secure.getString(
            contentResolver,
            Settings.Secure.ENABLED_ACCESSIBILITY_SERVICES
        ) ?: return false

        val colonSplitter = TextUtils.SimpleStringSplitter(':')
        colonSplitter.setString(enabledServices)
        while (colonSplitter.hasNext()) {
            val componentName = colonSplitter.next()
            if (componentName.equals(expectedService, ignoreCase = true) ||
                componentName.contains(ReelDetectorAccessibilityService::class.java.simpleName, ignoreCase = true)
            ) {
                return true
            }
        }
        return false
    }

    private fun isUsageStatsPermissionGranted(): Boolean {
        val appOps = getSystemService(Context.APP_OPS_SERVICE) as AppOpsManager
        val mode = if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.Q) {
            appOps.unsafeCheckOpNoThrow(
                AppOpsManager.OPSTR_GET_USAGE_STATS,
                Process.myUid(),
                packageName
            )
        } else {
            @Suppress("DEPRECATION")
            appOps.checkOpNoThrow(
                AppOpsManager.OPSTR_GET_USAGE_STATS,
                Process.myUid(),
                packageName
            )
        }
        return mode == AppOpsManager.MODE_ALLOWED
    }

    private fun isOverlayPermissionGranted(): Boolean {
        return if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.M) {
            Settings.canDrawOverlays(this)
        } else {
            true
        }
    }

    private fun isNotificationPermissionGranted(): Boolean {
        return if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.N) {
            val nm = getSystemService(Context.NOTIFICATION_SERVICE) as android.app.NotificationManager
            nm.areNotificationsEnabled()
        } else {
            true
        }
    }

    private fun getTodayDateString(): String {
        val sdf = SimpleDateFormat("yyyy-MM-dd", Locale.getDefault())
        return sdf.format(Date())
    }

    private fun getDailyStatsMap(): Map<String, Any> {
        val prefs = getSharedPreferences(PREFS_NAME, Context.MODE_PRIVATE)
        val dateKey = getTodayDateString()

        val totalReels = prefs.getInt("reels_count_$dateKey", 0)
        val totalSecs = prefs.getLong("reels_duration_$dateKey", 0L)

        val instagramReels = prefs.getInt("app_instagram_reels_$dateKey", 0)
        val instagramSecs = prefs.getLong("app_instagram_duration_$dateKey", 0L)

        val tiktokReels = prefs.getInt("app_tiktok_reels_$dateKey", 0)
        val tiktokSecs = prefs.getLong("app_tiktok_duration_$dateKey", 0L)

        val youtubeReels = prefs.getInt("app_youtube_reels_$dateKey", 0)
        val youtubeSecs = prefs.getLong("app_youtube_duration_$dateKey", 0L)

        val facebookReels = prefs.getInt("app_facebook_reels_$dateKey", 0)
        val facebookSecs = prefs.getLong("app_facebook_duration_$dateKey", 0L)

        val limit = prefs.getInt("daily_reel_limit", 30)

        return mapOf(
            "date" to dateKey,
            "totalReels" to totalReels,
            "totalDurationSeconds" to totalSecs,
            "dailyLimit" to limit,
            "apps" to mapOf(
                "instagram" to mapOf("reels" to instagramReels, "duration" to instagramSecs),
                "tiktok" to mapOf("reels" to tiktokReels, "duration" to tiktokSecs),
                "youtube" to mapOf("reels" to youtubeReels, "duration" to youtubeSecs),
                "facebook" to mapOf("reels" to facebookReels, "duration" to facebookSecs)
            )
        )
    }

    private fun resetDailyStats() {
        val prefs = getSharedPreferences(PREFS_NAME, Context.MODE_PRIVATE)
        val dateKey = getTodayDateString()
        prefs.edit()
            .remove("reels_count_$dateKey")
            .remove("reels_duration_$dateKey")
            .remove("app_instagram_reels_$dateKey")
            .remove("app_instagram_duration_$dateKey")
            .remove("app_tiktok_reels_$dateKey")
            .remove("app_tiktok_duration_$dateKey")
            .remove("app_youtube_reels_$dateKey")
            .remove("app_youtube_duration_$dateKey")
            .remove("app_facebook_reels_$dateKey")
            .remove("app_facebook_duration_$dateKey")
            .apply()
    }

    private fun getInstalledSocialAppsList(): List<String> {
        val installed = mutableListOf<String>()

        // Instagram
        if (isAppInstalled("com.instagram.android")) {
            installed.add("instagram")
        }

        // TikTok (standard international and US variants)
        if (isAppInstalled("com.zhiliaoapp.musically") || isAppInstalled("com.ss.android.ugc.trill")) {
            installed.add("tiktok")
        }

        // YouTube
        if (isAppInstalled("com.google.android.youtube")) {
            installed.add("youtube")
        }

        // Facebook
        if (isAppInstalled("com.facebook.katana") || isAppInstalled("com.facebook.lite")) {
            installed.add("facebook")
        }

        return installed
    }

    private fun isAppInstalled(packageName: String): Boolean {
        return try {
            if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.TIRAMISU) {
                packageManager.getPackageInfo(packageName, PackageManager.PackageInfoFlags.of(0))
            } else {
                @Suppress("DEPRECATION")
                packageManager.getPackageInfo(packageName, 0)
            }
            true
        } catch (_: Exception) {
            false
        }
    }
}
