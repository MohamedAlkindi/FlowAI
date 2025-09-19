package com.example.flow_ai.utils

import android.os.Bundle
import android.util.Log
import android.view.accessibility.AccessibilityNodeInfo
import com.example.flow_ai.constants.ServiceConstants
import com.example.flow_ai.models.TextSpan

object TextUtils {
    
    fun findAiSpan(text: String, aiTrigger: String, endTrigger: String): TextSpan? {
        val start = text.indexOf(aiTrigger)
        if (start == -1) return null
        val end = text.indexOf(endTrigger, start + aiTrigger.length)
        if (end == -1) return null
        return TextSpan(start, end)
    }
    
    fun replaceText(node: AccessibilityNodeInfo, newText: String) {
        try {
            // For Android 11+, we need to be more careful with text replacement
            val args = Bundle().apply {
                putCharSequence(AccessibilityNodeInfo.ACTION_ARGUMENT_SET_TEXT_CHARSEQUENCE, newText)
            }
            
            // Try ACTION_SET_TEXT first
            val result = node.performAction(AccessibilityNodeInfo.ACTION_SET_TEXT, args)
            if (!result) {
                // Fallback: try to clear and set text
                Log.d(ServiceConstants.TAG, "ACTION_SET_TEXT failed, trying fallback method")
                node.performAction(AccessibilityNodeInfo.ACTION_CLEAR_SELECTION)
                node.performAction(AccessibilityNodeInfo.ACTION_SET_SELECTION, Bundle().apply {
                    putInt(AccessibilityNodeInfo.ACTION_ARGUMENT_SELECTION_START_INT, 0)
                    putInt(AccessibilityNodeInfo.ACTION_ARGUMENT_SELECTION_END_INT, node.text?.length ?: 0)
                })
                node.performAction(AccessibilityNodeInfo.ACTION_SET_TEXT, args)
            }
        } catch (e: Exception) {
            Log.e(ServiceConstants.TAG, "Error replacing text", e)
        }
    }
    
    fun getCursorPosition(node: AccessibilityNodeInfo): Int {
        // Try to get cursor position from selection
        val selectionStart = node.textSelectionStart
        if (selectionStart >= 0) {
            return selectionStart
        }
        
        // Fallback to text length if no selection info
        val text = node.text?.toString() ?: ""
        return text.length
    }
    
    fun extractTextParts(fullText: String, startIndex: Int, endIndexInclusive: Int, aiTrigger: String, endTrigger: String): Triple<String, String, String> {
        // Extract the prompt (text between triggers, excluding the triggers themselves)
        val prompt = fullText.substring(startIndex + aiTrigger.length, endIndexInclusive)
        
        // Get text before the start trigger
        val prefixText = fullText.substring(0, startIndex)
        
        // Get text after the end trigger
        val suffixText = if (endIndexInclusive + endTrigger.length <= fullText.length) {
            fullText.substring(endIndexInclusive + endTrigger.length)
        } else {
            ""
        }
        
        return Triple(prefixText, prompt, suffixText)
    }
}

