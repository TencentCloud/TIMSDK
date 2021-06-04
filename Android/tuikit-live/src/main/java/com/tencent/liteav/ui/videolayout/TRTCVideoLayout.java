package com.tencent.liteav.ui.videolayout;

import android.content.Context;
import android.util.AttributeSet;
import android.view.LayoutInflater;
import android.widget.FrameLayout;
import android.widget.ProgressBar;
import android.widget.RelativeLayout;
import android.widget.TextView;

import com.tencent.qcloud.tim.tuikit.live.R;
import com.tencent.rtmp.ui.TXCloudVideoView;

/**
 * Module: TRTCVideoLayout
 * <p>
 * Function:
 * <p>
 * 此 TRTCVideoLayout 封装了{@link TXCloudVideoView} 以及业务逻辑 UI 控件
 */
public class TRTCVideoLayout extends RelativeLayout {
    private boolean          mMoveable;
    private TXCloudVideoView mTcCloudViewTrtc;
    private SquareImageView  mHeadImg;
    private TextView         mUserNameTv;
    private FrameLayout      mFlNoVideo;
    private ProgressBar      mAudioPb;


    public TRTCVideoLayout(Context context) {
        this(context, null);
    }

    public TRTCVideoLayout(Context context, AttributeSet attrs) {
        super(context, attrs);
        initView();
        setClickable(true);
    }

    public TXCloudVideoView getVideoView() {
        return mTcCloudViewTrtc;
    }

    public SquareImageView getHeadImg() {
        return mHeadImg;
    }

    public TextView getUserNameTv() {
        return mUserNameTv;
    }

    public void setVideoAvailable(boolean available) {
        if (available) {
            mTcCloudViewTrtc.setVisibility(VISIBLE);
            mFlNoVideo.setVisibility(GONE);
        } else {
            mTcCloudViewTrtc.setVisibility(GONE);
            mFlNoVideo.setVisibility(VISIBLE);
        }
    }

    public void setAudioVolumeProgress(int progress) {
        if (mAudioPb != null) {
            mAudioPb.setProgress(progress);
        }
    }

    public void setAudioVolumeProgressBarVisibility(int visibility) {
        if (mAudioPb != null) {
            mAudioPb.setVisibility(visibility);
        }
    }

    private void initView() {
        LayoutInflater.from(getContext()).inflate(R.layout.videocall_item_user_user_layout, this, true);
        mTcCloudViewTrtc = (TXCloudVideoView) findViewById(R.id.trtc_tc_cloud_view);
        mHeadImg = (SquareImageView) findViewById(R.id.img_avatar);
        mUserNameTv = (TextView) findViewById(R.id.tv_user_name);
        mFlNoVideo = (FrameLayout) findViewById(R.id.fl_no_video);
        mAudioPb = (ProgressBar) findViewById(R.id.pb_audio);
    }

    public boolean isMoveable() {
        return mMoveable;
    }

    public void setMoveable(boolean enable) {
        mMoveable = enable;
    }
}
