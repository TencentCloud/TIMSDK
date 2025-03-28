package com.tencent.cloud.tuikit.roomkit.view.main.localaudioindicator;

import android.content.Context;
import android.view.View;
import android.widget.FrameLayout;

import androidx.constraintlayout.utils.widget.ImageFilterButton;

import com.tencent.cloud.tuikit.roomkit.R;
import com.tencent.cloud.tuikit.roomkit.view.main.videoseat.ui.view.UserVolumePromptView;

public class LocalAudioToggleView extends FrameLayout implements LocalAudioToggleViewResponder {
    private Context              mContext;
    private ImageFilterButton    mBtnAudioToggle;
    private UserVolumePromptView mVolumePromptView;

    private boolean mIsLocalAudioEnabled = false;

    private LocalAudioToggleViewAction mViewAction;

    @Override
    public void onLocalAudioEnabled() {
        mVolumePromptView.enableVolumeEffect(true);
        mIsLocalAudioEnabled = true;
    }

    @Override
    public void onLocalAudioDisabled() {
        mVolumePromptView.enableVolumeEffect(false);
        mIsLocalAudioEnabled = false;
    }

    @Override
    public void onLocalAudioVolumedChanged(int volume) {
        mVolumePromptView.updateVolumeEffect(volume);
    }

    @Override
    public void onLocalAudioVisibilityChanged(boolean visible) {
        setVisibility(visible ? VISIBLE : INVISIBLE);
    }

    public LocalAudioToggleView(Context context) {
        super(context);
        mContext = context;
        initView();
    }

    @Override
    protected void onAttachedToWindow() {
        super.onAttachedToWindow();

        mViewAction = new LocalAudioToggleViewModel(this);
    }

    @Override
    protected void onDetachedFromWindow() {
        super.onDetachedFromWindow();

        mViewAction.destroy();
        mViewAction = null;
    }

    private void initView() {
        inflate(mContext, R.layout.tuiroomkit_view_local_audio, this);
        mBtnAudioToggle = findViewById(R.id.tuiroomkit_btn_local_audio_toggle);
        mVolumePromptView = findViewById(R.id.tuiroomkit_user_volume_prompt);

        mBtnAudioToggle.setOnClickListener(new OnClickListener() {
            @Override
            public void onClick(View v) {
                if (mIsLocalAudioEnabled) {
                    mViewAction.disableLocalAudio();
                } else {
                    mViewAction.enableLocalAudio();
                }
            }
        });
    }
}
