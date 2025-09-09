package com.example.flow_ai

import android.content.Context
import android.content.Intent
import android.provider.Settings
import android.text.TextUtils
import android.net.Uri
import android.os.Build
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel
import com.example.flow_ai.FlowAccessibilityService
import com.example.flow_ai.models.TriggerConfig
import com.example.flow_ai.utils.DashboardStorage

class MainActivity: FlutterActivity() {
    private val CHANNEL = "flow_ai/platform"

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)

        val channel = MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL)
        channel.setMethodCallHandler { call, result ->
            when (call.method) {
                "isAccessibilityServiceEnabled" -> {
                    val enabled = isAccessibilityServiceEnabled(this)
                    result.success(enabled)
                }
                "openAccessibilitySettings" -> {
                    openAccessibilitySettings()
                    result.success(true)
                }
                "setTriggers" -> {
                    val newStart = call.argument<String>("startTrigger")
                    val newEnd = call.argument<String>("endTrigger")

                    if (!newStart.isNullOrEmpty()) FlowAccessibilityService.triggerConfig.aiTrigger = newStart
                    if (!newEnd.isNullOrEmpty()) FlowAccessibilityService.triggerConfig.endTrigger = newEnd
                    result.success(null)
                }
                "checkOverlayPermission" -> {
                    val hasPermission = if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.M) {
                        Settings.canDrawOverlays(this)
                    } else {
                        true
                    }
                    result.success(hasPermission)
                }
                "requestOverlayPermission" -> {
                    requestOverlayPermission()
                    result.success(true)
                }
                "getDashboardUsage" -> {
                    val json = DashboardStorage.getUsageJson(this)
                    // Log.d("MainActivity", "getDashboardUsage called, returning: $json")
                    result.success(json)
                }
                "getDashboardUsageHistory" -> {
                    val jsonArr = DashboardStorage.getUsageHistoryJson(this)
                    result.success(jsonArr)
                }
                "testSaveUsage" -> {
                    // Test method to manually save usage data
                    val testUsage = org.json.JSONObject().apply {
                        put("request_count", 5)
                        put("daily_limit", 40000)
                        put("requests_last_minute", 2)
                        put("per_minute_limit", 4000)
                        put("last_request_date", "2024-01-15")
                        put("last_request_minute", "2024-01-15T10:30:00.000Z")
                    }
                    DashboardStorage.saveUsage(this, testUsage)
                    result.success("Test usage data saved")
                }
                else -> result.notImplemented()
            }
        }
    }

    private fun openAccessibilitySettings() {
        startActivity(Intent(Settings.ACTION_ACCESSIBILITY_SETTINGS).addFlags(Intent.FLAG_ACTIVITY_NEW_TASK))
    }

    private fun requestOverlayPermission() {
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.M) {
            val intent = Intent(
                Settings.ACTION_MANAGE_OVERLAY_PERMISSION,
                Uri.parse("package:$packageName")
            )
            startActivity(intent)
        }
    }

    private fun isAccessibilityServiceEnabled(context: Context): Boolean {
        val expectedComponentName = "${context.packageName}/${FlowAccessibilityService::class.java.name}"
        val enabledServicesSetting = Settings.Secure.getString(context.contentResolver, Settings.Secure.ENABLED_ACCESSIBILITY_SERVICES)
        if (!enabledServicesSetting.isNullOrEmpty()) {
            val colonSplitter = TextUtils.SimpleStringSplitter(':')
            colonSplitter.setString(enabledServicesSetting)
            while (colonSplitter.hasNext()) {
                val componentName = colonSplitter.next()
                if (componentName.equals(expectedComponentName, ignoreCase = true)) {
                    return true
                }
            }
        }
        val accessibilityEnabled = Settings.Secure.getInt(context.contentResolver, Settings.Secure.ACCESSIBILITY_ENABLED, 0)
        return accessibilityEnabled == 1
    }
}
