package com.example.flow_ai.utils

import android.content.Context
import android.util.Log
import org.json.JSONObject
import com.example.flow_ai.constants.ServiceConstants

object DashboardStorage {
    private const val PREFS_NAME = "flow_ai_dashboard"
    private const val KEY_USAGE_JSON = "usage_json"
    private const val KEY_HISTORY_JSON = "history_json" // stores array of {date, request_count}

    fun saveUsage(context: Context, usage: JSONObject) {
        val prefs = context.getSharedPreferences(PREFS_NAME, Context.MODE_PRIVATE)
        val jsonString = usage.toString()
        Log.d(ServiceConstants.TAG, "Saving usage JSON: $jsonString")
        prefs.edit().putString(KEY_USAGE_JSON, jsonString).apply()
        Log.d(ServiceConstants.TAG, "Usage saved successfully")

        // Update daily history using last_request_date and request_count
        try {
            val date = usage.optString("last_request_date", null)
            val count = usage.optInt("request_count", -1)
            if (!date.isNullOrEmpty() && count >= 0) {
                val updatedHistory = updateHistoryJson(getHistoryArray(prefs), date, count)
                prefs.edit().putString(KEY_HISTORY_JSON, updatedHistory.toString()).apply()
                Log.d(ServiceConstants.TAG, "History updated: $updatedHistory")
            } else {
                Log.d(ServiceConstants.TAG, "Skipping history update: missing date or count")
            }
        } catch (e: Exception) {
            Log.w(ServiceConstants.TAG, "Failed to update history: ${e.message}")
        }
    }

    fun getUsageJson(context: Context): String? {
        val prefs = context.getSharedPreferences(PREFS_NAME, Context.MODE_PRIVATE)
        val result = prefs.getString(KEY_USAGE_JSON, null)
        Log.d(ServiceConstants.TAG, "Retrieved usage JSON: $result")
        return result
    }

    fun getUsageHistoryJson(context: Context): String {
        val prefs = context.getSharedPreferences(PREFS_NAME, Context.MODE_PRIVATE)
        val arr = getHistoryArray(prefs)
        return arr.toString()
    }

    private fun getHistoryArray(prefs: android.content.SharedPreferences): org.json.JSONArray {
        val existing = prefs.getString(KEY_HISTORY_JSON, null)
        return try {
            if (existing.isNullOrEmpty()) org.json.JSONArray() else org.json.JSONArray(existing)
        } catch (_: Exception) {
            org.json.JSONArray()
        }
    }

    private fun updateHistoryJson(
        arr: org.json.JSONArray,
        date: String,
        count: Int
    ): org.json.JSONArray {
        // Update if date exists, else append; keep only last 21 entries
        var updated = false
        for (i in 0 until arr.length()) {
            val obj = arr.optJSONObject(i) ?: continue
            if (date == obj.optString("date")) {
                obj.put("request_count", count)
                updated = true
                break
            }
        }
        if (!updated) {
            val obj = org.json.JSONObject().apply {
                put("date", date)
                put("request_count", count)
            }
            arr.put(obj)
        }
        // Trim to last 21 entries
        while (arr.length() > 21) {
            // remove oldest (index 0)
            try {
                val newArr = org.json.JSONArray()
                for (i in 1 until arr.length()) newArr.put(arr.get(i))
                return newArr
            } catch (_: Exception) {
                break
            }
        }
        return arr
    }
}


