package com.tencent.qcloud.tuikit.tuicallkit.base;

import android.content.Context;
import android.util.AttributeSet;
import android.view.LayoutInflater;
import android.view.MotionEvent;
import android.widget.ImageView;
import android.widget.RelativeLayout;
import android.widget.TextView;

import com.tencent.qcloud.tuikit.TUIVideoView;
import com.tencent.qcloud.tuikit.tuicallkit.R;
import com.tencent.qcloud.tuikit.tuicallkit.utils.ImageLoader;

public class UserLayout extends RelativeLayout {
    private TUIVideoView mTUIVideoView;
    private ImageView    mImgUserAvatar;
    private TextView     mTextUserName;
    private ImageView    mImgAudioInput;
    private ImageView    mImgLoading;
    private boolean      mMoveAble;
    private boolean      mMuteAudio         = false;
    private boolean      mDisableAudioImage = false;

    public UserLayout(Context context) {
        this(context, null);
    }

    public UserLayout(Context context, AttributeSet attrs) {
        super(context, attrs);
        initView();
        setClickable(true);
    }

    private void initView() {
        LayoutInflater.from(getContext()).inflate(R.layout.tuicalling_group_user_layout, this, true);
        mTUIVideoView = findViewById(R.id.tx_cloud_view);
        mImgUserAvatar = findViewById(R.id.img_head);
        mTextUserName = findViewById(R.id.tv_name);
        mImgAudioInput = findViewById(R.id.iv_audio_input);
        mImgLoading = (ImageView) findViewById(R.id.img_loading);
        ImageLoader.loadGifImage(getContext(), mImgLoading, R.drawable.tuicalling_loading);
    }

    public TUIVideoView getVideoView() {
        return mTUIVideoView;
    }

    public void addVideoView(TUIVideoView view) {
        if (this.mTUIVideoView != null) {
            this.removeView(this.mTUIVideoView);
        }

        this.mTUIVideoView = view;
        this.addView(this.mTUIVideoView);
    }

    public ImageView getAvatarImage() {
        return mImgUserAvatar;
    }

    public void setVideoAvailable(boolean available) {
        if (available) {
            mTUIVideoView.setVisibility(VISIBLE);
            mImgUserAvatar.setVisibility(GONE);
            mTextUserName.setVisibility(VISIBLE);
        } else {
            mTUIVideoView.setVisibility(GONE);
            mImgUserAvatar.setVisibility(VISIBLE);
            mTextUserName.setVisibility(VISIBLE);
        }
    }

    public void setRemoteIconAvailable(boolean available) {
        mImgUserAvatar.setVisibility(available ? VISIBLE : GONE);
        mTextUserName.setVisibility(available ? VISIBLE : GONE);
    }

    public void setUserName(String userName) {
        mTextUserName.setText(userName);
    }

    public void setAudioVolume(int vol, boolean isAudioAvailable) {
        if (mMuteAudio || mDisableAudioImage) {
            return;
        }
        mImgAudioInput.setVisibility((isAudioAvailable && vol > Constants.MIN_AUDIO_VOLUME) ? VISIBLE : GONE);
    }

    public void muteMic(boolean mute) {
        mMuteAudio = mute;
        if (mDisableAudioImage) {
            return;
        }
        mImgAudioInput.setVisibility(mMuteAudio ? GONE : VISIBLE);
    }

    public void disableAudioImage(boolean enable) {
        mDisableAudioImage = enable;
    }

    public void startLoading() {
        mImgLoading.setVisibility(VISIBLE);
    }

    public void stopLoading() {
        mImgLoading.setVisibility(GONE);
    }

    public boolean isMoveAble() {
        return mMoveAble;
    }

    public void setMoveAble(boolean enable) {
        mMoveAble = enable;
    }

    @Override
    public boolean onInterceptTouchEvent(MotionEvent ev) {
        return true;
    }
}