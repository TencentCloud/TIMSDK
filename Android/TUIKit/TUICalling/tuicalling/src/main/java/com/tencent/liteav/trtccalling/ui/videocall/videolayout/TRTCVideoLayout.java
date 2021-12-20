package com.tencent.liteav.trtccalling.ui.videocall.videolayout;

import android.content.Context;
import android.util.AttributeSet;
import android.view.LayoutInflater;
import android.widget.ProgressBar;
import android.widget.RelativeLayout;
import android.widget.TextView;

import com.tencent.liteav.trtccalling.R;
import com.tencent.liteav.trtccalling.ui.common.RoundCornerImageView;
import com.tencent.rtmp.ui.TXCloudVideoView;

/**
 * Module: TRTCVideoLayout
 * <p>
 * Function:
 * <p>
 * 此 TRTCVideoLayout 封装了{@link TXCloudVideoView} 以及业务逻辑 UI 控件
 */
public class TRTCVideoLayout extends RelativeLayout {
    private boolean              mMoveAble;
    private TXCloudVideoView     mTCCloudViewTRTC;
    private ProgressBar          mProgressAudio;
    private RoundCornerImageView mImageHead;
    private TextView             mTextUserName;


    public TRTCVideoLayout(Context context) {
        this(context, null);
    }

    public TRTCVideoLayout(Context context, AttributeSet attrs) {
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
        } else {
            mTCCloudViewTRTC.setVisibility(GONE);
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
        LayoutInflater.from(getContext()).inflate(R.layout.trtccalling_videocall_item_user_layout, this, true);
        mTCCloudViewTRTC = (TXCloudVideoView) findViewById(R.id.trtc_tc_cloud_view);
        mProgressAudio = (ProgressBar) findViewById(R.id.progress_bar_audio);
        mImageHead = (RoundCornerImageView) findViewById(R.id.iv_avatar);
        mTextUserName = (TextView) findViewById(R.id.tv_user_name);
    }

    public boolean isMoveAble() {
        return mMoveAble;
    }

    public void setMoveAble(boolean enable) {
        mMoveAble = enable;
    }

    public void setUserName(String userName) {
        mTextUserName.setText(userName);
    }

    public void setUserNameColor(int color) {
        mTextUserName.setTextColor(color);
    }
}
