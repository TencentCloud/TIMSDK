package com.tencent.qcloud.tuikit.timcommon.component;

import android.content.Context;
import android.graphics.Color;
import android.graphics.drawable.Drawable;
import android.util.AttributeSet;

import androidx.annotation.Nullable;

import com.tencent.qcloud.tuikit.timcommon.R;

public class MinimalistTitleBar extends TitleBarLayout {
    public MinimalistTitleBar(Context context) {
        super(context);
        initView(context);
    }

    public MinimalistTitleBar(Context context, @Nullable AttributeSet attrs) {
        super(context, attrs);
        initView(context);
    }

    public MinimalistTitleBar(Context context, @Nullable AttributeSet attrs, int defStyleAttr) {
        super(context, attrs, defStyleAttr);
        initView(context);
    }

    private void initView(Context context) {
        setLeftReturnListener(context);
        setBackgroundColor(Color.WHITE);
        getLeftIcon().setBackgroundResource(R.drawable.core_minimalist_back_icon);
        Drawable leftIconDrawable = getLeftIcon().getBackground();
        if (leftIconDrawable != null) {
            leftIconDrawable.setAutoMirrored(true);
        }
        getLeftTitle().setTextColor(0xFF0365F9);
        getRightTitle().setTextColor(0xFF0365F9);
    }
}
