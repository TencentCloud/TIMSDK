package com.tencent.liteav.trtccalling.ui.videocall.videolayout;

import android.content.Context;
import android.util.AttributeSet;
import android.view.LayoutInflater;
import android.widget.ImageView;
import android.widget.ProgressBar;
import android.widget.RelativeLayout;
import android.widget.TextView;

import com.tencent.liteav.trtccalling.R;
import com.tencent.liteav.trtccalling.model.util.ImageLoader;
import com.tencent.liteav.trtccalling.ui.common.RoundCornerImageView;
import com.tencent.rtmp.ui.TXCloudVideoView;

/**
 * Module: TRTCGroupVideoLayout
 * 视频通话界面中，显示多个用户的自定义布局
 * 此 TRTCGroupVideoLayout 封装了{@link TXCloudVideoView} 以及业务逻辑 UI 控件
 */
public class TRTCGroupVideoLayout extends RelativeLayout {
    private static final int MIN_AUDIO_VOLUME = 10;

    private TXCloudVideoView     mTCCloudViewTRTC;
    private ProgressBar          mProgressAudio;
    private RoundCornerImageView mImageHead;
    private TextView             mTextUserName;
    private ImageView            mImageAudioInput;
    private ImageView            mImgLoading;

    private boolean mMuteAudio = false; // 静音状态 true : 开启静音

    public TRTCGroupVideoLayout(Context context) {
        this(context, null);
    }

    public TRTCGroupVideoLayout(Context context, AttributeSet attrs) {
        super(context, attrs);
        initView();
        setClickable(true);
    }

    public TXCloudVideoView getVideoView() {
        return mTCCloudViewTRTC;
    }

    public RoundCornerImageView getHeadImg() {
        return mImageHead;
    }

    public void setVideoAvailable(boolean available) {
        if (available) {
            mTCCloudViewTRTC.setVisibility(VISIBLE);
            mImageHead.setVisibility(GONE);
            mTextUserName.setVisibility(VISIBLE);
        } else {
            mTCCloudViewTRTC.setVisibility(GONE);
            mImageHead.setVisibility(VISIBLE);
            mTextUserName.setVisibility(VISIBLE);
        }
    }

    public void setRemoteIconAvailable(boolean available) {
        mImageHead.setVisibility(available ? VISIBLE : GONE);
        mTextUserName.setVisibility(available ? VISIBLE : GONE);
    }

    public void setAudioVolumeProgress(int progress) {
        if (mProgressAudio != null) {
            mProgressAudio.setProgress(progress);
        }
    }

    public void setAudioVolumeProgressBarVisibility(int visibility) {
        if (mProgressAudio != null) {
            mProgressAudio.setVisibility(visibility);
        }
    }

    private void initView() {
        LayoutInflater.from(getContext()).inflate(R.layout.trtccalling_group_videocall_item_user_layout, this, true);
        mTCCloudViewTRTC = findViewById(R.id.trtc_cloud_view);
        mProgressAudio = findViewById(R.id.progress_bar_audio);
        mImageHead = findViewById(R.id.img_head);
        mTextUserName = findViewById(R.id.tv_name);
        mImageAudioInput = findViewById(R.id.iv_audio_input);
        mImgLoading = (ImageView) findViewById(R.id.img_loading);
        ImageLoader.loadGifImage(getContext(), mImgLoading, R.drawable.trtccalling_loading);
    }

    public void setUserName(String userName) {
        mTextUserName.setText(userName);
    }

    public void setAudioVolume(int vol) {
        if (mMuteAudio) {
            return;
        }
        mImageAudioInput.setVisibility(vol > MIN_AUDIO_VOLUME ? VISIBLE : GONE);
    }

    public void muteMic(boolean mute) {
        mMuteAudio = mute;
        mImageAudioInput.setVisibility(mMuteAudio ? GONE : VISIBLE);
    }

    public void startLoading() {
        mImgLoading.setVisibility(VISIBLE);
    }

    public void stopLoading() {
        mImgLoading.setVisibility(GONE);
    }
}