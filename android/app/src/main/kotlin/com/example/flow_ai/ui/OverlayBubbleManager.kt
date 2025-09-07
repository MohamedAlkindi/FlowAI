package com.example.flow_ai.ui

import android.content.Context
import android.os.Build
import android.os.Handler
import android.os.Looper
import android.provider.Settings
import android.util.Log
import android.view.Gravity
import android.view.LayoutInflater
import android.view.MotionEvent
import android.view.View
import android.view.WindowManager
import android.view.inputmethod.InputMethodManager
import android.widget.Button
import android.widget.EditText
import android.widget.TextView
import com.example.flow_ai.R
import com.example.flow_ai.constants.ServiceConstants

class OverlayBubbleManager(private val context: Context) {
    
    private var aiBubbleView: View? = null
    private var aiBubbleParams: WindowManager.LayoutParams? = null
    private var windowManager: WindowManager? = null
    
    init {
        windowManager = context.getSystemService(Context.WINDOW_SERVICE) as WindowManager
    }
    
    fun removeAIBubble() {
        aiBubbleView?.let {
            windowManager?.removeView(it)
        }
        aiBubbleView = null
        aiBubbleParams = null
    }
    
    fun showDraggableAIBubble(
        prompt: String,
        aiText: String,
        onApply: (String) -> Unit,
        onCancel: () -> Unit,
        onRedo: (String) -> Unit
    ) {
        Log.d(ServiceConstants.TAG, "Showing AI bubble with prompt: '$prompt', AI text: '$aiText'")

        if (windowManager == null) {
            windowManager = context.getSystemService(Context.WINDOW_SERVICE) as WindowManager
        }

        if (!Settings.canDrawOverlays(context)) {
            Log.w(ServiceConstants.TAG, "No overlay permission, falling back to direct replacement")
            onApply(aiText)
            return
        }

        removeAIBubble()

        val inflater = LayoutInflater.from(context)
        val bubbleView = inflater.inflate(R.layout.ai_bubble_overlay, null)

        val promptEditText = bubbleView.findViewById<EditText>(R.id.promptEditText)
        val aiResultText = bubbleView.findViewById<TextView>(R.id.aiResultText)
        val aiResultScroll = bubbleView.findViewById<android.widget.ScrollView>(R.id.aiResultScrollView)
        val applyButton = bubbleView.findViewById<Button>(R.id.applyButton)
        val cancelButton = bubbleView.findViewById<Button>(R.id.cancelButton)
        val redoButton = bubbleView.findViewById<Button>(R.id.redoButton)

        promptEditText?.setText(prompt)
        aiResultText?.text = aiText
        aiResultScroll?.post { aiResultScroll.fullScroll(View.FOCUS_DOWN) }

        val params = createWindowParams()
        aiBubbleView = bubbleView
        aiBubbleParams = params

        try {
            windowManager?.addView(bubbleView, params)
            Log.d(ServiceConstants.TAG, "AI bubble added")
        } catch (e: Exception) {
            Log.e(ServiceConstants.TAG, "Failed to add AI bubble", e)
            onApply(aiText)
            return
        }

        setupFocusHandling(bubbleView, promptEditText)
        setupButtonActions(bubbleView, promptEditText, aiResultText, aiResultScroll, onApply, onCancel, onRedo)
        setupDragHandling(bubbleView, params)
    }
    
    private fun createWindowParams(): WindowManager.LayoutParams {
        return WindowManager.LayoutParams().apply {
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
            format = android.graphics.PixelFormat.TRANSLUCENT
            softInputMode = WindowManager.LayoutParams.SOFT_INPUT_ADJUST_RESIZE
        }
    }
    
    private fun setupFocusHandling(bubbleView: View, promptEditText: EditText?) {
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
                    Log.e(ServiceConstants.TAG, "Failed to update bubble focus flags", e)
                }
            }
        }
    }
    
    private fun setupButtonActions(
        bubbleView: View,
        promptEditText: EditText?,
        aiResultText: TextView?,
        aiResultScroll: android.widget.ScrollView?,
        onApply: (String) -> Unit,
        onCancel: () -> Unit,
        onRedo: (String) -> Unit
    ) {
        val applyButton = bubbleView.findViewById<Button>(R.id.applyButton)
        val cancelButton = bubbleView.findViewById<Button>(R.id.cancelButton)
        val redoButton = bubbleView.findViewById<Button>(R.id.redoButton)

        applyButton?.setOnClickListener {
            val finalText = aiResultText?.text?.toString() ?: ""
            onApply(finalText)
            resetFocus(promptEditText)
            removeAIBubble()
        }

        cancelButton?.setOnClickListener {
            onCancel()
            resetFocus(promptEditText)
            removeAIBubble()
        }

        redoButton?.setOnClickListener {
            val newPrompt = promptEditText?.text?.toString() ?: ""
            aiResultText?.text = "..." // show waiting indicator
            aiResultScroll?.post { aiResultScroll.fullScroll(View.FOCUS_DOWN) }

            onRedo(newPrompt)
            resetFocus(promptEditText)
        }
    }
    
    private fun setupDragHandling(bubbleView: View, params: WindowManager.LayoutParams) {
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
    
    private fun resetFocus(promptEditText: EditText?) {
        aiBubbleParams?.let { currentParams ->
            currentParams.flags = WindowManager.LayoutParams.FLAG_NOT_FOCUSABLE or
                                WindowManager.LayoutParams.FLAG_NOT_TOUCH_MODAL or
                                WindowManager.LayoutParams.FLAG_WATCH_OUTSIDE_TOUCH
            try {
                windowManager?.updateViewLayout(aiBubbleView, currentParams)
            } catch (e: Exception) {
                Log.e(ServiceConstants.TAG, "Failed to reset bubble focus", e)
            }
        }
        // also clear keyboard
        promptEditText?.clearFocus()
        val imm = context.getSystemService(Context.INPUT_METHOD_SERVICE) as InputMethodManager
        imm.hideSoftInputFromWindow(promptEditText?.windowToken, 0)
    }
    
    fun updateBubbleText(newText: String) {
        aiBubbleView?.let { bubbleView ->
            val aiResultText = bubbleView.findViewById<TextView>(R.id.aiResultText)
            val aiResultScroll = bubbleView.findViewById<android.widget.ScrollView>(R.id.aiResultScrollView)
            aiResultText?.text = newText
            aiResultScroll?.post { aiResultScroll.fullScroll(View.FOCUS_DOWN) }
        }
    }
}

