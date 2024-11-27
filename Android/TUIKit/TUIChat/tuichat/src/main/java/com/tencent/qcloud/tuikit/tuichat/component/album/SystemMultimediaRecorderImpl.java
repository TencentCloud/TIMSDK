package com.tencent.qcloud.tuikit.tuichat.component.album;

import android.net.Uri;
import android.os.Build;
import androidx.activity.result.ActivityResultCaller;
import com.tencent.qcloud.tuicore.interfaces.TUIValueCallback;
import com.tencent.qcloud.tuicore.util.TUIBuild;
import com.tencent.qcloud.tuikit.timcommon.util.ActivityResultResolver;
import com.tencent.qcloud.tuikit.timcommon.util.FileUtil;
import com.tencent.qcloud.tuikit.tuichat.interfaces.IMultimediaRecorder;
import com.tencent.qcloud.tuikit.tuichat.interfaces.MultimediaRecorderListener;
import com.tencent.qcloud.tuikit.tuichat.util.PermissionHelper;
import com.tencent.qcloud.tuikit.tuichat.util.TUIChatLog;
import java.io.File;

class SystemMultimediaRecorderImpl extends IMultimediaRecorder {
    private static final String TAG = "SystemVideoRecorder";

    @Override
    public void openRecorder(ActivityResultCaller activityResultCaller, MultimediaRecorderListener listener) {
        if (listener == null) {
            return;
        }
        if (TUIBuild.getVersionInt() < Build.VERSION_CODES.N) {
            PermissionHelper.requestPermission(PermissionHelper.PERMISSION_STORAGE, new PermissionHelper.PermissionCallback() {
                @Override
                public void onGranted() {
                    String path = FileUtil.generateExternalStorageVideoFilePath();
                    recordVideo(activityResultCaller, path, listener);
                }

                @Override
                public void onDenied() {
                    listener.onFailed(-1, "STORAGE permission denied");
                    TUIChatLog.i(TAG, "startVideoRecord checkPermission failed");
                }
            });
        } else {
            String path = FileUtil.generateVideoFilePath();
            recordVideo(activityResultCaller, path, listener);
        }
    }

    private void recordVideo(ActivityResultCaller activityResultCaller, String path, MultimediaRecorderListener listener) {
        Uri uri = FileUtil.getUriFromPath(path);
        if (uri == null) {
            listener.onFailed(-1, "record failed, uri is null");
            return;
        }
        ActivityResultResolver.takeVideo(activityResultCaller, uri, new TUIValueCallback<Boolean>() {
            @Override
            public void onSuccess(Boolean object) {
                File videoFile = new File(path);
                if (videoFile.exists()) {
                    listener.onSuccess(uri);
                    return;
                }
                listener.onFailed(-1, "record failed, file not exists");
            }

            @Override
            public void onError(int errorCode, String errorMessage) {
                listener.onFailed(errorCode, errorMessage);
            }
        });
    }


    public void openCamera(ActivityResultCaller activityResultCaller, MultimediaRecorderListener listener) {
        if (listener == null) {
            return;
        }
        if (TUIBuild.getVersionInt() < Build.VERSION_CODES.N) {
            PermissionHelper.requestPermission(PermissionHelper.PERMISSION_STORAGE, new PermissionHelper.PermissionCallback() {
                @Override
                public void onGranted() {
                    String path = FileUtil.generateExternalStorageImageFilePath();
                    systemCapture(activityResultCaller, path, listener);
                }

                @Override
                public void onDenied() {
                    listener.onFailed(-1, "take photo failed, checkPermission failed");
                    TUIChatLog.i(TAG, "startCapture checkPermission failed");
                }
            });
        } else {
            String path = FileUtil.generateImageFilePath();
            systemCapture(activityResultCaller, path, listener);
        }
    }

    private void systemCapture(ActivityResultCaller activityResultCaller, String path, MultimediaRecorderListener listener) {
        Uri uri = FileUtil.getUriFromPath(path);
        if (uri == null) {
            return;
        }
        ActivityResultResolver.takePicture(activityResultCaller, uri, new TUIValueCallback<Boolean>() {
            @Override
            public void onSuccess(Boolean object) {
                File imageFile = new File(path);
                if (imageFile.exists()) {
                    listener.onSuccess(uri);
                } else {
                    listener.onFailed(-1, "take photo failed, file not exist");
                }
            }

            @Override
            public void onError(int errorCode, String errorMessage) {
                listener.onFailed(errorCode, errorMessage);
            }
        });
    }
}
