package com.tencent.qcloud.tim.uikit.component.video;

import android.Manifest;
import android.app.Activity;
import android.content.Intent;
import android.content.pm.ActivityInfo;
import android.graphics.Bitmap;
import android.os.Build;
import android.os.Bundle;
import android.view.View;
import android.view.Window;
import android.view.WindowManager;

import com.tencent.qcloud.tim.uikit.R;
import com.tencent.qcloud.tim.uikit.base.IUIKitCallBack;
import com.tencent.qcloud.tim.uikit.component.video.listener.ClickListener;
import com.tencent.qcloud.tim.uikit.component.video.listener.ErrorListener;
import com.tencent.qcloud.tim.uikit.component.video.listener.JCameraListener;
import com.tencent.qcloud.tim.uikit.component.video.util.DeviceUtil;
import com.tencent.qcloud.tim.uikit.utils.FileUtil;
import com.tencent.qcloud.tim.uikit.utils.PermissionUtils;
import com.tencent.qcloud.tim.uikit.utils.TUIKitConstants;
import com.tencent.qcloud.tim.uikit.utils.TUIKitLog;
import com.tencent.qcloud.tim.uikit.utils.ToastUtil;

public class CameraActivity extends Activity {

    private static final String TAG = CameraActivity.class.getSimpleName();
    private static final int REQUEST_CODE_PHOTO_AND_VIDEO = 1000;
    public static IUIKitCallBack mCallBack;
    private JCameraView jCameraView;

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        TUIKitLog.i(TAG, "onCreate");
        super.onCreate(savedInstanceState);
        //去除标题栏
        requestWindowFeature(Window.FEATURE_NO_TITLE);
        //去除状态栏
        getWindow().setFlags(WindowManager.LayoutParams.FLAG_FULLSCREEN, WindowManager.LayoutParams.FLAG_FULLSCREEN);
        setRequestedOrientation(ActivityInfo.SCREEN_ORIENTATION_PORTRAIT);
        setContentView(R.layout.activity_camera);
        jCameraView = findViewById(R.id.jcameraview);
        //设置视频保存路径
        //jCameraView.setSaveVideoPath(Environment.getExternalStorageDirectory().getPath() + File.separator + "JCamera");

        int state = getIntent().getIntExtra(TUIKitConstants.CAMERA_TYPE, JCameraView.BUTTON_STATE_BOTH);
        jCameraView.setFeatures(state);
        if (state == JCameraView.BUTTON_STATE_ONLY_CAPTURE) {
            jCameraView.setTip(getString(R.string.tap_capture));
        } else if (state == JCameraView.BUTTON_STATE_ONLY_RECORDER) {
            jCameraView.setTip(getString(R.string.tap_video));
        }

        jCameraView.setMediaQuality(JCameraView.MEDIA_QUALITY_MIDDLE);
        jCameraView.setErrorLisenter(new ErrorListener() {
            @Override
            public void onError() {
                //错误监听
                TUIKitLog.i(TAG, "camera error");
                Intent intent = new Intent();
                setResult(103, intent);
                finish();
            }

            @Override
            public void AudioPermissionError() {
                ToastUtil.toastShortMessage(getString(R.string.audio_permission_error));
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
                intent.putExtra(TUIKitConstants.IMAGE_WIDTH, firstFrame.getWidth());
                intent.putExtra(TUIKitConstants.IMAGE_HEIGHT, firstFrame.getHeight());
                intent.putExtra(TUIKitConstants.VIDEO_TIME, duration);
                intent.putExtra(TUIKitConstants.CAMERA_IMAGE_PATH, path);
                intent.putExtra(TUIKitConstants.CAMERA_VIDEO_PATH, url);
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
                startSendPhoto();
            }
        });
        //jCameraView.setVisibility(View.GONE);
        TUIKitLog.i(TAG, DeviceUtil.getDeviceModel());
    }

    private boolean checkPermission() {
        if (!PermissionUtils.checkPermission(this, Manifest.permission.WRITE_EXTERNAL_STORAGE)) {
            return false;
        }
        if (!PermissionUtils.checkPermission(this, Manifest.permission.READ_EXTERNAL_STORAGE)) {
            return false;
        }
        return true;
    }

    private void startSendPhoto() {
        TUIKitLog.i(TAG, "startSendPhoto");
        if (!checkPermission()) {
            TUIKitLog.i(TAG, "startSendPhoto checkPermission failed");
            return;
        }

        Intent intent = new Intent(Intent.ACTION_GET_CONTENT);
        intent.addCategory(Intent.CATEGORY_OPENABLE);
        intent.setType("*/*");
        String[] mimeTypes = {"image/*", "video/*"};
        intent.putExtra(Intent.EXTRA_MIME_TYPES, mimeTypes);
        startActivityForResult(intent, REQUEST_CODE_PHOTO_AND_VIDEO);
    }

    @Override
    protected void onActivityResult(int requestCode, int resultCode, Intent data) {
        super.onActivityResult(requestCode, resultCode, data);
        if (requestCode == REQUEST_CODE_PHOTO_AND_VIDEO) {
            if (resultCode != RESULT_OK) {
                return;
            }
            setResult(RESULT_OK, data);
            finish();
        }
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
        TUIKitLog.i(TAG, "onResume");
        super.onResume();
        jCameraView.onResume();
    }

    @Override
    protected void onPause() {
        TUIKitLog.i(TAG, "onPause");
        super.onPause();
        jCameraView.onPause();
    }

    @Override
    protected void onDestroy() {
        TUIKitLog.i(TAG, "onDestroy");
        super.onDestroy();
        mCallBack = null;
    }

}
