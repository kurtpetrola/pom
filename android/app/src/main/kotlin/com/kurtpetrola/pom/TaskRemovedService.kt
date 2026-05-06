package com.kurtpetrola.pom

import android.app.NotificationManager
import android.app.Service
import android.content.Intent
import android.os.IBinder

/**
 * A lightweight service whose sole purpose is to cancel the ongoing timer
 * notification when the user swipes the app from the recents screen.
 *
 * Android calls [onTaskRemoved] reliably — even on gesture-nav devices —
 * unlike Flutter's `AppLifecycleState.detached` which is often skipped.
 */
class TaskRemovedService : Service() {

    companion object {
        /** Must match [NotificationService._ongoingNotificationId] on the Dart side. */
        const val ONGOING_NOTIFICATION_ID = 2
    }

    override fun onBind(intent: Intent?): IBinder? = null

    override fun onTaskRemoved(rootIntent: Intent?) {
        val manager = getSystemService(NOTIFICATION_SERVICE) as NotificationManager
        manager.cancel(ONGOING_NOTIFICATION_ID)
        stopSelf()
    }
}
