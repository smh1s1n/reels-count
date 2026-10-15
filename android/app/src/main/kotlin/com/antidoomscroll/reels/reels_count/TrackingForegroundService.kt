package com.antidoomscroll.reels.reels_count

import android.app.Notification
import android.app.NotificationChannel
import android.app.NotificationManager
import android.app.PendingIntent
import android.app.Service
import android.content.Context
import android.content.Intent
import android.os.Build
import android.os.IBinder
import androidx.core.app.NotificationCompat

class TrackingForegroundService : Service() {

    companion object {
        const val CHANNEL_ID = "reels_tracking_channel"
        const val CHANNEL_INTERVENTION_ID = "reels_intervention_channel"
        const val NOTIFICATION_ID = 1001
        const val INTERVENTION_NOTIFICATION_ID = 1002
        const val ACTION_START = "ACTION_START"
        const val ACTION_UPDATE = "ACTION_UPDATE"
        const val ACTION_STOP = "ACTION_STOP"
        const val ACTION_TRIGGER_INTERVENTION = "ACTION_TRIGGER_INTERVENTION"
        const val EXTRA_APP = "EXTRA_APP"
        const val EXTRA_COUNT = "EXTRA_COUNT"
        const val EXTRA_DURATION = "EXTRA_DURATION"
    }

    override fun onCreate() {
        super.onCreate()
        createNotificationChannels()
    }

    override fun onStartCommand(intent: Intent?, flags: Int, startId: Int): Int {
        when (intent?.action) {
            ACTION_STOP -> {
                stopForeground(STOP_FOREGROUND_REMOVE)
                stopSelf()
            }
            ACTION_UPDATE -> {
                val app = intent.getStringExtra(EXTRA_APP) ?: "Social Media"
                val count = intent.getIntExtra(EXTRA_COUNT, 0)
                val duration = intent.getLongExtra(EXTRA_DURATION, 0L)
                updateNotification(app, count, duration)
            }
            ACTION_TRIGGER_INTERVENTION -> {
                val app = intent.getStringExtra(EXTRA_APP) ?: "Social Media"
                val count = intent.getIntExtra(EXTRA_COUNT, 0)
                showInterventionNotification(app, count)
            }
            else -> {
                startForeground(NOTIFICATION_ID, buildNotification("Active", 0, 0L))
            }
        }
        return START_STICKY
    }

    private fun createNotificationChannels() {
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
            val manager = getSystemService(Context.NOTIFICATION_SERVICE) as NotificationManager

            // Low priority persistent tracking channel
            val trackingChannel = NotificationChannel(
                CHANNEL_ID,
                "Reel Tracking & Digital Wellness",
                NotificationManager.IMPORTANCE_LOW
            ).apply {
                description = "Monitors reel scrolling and screen time for digital wellbeing"
                setShowBadge(false)
            }
            manager.createNotificationChannel(trackingChannel)

            // High priority heads-up intervention channel
            val interventionChannel = NotificationChannel(
                CHANNEL_INTERVENTION_ID,
                "Mindful Break Alerts",
                NotificationManager.IMPORTANCE_HIGH
            ).apply {
                description = "Alerts you when daily reel limit is exceeded"
                enableVibration(true)
                vibrationPattern = longArrayOf(0, 300, 150, 300)
                setShowBadge(true)
                lockscreenVisibility = Notification.VISIBILITY_PUBLIC
            }
            manager.createNotificationChannel(interventionChannel)
        }
    }

    private fun buildNotification(app: String, count: Int, durationSeconds: Long): Notification {
        val minutes = durationSeconds / 60
        val seconds = durationSeconds % 60
        val timeString = if (minutes > 0) "${minutes}m ${seconds}s" else "${seconds}s"

        val openAppIntent = Intent(this, MainActivity::class.java).apply {
            flags = Intent.FLAG_ACTIVITY_NEW_TASK or Intent.FLAG_ACTIVITY_CLEAR_TOP
        }
        val pendingIntent = PendingIntent.getActivity(
            this,
            0,
            openAppIntent,
            PendingIntent.FLAG_UPDATE_CURRENT or (if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.M) PendingIntent.FLAG_IMMUTABLE else 0)
        )

        return NotificationCompat.Builder(this, CHANNEL_ID)
            .setContentTitle("ReelsGuard: Mindful Tracker")
            .setContentText("Today: $count reels watched ($timeString) • $app")
            .setSmallIcon(android.R.drawable.ic_dialog_info)
            .setContentIntent(pendingIntent)
            .setOngoing(true)
            .setPriority(NotificationCompat.PRIORITY_LOW)
            .build()
    }

    private fun updateNotification(app: String, count: Int, durationSeconds: Long) {
        val notification = buildNotification(app, count, durationSeconds)
        val manager = getSystemService(Context.NOTIFICATION_SERVICE) as NotificationManager
        manager.notify(NOTIFICATION_ID, notification)
    }

    private fun showInterventionNotification(app: String, count: Int) {
        val interventionIntent = Intent(this, MainActivity::class.java).apply {
            action = Intent.ACTION_MAIN
            addCategory(Intent.CATEGORY_LAUNCHER)
            flags = Intent.FLAG_ACTIVITY_NEW_TASK or
                    Intent.FLAG_ACTIVITY_REORDER_TO_FRONT or
                    Intent.FLAG_ACTIVITY_SINGLE_TOP
            putExtra("open_mindful_break", true)
            putExtra("reels_count", count)
            putExtra("trigger_app", app)
        }

        val pendingIntent = PendingIntent.getActivity(
            this,
            101,
            interventionIntent,
            PendingIntent.FLAG_UPDATE_CURRENT or (if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.M) PendingIntent.FLAG_IMMUTABLE else 0)
        )

        val notification = NotificationCompat.Builder(this, CHANNEL_INTERVENTION_ID)
            .setContentTitle("🛑 Daily Reel Limit Reached ($count Reels)")
            .setContentText("You reached your reel target on $app. Tap to take a mindful break.")
            .setSmallIcon(android.R.drawable.ic_dialog_alert)
            .setContentIntent(pendingIntent)
            .setFullScreenIntent(pendingIntent, true)
            .setAutoCancel(true)
            .setPriority(NotificationCompat.PRIORITY_MAX)
            .setCategory(NotificationCompat.CATEGORY_ALARM)
            .addAction(
                android.R.drawable.ic_media_pause,
                "Take Mindful Break",
                pendingIntent
            )
            .build()

        val manager = getSystemService(Context.NOTIFICATION_SERVICE) as NotificationManager
        manager.notify(INTERVENTION_NOTIFICATION_ID, notification)
    }

    override fun onBind(intent: Intent?): IBinder? = null
}
