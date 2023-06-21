package com.tencent.qcloud.tuikit.timcommon.component;

import android.content.Context;
import android.content.res.TypedArray;
import android.util.AttributeSet;
import android.util.Log;

import androidx.annotation.NonNull;
import androidx.annotation.Nullable;
import androidx.appcompat.widget.SwitchCompat;

import com.tencent.qcloud.tuikit.timcommon.R;

import java.lang.reflect.Field;

public class SwitchCustomWidth extends SwitchCompat {
    private static final String TAG = "SwitchCustomWidth";

    private int customSwitchWidth;

    public SwitchCustomWidth(@NonNull Context context) {
        super(context);
        initCustomAttr(context, null);
    }

    public SwitchCustomWidth(@NonNull Context context, @Nullable AttributeSet attrs) {
        super(context, attrs);
        initCustomAttr(context, attrs);
    }

    public SwitchCustomWidth(@NonNull Context context, @Nullable AttributeSet attrs, int defStyleAttr) {
        super(context, attrs, defStyleAttr);
        initCustomAttr(context, attrs);
    }

    public void initCustomAttr(Context context, AttributeSet attributeSet) {
        if (attributeSet != null) {
            TypedArray array = context.obtainStyledAttributes(attributeSet, R.styleable.SwitchCustomWidth);
            customSwitchWidth = array.getDimensionPixelSize(R.styleable.SwitchCustomWidth_custom_width, 0);
            array.recycle();
        }
    }

    @Override
    public void onMeasure(int widthMeasureSpec, int heightMeasureSpec) {
        super.onMeasure(widthMeasureSpec, heightMeasureSpec);
        try {
            if (customSwitchWidth == 0) {
                return;
            }
            Class<SwitchCompat> clazz = SwitchCompat.class;
            Field mSwitchWidthFiled = clazz.getDeclaredField("mSwitchWidth");
            mSwitchWidthFiled.setAccessible(true);
            mSwitchWidthFiled.set(this, customSwitchWidth);
        } catch (Exception e) {
            Log.w(TAG, e.getMessage());
        }
    }
}
