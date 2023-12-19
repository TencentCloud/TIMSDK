package com.tencent.cloud.tuikit.roomkit.view.page.widget.LocalAudioIndicator;

import android.content.Context;
import android.view.View;
import android.widget.FrameLayout;

import androidx.constraintlayout.utils.widget.ImageFilterButton;

import com.tencent.cloud.tuikit.roomkit.R;
import com.tencent.cloud.tuikit.roomkit.videoseat.ui.view.UserVolumePromptView;
import com.tencent.cloud.tuikit.roomkit.viewmodel.LocalAudioToggleViewModel;

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
