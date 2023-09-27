package com.tencent.qcloud.tuikit.tuichat.component.camera;

import android.app.Activity;
import android.content.Intent;
import android.content.pm.ActivityInfo;
import android.net.Uri;
import android.os.Build;
import android.os.Bundle;
import android.view.View;
import android.view.Window;
import android.view.WindowManager;

import androidx.fragment.app.FragmentActivity;

import com.tencent.qcloud.tuicore.TUILogin;
import com.tencent.qcloud.tuicore.interfaces.TUIValueCallback;
import com.tencent.qcloud.tuicore.util.TUIBuild;
import com.tencent.qcloud.tuicore.util.ToastUtil;
import com.tencent.qcloud.tuikit.timcommon.util.ActivityResultResolver;
import com.tencent.qcloud.tuikit.timcommon.util.FileUtil;
import com.tencent.qcloud.tuikit.tuichat.R;
import com.tencent.qcloud.tuikit.tuichat.TUIChatConstants;
import com.tencent.qcloud.tuikit.tuichat.component.camera.listener.CameraListener;
import com.tencent.qcloud.tuikit.tuichat.component.camera.listener.ClickListener;
import com.tencent.qcloud.tuikit.tuichat.component.camera.listener.ErrorListener;
import com.tencent.qcloud.tuikit.tuichat.component.camera.view.CameraView;
import com.tencent.qcloud.tuikit.tuichat.util.TUIChatLog;

public class CameraActivity extends FragmentActivity {
    private static final String TAG = CameraActivity.class.getSimpleName();

    public static final int BUTTON_STATE_ONLY_CAPTURE = 0x101; // 只能拍照
    public static final int BUTTON_STATE_ONLY_RECORDER = 0x102; // 只能录像
    public static final int BUTTON_STATE_BOTH = 0x103; // 两者都可以
    private CameraView cameraView;

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        TUIChatLog.i(TAG, "onCreate");
        super.onCreate(savedInstanceState);
        requestWindowFeature(Window.FEATURE_NO_TITLE);
        getWindow().setFlags(WindowManager.LayoutParams.FLAG_FULLSCREEN, WindowManager.LayoutParams.FLAG_FULLSCREEN);
        setRequestedOrientation(ActivityInfo.SCREEN_ORIENTATION_PORTRAIT);
        setContentView(R.layout.chat_camera_activity_layout);
        cameraView = findViewById(R.id.camera_view);

        int feature = getIntent().getIntExtra(TUIChatConstants.CAMERA_TYPE, BUTTON_STATE_BOTH);
        cameraView.setFeature(feature);
        if (feature == BUTTON_STATE_ONLY_CAPTURE) {
            cameraView.setTip(getString(R.string.tap_capture));
        } else if (feature == BUTTON_STATE_ONLY_RECORDER) {
            cameraView.setTip(getString(R.string.tap_video));
        }

        cameraView.setMediaQuality(CameraView.MEDIA_QUALITY_MIDDLE);
        cameraView.setErrorListener(new ErrorListener() {
            @Override
            public void onError(String errorMsg) {
                TUIChatLog.e(TAG, "camera error " + errorMsg);
                int currentBusinessScene = TUILogin.getCurrentBusinessScene();
                if (currentBusinessScene != TUILogin.TUIBusinessScene.NONE) {
                    String tipMsg = getString(R.string.chat_camera_occupied_tip);
                    TUIChatLog.e(TAG, tipMsg);
                    ToastUtil.toastShortMessage(tipMsg);
                }
                Intent intent = new Intent();
                setResult(103, intent);
                finish();
            }
        });

        cameraView.setCameraListener(new CameraListener() {
            @Override
            public void onCaptureSuccess(String path) {
                setResultAndFinish(FileUtil.getUriFromPath(path));
            }

            @Override
            public void onRecordSuccess(String path) {
                setResultAndFinish(FileUtil.getUriFromPath(path));
            }
        });

        cameraView.setLeftClickListener(new ClickListener() {
            @Override
            public void onClick() {
                CameraActivity.this.finish();
            }
        });
        cameraView.setRightClickListener(new ClickListener() {
            @Override
            public void onClick() {
                startSelectMedia();
            }
        });
        TUIChatLog.i(TAG, "device " + TUIBuild.getDevice());
    }

    private void startSelectMedia() {
        TUIChatLog.i(TAG, "startSelectMedia");

        ActivityResultResolver.getSingleContent(
            this, new String[] {ActivityResultResolver.CONTENT_TYPE_VIDEO, ActivityResultResolver.CONTENT_TYPE_IMAGE}, new TUIValueCallback<Uri>() {
                @Override
                public void onSuccess(Uri uri) {
                    setResultAndFinish(uri);
                }

                @Override
                public void onError(int errorCode, String errorMessage) {}
            });
    }

    private void setResultAndFinish(Uri uri) {
        Intent intent = new Intent();
        intent.setData(uri);
        setResult(Activity.RESULT_OK, intent);
        finish();
    }

    @Override
    protected void onStart() {
        super.onStart();
        if (Build.VERSION.SDK_INT >= 19) {
            View decorView = getWindow().getDecorView();
            decorView.setSystemUiVisibility(View.SYSTEM_UI_FLAG_LAYOUT_STABLE | View.SYSTEM_UI_FLAG_LAYOUT_HIDE_NAVIGATION
                | View.SYSTEM_UI_FLAG_LAYOUT_FULLSCREEN | View.SYSTEM_UI_FLAG_HIDE_NAVIGATION | View.SYSTEM_UI_FLAG_FULLSCREEN
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
        cameraView.onResume();
        super.onResume();
    }

    @Override
    protected void onPause() {
        TUIChatLog.i(TAG, "onPause");
        cameraView.onPause();
        super.onPause();
    }

    @Override
    protected void onDestroy() {
        TUIChatLog.i(TAG, "onDestroy");
        cameraView.onDestroy();
        super.onDestroy();
    }
}
