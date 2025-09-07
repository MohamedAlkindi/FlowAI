package com.example.flow_ai.models

import android.view.accessibility.AccessibilityNodeInfo
import com.example.flow_ai.constants.ServiceConstants

data class GenerationState(
    var lastNode: AccessibilityNodeInfo? = null,
    var originalSourceNode: AccessibilityNodeInfo? = null,
    var lastPrefix: String = "",
    var lastSuffix: String = "",
    var lastPrompt: String = "",
    var lastAIText: String = "",
    var isGenerating: Boolean = false
)

data class TriggerConfig(
    var aiTrigger: String = ServiceConstants.DEFAULT_AI_TRIGGER,
    var endTrigger: String = ServiceConstants.DEFAULT_END_TRIGGER
)

data class TextSpan(
    val start: Int,
    val end: Int
)
