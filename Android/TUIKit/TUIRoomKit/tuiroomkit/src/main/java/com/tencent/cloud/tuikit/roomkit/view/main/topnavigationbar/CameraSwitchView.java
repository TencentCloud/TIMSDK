package com.tencent.cloud.tuikit.roomkit.view.main.topnavigationbar;

import android.content.Context;
import android.util.AttributeSet;

import androidx.annotation.NonNull;
import androidx.annotation.Nullable;
import androidx.appcompat.widget.AppCompatImageView;

import com.tencent.cloud.tuikit.roomkit.manager.ConferenceController;
import com.trtc.tuikit.common.livedata.Observer;

public class CameraSwitchView extends AppCompatImageView {
    private final Observer<Boolean> mObserver = this::updateView;

    public CameraSwitchView(@NonNull Context context) {
        this(context, null);
    }

    public CameraSwitchView(@NonNull Context context, @Nullable AttributeSet attrs) {
        super(context, attrs);
        initView();
    }

    @Override
    protected void onAttachedToWindow() {
        super.onAttachedToWindow();
        ConferenceController.sharedInstance().getMediaState().isCameraOpened.observe(mObserver);
    }

    @Override
    protected void onDetachedFromWindow() {
        super.onDetachedFromWindow();
        ConferenceController.sharedInstance().getMediaState().isCameraOpened.removeObserver(mObserver);
    }

    private void initView() {
        setOnClickListener(v -> ConferenceController.sharedInstance().getMediaController().switchCamera());
    }

    private void updateView(boolean isCameraOpened) {
        setVisibility(isCameraOpened ? VISIBLE : INVISIBLE);
    }
}
