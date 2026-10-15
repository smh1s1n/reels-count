package com.antidoomscroll.reels.reels_count

import android.accessibilityservice.AccessibilityService
import android.content.Context
import android.content.Intent
import android.content.SharedPreferences
import android.os.Handler
import android.os.Looper
import android.util.Log
import android.view.accessibility.AccessibilityEvent
import android.view.accessibility.AccessibilityNodeInfo
import java.text.SimpleDateFormat
import java.util.Date
import java.util.Locale

class ReelDetectorAccessibilityService : AccessibilityService() {

    companion object {
        private const val TAG = "ReelDetector"
        var isServiceRunning = false
        var eventListener: ((Map<String, Any>) -> Unit)? = null
        private const val PREFS_NAME = "reels_detector_prefs"
        private const val MIN_DWELL_MS = 1000L // 1.0s minimum dwell between reel scrolls
    }

    private lateinit var prefs: SharedPreferences
    private var currentPackage: String? = null
    private var isInsideReels = false
    private var lastScrollTime = 0L
    private var currentReelsToday = 0
    private var currentDurationSeconds = 0L

    private val handler = Handler(Looper.getMainLooper())
    private val timerRunnable = object : Runnable {
        override fun run() {
            if (isInsideReels) {
                currentDurationSeconds++
                saveDailyStats(currentPackage ?: "unknown", 0, 1)
                notifyFlutter("session_tick", currentPackage ?: "unknown", currentReelsToday, currentDurationSeconds)
                handler.postDelayed(this, 1000)
            }
        }
    }

    override fun onServiceConnected() {
        super.onServiceConnected()
        isServiceRunning = true
        prefs = getSharedPreferences(PREFS_NAME, Context.MODE_PRIVATE)
        loadTodayStats()
        startForegroundTracking()
        Log.d(TAG, "ReelDetectorAccessibilityService connected. Current reels today: $currentReelsToday")
    }

    override fun onAccessibilityEvent(event: AccessibilityEvent?) {
        if (event == null) return

        val pkgName = event.packageName?.toString() ?: return
        val className = event.className?.toString() ?: ""

        // Handle target social platforms
        when (pkgName) {
            "com.instagram.android" -> handleInstagram(event, className)
            "com.zhiliaoapp.musically", "com.ss.android.ugc.trill" -> handleTikTok(event, className)
            "com.google.android.youtube" -> handleYouTube(event, className)
            "com.facebook.katana" -> handleFacebook(event, className)
            else -> {
                if (isInsideReels) {
                    exitReelsContainer()
                }
            }
        }
    }

    private fun isScrollOrPageEvent(eventType: Int): Boolean {
        return eventType == AccessibilityEvent.TYPE_VIEW_SCROLLED ||
                eventType == AccessibilityEvent.TYPE_VIEW_SELECTED
    }

    private fun handleInstagram(event: AccessibilityEvent, className: String) {
        currentPackage = "instagram"
        val sourceViewId = event.source?.viewIdResourceName ?: ""

        val isReelsWindow = className.contains("ClipsViewer", ignoreCase = true) ||
                className.contains("Reel", ignoreCase = true) ||
                sourceViewId.contains("clips", ignoreCase = true) ||
                sourceViewId.contains("reel", ignoreCase = true) ||
                containsReelsIdentifiers(rootInActiveWindow, listOf("clips_swipe_refresh_container", "clips_video_container", "reel_viewer", "clips_view_pager"))

        if (isReelsWindow) {
            enterReelsContainer("instagram")
            if (isScrollOrPageEvent(event.eventType)) {
                checkAndIncrementReel("instagram")
            }
        } else if (isInsideReels && isScrollOrPageEvent(event.eventType)) {
            checkAndIncrementReel("instagram")
        } else if (event.eventType == AccessibilityEvent.TYPE_WINDOW_STATE_CHANGED) {
            exitReelsContainer()
        }
    }

    private fun handleTikTok(event: AccessibilityEvent, className: String) {
        currentPackage = "tiktok"
        // TikTok feed is almost exclusively vertical short-form video
        enterReelsContainer("tiktok")
        if (isScrollOrPageEvent(event.eventType)) {
            checkAndIncrementReel("tiktok")
        }
    }

