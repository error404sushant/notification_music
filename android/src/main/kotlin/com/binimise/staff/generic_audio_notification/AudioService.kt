package com.binimise.staff.generic_audio_notification

import android.app.NotificationChannel
import android.app.NotificationManager
import android.app.PendingIntent
import android.app.Service
import android.content.Context
import android.content.Intent
import android.media.AudioAttributes
import android.media.MediaPlayer
import android.os.Build
import android.os.IBinder
import androidx.core.app.NotificationCompat

class AudioService : Service() {

    private var mediaPlayer: MediaPlayer? = null
    private var isServicePlaying = false
    private var notificationTimestamp: Long = 0
    private var notificationTitle: String = ""
    private var notificationBody: String = ""
    private var notificationUrl: String = ""

    companion object {
        const val ACTION_START = "START_AUDIO"
        const val ACTION_STOP = "STOP_AUDIO"
        const val ACTION_NOTIFICATION_TAPPED = "NOTIFICATION_TAPPED"
        const val EXTRA_URL = "EXTRA_URL"
        const val EXTRA_TITLE = "EXTRA_TITLE"
        const val EXTRA_BODY = "EXTRA_BODY"
        const val EXTRA_ICON = "EXTRA_ICON" // Resource name
        const val EXTRA_LOOP = "EXTRA_LOOP" // Loop audio or play once
        const val EXTRA_TIMESTAMP = "EXTRA_TIMESTAMP" // Notification timestamp
        const val EXTRA_NOTIFICATION_TITLE = "EXTRA_NOTIFICATION_TITLE"
        const val EXTRA_NOTIFICATION_BODY = "EXTRA_NOTIFICATION_BODY"
        const val EXTRA_NOTIFICATION_URL = "EXTRA_NOTIFICATION_URL"
        const val CHANNEL_ID = "generic_audio_alert_channel"
        const val NOTIFICATION_ID = 888
        const val BROADCAST_NOTIFICATION_TAPPED = "com.binimise.staff.generic_audio_notification.NOTIFICATION_TAPPED"
    }

    override fun onBind(intent: Intent?): IBinder? {
        return null
    }

    override fun onStartCommand(intent: Intent?, flags: Int, startId: Int): Int {
        if (intent == null) return START_NOT_STICKY

        when (intent.action) {
            ACTION_START -> {
                val url = intent.getStringExtra(EXTRA_URL)
                val title = intent.getStringExtra(EXTRA_TITLE) ?: "Alert"
                val body = intent.getStringExtra(EXTRA_BODY) ?: "Playing audio..."
                val icon = intent.getStringExtra(EXTRA_ICON)
                val loop = intent.getBooleanExtra(EXTRA_LOOP, true)
                
                // Store notification data
                notificationTimestamp = System.currentTimeMillis()
                notificationTitle = title
                notificationBody = body
                notificationUrl = url ?: ""
                
                startForegroundService(title, body, icon)
                if (url != null) {
                    playAudio(url, loop)
                }
            }
            ACTION_STOP -> {
                stopAudio()
                stopForeground(true)
                stopSelf()
            }
            ACTION_NOTIFICATION_TAPPED -> {
                // Broadcast the tap event with all notification data to Flutter
                val broadcastIntent = Intent(BROADCAST_NOTIFICATION_TAPPED)
                broadcastIntent.putExtra(EXTRA_TIMESTAMP, notificationTimestamp)
                broadcastIntent.putExtra(EXTRA_NOTIFICATION_TITLE, notificationTitle)
                broadcastIntent.putExtra(EXTRA_NOTIFICATION_BODY, notificationBody)
                broadcastIntent.putExtra(EXTRA_NOTIFICATION_URL, notificationUrl)
                sendBroadcast(broadcastIntent)
                
                // Stop audio and service
                stopAudio()
                stopForeground(true)
                stopSelf()
            }
        }

        return START_NOT_STICKY
    }

    private fun startForegroundService(title: String, body: String, iconName: String?) {
        createNotificationChannel()

        // Try to find the icon resource ID
        var iconResId = android.R.drawable.ic_media_play
        if (iconName != null) {
            val resId = resources.getIdentifier(iconName, "drawable", packageName)
            if (resId != 0) {
                iconResId = resId
            } else {
                 // Try mipmap if drawable failed
                 val mipmapId = resources.getIdentifier(iconName, "mipmap", packageName)
                 if (mipmapId != 0) iconResId = mipmapId
            }
        }
        
        // Create intent for notification tap - this will stop audio and send timestamp
        val tapIntent = Intent(this, AudioService::class.java)
        tapIntent.action = ACTION_NOTIFICATION_TAPPED
        val pendingIntent = PendingIntent.getService(
            this, 
            0, 
            tapIntent, 
            PendingIntent.FLAG_UPDATE_CURRENT or PendingIntent.FLAG_IMMUTABLE
        )

        val notification = NotificationCompat.Builder(this, CHANNEL_ID)
            .setContentTitle(title)
            .setContentText(body)
            .setSmallIcon(iconResId)
            .setOngoing(true)
            .setContentIntent(pendingIntent)
            .setPriority(NotificationCompat.PRIORITY_MAX)
            .setCategory(NotificationCompat.CATEGORY_ALARM)
            .build()

        startForeground(NOTIFICATION_ID, notification)
    }

    private fun createNotificationChannel() {
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
            val channelName = "Critical Alerts"
            val channelDescription = "Notifications for critical audio alerts"
            val importance = NotificationManager.IMPORTANCE_HIGH
            val channel = NotificationChannel(CHANNEL_ID, channelName, importance).apply {
                description = channelDescription
                setSound(null, null) // Silent notification, we handle audio
                enableVibration(true)
            }
            val notificationManager = getSystemService(Context.NOTIFICATION_SERVICE) as NotificationManager
            notificationManager.createNotificationChannel(channel)
        }
    }

    private fun playAudio(url: String, loop: Boolean = true) {
        if (isServicePlaying) return

        try {
            mediaPlayer = MediaPlayer().apply {
                setAudioAttributes(
                    AudioAttributes.Builder()
                        .setContentType(AudioAttributes.CONTENT_TYPE_MUSIC)
                        .setUsage(AudioAttributes.USAGE_ALARM)
                        .build()
                )
                setDataSource(url)
                isLooping = loop // Set looping based on parameter
                setOnPreparedListener { 
                    it.start() 
                    isServicePlaying = true
                }
                setOnErrorListener { mp, what, extra ->
                    android.util.Log.e("AudioService", "MediaPlayer error: what=$what, extra=$extra")
                    stopSelf()
                    true
                }
                setOnCompletionListener {
                    // If not looping, stop the service when audio completes
                    if (!loop) {
                        stopSelf()
                    }
                }
                prepareAsync()
            }
        } catch (e: Exception) {
            android.util.Log.e("AudioService", "Error playing audio", e)
            stopSelf()
        }
    }

    private fun stopAudio() {
        try {
            if (mediaPlayer?.isPlaying == true) {
                mediaPlayer?.stop()
            }
            mediaPlayer?.release()
            mediaPlayer = null
            isServicePlaying = false
        } catch (e: Exception) {
            e.printStackTrace()
        }
    }

    override fun onDestroy() {
        stopAudio()
        super.onDestroy()
    }
}
