package com.tencent.cloud.tuikit.roomkit.view.main.topnavigationbar;

import android.content.Context;
import android.util.AttributeSet;
import android.view.View;

import androidx.annotation.Nullable;

import com.tencent.cloud.tuikit.roomkit.R;
import com.tencent.cloud.tuikit.roomkit.manager.ConferenceController;
import com.trtc.tuikit.common.livedata.Observer;

public class AudioRouteSwitchView extends androidx.appcompat.widget.AppCompatImageView {

    private final Observer<Boolean> mObserver = this::updateView;

    public AudioRouteSwitchView(Context context) {
        this(context, null);
    }

    public AudioRouteSwitchView(Context context, @Nullable AttributeSet attrs) {
        super(context, attrs);
        initView();
    }

    @Override
    protected void onAttachedToWindow() {
        super.onAttachedToWindow();
        ConferenceController.sharedInstance().getMediaState().isSpeakerOpened.observe(mObserver);
    }

    @Override
    protected void onDetachedFromWindow() {
        super.onDetachedFromWindow();
        ConferenceController.sharedInstance().getMediaState().isSpeakerOpened.removeObserver(mObserver);
    }

    private void initView() {
        setOnClickListener(new OnClickListener() {
            @Override
            public void onClick(View v) {
                ConferenceController.sharedInstance().getMediaController().switchAudioRoute();
            }
        });
    }

    private void updateView(boolean isSpeakerOpened) {
        setImageResource(isSpeakerOpened ? R.drawable.tuiroomkit_icon_speaker :
                R.drawable.tuiroomkit_ic_headset);
    }
}
