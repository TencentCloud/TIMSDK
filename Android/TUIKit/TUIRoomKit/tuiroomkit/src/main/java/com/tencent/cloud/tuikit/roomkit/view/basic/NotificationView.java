package com.tencent.cloud.tuikit.roomkit.view.basic;

import static com.tencent.cloud.tuikit.roomkit.manager.constant.ConferenceConstant.DURATION_FOREVER;

import android.content.Context;
import android.content.res.TypedArray;
import android.util.AttributeSet;
import android.view.View;
import android.widget.Button;
import android.widget.FrameLayout;
import android.widget.TextView;

import com.tencent.cloud.tuikit.roomkit.R;

public class NotificationView extends FrameLayout {
    protected Context mContext;

    private TextView mTvMessage;
    private Button   mBtnConfirm;

    private int mDurationMS;

    private final Runnable mDismissRun = new Runnable() {
        @Override
        public void run() {
            setVisibility(GONE);
        }
    };

    public NotificationView(Context context) {
        this(context, null);
    }

    public NotificationView(Context context, AttributeSet attrs) {
        this(context, attrs, 0);
    }

    public NotificationView(Context context, AttributeSet attrs, int defStyleAttr) {
        super(context, attrs, defStyleAttr);
        TypedArray typedArray = context.obtainStyledAttributes(attrs, R.styleable.NotificationView);
        mDurationMS = typedArray.getInt(R.styleable.NotificationView_durationMS, DURATION_FOREVER);
        typedArray.recycle();

        mContext = context;
        setVisibility(GONE);
        View roomView = inflate(mContext, R.layout.tuiroomkit_layout_notification, this);
        mTvMessage = roomView.findViewById(R.id.tuiroomkit_notification_message);
        mBtnConfirm = roomView.findViewById(R.id.tuiroomkit_notification_confirm);
    }

    public NotificationView setMessage(String message) {
        mTvMessage.setText(message);
        return this;
    }

    public NotificationView setDuration(int duration) {
        mDurationMS = duration;
        return this;
    }

    public int getDuration() {
        return mDurationMS;
    }

    public NotificationView setClickListener(OnClickListener clickListener) {
        mBtnConfirm.setOnClickListener(clickListener);
        return this;
    }

    public void show() {
        setVisibility(VISIBLE);
        removeCallbacks(mDismissRun);
        if (mDurationMS == DURATION_FOREVER) {
            return;
        }
        postDelayed(mDismissRun, mDurationMS);
    }

    public void dismiss() {
        setVisibility(GONE);
        removeCallbacks(mDismissRun);
    }

    @Override
    protected void onDetachedFromWindow() {
        super.onDetachedFromWindow();
        removeCallbacks(mDismissRun);
    }
}
