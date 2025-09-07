package com.example.flow_ai

import android.accessibilityservice.AccessibilityService
import android.accessibilityservice.AccessibilityServiceInfo
import android.util.Log
import android.view.KeyEvent
import android.view.accessibility.AccessibilityEvent
import android.view.accessibility.AccessibilityNodeInfo
import com.example.flow_ai.constants.ServiceConstants
import com.example.flow_ai.handlers.GenerationHandler
import com.example.flow_ai.handlers.TriggerHandler
import com.example.flow_ai.models.GenerationState
import com.example.flow_ai.models.TextSpan
import com.example.flow_ai.models.TriggerConfig
import com.example.flow_ai.services.AIService
import com.example.flow_ai.ui.OverlayBubbleManager

class FlowAccessibilityService : AccessibilityService() {
    
    companion object {
        @Volatile var instance: FlowAccessibilityService? = null
        @Volatile var triggerConfig: TriggerConfig = TriggerConfig()
    }
    
    private lateinit var generationState: GenerationState
    private lateinit var aiService: AIService
    private lateinit var overlayBubbleManager: OverlayBubbleManager
    private lateinit var generationHandler: GenerationHandler
    private lateinit var triggerHandler: TriggerHandler
    
    override fun onCreate() {
        super.onCreate()
        Log.d(ServiceConstants.TAG, "FlowAccessibilityService onCreate")
        instance = this
        
        initializeComponents()
    }
    
    private fun initializeComponents() {
        generationState = GenerationState()
        aiService = AIService(this)
        overlayBubbleManager = OverlayBubbleManager(this)
        generationHandler = GenerationHandler(this, generationState, aiService, overlayBubbleManager)
        
        triggerHandler = TriggerHandler(
            service = this,
            generationState = generationState,
            triggerConfig = triggerConfig,
            onTriggerDetected = { source, text, span ->
                generationHandler.performGeneration(
                    source, 
                    text, 
                    span, 
                    triggerConfig.aiTrigger, 
                    triggerConfig.endTrigger
                )
            }
        )
    }

    override fun onServiceConnected() {
        super.onServiceConnected()
        val info = AccessibilityServiceInfo().apply {
            eventTypes = AccessibilityEvent.TYPE_VIEW_TEXT_CHANGED or AccessibilityEvent.TYPE_VIEW_TEXT_SELECTION_CHANGED
            feedbackType = AccessibilityServiceInfo.FEEDBACK_GENERIC
            flags = AccessibilityServiceInfo.FLAG_REPORT_VIEW_IDS or AccessibilityServiceInfo.FLAG_REQUEST_FILTER_KEY_EVENTS
            notificationTimeout = 50
        }
        serviceInfo = info
    }
    
    override fun onAccessibilityEvent(event: AccessibilityEvent) {
        triggerHandler.handleAccessibilityEvent(event)
    }
    
    override fun onKeyEvent(event: KeyEvent): Boolean {
        return triggerHandler.handleKeyEvent(event)
    }

    fun handleAIBubbleAction(action: String, newPrompt: String? = null) {
        generationHandler.handleAIBubbleAction(action, newPrompt)
    }

    override fun onInterrupt() {}

    override fun onDestroy() {
        super.onDestroy()
        Log.d(ServiceConstants.TAG, "FlowAccessibilityService onDestroy")
        generationHandler.cleanup()
        instance = null
    }
}

