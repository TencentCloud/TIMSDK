package com.tencent.cloud.tuikit.roomkit.view.page.widget.UserControlPanel;

import android.content.Context;
import android.util.AttributeSet;

import androidx.annotation.NonNull;
import androidx.annotation.Nullable;
import androidx.appcompat.widget.AppCompatImageButton;

import com.trtc.tuikit.common.livedata.Observer;

public class MicIconView extends AppCompatImageButton {
    private MicIconStateHolder       mStateHolder = new MicIconStateHolder();
    private Observer<MicIconUiState> mObserver    = new Observer<MicIconUiState>() {
        @Override
        public void onChanged(MicIconUiState micIconUiState) {
            updateView(micIconUiState);
        }
    };

    public MicIconView(@NonNull Context context) {
        this(context, null);
    }

    public MicIconView(@NonNull Context context, @Nullable AttributeSet attrs) {
        this(context, attrs, 0);
    }

    public MicIconView(@NonNull Context context, @Nullable AttributeSet attrs, int defStyleAttr) {
        super(context, attrs, defStyleAttr);
    }

    public void setUserId(String userId) {
        mStateHolder.setUserId(userId);
    }

    @Override
    protected void onAttachedToWindow() {
        super.onAttachedToWindow();
        mStateHolder.observe(mObserver);
    }

    @Override
    protected void onDetachedFromWindow() {
        super.onDetachedFromWindow();
        mStateHolder.removeObserver(mObserver);
    }

    private void updateView(MicIconUiState micIconUiState) {
        setSelected(micIconUiState.hasAudioStream);
        setVisibility(micIconUiState.isShow ? VISIBLE : INVISIBLE);
    }
}
