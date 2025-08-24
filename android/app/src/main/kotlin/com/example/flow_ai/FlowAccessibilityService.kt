package com.example.flow_ai
import android.accessibilityservice.AccessibilityService
import android.accessibilityservice.AccessibilityServiceInfo
import android.os.Bundle
import android.provider.Settings
import android.util.Log
import android.view.KeyEvent
import android.view.accessibility.AccessibilityEvent
import android.view.accessibility.AccessibilityNodeInfo
import kotlinx.coroutines.*
import org.json.JSONObject
import java.io.BufferedReader
import java.io.OutputStreamWriter
import java.net.HttpURLConnection
import java.net.URL
import io.flutter.plugin.common.MethodChannel
import io.flutter.embedding.engine.FlutterEngineCache
import android.os.Handler
import android.os.Looper
import android.view.LayoutInflater
import android.view.WindowManager
import android.view.Gravity
import android.view.MotionEvent
import android.widget.EditText
import android.widget.TextView
import android.widget.Button
import android.content.Intent
import android.content.Context
import android.os.Build
import android.graphics.PixelFormat
import android.view.View
import android.view.inputmethod.InputMethodManager

class FlowAccessibilityService : AccessibilityService() {
    
    companion object {
        private const val TAG = "FlowAI"
        // By default it's "/ai" .
        var aiTrigger : String = "/ai"
        // By default it's "/".
        var endTrigger : String = "/"
        @Volatile var instance: FlowAccessibilityService? = null
    }
    
    private val serviceScope = CoroutineScope(Dispatchers.IO + SupervisorJob())
    @Volatile private var isGenerating: Boolean = false
    
    override fun onCreate() {
        super.onCreate()
        Log.d(TAG, "FlowAccessibilityService onCreate")
        instance = this
        windowManager = getSystemService(Context.WINDOW_SERVICE) as WindowManager
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
        if (event.eventType == AccessibilityEvent.TYPE_VIEW_TEXT_CHANGED) {
            // --- IME/soft keyboard logic ---
            val newText = event.text?.joinToString("") ?: ""
            if (newText.isNotEmpty() && !event.isPassword) {
                Log.d("FlowAI", "TextChanged: '$newText'")
                val aiIndex = newText.indexOf(aiTrigger)
                val endIndex = newText.indexOf(endTrigger, aiIndex + aiTrigger.length)
                if (aiIndex != -1 && endIndex != -1 && endIndex > aiIndex) {
                    Log.d("FlowAI", "Trigger via soft keyboard: aiTrigger='$aiTrigger', endTrigger='$endTrigger', aiIndex=$aiIndex, endIndex=$endIndex")
                    handleTrigger()
                    return
                }
            }
            // --- Physical keyboard logic (using source.text) ---
            val source = event.source ?: return
            val text = source.text?.toString() ?: event.text.joinToString("")
            if (!isGenerating) {
                val span = findAiSpan(text)
                if (span != null && span.second > span.first && text[span.second] == endTrigger.firstOrNull()) {
                    performGeneration(source, text, span.first, span.second)
                }
            }
        }
    }
        // Called for physical keyboards
    override fun onKeyEvent(event: KeyEvent): Boolean {
        if (event.action == KeyEvent.ACTION_UP) {
            val endTriggerChar = endTrigger.firstOrNull()
            if (endTriggerChar != null && event.unicodeChar == endTriggerChar.code) {
                Log.d("FlowAI", "Trigger via physical key: $endTriggerChar")
                handleTrigger()
            }
        }
        return false
    }

    // Debounce to prevent double firing
    private var lastTriggerTime = 0L
    private val triggerCooldown = 200L // ms

    // Shared logic for both paths
    private fun handleTrigger() {
        val now = System.currentTimeMillis()
        if (now - lastTriggerTime < triggerCooldown) return
        lastTriggerTime = now

        val focusedNode = getFocusedEditableNode()
        if (focusedNode != null && !isGenerating) {
            try {
                val text = focusedNode.text?.toString() ?: ""
                val span = findAiSpan(text)
                if (span != null) {
                    Log.d("FlowAI", "Performing AI generation on span: $span")
                    performGeneration(focusedNode, text, span.first, span.second)
                }
            } finally {
                // Important: free resources
                focusedNode.recycle()
            }
        }
    }
    
