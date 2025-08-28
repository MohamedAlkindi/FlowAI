package com.example.flow_ai

import android.content.Context
import android.util.AttributeSet
import android.view.View
import android.widget.ScrollView

class MaxHeightScrollView @JvmOverloads constructor(
    context: Context,
    attrs: AttributeSet? = null,
    defStyleAttr: Int = 0
) : ScrollView(context, attrs, defStyleAttr) {

    private var maximumHeightPx: Int = 0

    init {
        if (attrs != null) {
            val ta = context.obtainStyledAttributes(attrs, R.styleable.MaxHeightScrollView)
            try {
                maximumHeightPx = ta.getDimensionPixelSize(R.styleable.MaxHeightScrollView_maxHeight, 0)
            } finally {
                ta.recycle()
            }
        }
        // Ensure this view is at least focusable for accessibility if needed
        isFocusable = false
        isFocusableInTouchMode = false
    }

    override fun onMeasure(widthMeasureSpec: Int, heightMeasureSpec: Int) {
        val cappedHeightSpec = if (maximumHeightPx > 0) {
            MeasureSpec.makeMeasureSpec(maximumHeightPx, MeasureSpec.AT_MOST)
        } else {
            heightMeasureSpec
        }
        super.onMeasure(widthMeasureSpec, cappedHeightSpec)
    }
}


