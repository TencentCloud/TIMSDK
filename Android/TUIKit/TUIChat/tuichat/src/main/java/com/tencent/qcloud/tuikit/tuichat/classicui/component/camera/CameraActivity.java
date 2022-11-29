package com.tencent.qcloud.tuikit.tuichat.classicui.component.camera;

import android.app.Activity;
import android.content.Intent;
import android.content.pm.ActivityInfo;
import android.graphics.Bitmap;
import android.os.Build;
import android.os.Bundle;
import android.view.View;
import android.view.Window;
import android.view.WindowManager;

import com.tencent.qcloud.tuicore.component.interfaces.IUIKitCallback;
import com.tencent.qcloud.tuicore.util.FileUtil;
import com.tencent.qcloud.tuicore.util.TUIBuild;
import com.tencent.qcloud.tuicore.util.ToastUtil;
import com.tencent.qcloud.tuikit.tuichat.R;
import com.tencent.qcloud.tuikit.tuichat.TUIChatConstants;
import com.tencent.qcloud.tuikit.tuichat.classicui.component.camera.listener.ClickListener;
import com.tencent.qcloud.tuikit.tuichat.classicui.component.camera.listener.ErrorListener;
import com.tencent.qcloud.tuikit.tuichat.classicui.component.camera.listener.JCameraListener;
import com.tencent.qcloud.tuikit.tuichat.classicui.component.camera.view.JCameraView;
import com.tencent.qcloud.tuikit.tuichat.util.TUIChatLog;

public class CameraActivity extends Activity {

    private static final String TAG = CameraActivity.class.getSimpleName();
    private static final int REQUEST_CODE_PHOTO_AND_VIDEO = 1000;
    public static IUIKitCallback mCallBack;
    private JCameraView jCameraView;

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        TUIChatLog.i(TAG, "onCreate");
        super.onCreate(savedInstanceState);
        requestWindowFeature(Window.FEATURE_NO_TITLE);
        getWindow().setFlags(WindowManager.LayoutParams.FLAG_FULLSCREEN, WindowManager.LayoutParams.FLAG_FULLSCREEN);
        setRequestedOrientation(ActivityInfo.SCREEN_ORIENTATION_PORTRAIT);
        setContentView(R.layout.activity_camera);
        jCameraView = findViewById(R.id.jcameraview);
        //jCameraView.setSaveVideoPath(Environment.getExternalStorageDirectory().getPath() + File.separator + "JCamera");

        int state = getIntent().getIntExtra(TUIChatConstants.CAMERA_TYPE, JCameraView.BUTTON_STATE_BOTH);
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
                TUIChatLog.i(TAG, "camera error");
                Intent intent = new Intent();
                setResult(103, intent);
                finish();
            }

            @Override
            public void AudioPermissionError() {
                ToastUtil.toastShortMessage(getString(R.string.audio_permission_error));
            }
        });

        jCameraView.setJCameraLisenter(new JCameraListener() {
            @Override
            public void captureSuccess(Bitmap bitmap) {
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
                String path = FileUtil.saveBitmap("JCamera", firstFrame);
                Intent intent = new Intent();
                intent.putExtra(TUIChatConstants.IMAGE_WIDTH, firstFrame.getWidth());
                intent.putExtra(TUIChatConstants.IMAGE_HEIGHT, firstFrame.getHeight());
                intent.putExtra(TUIChatConstants.VIDEO_TIME, duration);
                intent.putExtra(TUIChatConstants.CAMERA_IMAGE_PATH, path);
                intent.putExtra(TUIChatConstants.CAMERA_VIDEO_PATH, url);
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
        TUIChatLog.i(TAG, TUIBuild.getDevice());
    }

    private void startSendPhoto() {
        TUIChatLog.i(TAG, "startSendPhoto");

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
        TUIChatLog.i(TAG, "onResume");
        super.onResume();
        jCameraView.onResume();
    }

    @Override
    protected void onPause() {
        TUIChatLog.i(TAG, "onPause");
        super.onPause();
        jCameraView.onPause();
    }

    @Override
    protected void onDestroy() {
        TUIChatLog.i(TAG, "onDestroy");
        super.onDestroy();
        jCameraView.onDestroy();
        mCallBack = null;
    }

}
