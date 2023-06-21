package com.tencent.cloud.tuikit.roomkit.imaccess.view;

import android.content.Context;
import android.view.LayoutInflater;
import android.view.MotionEvent;
import android.view.View;
import android.widget.Button;
import android.widget.FrameLayout;

import androidx.annotation.NonNull;

import com.tencent.cloud.tuikit.roomkit.R;

public class RoomFloatView extends FrameLayout {

    private Button mRoomFloatBtn;

    private View.OnTouchListener mTouchListener;

    public RoomFloatView(@NonNull Context context) {
        super(context);

        initView(context);
    }

    private void initView(Context context) {
        LayoutInflater.from(context).inflate(R.layout.tuiroomkit_room_float_layout, this);
        mRoomFloatBtn = findViewById(R.id.tuiroomkit_room_float_btn);
        mRoomFloatBtn.setOnClickListener(new OnClickListener() {
            @Override
            public void onClick(View v) {
                backToRoom();
            }
        });
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

    private void backToRoom() {

    }


}
