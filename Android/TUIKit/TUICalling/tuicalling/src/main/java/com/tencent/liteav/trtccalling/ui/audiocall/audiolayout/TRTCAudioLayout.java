package com.tencent.liteav.trtccalling.ui.audiocall.audiolayout;

import android.content.Context;
import android.graphics.Bitmap;
import android.util.AttributeSet;
import android.widget.ImageView;
import android.widget.RelativeLayout;
import android.widget.TextView;

import com.tencent.liteav.trtccalling.R;
import com.tencent.liteav.trtccalling.ui.common.RoundCornerImageView;

/**
 * 通话界面中，显示单个用户头像的自定义布局
 */
public class TRTCAudioLayout extends RelativeLayout {
    private static final int MIN_AUDIO_VOLUME = 10;

    private RoundCornerImageView mImageHead;
    private TextView             mTextName;
    private ImageView            mImageAudioInput;
    private ImageView            mImgLoading;

    public TRTCAudioLayout(Context context) {
        this(context, null);
    }

    public TRTCAudioLayout(Context context, AttributeSet attrs) {
        super(context, attrs);
        inflate(context, R.layout.trtccalling_audiocall_item_user_layout, this);
        initView();
    }

    private void initView() {
        mImageHead = (RoundCornerImageView) findViewById(R.id.img_head);
        mTextName = (TextView) findViewById(R.id.tv_name);
        mImageAudioInput = (ImageView) findViewById(R.id.iv_audio_input);
        mImgLoading = (ImageView) findViewById(R.id.img_loading);
    }

    public void setAudioVolume(int vol) {
        if (vol > MIN_AUDIO_VOLUME) {
            mImageAudioInput.setVisibility(VISIBLE);
        } else {
            mImageAudioInput.setVisibility(GONE);
        }
    }

    public void setUserName(String userName) {
        mTextName.setText(userName);
    }

    public RoundCornerImageView getImageView() {
        return mImageHead;
    }

    public void startLoading() {
        mImgLoading.setVisibility(VISIBLE);
    }

    public void stopLoading() {
        mImgLoading.setVisibility(GONE);
    }
}
