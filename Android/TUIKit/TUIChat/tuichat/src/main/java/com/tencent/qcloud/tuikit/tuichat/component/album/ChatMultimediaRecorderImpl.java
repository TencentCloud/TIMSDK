package com.tencent.qcloud.tuikit.tuichat.component.album;

import android.content.Intent;
import android.net.Uri;
import android.os.Bundle;
import androidx.activity.result.ActivityResultCaller;
import com.tencent.qcloud.tuicore.TUICore;
import com.tencent.qcloud.tuikit.tuichat.TUIChatConstants;
import com.tencent.qcloud.tuikit.tuichat.component.camera.CameraActivity;
import com.tencent.qcloud.tuikit.tuichat.interfaces.IMultimediaRecorder;
import com.tencent.qcloud.tuikit.tuichat.interfaces.MultimediaRecorderListener;

class ChatMultimediaRecorderImpl extends IMultimediaRecorder {
    @Override
    public void openRecorder(ActivityResultCaller activityResultCaller, MultimediaRecorderListener listener) {
        if (listener == null) {
            return;
        }
        Bundle bundle = new Bundle();
        bundle.putInt(TUIChatConstants.CAMERA_TYPE, CameraActivity.BUTTON_STATE_ONLY_RECORDER);

        TUICore.startActivityForResult(activityResultCaller, CameraActivity.class, bundle, result -> {
            Intent data = result.getData();
            if (data == null) {
                listener.onFailed(-1, "record failed");
                return;
            }
            Uri uri = data.getData();
            if (uri != null) {
                listener.onSuccess(uri);
                return;
            }
            listener.onFailed(-1, "record failed");
        });
    }

    public void openCamera(ActivityResultCaller activityResultCaller, MultimediaRecorderListener listener) {
        if (listener == null) {
            return;
        }
        Bundle bundle = new Bundle();
        bundle.putInt(TUIChatConstants.CAMERA_TYPE, CameraActivity.BUTTON_STATE_ONLY_CAPTURE);
        TUICore.startActivityForResult(activityResultCaller, CameraActivity.class, bundle, result -> {
            if (result.getData() != null) {
                Uri uri = result.getData().getData();
                if (uri != null) {
                    listener.onSuccess(uri);
                    return;
                }
            }
            listener.onFailed(-1, "take photo failed");
        });
    }
}
