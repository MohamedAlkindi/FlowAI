package com.example.flow_ai.handlers

import android.accessibilityservice.AccessibilityService
import android.util.Log
import android.view.KeyEvent
import android.view.accessibility.AccessibilityEvent
import android.view.accessibility.AccessibilityNodeInfo
import com.example.flow_ai.constants.ServiceConstants
import com.example.flow_ai.models.GenerationState
import com.example.flow_ai.models.TriggerConfig
import com.example.flow_ai.models.TextSpan
import com.example.flow_ai.utils.AccessibilityUtils
import com.example.flow_ai.utils.TextUtils

class TriggerHandler(
    private val service: AccessibilityService,
    private val generationState: GenerationState,
    private val triggerConfig: TriggerConfig,
    private val onTriggerDetected: (AccessibilityNodeInfo, String, TextSpan) -> Unit
) {
    
    private var lastTriggerTime = 0L
    
    fun handleAccessibilityEvent(event: AccessibilityEvent) {
        if (event.eventType == AccessibilityEvent.TYPE_VIEW_TEXT_CHANGED) {
            // --- IME/soft keyboard logic ---
            val newText = event.text?.joinToString("") ?: ""
            if (newText.isNotEmpty() && !event.isPassword) {
                Log.d(ServiceConstants.TAG, "TextChanged: '$newText'")
                val aiIndex = newText.indexOf(triggerConfig.aiTrigger)
                val endIndex = newText.indexOf(triggerConfig.endTrigger, aiIndex + triggerConfig.aiTrigger.length)
                if (aiIndex != -1 && endIndex != -1 && endIndex > aiIndex) {
                    Log.d(ServiceConstants.TAG, "Trigger via soft keyboard: aiTrigger='${triggerConfig.aiTrigger}', endTrigger='${triggerConfig.endTrigger}', aiIndex=$aiIndex, endIndex=$endIndex")
                    handleTrigger()
                    return
                }
            }
            // --- Physical keyboard logic (using source.text) ---
            val source = event.source ?: return
            val text = source.text?.toString() ?: event.text.joinToString("")
            if (!generationState.isGenerating) {
                val span = TextUtils.findAiSpan(text, triggerConfig.aiTrigger, triggerConfig.endTrigger)
                if (span != null && span.end > span.start && text[span.end] == triggerConfig.endTrigger.firstOrNull()) {
                    onTriggerDetected(source, text, span)
                }
            }
        }
    }
    
    fun handleKeyEvent(event: KeyEvent): Boolean {
        if (event.action == KeyEvent.ACTION_UP) {
            val endTriggerChar = triggerConfig.endTrigger.firstOrNull()
            if (endTriggerChar != null && event.unicodeChar == endTriggerChar.code) {
                Log.d(ServiceConstants.TAG, "Trigger via physical key: $endTriggerChar")
                handleTrigger()
            }
        }
        return false
    }
    
    private fun handleTrigger() {
        val now = System.currentTimeMillis()
        if (now - lastTriggerTime < ServiceConstants.TRIGGER_COOLDOWN) return
        lastTriggerTime = now

        val focusedNode = AccessibilityUtils.getFocusedEditableNode(service)
        if (focusedNode != null && !generationState.isGenerating) {
            try {
                val text = focusedNode.text?.toString() ?: ""
                val span = TextUtils.findAiSpan(text, triggerConfig.aiTrigger, triggerConfig.endTrigger)
                if (span != null) {
                    Log.d(ServiceConstants.TAG, "Performing AI generation on span: $span")
                    // Create a copy of the node info to avoid recycling issues
                    val nodeCopy = AccessibilityNodeInfo.obtain(focusedNode)
                    onTriggerDetected(nodeCopy, text, span)
                }
            } finally {
                // Important: free resources - only recycle the original node
                focusedNode.recycle()
            }
        }
    }
}

