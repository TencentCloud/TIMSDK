package com.tencent.cloud.tuikit.roomkit.view.main.usercontrolpanel.userlistitem;

import android.content.Context;
import android.util.AttributeSet;

import androidx.annotation.NonNull;
import androidx.annotation.Nullable;
import androidx.appcompat.widget.AppCompatImageButton;

import com.trtc.tuikit.common.livedata.Observer;

public class CameraIconView extends AppCompatImageButton {
    private final CameraIconStateHolder       mStateHolder = new CameraIconStateHolder();
    private final Observer<CameraIconUiState> mObserver    = this::updateView;

    public CameraIconView(@NonNull Context context) {
        this(context, null);
    }

    public CameraIconView(@NonNull Context context, @Nullable AttributeSet attrs) {
        this(context, attrs, 0);
    }

    public CameraIconView(@NonNull Context context, @Nullable AttributeSet attrs, int defStyleAttr) {
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

    private void updateView(CameraIconUiState cameraIconUiState) {
        setSelected(cameraIconUiState.hasCameraStream);
        setVisibility(cameraIconUiState.isShow ? VISIBLE : INVISIBLE);
    }
}
