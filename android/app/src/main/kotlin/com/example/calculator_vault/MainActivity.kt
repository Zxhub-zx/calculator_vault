package com.example.calculator_vault

import android.content.ComponentName
import android.content.Intent
import android.content.pm.PackageManager
import android.provider.Settings
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

class MainActivity : FlutterActivity() {
    private val appsChannel = "calculator_vault/apps"
    private val notificationsChannel = "calculator_vault/notifications"

    override fun configureFlutterEngine(engine: FlutterEngine) {
        super.configureFlutterEngine(engine)
        MethodChannel(engine.dartExecutor.binaryMessenger, appsChannel).setMethodCallHandler { call, result ->
            when (call.method) {
                "getLaunchableApps" -> {
                    val intent = Intent(Intent.ACTION_MAIN).apply { addCategory(Intent.CATEGORY_LAUNCHER) }
                    val list = packageManager.queryIntentActivities(intent, PackageManager.MATCH_ALL)
                        .filter { it.activityInfo.packageName != packageName }
                        .map { mapOf("label" to it.loadLabel(packageManager).toString(), "packageName" to it.activityInfo.packageName) }
                        .distinctBy { it["packageName"] }
                        .sortedBy { it["label"].toString().lowercase() }
                    result.success(list)
                }
                "launchApp" -> {
                    val pkg = call.argument<String>("packageName")
                    val launch = pkg?.let { packageManager.getLaunchIntentForPackage(it) }
                    if (launch == null) result.success(false)
                    else { launch.addFlags(Intent.FLAG_ACTIVITY_NEW_TASK); startActivity(launch); result.success(true) }
                }
                else -> result.notImplemented()
            }
        }
        MethodChannel(engine.dartExecutor.binaryMessenger, notificationsChannel).setMethodCallHandler { call, result ->
            val prefs = getSharedPreferences("vault", MODE_PRIVATE)
            when (call.method) {
                "isNotificationAccessEnabled" -> {
                    val enabled = NotificationListenerServiceEnabled()
                    result.success(enabled)
                }
                "openNotificationAccessSettings" -> {
                    startActivity(Intent("android.settings.ACTION_NOTIFICATION_LISTENER_SETTINGS")); result.success(null)
                }
                "setHiddenPackages" -> {
                    val list = call.argument<List<String>>("packages") ?: emptyList()
                    prefs.edit().putStringSet("hidden_packages", list.toSet()).apply(); result.success(null)
                }
                "clearHiddenPackage" -> {
                    val set = (prefs.getStringSet("hidden_packages", emptySet()) ?: emptySet()).toMutableSet()
                    set.remove(call.argument<String>("packageName")); prefs.edit().putStringSet("hidden_packages", set).apply(); result.success(null)
                }
                else -> result.notImplemented()
            }
        }
    }

    private fun NotificationListenerServiceEnabled(): Boolean {
        val cn = ComponentName(this, NotificationBlockerService::class.java)
        val enabled = Settings.Secure.getString(contentResolver, "enabled_notification_listeners") ?: return false
        return enabled.split(":").mapNotNull { ComponentName.unflattenFromString(it) }.contains(cn)
    }
}
