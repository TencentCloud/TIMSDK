package com.tencent.qcloud.tim.uikit.component.video;

import android.app.Activity;
import android.content.res.Configuration;
import android.graphics.Bitmap;
import android.media.MediaPlayer;
import android.net.Uri;
import android.os.Bundle;
import android.view.View;
import android.view.ViewGroup;
import android.view.Window;
import android.view.WindowManager;
import android.widget.VideoView;

import com.tencent.qcloud.tim.uikit.R;
import com.tencent.qcloud.tim.uikit.utils.ImageUtil;
import com.tencent.qcloud.tim.uikit.utils.ScreenUtil;
import com.tencent.qcloud.tim.uikit.utils.TUIKitConstants;
import com.tencent.qcloud.tim.uikit.utils.TUIKitLog;

public class VideoViewActivity extends Activity {

    private static final String TAG = VideoViewActivity.class.getSimpleName();

    private VideoView mVideoView;
    private boolean mIsPause;
    private int videoWidth = 0;
    private int videoHeight = 0;

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        TUIKitLog.i(TAG, "onCreate start");
        super.onCreate(savedInstanceState);
        //去除标题栏
        requestWindowFeature(Window.FEATURE_NO_TITLE);
        //去除状态栏
        getWindow().setFlags(WindowManager.LayoutParams.FLAG_FULLSCREEN, WindowManager.LayoutParams.FLAG_FULLSCREEN);
        setContentView(R.layout.activity_video_view);
        mVideoView = findViewById(R.id.video_play_view);

        String imagePath = getIntent().getStringExtra(TUIKitConstants.CAMERA_IMAGE_PATH);
        Uri videoUri = getIntent().getParcelableExtra(TUIKitConstants.CAMERA_VIDEO_PATH);
        Bitmap firstFrame = ImageUtil.getBitmapFormPath(imagePath);
        if (firstFrame != null) {
            videoWidth = firstFrame.getWidth();
            videoHeight = firstFrame.getHeight();
            updateVideoView();
        }

        mVideoView.setOnCompletionListener(new MediaPlayer.OnCompletionListener() {
            @Override
            public void onCompletion(MediaPlayer mp) {

            }
        });
        mVideoView.setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View v) {
                if (mIsPause) {
                    mVideoView.resume();
                    mIsPause = false;
                } else if (mVideoView.isPlaying()) {
                    mVideoView.pause();
                    mIsPause = true;
                } else {
                    mIsPause = false;
                    mVideoView.start();
                }
            }
        });
        mVideoView.setVideoURI(videoUri);
        mVideoView.setOnPreparedListener(new MediaPlayer.OnPreparedListener() {
            @Override
            public void onPrepared(MediaPlayer mediaPlayer) {
                mVideoView.start();
            }
        });

        findViewById(R.id.video_view_back).setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View v) {
                finish();
            }
        });
        TUIKitLog.i(TAG, "onCreate end");
    }


    @Override
    public void onConfigurationChanged(Configuration newConfig) {
        TUIKitLog.i(TAG, "onConfigurationChanged start");
        super.onConfigurationChanged(newConfig);
        updateVideoView();
        TUIKitLog.i(TAG, "onConfigurationChanged end");
    }

    private void updateVideoView() {
        if (videoWidth <= 0 && videoHeight <= 0) {
            return;
        }
        boolean isLandscape = true;
        if (getResources().getConfiguration().orientation == Configuration.ORIENTATION_PORTRAIT) {
            isLandscape = false;
        }

        int deviceWidth;
        int deviceHeight;
        if (isLandscape) {
            deviceWidth = Math.max(ScreenUtil.getScreenWidth(this), ScreenUtil.getScreenHeight(this));
            deviceHeight = Math.min(ScreenUtil.getScreenWidth(this), ScreenUtil.getScreenHeight(this));
        } else {
            deviceWidth = Math.min(ScreenUtil.getScreenWidth(this), ScreenUtil.getScreenHeight(this));
            deviceHeight = Math.max(ScreenUtil.getScreenWidth(this), ScreenUtil.getScreenHeight(this));
        }
        float deviceRate = (float) deviceWidth / (float) deviceHeight;

        float rate = (float) videoWidth / (float) videoHeight;
        int width = 0;
        int height = 0;
        if (rate < deviceRate) {
            height = deviceHeight;
            width = (int) (deviceHeight * rate);
        } else {
            width = deviceWidth;
            height = (int) (deviceWidth / rate);
        }
        TUIKitLog.i(TAG, "scaled width: " + width + "  height: " + height);

        ViewGroup.LayoutParams params = mVideoView.getLayoutParams();
        params.width = width;
        params.height = height;
        mVideoView.setLayoutParams(params);
    }
}
