package com.tencent.qcloud.uikit.common.component.video;

import android.app.Activity;
import android.content.pm.ActivityInfo;
import android.graphics.Bitmap;
import android.media.MediaPlayer;
import android.net.Uri;
import android.os.Bundle;
import android.view.View;
import android.view.Window;
import android.view.WindowManager;
import android.widget.VideoView;

import com.tencent.qcloud.uikit.R;
import com.tencent.qcloud.uikit.common.UIKitConstants;
import com.tencent.qcloud.uikit.common.utils.ImageUtil;

public class VideoViewActivity extends Activity {
    private VideoView mVideoView;
    private boolean pause;

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        //去除标题栏
        requestWindowFeature(Window.FEATURE_NO_TITLE);
        //去除状态栏
        getWindow().setFlags(WindowManager.LayoutParams.FLAG_FULLSCREEN,
                WindowManager.LayoutParams.FLAG_FULLSCREEN);
        setContentView(R.layout.activity_video_view);
        String imagePath = getIntent().getStringExtra(UIKitConstants.CAMERA_IMAGE_PATH);
        Uri videoUri = getIntent().getParcelableExtra(UIKitConstants.CAMERA_VIDEO_PATH);
        Bitmap firstFrame = ImageUtil.getBitmapFormPath(imagePath);
        if (firstFrame != null) {
            if (firstFrame.getWidth() > firstFrame.getHeight()) {
                setRequestedOrientation(ActivityInfo.SCREEN_ORIENTATION_LANDSCAPE);
            }
        }

        mVideoView = findViewById(R.id.video_play_view);
        mVideoView.setOnCompletionListener(new MediaPlayer.OnCompletionListener() {
            @Override
            public void onCompletion(MediaPlayer mp) {

            }
        });
        mVideoView.setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View v) {
                if (pause) {
                    mVideoView.resume();
                    pause = false;
                } else if (mVideoView.isPlaying()) {
                    mVideoView.pause();
                    pause = true;
                } else {
                    pause = false;
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
    }

}
