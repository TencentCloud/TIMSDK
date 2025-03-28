package com.tencent.cloud.tuikit.roomkit.view.main.bottomnavigationbar;

import android.content.Context;
import android.util.AttributeSet;
import android.view.View;
import android.widget.FrameLayout;
import android.widget.TextView;

import androidx.annotation.NonNull;
import androidx.annotation.Nullable;

import com.tencent.cloud.tuikit.roomkit.R;
import com.trtc.tuikit.common.livedata.Observer;

public class SeatRequestCountView extends FrameLayout {
    private Context  mContext;
    private TextView mTvCount;

    private SeatRequestCountStateHolder       mStateHolder;
    private Observer<SeatRequestCountUiState> mObserver = new Observer<SeatRequestCountUiState>() {
        @Override
        public void onChanged(SeatRequestCountUiState seatRequestCountUiState) {
            setVisibility(seatRequestCountUiState.isShow ? VISIBLE : INVISIBLE);
            if (!seatRequestCountUiState.isShow) {
                return;
            }
            mTvCount.setText(seatRequestCountUiState.message);
        }
    };

    public SeatRequestCountView(@NonNull Context context) {
        this(context, null);
    }

    public SeatRequestCountView(@NonNull Context context, @Nullable AttributeSet attrs) {
        this(context, attrs, 0);
    }

    public SeatRequestCountView(@NonNull Context context, @Nullable AttributeSet attrs, int defStyleAttr) {
        super(context, attrs, defStyleAttr);
        mContext = context;
        initView();
    }

    @Override
    protected void onAttachedToWindow() {
        super.onAttachedToWindow();
        mStateHolder = new SeatRequestCountStateHolder();
        mStateHolder.observe(mObserver);
    }

    @Override
    protected void onDetachedFromWindow() {
        super.onDetachedFromWindow();
        mStateHolder.removeObserver(mObserver);
    }

    private void initView() {
        View parent = inflate(mContext, R.layout.tuiroomkit_view_text_dot, this);
        mTvCount = parent.findViewById(R.id.tuiroomkit_tv_red_dot);
        setVisibility(INVISIBLE);
    }
}