    private fun handleYouTube(event: AccessibilityEvent, className: String) {
        currentPackage = "youtube"
        val sourceViewId = event.source?.viewIdResourceName ?: ""
        val contentDesc = event.contentDescription?.toString() ?: ""

        val isShorts = className.contains("Shorts", ignoreCase = true) ||
                sourceViewId.contains("reel", ignoreCase = true) ||
                sourceViewId.contains("shorts", ignoreCase = true) ||
                contentDesc.contains("Shorts", ignoreCase = true) ||
                containsReelsIdentifiers(rootInActiveWindow, listOf("reel_player_page_holder", "shorts_container", "shorts_player", "reel_recycler", "shorts_surface_view", "shorts_pager"))

        if (isShorts) {
            enterReelsContainer("youtube")
            if (isScrollOrPageEvent(event.eventType)) {
                checkAndIncrementReel("youtube")
            }
        } else if (isInsideReels && isScrollOrPageEvent(event.eventType)) {
            checkAndIncrementReel("youtube")
        } else if (event.eventType == AccessibilityEvent.TYPE_WINDOW_STATE_CHANGED) {
            exitReelsContainer()
        }
    }

    private fun handleFacebook(event: AccessibilityEvent, className: String) {
        currentPackage = "facebook"
        val sourceViewId = event.source?.viewIdResourceName ?: ""

        val isFbReels = className.contains("FbClips", ignoreCase = true) ||
                sourceViewId.contains("clips", ignoreCase = true) ||
                sourceViewId.contains("shorts", ignoreCase = true) ||
                containsReelsIdentifiers(rootInActiveWindow, listOf("fb_shorts_container", "fb_clips_viewer", "fb_reels_container", "video_fullscreen_reels"))

        if (isFbReels) {
            enterReelsContainer("facebook")
            if (isScrollOrPageEvent(event.eventType)) {
                checkAndIncrementReel("facebook")
            }
        } else if (isInsideReels && isScrollOrPageEvent(event.eventType)) {
            checkAndIncrementReel("facebook")
        } else if (event.eventType == AccessibilityEvent.TYPE_WINDOW_STATE_CHANGED) {
            exitReelsContainer()
        }
    }

    private fun containsReelsIdentifiers(node: AccessibilityNodeInfo?, targetIds: List<String>, depth: Int = 0): Boolean {
        if (node == null || depth > 4) return false
        val viewId = node.viewIdResourceName ?: ""
        for (target in targetIds) {
            if (viewId.contains(target, ignoreCase = true)) return true
        }

        for (i in 0 until node.childCount) {
            val child = node.getChild(i)
            if (containsReelsIdentifiers(child, targetIds, depth + 1)) {
                return true
            }
        }
        return false
    }

    private fun enterReelsContainer(appName: String) {
        if (!isInsideReels) {
            isInsideReels = true
            handler.removeCallbacks(timerRunnable)
            handler.post(timerRunnable)
            notifyFlutter("container_entered", appName, currentReelsToday, currentDurationSeconds)
        }
    }

    private fun exitReelsContainer() {
        if (isInsideReels) {
            isInsideReels = false
            handler.removeCallbacks(timerRunnable)
            notifyFlutter("container_exited", currentPackage ?: "unknown", currentReelsToday, currentDurationSeconds)
        }
    }

    private fun checkAndIncrementReel(appName: String) {
        val now = System.currentTimeMillis()
        if (now - lastScrollTime >= MIN_DWELL_MS) {
            lastScrollTime = now
            saveDailyStats(appName, 1, 0)
            Log.d(TAG, "Reel counted on $appName! Total today: $currentReelsToday")
            notifyFlutter("reel_detected", appName, currentReelsToday, currentDurationSeconds)
            updateForegroundNotification(appName, currentReelsToday, currentDurationSeconds)
            checkDailyLimitAndIntervene(appName)
        }
    }

    private fun checkDailyLimitAndIntervene(appName: String) {
        val limit = prefs.getInt("daily_reel_limit", 30)
        val dateKey = getTodayDateString()
        val lastIntervention = prefs.getInt("last_intervention_reel_count_$dateKey", 0)

        val isFirstTriggerForLimit = (currentReelsToday >= limit && lastIntervention < limit)
        val isPostDismissalRecurringNudge = (lastIntervention >= limit && currentReelsToday >= lastIntervention + 5)

        if (isFirstTriggerForLimit || isPostDismissalRecurringNudge) {
            prefs.edit().putInt("last_intervention_reel_count_$dateKey", currentReelsToday).apply()
            triggerMindfulBreakIntervention(appName, currentReelsToday)
        }
    }

