package com.example.calculator_vault

import android.service.notification.NotificationListenerService
import android.service.notification.StatusBarNotification

class NotificationBlockerService : NotificationListenerService() {
    override fun onNotificationPosted(sbn: StatusBarNotification) {
        val prefs = getSharedPreferences("vault", MODE_PRIVATE)
        val hidden = prefs.getStringSet("hidden_packages", emptySet()) ?: emptySet()
        if (hidden.contains(sbn.packageName) && sbn.packageName != packageName) {
            cancelNotification(sbn.key)
        }
    }
}
