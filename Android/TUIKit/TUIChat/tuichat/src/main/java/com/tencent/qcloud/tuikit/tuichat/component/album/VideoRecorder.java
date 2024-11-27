package com.tencent.qcloud.tuikit.tuichat.component.album;

import android.net.Uri;
import androidx.activity.result.ActivityResultCaller;
import com.tencent.qcloud.tuicore.interfaces.TUIValueCallback;
import com.tencent.qcloud.tuikit.tuichat.config.classicui.TUIChatConfigClassic;
import com.tencent.qcloud.tuikit.tuichat.interfaces.IMultimediaRecorder;
import com.tencent.qcloud.tuikit.tuichat.interfaces.MultimediaRecorderListener;
import com.tencent.qcloud.tuikit.tuichat.util.PermissionHelper;
import com.tencent.qcloud.tuikit.tuichat.util.TUIChatLog;

public class VideoRecorder {
    private static final String TAG = "VideoRecorder";

    private static final VideoRecorder INSTANCE = new VideoRecorder();

    private final IMultimediaRecorder defaultVideoRecorder = new ChatMultimediaRecorderImpl();
    private final IMultimediaRecorder systemVideoRecorder = new SystemMultimediaRecorderImpl();
    private IMultimediaRecorder advancedVideoRecorder;

    private VideoRecorder() {}

    public static void registerAdvancedVideoRecorder(IMultimediaRecorder videoRecorder) {
        INSTANCE.advancedVideoRecorder = videoRecorder;
    }

    public static void openVideoRecorder(ActivityResultCaller activityResultCaller, TUIValueCallback<Uri> callback) {
        IMultimediaRecorder videoRecorder = INSTANCE.defaultVideoRecorder;
        if (INSTANCE.advancedVideoRecorder != null) {
            videoRecorder = INSTANCE.advancedVideoRecorder;
            //TUIMultimediaPlugin.setConfig("{\"theme_color\": \"#FFFFFF00\",\"max_record_duration_ms\": \"15000\"}");
        } else {
            if (TUIChatConfigClassic.isUseSystemCamera()) {
                videoRecorder = INSTANCE.systemVideoRecorder;
            }
        }

        IMultimediaRecorder finalVideoRecorder = videoRecorder;
        PermissionHelper.requestPermission(PermissionHelper.PERMISSION_CAMERA, new PermissionHelper.PermissionCallback() {
            @Override
            public void onGranted() {
                PermissionHelper.requestPermission(PermissionHelper.PERMISSION_MICROPHONE, new PermissionHelper.PermissionCallback() {
                    @Override
                    public void onGranted() {
                        finalVideoRecorder.openRecorder(activityResultCaller, new MultimediaRecorderListener() {
                            @Override
                            public void onSuccess(Uri uri) {
                                TUIValueCallback.onSuccess(callback, uri);
                            }

                            @Override
                            public void onFailed(int errorCode, String errorMessage) {
                                TUIValueCallback.onError(callback, errorCode, errorMessage);
                            }
                        });
                    }

                    @Override
                    public void onDenied() {
                        TUIValueCallback.onError(callback, -1, "Microphone permission denied");
                        TUIChatLog.e(TAG, "openVideoRecorder checkPermission failed, Microphone permission denied");
                    }
                });
            }

            @Override
            public void onDenied() {
                TUIValueCallback.onError(callback, -1, "camera permission denied");
                TUIChatLog.e(TAG, "openVideoRecorder checkPermission failed, camera permission denied");
            }
        });
    }

    public static void openCamera(ActivityResultCaller activityResultCaller, TUIValueCallback<Uri> callback) {
        IMultimediaRecorder videoRecorder = INSTANCE.defaultVideoRecorder;
        if (INSTANCE.advancedVideoRecorder != null) {
            videoRecorder = INSTANCE.advancedVideoRecorder;
        } else {
            if (TUIChatConfigClassic.isUseSystemCamera()) {
                videoRecorder = INSTANCE.systemVideoRecorder;
            }
        }

        IMultimediaRecorder finalVideoRecorder = videoRecorder;
        PermissionHelper.requestPermission(PermissionHelper.PERMISSION_CAMERA, new PermissionHelper.PermissionCallback() {
            @Override
            public void onGranted() {
                finalVideoRecorder.openCamera(activityResultCaller, new MultimediaRecorderListener() {
                    @Override
                    public void onSuccess(Uri uri) {
                        TUIValueCallback.onSuccess(callback, uri);
                    }

                    @Override
                    public void onFailed(int errorCode, String errorMessage) {
                        TUIValueCallback.onError(callback, errorCode, errorMessage);
                    }
                });
            }

            @Override
            public void onDenied() {
                TUIChatLog.e(TAG, "camera permission denied");
                TUIValueCallback.onError(callback, -1, "camera permission denied");
            }
        });
    }
}
