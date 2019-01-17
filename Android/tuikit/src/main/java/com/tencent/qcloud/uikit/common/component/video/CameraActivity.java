package com.tencent.qcloud.uikit.common.component.video;

import android.content.Intent;
import android.content.pm.ActivityInfo;
import android.graphics.Bitmap;
import android.os.Build;
import android.os.Bundle;
import android.support.v7.app.AppCompatActivity;
import android.util.Log;
import android.view.View;
import android.view.WindowManager;
import android.widget.Toast;

import com.tencent.qcloud.uikit.R;
import com.tencent.qcloud.uikit.common.IUIKitCallBack;
import com.tencent.qcloud.uikit.common.UIKitConstants;
import com.tencent.qcloud.uikit.common.component.video.listener.ClickListener;
import com.tencent.qcloud.uikit.common.component.video.listener.ErrorListener;
import com.tencent.qcloud.uikit.common.component.video.listener.JCameraListener;
import com.tencent.qcloud.uikit.common.component.video.util.DeviceUtil;
import com.tencent.qcloud.uikit.common.utils.FileUtil;

public class CameraActivity extends AppCompatActivity {
    private JCameraView jCameraView;
    public static IUIKitCallBack mCallBack;

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        getWindow().setFlags(WindowManager.LayoutParams.FLAG_FULLSCREEN, WindowManager.LayoutParams.FLAG_FULLSCREEN);
        setRequestedOrientation(ActivityInfo.SCREEN_ORIENTATION_PORTRAIT);
        setContentView(R.layout.activity_camera);
        jCameraView = (JCameraView) findViewById(R.id.jcameraview);
        //设置视频保存路径
        //jCameraView.setSaveVideoPath(Environment.getExternalStorageDirectory().getPath() + File.separator + "JCamera");

        int state = getIntent().getIntExtra(UIKitConstants.CAMERA_TYPE, JCameraView.BUTTON_STATE_BOTH);
        jCameraView.setFeatures(state);
        if (state == JCameraView.BUTTON_STATE_ONLY_CAPTURE)
            jCameraView.setTip("点击拍照");
        else if (state == JCameraView.BUTTON_STATE_ONLY_RECORDER)
            jCameraView.setTip("长按摄像");

        jCameraView.setMediaQuality(JCameraView.MEDIA_QUALITY_MIDDLE);
        jCameraView.setErrorLisenter(new ErrorListener() {
            @Override
            public void onError() {
                //错误监听
                Log.i("CJT", "camera error");
                Intent intent = new Intent();
                setResult(103, intent);
                finish();
            }

            @Override
            public void AudioPermissionError() {
                Toast.makeText(CameraActivity.this, "给点录音权限可以?", Toast.LENGTH_SHORT).show();
            }
        });
        //JCameraView监听
        jCameraView.setJCameraLisenter(new JCameraListener() {
            @Override
            public void captureSuccess(Bitmap bitmap) {
                //获取图片bitmap
                String path = FileUtil.saveBitmap("JCamera", bitmap);
               /* Intent intent = new Intent();
                intent.putExtra(ILiveConstants.CAMERA_IMAGE_PATH, path);
                setResult(-1, intent);*/
                if (mCallBack != null) {
                    mCallBack.onSuccess(path);
                }
                finish();
            }

            @Override
            public void recordSuccess(String url, Bitmap firstFrame, long duration) {
                //获取视频路径
                String path = FileUtil.saveBitmap("JCamera", firstFrame);
                Intent intent = new Intent();
                intent.putExtra(UIKitConstants.IMAGE_WIDTH, firstFrame.getWidth());
                intent.putExtra(UIKitConstants.IMAGE_HEIGHT, firstFrame.getHeight());
                intent.putExtra(UIKitConstants.VIDEO_TIME, duration);
                intent.putExtra(UIKitConstants.CAMERA_IMAGE_PATH, path);
                intent.putExtra(UIKitConstants.CAMERA_VIDEO_PATH, url);
                firstFrame.getWidth();
                //setResult(-1, intent);
                if (mCallBack != null) {
                    mCallBack.onSuccess(intent);
                }
                finish();
            }
        });

        jCameraView.setLeftClickListener(new ClickListener() {
            @Override
            public void onClick() {
                CameraActivity.this.finish();
            }
        });
        jCameraView.setRightClickListener(new ClickListener() {
            @Override
            public void onClick() {
                Toast.makeText(CameraActivity.this, "Right", Toast.LENGTH_SHORT).show();
            }
        });
        //jCameraView.setVisibility(View.GONE);
        Log.i("CJT", DeviceUtil.getDeviceModel());
    }

    @Override
    public void onDetachedFromWindow() {
        super.onDetachedFromWindow();
    }

    @Override
    protected void onStart() {
        super.onStart();
        //全屏显示
        if (Build.VERSION.SDK_INT >= 19) {
            View decorView = getWindow().getDecorView();
            decorView.setSystemUiVisibility(
                    View.SYSTEM_UI_FLAG_LAYOUT_STABLE
                            | View.SYSTEM_UI_FLAG_LAYOUT_HIDE_NAVIGATION
                            | View.SYSTEM_UI_FLAG_LAYOUT_FULLSCREEN
                            | View.SYSTEM_UI_FLAG_HIDE_NAVIGATION
                            | View.SYSTEM_UI_FLAG_FULLSCREEN
                            | View.SYSTEM_UI_FLAG_IMMERSIVE_STICKY);
        } else {
            View decorView = getWindow().getDecorView();
            int option = View.SYSTEM_UI_FLAG_FULLSCREEN;
            decorView.setSystemUiVisibility(option);
        }
    }

    @Override
    protected void onResume() {
        super.onResume();
        jCameraView.onResume();
    }

    @Override
    protected void onPause() {
        super.onPause();
        jCameraView.onPause();
    }
}
