package com.example.flow_ai.utils

import android.accessibilityservice.AccessibilityService
import android.util.Log
import android.view.accessibility.AccessibilityNodeInfo
import com.example.flow_ai.constants.ServiceConstants

object AccessibilityUtils {
    
    fun getFocusedEditableNode(service: AccessibilityService): AccessibilityNodeInfo? {
        val root = service.rootInActiveWindow ?: return null
        val inputFocus = root.findFocus(AccessibilityNodeInfo.FOCUS_INPUT)
        if (inputFocus != null && (inputFocus.isEditable || inputFocus.className?.toString()?.contains("EditText") == true)) {
            return inputFocus
        }
        val queue: ArrayDeque<AccessibilityNodeInfo> = ArrayDeque()
        queue.add(root)
        while (queue.isNotEmpty()) {
            val node = queue.removeFirst()
            if (node.isFocused && (node.isEditable || node.className?.toString()?.contains("EditText") == true)) {
                return node
            }
            for (i in 0 until node.childCount) {
                node.getChild(i)?.let { queue.add(it) }
            }
        }
        return null
    }
    
    fun findFocusedEditableNode(service: AccessibilityService): AccessibilityNodeInfo? {
        val rootNode = service.rootInActiveWindow ?: return null
        
        // Search for focused editable nodes
        val focusedNodes = rootNode.findAccessibilityNodeInfosByViewId("android:id/edit")
        for (node in focusedNodes) {
            if (node.isFocused && node.isEditable) {
                return node
            }
        }
        
        // If no specific edit ID found, search more broadly
        return findFocusedEditableNodeRecursive(rootNode)
    }
    
    private fun findFocusedEditableNodeRecursive(node: AccessibilityNodeInfo?): AccessibilityNodeInfo? {
        if (node == null) return null
        
        if (node.isFocused && node.isEditable) {
            return node
        }
        
        for (i in 0 until node.childCount) {
            val child = node.getChild(i)
            val result = findFocusedEditableNodeRecursive(child)
            if (result != null) {
                return result
            }
        }
        
        return null
    }
    
    fun isEditableNode(node: AccessibilityNodeInfo?): Boolean {
        return node != null && (node.isEditable || node.className?.toString()?.contains("EditText") == true)
    }
}

