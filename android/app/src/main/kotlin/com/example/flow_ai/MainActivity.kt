package com.example.flow_ai

import android.content.Context
import android.content.Intent
import android.provider.Settings
import android.text.TextUtils
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel
import com.example.flow_ai.FlowAccessibilityService

class MainActivity: FlutterActivity() {
    private val CHANNEL = "flow_ai/platform"

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)

        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL).setMethodCallHandler { call, result ->
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

                    if (!newStart.isNullOrEmpty()) FlowAccessibilityService.aiTrigger = newStart
                    if (!newEnd.isNullOrEmpty()) FlowAccessibilityService.endTrigger = newEnd
                    result.success(null)
                }
                else -> result.notImplemented()
            }
        }
    }

    private fun openAccessibilitySettings() {
        startActivity(Intent(Settings.ACTION_ACCESSIBILITY_SETTINGS).addFlags(Intent.FLAG_ACTIVITY_NEW_TASK))
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
