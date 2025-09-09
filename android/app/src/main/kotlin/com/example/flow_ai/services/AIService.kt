package com.example.flow_ai.services

import android.content.Context
import android.provider.Settings
import android.util.Log
import com.example.flow_ai.BuildConfig
import com.example.flow_ai.constants.ServiceConstants
import kotlinx.coroutines.Dispatchers
import kotlinx.coroutines.withContext
import com.example.flow_ai.utils.DashboardStorage
import org.json.JSONObject
import java.io.BufferedReader
import java.io.OutputStreamWriter
import java.net.HttpURLConnection
import java.net.URL

class AIService(private val context: Context) {
    
    suspend fun invokeSupabaseFunction(prompt: String, onDelta: suspend (String) -> Unit) = 
        withContext(Dispatchers.IO) {
            val supabaseUrl = BuildConfig.SUPABASE_URL
            val anonKey = BuildConfig.SUPABASE_ANON_KEY
            
            // Connectivity pre-check
            checkConnectivity(supabaseUrl)
            
            val url = URL("$supabaseUrl/functions/v1/gemini")
            val connection = createConnection(url, anonKey)
            
            val deviceId = Settings.Secure.getString(context.contentResolver, Settings.Secure.ANDROID_ID) ?: "unknown_device"
            val body = createRequestBody(prompt, deviceId)
            
            sendRequest(connection, body)
            processResponse(connection, onDelta)
        }
    
    private fun checkConnectivity(supabaseUrl: String) {
        try {
            val pingUrl = URL(supabaseUrl)
            val pingConn = (pingUrl.openConnection() as HttpURLConnection).apply {
                requestMethod = "HEAD"
                connectTimeout = ServiceConstants.CONNECTIVITY_TIMEOUT
                readTimeout = ServiceConstants.CONNECTIVITY_TIMEOUT
            }
            pingConn.connect()
        } catch (e: Exception) {
            throw RuntimeException(ServiceConstants.ERROR_NO_INTERNET)
        }
    }
    
    private fun createConnection(url: URL, anonKey: String): HttpURLConnection {
        return (url.openConnection() as HttpURLConnection).apply {
            requestMethod = "POST"
            setRequestProperty("Content-Type", "application/json")
            setRequestProperty("Authorization", "Bearer $anonKey")
            setRequestProperty("apikey", anonKey)
            setRequestProperty("Accept", "*/*")
            setRequestProperty("Connection", "keep-alive")
            doOutput = true
            connectTimeout = ServiceConstants.CONNECTION_TIMEOUT
            readTimeout = ServiceConstants.READ_TIMEOUT
            setChunkedStreamingMode(0)
        }
    }
    
    private fun createRequestBody(prompt: String, deviceId: String): String {
        return JSONObject().apply {
            put("prompt", prompt)
            put("deviceId", deviceId)
            put("stream", true)
        }.toString()
    }
    
    private fun sendRequest(connection: HttpURLConnection, body: String) {
        OutputStreamWriter(connection.outputStream).use { it.write(body) }
    }
    
    private suspend fun processResponse(connection: HttpURLConnection, onDelta: suspend (String) -> Unit) {
        val code = connection.responseCode
        val stream = if (code in 200..299) connection.inputStream else connection.errorStream
        val reader = BufferedReader(stream.reader())
        
        val accumulated = StringBuilder()
        var capturedErrorMessage: String? = null
        var usageSaved = false
        
        reader.use { r ->
            var line: String?
            while (r.readLine().also { line = it } != null) {
                val ln = line!!
                var foundErrorThisLine = false
                
                try {
                    val json = JSONObject(ln)
                    Log.d(ServiceConstants.TAG, "Received JSON line: $ln")
                    when {
                        json.has("delta") -> {
                            val piece = json.optString("delta", "")
                            if (piece.isNotEmpty()) {
                                accumulated.append(piece)
                                onDelta(accumulated.toString())
                            }
                        }
                        json.has("text") -> {
                            val finalText = json.optString("text", "")
                            accumulated.clear().append(finalText)
                            onDelta(accumulated.toString())
                            
                            // Check if this response also contains usage data
                            if (json.has("usage")) {
                                val usage = json.optJSONObject("usage")
                                if (usage != null) {
                                    Log.d(ServiceConstants.TAG, "Saving usage data: $usage")
                                    DashboardStorage.saveUsage(context, usage)
                                    usageSaved = true
                                } else {
                                    Log.w(ServiceConstants.TAG, "Usage field exists but is null")
                                }
                            } else {
                                Log.d(ServiceConstants.TAG, "No usage field in response")
                            }
                        }
                        json.has("error") -> {
                            val codeErr = json.optString("error", "")
                            capturedErrorMessage = when {
                                code == 429 && codeErr == "daily_usage_limit_reached" -> ServiceConstants.ERROR_DAILY_LIMIT
                                code == 429 && codeErr == "per_minute_usage_limit_reached" -> ServiceConstants.ERROR_RATE_LIMIT
                                else -> json.optString("message", "${ServiceConstants.ERROR_REQUEST_FAILED} ($code)")
                            }
                            foundErrorThisLine = true
                        }
                        else -> {
                            // Not a recognized JSON shape, treat as plain text chunk with newline
                            accumulated.append(ln).append('\n')
                            onDelta(accumulated.toString())
                        }
                    }
                } catch (e: Exception) {
                    // Plain text line, preserve newline
                    accumulated.append(ln).append('\n')
                    onDelta(accumulated.toString())
                }
                if (foundErrorThisLine) break
            }
        }
        
        // Final check: if we haven't saved usage data yet, try to parse the accumulated response
        if (code in 200..299 && !usageSaved) {
            try {
                val finalResponse = accumulated.toString().trim()
                if (finalResponse.isNotEmpty()) {
                    // Try to find the last complete JSON object that contains usage data
                    val jsonObjects = finalResponse.split("}{")
                    for (i in jsonObjects.size - 1 downTo 0) {
                        try {
                            val jsonStr = if (i == 0) jsonObjects[i] else "{" + jsonObjects[i]
                            if (i < jsonObjects.size - 1) {
                                val jsonStr = jsonStr + "}"
                            }
                            val json = JSONObject(jsonStr)
                            if (json.has("usage")) {
                                val usage = json.optJSONObject("usage")
                                if (usage != null) {
                                    Log.d(ServiceConstants.TAG, "Saving usage data from final response: $usage")
                                    DashboardStorage.saveUsage(context, usage)
                                    break
                                }
                            }
                        } catch (e: Exception) {
                            // Continue to next JSON object
                            continue
                        }
                    }
                }
            } catch (e: Exception) {
                Log.d(ServiceConstants.TAG, "Could not parse final response for usage data: $e")
            }
        }
        
        if (code !in 200..299) {
            val fallback = accumulated.toString().trim()
            val message = capturedErrorMessage ?: if (fallback.isNotEmpty()) fallback else "${ServiceConstants.ERROR_REQUEST_FAILED} ($code)"
            throw RuntimeException(message)
        }
    }
}

