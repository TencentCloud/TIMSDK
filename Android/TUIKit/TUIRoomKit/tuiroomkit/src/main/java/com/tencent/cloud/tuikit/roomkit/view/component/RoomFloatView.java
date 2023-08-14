package com.tencent.cloud.tuikit.roomkit.view.component;

import android.content.Context;
import android.view.LayoutInflater;
import android.view.MotionEvent;
import android.view.View;
import android.widget.FrameLayout;

import androidx.annotation.NonNull;

import com.tencent.cloud.tuikit.roomkit.R;

public class RoomFloatView extends FrameLayout {
    private View.OnTouchListener mTouchListener;

    public RoomFloatView(@NonNull Context context) {
        super(context);

        LayoutInflater.from(context).inflate(R.layout.tuiroomkit_room_float_layout, this);
    }

    public void setTouchListener(OnTouchListener touchListener) {
        mTouchListener = touchListener;
    }

    @Override
    public boolean dispatchTouchEvent(MotionEvent event) {
        if (mTouchListener != null) {
            mTouchListener.onTouch(this, event);
        }
        return true;
    }
}