    private fun triggerMindfulBreakIntervention(appName: String, count: Int) {
        Log.i(TAG, "Reel limit reached ($count >= limit)! Triggering mindful break intervention over $appName")

        // 1. Notify Flutter via active event channel
        notifyFlutter("open_mindful_break", appName, count, currentDurationSeconds)

        // 2. Trigger high-priority heads-up / full screen intent via foreground service
        val fgsIntent = Intent(this, TrackingForegroundService::class.java).apply {
            action = TrackingForegroundService.ACTION_TRIGGER_INTERVENTION
            putExtra(TrackingForegroundService.EXTRA_APP, appName)
            putExtra(TrackingForegroundService.EXTRA_COUNT, count)
        }
        try {
            startService(fgsIntent)
        } catch (e: Exception) {
            Log.e(TAG, "Error triggering intervention notification: ${e.message}")
        }

        // 3. Directly launch MainActivity over current app (AccessibilityService has permission to start activities from background)
        try {
            val activityIntent = Intent(this, MainActivity::class.java).apply {
                action = Intent.ACTION_MAIN
                addCategory(Intent.CATEGORY_LAUNCHER)
                flags = Intent.FLAG_ACTIVITY_NEW_TASK or
                        Intent.FLAG_ACTIVITY_REORDER_TO_FRONT or
                        Intent.FLAG_ACTIVITY_SINGLE_TOP
                putExtra("open_mindful_break", true)
                putExtra("reels_count", count)
                putExtra("trigger_app", appName)
            }
            startActivity(activityIntent)
        } catch (e: Exception) {
            Log.e(TAG, "Error starting MainActivity from accessibility service: ${e.message}")
        }
    }

    private fun getTodayDateString(): String {
        val sdf = SimpleDateFormat("yyyy-MM-dd", Locale.getDefault())
        return sdf.format(Date())
    }

    private fun loadTodayStats() {
        val dateKey = getTodayDateString()
        currentReelsToday = prefs.getInt("reels_count_$dateKey", 0)
        currentDurationSeconds = prefs.getLong("reels_duration_$dateKey", 0L)
    }

    private fun saveDailyStats(appName: String, reelsDelta: Int, durationDeltaSeconds: Long) {
        val dateKey = getTodayDateString()
        val totalReels = prefs.getInt("reels_count_$dateKey", 0) + reelsDelta
        val totalSecs = prefs.getLong("reels_duration_$dateKey", 0L) + durationDeltaSeconds

        val appReels = prefs.getInt("app_${appName}_reels_$dateKey", 0) + reelsDelta
        val appSecs = prefs.getLong("app_${appName}_duration_$dateKey", 0L) + durationDeltaSeconds

        prefs.edit()
            .putInt("reels_count_$dateKey", totalReels)
            .putLong("reels_duration_$dateKey", totalSecs)
            .putInt("app_${appName}_reels_$dateKey", appReels)
            .putLong("app_${appName}_duration_$dateKey", appSecs)
            .apply()

        currentReelsToday = totalReels
        currentDurationSeconds = totalSecs
    }

    private fun notifyFlutter(eventType: String, appName: String, reelsCount: Int, durationSeconds: Long) {
        val data = mapOf(
            "eventType" to eventType,
            "appName" to appName,
            "reelsCount" to reelsCount,
            "durationSeconds" to durationSeconds,
            "timestamp" to System.currentTimeMillis()
        )
        Handler(Looper.getMainLooper()).post {
            eventListener?.invoke(data)
        }
    }

    private fun startForegroundTracking() {
        val intent = Intent(this, TrackingForegroundService::class.java).apply {
            action = TrackingForegroundService.ACTION_START
        }
        try {
            startService(intent)
        } catch (_: Exception) {}
    }

    private fun updateForegroundNotification(appName: String, count: Int, durationSeconds: Long) {
        val intent = Intent(this, TrackingForegroundService::class.java).apply {
            action = TrackingForegroundService.ACTION_UPDATE
            putExtra(TrackingForegroundService.EXTRA_APP, appName)
            putExtra(TrackingForegroundService.EXTRA_COUNT, count)
            putExtra(TrackingForegroundService.EXTRA_DURATION, durationSeconds)
        }
        try {
            startService(intent)
        } catch (_: Exception) {}
    }

    override fun onInterrupt() {
        exitReelsContainer()
    }

    override fun onDestroy() {
        isServiceRunning = false
        exitReelsContainer()
        super.onDestroy()
    }
}
