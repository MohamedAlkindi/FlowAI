package com.example.flow_ai.handlers

import android.content.Context
import android.os.Handler
import android.os.Looper
import android.provider.Settings
import android.util.Log
import android.view.accessibility.AccessibilityNodeInfo
import com.example.flow_ai.constants.ServiceConstants
import com.example.flow_ai.models.GenerationState
import com.example.flow_ai.models.TextSpan
import com.example.flow_ai.services.AIService
import com.example.flow_ai.ui.OverlayBubbleManager
import com.example.flow_ai.utils.TextUtils
import kotlinx.coroutines.CoroutineScope
import kotlinx.coroutines.Dispatchers
import kotlinx.coroutines.SupervisorJob
import kotlinx.coroutines.cancel
import kotlinx.coroutines.launch

class GenerationHandler(
    private val context: Context,
    private val generationState: GenerationState,
    private val aiService: AIService,
    private val overlayBubbleManager: OverlayBubbleManager
) {
    
    private val serviceScope = CoroutineScope(Dispatchers.IO + SupervisorJob())
    
    fun performGeneration(source: AccessibilityNodeInfo, fullText: String, span: TextSpan, aiTrigger: String, endTrigger: String) {
        if (generationState.isGenerating) {
            Log.w(ServiceConstants.TAG, "Already generating, skipping request")
            return
        }

        generationState.isGenerating = true
        
        val (prefixText, prompt, suffixText) = TextUtils.extractTextParts(fullText, span.start, span.end, aiTrigger, endTrigger)

        // Store for callbacks - create copies to avoid recycling issues
        generationState.lastNode = AccessibilityNodeInfo.obtain(source)
        generationState.originalSourceNode = AccessibilityNodeInfo.obtain(source)
        generationState.lastPrefix = prefixText
        generationState.lastSuffix = suffixText
        generationState.lastPrompt = prompt

        Log.d(ServiceConstants.TAG, "Generation started - Prompt: '$prompt', Prefix: '$prefixText', Suffix: '$suffixText'")

        // Show dots immediately on the main thread, replacing ONLY the trigger section
        Handler(Looper.getMainLooper()).post {
            val textWithDots = prefixText + "…" + suffixText
            Log.d(ServiceConstants.TAG, "Replacing trigger section with dots: '$textWithDots'")
            TextUtils.replaceText(source, textWithDots)
        }

        serviceScope.launch {
            try {
                aiService.invokeSupabaseFunction(prompt) { delta ->
                    generationState.lastAIText = delta
                    Log.d(ServiceConstants.TAG, "AI response received: '$delta'")
                    Handler(Looper.getMainLooper()).post {
                        if (Settings.canDrawOverlays(context)) {
                            showAIBubbleWithCallbacks(prompt, delta, source)
                        } else {
                            Log.w(ServiceConstants.TAG, "SYSTEM_ALERT_WINDOW permission not granted, falling back to direct replacement")
                            val finalText = generationState.lastPrefix + delta + generationState.lastSuffix
                            Log.d(ServiceConstants.TAG, "Direct replacement: '$finalText' (preserving surrounding text)")
                            TextUtils.replaceText(source, finalText)
                        }
                    }
                }
            } catch (e: Exception) {
                handleGenerationError(e, prompt, source)
            } finally {
                generationState.isGenerating = false
            }
        }
    }
    
    private fun showAIBubbleWithCallbacks(prompt: String, delta: String, source: AccessibilityNodeInfo) {
        overlayBubbleManager.showDraggableAIBubble(
            prompt,
            delta,
            onApply = { textToApply ->
                // Replace the dots with AI text in the ORIGINAL app's text field
                val finalText = generationState.lastPrefix + textToApply + generationState.lastSuffix
                Log.d(ServiceConstants.TAG, "Applying AI text to original app field: '$finalText' (preserving surrounding text)")
                generationState.originalSourceNode?.let { node ->
                    TextUtils.replaceText(node, finalText)
                }
                overlayBubbleManager.removeAIBubble()
            },
            onCancel = {
                // Restore the original trigger text in the ORIGINAL app's text field
                val originalText = generationState.lastPrefix + prompt + generationState.lastSuffix
                Log.d(ServiceConstants.TAG, "Canceling - restoring original trigger in original app field: '$originalText' (preserving surrounding text)")
                generationState.originalSourceNode?.let { node ->
                    TextUtils.replaceText(node, originalText)
                }
                overlayBubbleManager.removeAIBubble()
            },
            onRedo = { newPrompt ->
                // Re-trigger generation but KEEP the bubble visible
                serviceScope.launch {
                    try {
                        aiService.invokeSupabaseFunction(newPrompt) { newDelta ->
                            generationState.lastAIText = newDelta
                            Handler(Looper.getMainLooper()).post {
                                overlayBubbleManager.updateBubbleText(newDelta)
                            }
                        }
                    } catch (e: Exception) {
                        Handler(Looper.getMainLooper()).post {
                            overlayBubbleManager.updateBubbleText("Error: ${e.message}")
                        }
                    }
                }
            }
        )
    }
    
    private fun handleGenerationError(e: Exception, prompt: String, source: AccessibilityNodeInfo) {
        val errorMsg = "Error: ${e.message}"
        Log.e(ServiceConstants.TAG, "Edge function error: $errorMsg", e)
        Handler(Looper.getMainLooper()).post {
            if (Settings.canDrawOverlays(context)) {
                showErrorBubbleWithCallbacks(prompt, errorMsg, source)
            } else {
                Log.w(ServiceConstants.TAG, "SYSTEM_ALERT_WINDOW permission not granted, falling back to direct replacement for error")
                val finalText = generationState.lastPrefix + errorMsg + generationState.lastSuffix
                Log.d(ServiceConstants.TAG, "Direct error replacement: '$finalText' (preserving surrounding text)")
                TextUtils.replaceText(source, finalText)
            }
        }
    }
    
    private fun showErrorBubbleWithCallbacks(prompt: String, errorMsg: String, source: AccessibilityNodeInfo) {
        overlayBubbleManager.showDraggableAIBubble(
            prompt,
            errorMsg,
            onApply = { textToApply ->
                val finalText = generationState.lastPrefix + textToApply + generationState.lastSuffix
                Log.d(ServiceConstants.TAG, "Applying error text to original app field: '$finalText' (preserving surrounding text)")
                generationState.originalSourceNode?.let { node ->
                    TextUtils.replaceText(node, finalText)
                }
                overlayBubbleManager.removeAIBubble()
            },
            onCancel = {
                val originalText = generationState.lastPrefix + prompt + generationState.lastSuffix
                Log.d(ServiceConstants.TAG, "Canceling error - restoring original trigger in original app field: '$originalText' (preserving surrounding text)")
                generationState.originalSourceNode?.let { node ->
                    TextUtils.replaceText(node, originalText)
                }
                overlayBubbleManager.removeAIBubble()
            },
            onRedo = { newPrompt ->
                serviceScope.launch {
                    try {
                        aiService.invokeSupabaseFunction(newPrompt) { newDelta ->
                            generationState.lastAIText = newDelta
                            Handler(Looper.getMainLooper()).post {
                                overlayBubbleManager.updateBubbleText(newDelta)
                            }
                        }
                    } catch (e: Exception) {
                        Handler(Looper.getMainLooper()).post {
                            overlayBubbleManager.updateBubbleText("Error: ${e.message}")
                        }
                    }
                }
            }
        )
    }
    
    fun handleAIBubbleAction(action: String, newPrompt: String? = null) {
        when (action) {
            "apply" -> {
                generationState.lastNode?.let {
                    TextUtils.replaceText(it, generationState.lastPrefix + generationState.lastAIText + generationState.lastSuffix)
                }
            }
            "cancel" -> {
                // Do nothing, just dismiss
            }
            "redo" -> {
                val prompt = newPrompt ?: generationState.lastPrompt
                serviceScope.launch {
                    try {
                        aiService.invokeSupabaseFunction(prompt) { delta ->
                            generationState.lastAIText = delta
                            Handler(Looper.getMainLooper()).post {
                                overlayBubbleManager.showDraggableAIBubble(
                                    prompt, 
                                    delta,
                                    onApply = { aiText ->
                                        TextUtils.replaceText(generationState.lastNode ?: return@showDraggableAIBubble, generationState.lastPrefix + aiText + generationState.lastSuffix)
                                    }, 
                                    onCancel = {}, 
                                    onRedo = {}
                                )
                            }
                        }
                    } catch (e: Exception) {
                        Handler(Looper.getMainLooper()).post {
                            overlayBubbleManager.showDraggableAIBubble(
                                prompt, 
                                "Error: ${e.message}",
                                onApply = { aiText ->
                                    TextUtils.replaceText(generationState.lastNode ?: return@showDraggableAIBubble, generationState.lastPrefix + aiText + generationState.lastSuffix)
                                }, 
                                onCancel = {}, 
                                onRedo = {}
                            )
                        }
                    } finally {
                        generationState.isGenerating = false
                    }
                }
            }
        }
    }
    
    fun cleanup() {
        serviceScope.cancel()
        overlayBubbleManager.removeAIBubble()
        // Clean up stored nodes to prevent memory leaks
        generationState.lastNode?.recycle()
        generationState.originalSourceNode?.recycle()
        generationState.lastNode = null
        generationState.originalSourceNode = null
    }
}