    private fun getFocusedEditableNode(): AccessibilityNodeInfo? {
        val root = rootInActiveWindow ?: return null
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

    private fun findAiSpan(text: String): Pair<Int, Int>? {
        val start = text.indexOf(aiTrigger)
        if (start == -1) return null
        val end = text.indexOf(endTrigger, start + aiTrigger.length)
        if (end == -1) return null
        return Pair(start, end)
    }

    // Store for callbacks
    private var lastNode: AccessibilityNodeInfo? = null
    private var lastPrefix: String = ""
    private var lastSuffix: String = ""
    private var lastPrompt: String = ""
    private var lastAIText: String = ""
    
    // Store the ORIGINAL source node that won't change when focus shifts
    private var originalSourceNode: AccessibilityNodeInfo? = null
    // Remove flutterChannel and obtainFlutterChannel

    // Remove all MethodChannel and Flutter bubble logic
    // Placeholder for native overlay
    private var aiBubbleView: android.view.View? = null
    private var aiBubbleParams: WindowManager.LayoutParams? = null
    private var windowManager: WindowManager? = null

    private fun removeAIBubble() {
        aiBubbleView?.let {
            windowManager?.removeView(it)
        }
        aiBubbleView = null
        aiBubbleParams = null
    }

    fun handleAIBubbleAction(action: String, newPrompt: String? = null) {
        // TODO: Called from MainActivity via MethodChannel when user acts
        when (action) {
            "apply" -> {
                lastNode?.let {
                    replaceText(it, lastPrefix + lastAIText + lastSuffix)
                }
            }
            "cancel" -> {
                // Do nothing, just dismiss
            }
            "redo" -> {
                val prompt = newPrompt ?: lastPrompt
                serviceScope.launch {
                    try {
                        invokeSupabaseFunction(prompt) { delta ->
                            lastAIText = delta
                            showDraggableAIBubble(prompt, delta,
                                onApply = { aiText ->
                                    replaceText(lastNode ?: return@showDraggableAIBubble, lastPrefix + aiText + lastSuffix)
                                },
                                onCancel = {
                                    // Dismiss bubble, do nothing
                                },
                                onRedo = { newPrompt ->
                                    // Re-invoke AI with new prompt
                                    serviceScope.launch {
                                        invokeSupabaseFunction(newPrompt) { newDelta ->
                                            Handler(Looper.getMainLooper()).post {
                                                showDraggableAIBubble(newPrompt, newDelta, onApply = { aiText ->
                                                    replaceText(lastNode ?: return@showDraggableAIBubble, lastPrefix + aiText + lastSuffix)
                                                }, onCancel = {}, onRedo = {})
                                            }
                                        }
                                    }
                                }
                            )
                        }
                    } catch (e: Exception) {
                        showDraggableAIBubble(prompt, "Error: ${e.message}",
                            onApply = { aiText ->
                                replaceText(lastNode ?: return@showDraggableAIBubble, lastPrefix + aiText + lastSuffix)
                            },
                            onCancel = {
                                // Dismiss bubble, do nothing
                            },
                            onRedo = { newPrompt ->
                                // Re-invoke AI with new prompt
                                serviceScope.launch {
                                    invokeSupabaseFunction(newPrompt) { newDelta ->
                                        Handler(Looper.getMainLooper()).post {
                                            showDraggableAIBubble(newPrompt, newDelta, onApply = { aiText ->
                                                replaceText(lastNode ?: return@showDraggableAIBubble, lastPrefix + aiText + lastSuffix)
                                            }, onCancel = {}, onRedo = {})
                                        }
                                    }
                                }
                            }
                        )
                    } finally {
                        isGenerating = false
                    }
                }
            }
        }
    }

    private fun performGeneration(source: AccessibilityNodeInfo, fullText: String, startIndex: Int, endIndexInclusive: Int) {
        if (isGenerating) {
            Log.w(TAG, "Already generating, skipping request")
            return
        }

        isGenerating = true
        
        // Extract the prompt (text between triggers, excluding the triggers themselves)
        val prompt = fullText.substring(startIndex + aiTrigger.length, endIndexInclusive)
        
        // Get text before the start trigger (e.g., "Hello there ")
        val prefixText = fullText.substring(0, startIndex)
        
        // Get text after the end trigger (e.g., " now bye")
        val suffixText = if (endIndexInclusive + endTrigger.length <= fullText.length) {
            fullText.substring(endIndexInclusive + endTrigger.length)
        } else {
            ""
        }

        // Store for callbacks
        lastNode = source
        originalSourceNode = source  // Store the ORIGINAL source node that won't change
        lastPrefix = prefixText
        lastSuffix = suffixText
        lastPrompt = prompt

        Log.d(TAG, "Generation started - Prompt: '$prompt', Prefix: '$prefixText', Suffix: '$suffixText'")

        // Show dots immediately on the main thread, replacing ONLY the trigger section
        // This preserves the surrounding text: prefixText + "..." + suffixText
        Handler(Looper.getMainLooper()).post {
            val textWithDots = prefixText + "…" + suffixText
            Log.d(TAG, "Replacing trigger section with dots: '$textWithDots'")
            replaceText(source, textWithDots)
        }

        serviceScope.launch {
            try {
                invokeSupabaseFunction(prompt) { delta ->
                    lastAIText = delta
                    Log.d(TAG, "AI response received: '$delta'")
                    Handler(Looper.getMainLooper()).post {
                        if (Settings.canDrawOverlays(this@FlowAccessibilityService)) {
                            showDraggableAIBubble(
                                prompt,
                                delta,
                                onApply = { textToApply ->
                                    // Replace the dots with AI text in the ORIGINAL app's text field
                                    val finalText = lastPrefix + textToApply + lastSuffix
                                    Log.d(TAG, "Applying AI text to original app field: '$finalText' (preserving surrounding text)")
                                    originalSourceNode?.let { node ->
                                        replaceText(node, finalText)
                                    }
                                    removeAIBubble()
                                },
                                onCancel = {
                                    // Restore the original trigger text in the ORIGINAL app's text field
                                    val originalText = lastPrefix + aiTrigger + lastPrompt + endTrigger + lastSuffix
                                    Log.d(TAG, "Canceling - restoring original trigger in original app field: '$originalText' (preserving surrounding text)")
                                    originalSourceNode?.let { node ->
                                        replaceText(node, originalText)
                                    }
                                    removeAIBubble()
                                },
                                onRedo = { newPrompt ->
                                    // Re-trigger generation but KEEP the bubble visible
                                    serviceScope.launch {
                                        try {
                                            invokeSupabaseFunction(newPrompt) { newDelta ->
                                                lastAIText = newDelta
                                                Handler(Looper.getMainLooper()).post {
                                                    val bubbleView = aiBubbleView
                                                    if (bubbleView != null) {
                                                        val aiResultText = bubbleView.findViewById<TextView>(R.id.aiResultText)
                                                        aiResultText?.text = newDelta
                                                    }
                                                }
                                            }
                                        } catch (e: Exception) {
                                            Handler(Looper.getMainLooper()).post {
                                                val bubbleView = aiBubbleView
                                                if (bubbleView != null) {
                                                    val aiResultText = bubbleView.findViewById<TextView>(R.id.aiResultText)
                                                    aiResultText?.text = "Error: ${e.message}"
                                                }
                                            }
                                        }
                                    }
                                }
                            )
                        } else {
                            Log.w(TAG, "SYSTEM_ALERT_WINDOW permission not granted, falling back to direct replacement")
                            val finalText = lastPrefix + delta + lastSuffix
                            Log.d(TAG, "Direct replacement: '$finalText' (preserving surrounding text)")
                            replaceText(source, finalText)
                        }
                    }
                }
            } catch (e: Exception) {
                val errorMsg = "Error: ${e.message}"
                Log.e(TAG, "Edge function error: $errorMsg", e)
                Handler(Looper.getMainLooper()).post {
                    if (Settings.canDrawOverlays(this@FlowAccessibilityService)) {
                        showDraggableAIBubble(
                            prompt,
                            errorMsg,
                            onApply = { textToApply ->
                                // Replace the dots with error text in the ORIGINAL app's text field
                                val finalText = lastPrefix + textToApply + lastSuffix
                                Log.d(TAG, "Applying error text to original app field: '$finalText' (preserving surrounding text)")
                                originalSourceNode?.let { node ->
                                    replaceText(node, finalText)
                                }
                                removeAIBubble()
                            },
                            onCancel = {
                                // Restore the original trigger text in the ORIGINAL app's text field
                                val originalText = lastPrefix + aiTrigger + lastPrompt + endTrigger + lastSuffix
                                Log.d(TAG, "Canceling error - restoring original trigger in original app field: '$originalText' (preserving surrounding text)")
                                originalSourceNode?.let { node ->
                                    replaceText(node, originalText)
                                }
                                removeAIBubble()
                            },
                            onRedo = { newPrompt ->
                                // Just call AI again and update existing aiResultText
                                serviceScope.launch {
                                    try {
                                        invokeSupabaseFunction(newPrompt) { newDelta ->
                                            lastAIText = newDelta
                                            Handler(Looper.getMainLooper()).post {
                                                val bubbleView = aiBubbleView
                                                val aiResultText = bubbleView?.findViewById<TextView>(R.id.aiResultText)
                                                aiResultText?.text = newDelta
                                            }
                                        }
                                    } catch (e: Exception) {
                                        Handler(Looper.getMainLooper()).post {
                                            val bubbleView = aiBubbleView
                                            val aiResultText = bubbleView?.findViewById<TextView>(R.id.aiResultText)
                                            aiResultText?.text = "Error: ${e.message}"
                                        }
                                    }
                                }
                            }
                        )
                    } else {
                        Log.w(TAG, "SYSTEM_ALERT_WINDOW permission not granted, falling back to direct replacement for error")
                        val finalText = lastPrefix + errorMsg + lastSuffix
                        Log.d(TAG, "Direct error replacement: '$finalText' (preserving surrounding text)")
                        replaceText(source, finalText)
                    }
                }
            } finally {
                isGenerating = false
            }
        }
    }

    private fun findFocusedEditableNode(): AccessibilityNodeInfo? {
        val rootNode = rootInActiveWindow ?: return null
        
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
    
    private fun getCursorPosition(node: AccessibilityNodeInfo): Int {
        // Try to get cursor position from selection
        val selectionStart = node.textSelectionStart
        if (selectionStart >= 0) {
            return selectionStart
        }
        
        // Fallback to text length if no selection info
        val text = node.text?.toString() ?: ""
        return text.length
    }
    private fun showDraggableAIBubble(
        prompt: String,
        aiText: String,
        onApply: (String) -> Unit,
        onCancel: () -> Unit,
        onRedo: (String) -> Unit
    ) {
        Log.d(TAG, "Showing AI bubble with prompt: '$prompt', AI text: '$aiText'")

        if (windowManager == null) {
            windowManager = getSystemService(Context.WINDOW_SERVICE) as WindowManager
        }

        if (!Settings.canDrawOverlays(this)) {
            Log.w(TAG, "No overlay permission, falling back to direct replacement")
            onApply(aiText)
            return
        }

        removeAIBubble()

        val inflater = LayoutInflater.from(this)
        val bubbleView = inflater.inflate(R.layout.ai_bubble_overlay, null)

        val promptEditText = bubbleView.findViewById<EditText>(R.id.promptEditText)
        val aiResultText = bubbleView.findViewById<TextView>(R.id.aiResultText)
        val applyButton = bubbleView.findViewById<Button>(R.id.applyButton)
        val cancelButton = bubbleView.findViewById<Button>(R.id.cancelButton)
        val redoButton = bubbleView.findViewById<Button>(R.id.redoButton)

        promptEditText?.setText(prompt)
        aiResultText?.text = aiText

        // --- Focus handling: start as NOT_FOCUSABLE ---
        val params = WindowManager.LayoutParams().apply {
            width = WindowManager.LayoutParams.WRAP_CONTENT
            height = WindowManager.LayoutParams.WRAP_CONTENT
            type = if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
                WindowManager.LayoutParams.TYPE_APPLICATION_OVERLAY
            } else {
                WindowManager.LayoutParams.TYPE_SYSTEM_ALERT
            }
            flags = WindowManager.LayoutParams.FLAG_NOT_FOCUSABLE or
                    WindowManager.LayoutParams.FLAG_NOT_TOUCH_MODAL or
                    WindowManager.LayoutParams.FLAG_WATCH_OUTSIDE_TOUCH
            gravity = Gravity.TOP or Gravity.START
            x = 100
            y = 200
            format = PixelFormat.TRANSLUCENT
            softInputMode = WindowManager.LayoutParams.SOFT_INPUT_ADJUST_RESIZE
        }

        aiBubbleView = bubbleView
        aiBubbleParams = params

        try {
            windowManager?.addView(bubbleView, params)
            Log.d(TAG, "AI bubble added")
        } catch (e: Exception) {
            Log.e(TAG, "Failed to add AI bubble", e)
            onApply(aiText)
            return
        }

        // --- Toggle focusable only when EditText is tapped ---
        promptEditText?.setOnFocusChangeListener { _, hasFocus ->
            aiBubbleParams?.let { currentParams ->
                currentParams.flags = if (hasFocus) {
                    WindowManager.LayoutParams.FLAG_NOT_TOUCH_MODAL or
                    WindowManager.LayoutParams.FLAG_WATCH_OUTSIDE_TOUCH
                } else {
                    WindowManager.LayoutParams.FLAG_NOT_FOCUSABLE or
                    WindowManager.LayoutParams.FLAG_NOT_TOUCH_MODAL or
                    WindowManager.LayoutParams.FLAG_WATCH_OUTSIDE_TOUCH
                }
                try {
                    windowManager?.updateViewLayout(bubbleView, currentParams)
                } catch (e: Exception) {
                    Log.e(TAG, "Failed to update bubble focus flags", e)
                }
            }
        }

        // --- Helper to reset focus back to NOT_FOCUSABLE ---
        fun resetFocus() {
            aiBubbleParams?.let { currentParams ->
                currentParams.flags = WindowManager.LayoutParams.FLAG_NOT_FOCUSABLE or
                                    WindowManager.LayoutParams.FLAG_NOT_TOUCH_MODAL or
                                    WindowManager.LayoutParams.FLAG_WATCH_OUTSIDE_TOUCH
                try {
                    windowManager?.updateViewLayout(bubbleView, currentParams)
                } catch (e: Exception) {
                    Log.e(TAG, "Failed to reset bubble focus", e)
                }
            }
            // also clear keyboard
            promptEditText?.clearFocus()
            val imm = getSystemService(Context.INPUT_METHOD_SERVICE) as InputMethodManager
            imm.hideSoftInputFromWindow(promptEditText?.windowToken, 0)
        }

        // --- Button actions ---
        applyButton?.setOnClickListener {
            val finalText = aiResultText?.text?.toString() ?: aiText
            onApply(finalText)
            resetFocus()
            removeAIBubble()
        }

        cancelButton?.setOnClickListener {
            onCancel()
            resetFocus()
            removeAIBubble()
        }

        redoButton?.setOnClickListener {
            val newPrompt = promptEditText?.text?.toString() ?: prompt
            aiResultText?.text = "..." // show waiting indicator

            // Call onRedo with the new prompt
            onRedo(newPrompt)
            resetFocus()
        }        

        // --- Make bubble draggable ---
        bubbleView.setOnTouchListener(object : View.OnTouchListener {
    private var initialX = 0
    private var initialY = 0
    private var initialTouchX = 0f
    private var initialTouchY = 0f

    override fun onTouch(v: View?, event: MotionEvent?): Boolean {
        if (event == null) return false
        when (event.action) {
            MotionEvent.ACTION_DOWN -> {
                initialX = params.x
                initialY = params.y
                initialTouchX = event.rawX
                initialTouchY = event.rawY
                return true
            }
            MotionEvent.ACTION_MOVE -> {
                params.x = initialX + (event.rawX - initialTouchX).toInt()
                params.y = initialY + (event.rawY - initialTouchY).toInt()
                windowManager?.updateViewLayout(bubbleView, params)
                return true
            }
        }
        return false
    }
})
    }

    private suspend fun invokeSupabaseFunction(prompt: String, onDelta: suspend (String) -> Unit) = withContext(Dispatchers.IO) {
        val supabaseUrl = BuildConfig.SUPABASE_URL
        val anonKey = BuildConfig.SUPABASE_ANON_KEY
        // Connectivity pre-check
        try {
            val pingUrl = URL(supabaseUrl)
            val pingConn = (pingUrl.openConnection() as HttpURLConnection).apply {
                requestMethod = "HEAD"
                connectTimeout = 3000
                readTimeout = 3000
            }
            pingConn.connect()
        } catch (e: Exception) {
            throw RuntimeException("No internet connection")
        }
        val url = URL("$supabaseUrl/functions/v1/gemini")
        val connection = (url.openConnection() as HttpURLConnection).apply {
            requestMethod = "POST"
            setRequestProperty("Content-Type", "application/json")
            setRequestProperty("Authorization", "Bearer $anonKey")
            setRequestProperty("apikey", anonKey)
            setRequestProperty("Accept", "*/*")
            setRequestProperty("Connection", "keep-alive")
            doOutput = true
            connectTimeout = 15000
            readTimeout = 60000
            setChunkedStreamingMode(0)
        }

        val deviceId = Settings.Secure.getString(contentResolver, Settings.Secure.ANDROID_ID) ?: "unknown_device"

        val body = JSONObject().apply {
            put("prompt", prompt)
            put("deviceId", deviceId)
            put("stream", true)
        }.toString()

        OutputStreamWriter(connection.outputStream).use { it.write(body) }

        val code = connection.responseCode
        val stream = if (code in 200..299) connection.inputStream else connection.errorStream
        val reader = BufferedReader(stream.reader())

        val accumulated = StringBuilder()
        var capturedErrorMessage: String? = null
        reader.use { r ->
            var line: String?
            while (r.readLine().also { line = it } != null) {
                val ln = line!! // do not trim; preserve whitespace
                var foundErrorThisLine = false
                try {
                    val json = JSONObject(ln)
                    if (json.has("delta")) {
                        val piece = json.optString("delta", "")
                        if (piece.isNotEmpty()) {
                            accumulated.append(piece)
                            onDelta(accumulated.toString())
                        }
                    } else if (json.has("text")) {
                        val finalText = json.optString("text", "")
                        accumulated.clear().append(finalText)
                        onDelta(accumulated.toString())
                    } else if (json.has("error")) {
                        val codeErr = json.optString("error", "")
                        capturedErrorMessage = when {
                            code == 429 && codeErr == "daily_usage_limit_reached" -> "Daily limit reached. Try again tomorrow."
                            code == 429 && codeErr == "per_minute_usage_limit_reached" -> "Too many requests. Please wait a moment."
                            else -> json.optString("message", "Request failed ($code)")
                        }
                        foundErrorThisLine = true
                    } else {
                        // Not a recognized JSON shape, treat as plain text chunk with newline
                        accumulated.append(ln).append('\n')
                        onDelta(accumulated.toString())
                    }
                } catch (_: Exception) {
                    // Plain text line, preserve newline
                    accumulated.append(ln).append('\n')
                    onDelta(accumulated.toString())
                }
                if (foundErrorThisLine) break
            }
        }

        if (code !in 200..299) {
            val fallback = accumulated.toString().trim()
            val message = capturedErrorMessage ?: if (fallback.isNotEmpty()) fallback else "Request failed ($code)"
            throw RuntimeException(message)
        }
    }

    private fun replaceText(node: AccessibilityNodeInfo, newText: String) {
        try {
            val args = Bundle().apply {
                putCharSequence(AccessibilityNodeInfo.ACTION_ARGUMENT_SET_TEXT_CHARSEQUENCE, newText)
            }
            node.performAction(AccessibilityNodeInfo.ACTION_SET_TEXT, args)
        } catch (e: Exception) {
            Log.e(TAG, "Error replacing text", e)
        }
    }

    override fun onInterrupt() {}

    override fun onDestroy() {
        super.onDestroy()
        Log.d(TAG, "FlowAccessibilityService onDestroy")
        serviceScope.cancel()
        instance = null
        removeAIBubble()
    }
} 