package com.tencent.qcloud.tuikit.timcommon.component;

import android.content.Context;
import android.content.res.TypedArray;
import android.util.AttributeSet;
import android.widget.LinearLayout;

import androidx.annotation.NonNull;
import androidx.annotation.Nullable;

import com.tencent.qcloud.tuikit.timcommon.R;

public class MaxWidthLinearLayout extends LinearLayout {
    int maxWidthPx;

    public MaxWidthLinearLayout(@NonNull Context context) {
        super(context);
    }

    public MaxWidthLinearLayout(@NonNull Context context, @Nullable AttributeSet attrs) {
        super(context, attrs);
        init(context, attrs);
    }

    public MaxWidthLinearLayout(@NonNull Context context, @Nullable AttributeSet attrs, int defStyleAttr) {
        super(context, attrs, defStyleAttr);
        init(context, attrs);
    }

    private void init(Context context, AttributeSet attributeSet) {
        TypedArray array = context.obtainStyledAttributes(attributeSet, R.styleable.max_width_style);
        maxWidthPx = array.getDimensionPixelSize(R.styleable.max_width_style_maxWidth, 0);
        array.recycle();
    }

    @Override
    protected void onMeasure(int widthMeasureSpec, int heightMeasureSpec) {
        int measuredWidth = MeasureSpec.getSize(widthMeasureSpec);
        if (maxWidthPx > 0 && maxWidthPx < measuredWidth) {
            widthMeasureSpec = MeasureSpec.makeMeasureSpec(maxWidthPx, MeasureSpec.AT_MOST);
        }
        super.onMeasure(widthMeasureSpec, heightMeasureSpec);
    }
}
