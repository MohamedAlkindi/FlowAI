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

class FlowAccessibilityService : AccessibilityService() {
    
    companion object {
        private const val TAG = "FlowAI"
        // By default it's "/ai" .
        var aiTrigger : String = "/ai"
        // By default it's "/".
        var endTrigger : String = "/"
    }
    
    private val serviceScope = CoroutineScope(Dispatchers.IO + SupervisorJob())
    @Volatile private var isGenerating: Boolean = false
    
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

    private fun performGeneration(source: AccessibilityNodeInfo, fullText: String, startIndex: Int, endIndexInclusive: Int) {
        if (isGenerating) return
        if (startIndex < 0 || endIndexInclusive < startIndex || endIndexInclusive >= fullText.length) return

        val inner = fullText.substring(startIndex + aiTrigger.length, endIndexInclusive)
        val prompt = inner.trim()
        if (prompt.isEmpty()) return

        source.performAction(AccessibilityNodeInfo.ACTION_FOCUS)

        isGenerating = true
        val prefixText = fullText.substring(0, startIndex)
        val suffixText = if (endIndexInclusive + 1 <= fullText.length - 1) fullText.substring(endIndexInclusive + 1) else ""

        replaceText(source, prefixText + "…" + suffixText)

        serviceScope.launch {
            try {
                invokeSupabaseFunction(prompt) { delta ->
                    withContext(Dispatchers.Main) {
                        replaceText(source, prefixText + delta + suffixText)
                    }
                }
            } catch (e: Exception) {
                Log.e(TAG, "Edge function error", e)
                withContext(Dispatchers.Main) {
                    replaceText(source, prefixText + "Error: ${e.message}" + suffixText)
                }
            } finally {
                isGenerating = false
            }
        }
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
        serviceScope.cancel()
    }
} 