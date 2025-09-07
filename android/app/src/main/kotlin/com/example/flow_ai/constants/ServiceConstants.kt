package com.example.flow_ai.constants

object ServiceConstants {
    const val TAG = "FlowAI"
    const val TRIGGER_COOLDOWN = 200L // ms
    const val CONNECTIVITY_TIMEOUT = 3000
    const val CONNECTION_TIMEOUT = 15000
    const val READ_TIMEOUT = 60000
    
    // Default trigger values
    const val DEFAULT_AI_TRIGGER = "/ai"
    const val DEFAULT_END_TRIGGER = "/"
    
    // Error messages
    const val ERROR_NO_INTERNET = "No internet connection"
    const val ERROR_DAILY_LIMIT = "Daily limit reached. Try again tomorrow."
    const val ERROR_RATE_LIMIT = "Too many requests. Please wait a moment."
    const val ERROR_REQUEST_FAILED = "Request failed"
}