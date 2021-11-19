package com.tencent.qcloud.tuikit.tuichat.component.video;

import android.app.Activity;
import android.content.res.Configuration;
import android.graphics.Bitmap;
import android.net.Uri;
import android.os.Bundle;
import android.view.View;
import android.view.ViewGroup;
import android.view.Window;
import android.view.WindowManager;

import com.tencent.qcloud.tuicore.util.ImageUtil;
import com.tencent.qcloud.tuicore.util.ScreenUtil;
import com.tencent.qcloud.tuikit.tuichat.R;
import com.tencent.qcloud.tuikit.tuichat.TUIChatConstants;
import com.tencent.qcloud.tuikit.tuichat.component.video.proxy.IPlayer;
import com.tencent.qcloud.tuikit.tuichat.util.TUIChatLog;

public class VideoViewActivity extends Activity {

    private static final String TAG = VideoViewActivity.class.getSimpleName();

    private UIKitVideoView mVideoView;
    private int videoWidth = 0;
    private int videoHeight = 0;

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        TUIChatLog.i(TAG, "onCreate start");
        super.onCreate(savedInstanceState);
        //去除标题栏
        requestWindowFeature(Window.FEATURE_NO_TITLE);
        //去除状态栏
        getWindow().setFlags(WindowManager.LayoutParams.FLAG_FULLSCREEN, WindowManager.LayoutParams.FLAG_FULLSCREEN);
        setContentView(R.layout.activity_video_view);
        mVideoView = findViewById(R.id.video_play_view);

        String imagePath = getIntent().getStringExtra(TUIChatConstants.CAMERA_IMAGE_PATH);
        Uri videoUri = getIntent().getParcelableExtra(TUIChatConstants.CAMERA_VIDEO_PATH);
        Bitmap firstFrame = ImageUtil.getBitmapFormPath(imagePath);
        if (firstFrame != null) {
            videoWidth = firstFrame.getWidth();
            videoHeight = firstFrame.getHeight();
            updateVideoView();
        }

        mVideoView.setVideoURI(videoUri);
        mVideoView.setOnPreparedListener(new IPlayer.OnPreparedListener() {
            @Override
            public void onPrepared(IPlayer mediaPlayer) {
                mVideoView.start();
            }
        });
        mVideoView.setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View v) {
                if (mVideoView.isPlaying()) {
                    mVideoView.pause();
                } else {
                    mVideoView.start();
                }
            }
        });

        findViewById(R.id.video_view_back).setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View v) {
                mVideoView.stop();
                finish();
            }
        });
        TUIChatLog.i(TAG, "onCreate end");
    }


    @Override
    public void onConfigurationChanged(Configuration newConfig) {
        TUIChatLog.i(TAG, "onConfigurationChanged start");
        super.onConfigurationChanged(newConfig);
        updateVideoView();
        TUIChatLog.i(TAG, "onConfigurationChanged end");
    }

    private void updateVideoView() {
        TUIChatLog.i(TAG, "updateVideoView videoWidth: " + videoWidth + " videoHeight: " + videoHeight);
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
        int[] scaledSize = ScreenUtil.scaledSize(deviceWidth, deviceHeight, videoWidth, videoHeight);
        TUIChatLog.i(TAG, "scaled width: " + scaledSize[0] + " height: " + scaledSize[1]);
        ViewGroup.LayoutParams params = mVideoView.getLayoutParams();
        params.width = scaledSize[0];
        params.height = scaledSize[1];
        mVideoView.setLayoutParams(params);
    }

    @Override
    protected void onStop() {
        TUIChatLog.i(TAG, "onStop");
        super.onStop();
        if (mVideoView != null) {
            mVideoView.pause();
        }
    }

    @Override
    protected void onDestroy() {
        super.onDestroy();
        TUIChatLog.i(TAG, "onStop");
        if (mVideoView != null) {
            mVideoView.stop();
        }
    }
}
